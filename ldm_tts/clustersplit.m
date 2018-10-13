function clustersplit(phone,data,logLOrig,nodeId,nodePtr,quests,initialModel)
% Cluster Split
%   Split the given data into two if there is sufficient gain in likelihood
%   otherwise let the cluster stay as it is
% Inputs:
%       phone : phone associated
%       data : data to be clustered
%       logLOrig : log likelihood of data
%       nodeId : the node in tree to which data currently points to
%       nodePtr : class which contains pointers for each data point and
%       questions for each node, and is updated accordingly
%       quests : question struct
       
% author : Gagandeep Singh 2017

% parameters for clustering threshold
fprintf('Clustering node %s\n',nodeId);

params = getparameters();
m = params.m;
n = params.n;
clusterModelType = params.clusterModelType;

rho = params.rho;

N = size([data.mgc],2);
if strcmp(params.clusterModelType,'autoReg')
    k = 4*m;
else
    k = 4*n + m*n + 2*m;
end
threshold = rho*k*log2(N);
minFrameThreshold = params.minFrameThreshold;

changeLikelihood = zeros(length(quests),1);
logLY = zeros(length(quests),1);
logLN = zeros(length(quests),1);

% try to split data for each question and evaluate the gain in
% log-likelihood in each case
models = cell(length(quests),1);
if params.use_parfor
    parfor questId = 1:length(quests)

        quest = quests(questId);
        % if the question has already been used by some ancestor in the tree
        % then dont evaluate it again
        if regexp(quest.node_id,nodeId)
            continue
        end

        [model,logLY_,logLN_] = splitquestion(quest,phone,data,minFrameThreshold,clusterModelType,initialModel);
        if isfield(model,'Y')
            models{questId} = model;
            logLY(questId) = logLY_;
            logLN(questId) = logLN_;
            changeLikelihood(questId) = (logLY_ + logLN_) - logLOrig;
        else
            changeLikelihood(questId) = 0;
        end
    end
else
    for questId = 1:length(quests)
        quest = quests(questId);
        % if the question has already been used by some ancestor in the tree
        % then dont evaluate it again
        if regexp(quest.node_id,nodeId)
            continue
        end

        [model,logLY_,logLN_] = splitquestion(quest,phone,data,minFrameThreshold,clusterModelType,initialModel);
        if isfield(model,'Y')
            models{questId} = model;
            logLY(questId) = logLY_;
            logLN(questId) = logLN_;
            changeLikelihood(questId) = (logLY_ + logLN_) - logLOrig;
        else
            changeLikelihood(questId) = 0;
        end
    end
end

% the question which gives the maximum increase in log-likelihood
[maxInc, maxId ] = max(changeLikelihood);

% if gain is more than the threshold then split at that question
if maxInc > threshold
    % mark that the question has been used at this node
    quests(maxId).node_id = nodeId;
    
    % separate data again because earlier separation has not been stored
    [dataY, dataN] = separatedata(phone, data, quests(maxId).patterns);
    
    % store which questionn has been used at this node of the tree in
    % node_ptr data class
    nodePtr.quests.(nodeId) = quests(maxId);
    
    % create the node ids of the two new nodes
    yNodeId = strcat(nodeId,'1');
    nNodeId = strcat(nodeId,'0');
    
    % update the pointer to each data point
    updatenodeptr(nodePtr,[dataY.root_ind]',yNodeId);
    updatenodeptr(nodePtr,[dataN.root_ind]',nNodeId)
    
    % cluster again on the split data
    clustersplit(phone,dataY,logLY(maxId), yNodeId, nodePtr,quests,models{maxId}.Y);
    clustersplit(phone,dataN,logLN(maxId), nNodeId, nodePtr,quests,models{maxId}.N);
    
else
    nodePtr.leafNodes(end+1).nodeId = nodeId;
    nodePtr.leafNodes(end).maxSplitLogL = maxInc;
    nodePtr.leafNodes(end).bestQues = maxId;
    nodePtr.leafNodes(end).model = initialModel;
end
end

function [model,logLY,logLN] = splitquestion(quest,phone,data,minFrameThreshold,clusterModelType,initialModel)
% created just in order to be run from parfor as well as for loops

    model = struct();
    logLY = 0;
    logLN = 0;
    % separate the data which given yes and no for a particular question
    [dataY, dataN] = separatedata(phone, data, quest.patterns);
    
    minData = min(getnmgcs(dataY,3),getnmgcs(dataN,3));
    
    % if the minimum data in a partition is lesser than the threshold then
    % dont split and change in log-likelihood is defined to be zero
    if minData > minFrameThreshold
        % get likelihood for yes and no data
        if strcmp(clusterModelType, 'autoReg')
            [model.Y, logLY] = trainautoshannon(dataY, initialModel);
            [model.N, logLN] = trainautoshannon(dataN, initialModel);
        elseif strcmp(clusterModelType,'basicLDM') || strcmp(clusterModelType,'2ndOrderLDM')
            [model.Y, logLY] = trainldm(dataY, initialModel,clusterModelType);
            [model.N, logLN] = trainldm(dataN, initialModel,clusterModelType);
        end
        % changeLikelihood = (logLY + logLN) - logLOrig;
        % models{questId} = model;
    end
end

function updatenodeptr(ptr,root_ind,y_node_id)
for i = 1:length(root_ind)
    ptr.node_id{root_ind(i)} = y_node_id;
end
    
end

function nMgc = getnmgcs(data,minMgc)
nMgc = 0;
for i = 1:length(data)
    len = size(data(i).mgc,2);
    if len > minMgc
        nMgc = nMgc + len;
    end
end   
end