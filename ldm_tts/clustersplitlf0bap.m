function clustersplitlf0bap(phone,data,logLOrig,nodeId,node_ptr,quests,initialModel,type)
% Cluster Split lf0 BAP
%   Split the given data into two if there is sufficient gain in likelihood
%   otherwise let the cluster stay as it is
% Inputs:
%       phone : phone associated
%       data : data to be clustered
%       logLOrig : log likelihood of data
%       nodeId : the node in tree to which data currently points to
%       node_ptr : class which contains pointers for each data point and
%       questions for each node, and is updated accordingly
%       quests : question struct
%       initialModel
%       type : 'lf0' or 'bap'

% author : Gagandeep Singh 2017

% parameters for clustering threshold
params = getparameters();
disp(nodeId)
rho = params.(type).rho;
m = params.(type).m;
n = m;
k = 4*m;
N = size([data.lf0bap],2);

if strcmp(phone, 'sil') || strcmp(phone, 'sp')
    threshold = 1*rho*k*log2(N);
else
    threshold = 0.4*rho*k*log2(N);
end

% the minimum number of frames that should exist in each partition

if strcmp(phone, 'sil') %|| strcmp(phone, 'sp')
    minFrameThreshold = 5*params.(type).minFrameThreshold;
else
    minFrameThreshold = params.(type).minFrameThreshold;
end

changeLikelihood = zeros(length(quests),1);
logLY = zeros(length(quests),1);
logLN = zeros(length(quests),1);

% try to split data for each question and evaluate the gain in
% log-likelihood in each case
models = cell(length(quests),1);
if params.use_parfor
    parfor questId = 1: length(quests)
        quest = quests(questId);
        % if the question has already been used by some ancestor in the tree
        % then dont evaluate it again
        if regexp(quests(questId).node_id,nodeId)
            continue
        end
        [model,logLY_,logLN_] = splitquestion(quest,phone,data,minFrameThreshold,initialModel,type);
        
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
    for questId = 1: length(quests)
        quest = quests(questId);
        % if the question has already been used by some ancestor in the tree
        % then dont evaluate it again
        if regexp(quests(questId).node_id,nodeId)
            continue
        end
        [model,logLY_,logLN_] = splitquestion(quest,phone,data,minFrameThreshold,initialModel,type);
        
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
[max_inc, maxId ] = max(changeLikelihood);

% if gain is more than the threshold then split at that question
if max_inc > threshold
    % mark that the question has been used at this node
    quests(maxId).node_id = nodeId;
    
    % separate data again because earlier separation has not been stored
    [data_y, data_n] = separatedatalf0bap(phone, data, quests(maxId).patterns);
    
    % store which questionn has been used at this node of the tree in
    % node_ptr data class
    node_ptr.quests.(nodeId) = quests(maxId);
    
    % create the node ids of the two new nodes
    yNodeId = strcat(nodeId,'1');
    nNodeId = strcat(nodeId,'0');
    
    % update the pointer to each data point
    updatenodeptr(node_ptr,[data_y.root_ind]',yNodeId);
    updatenodeptr(node_ptr,[data_n.root_ind]',nNodeId)
    
    % cluster again on the split data
    clustersplitlf0bap(phone,data_y,logLY(maxId),yNodeId,node_ptr,quests,models{maxId}.Y,type);
    clustersplitlf0bap(phone,data_n,logLN(maxId),nNodeId,node_ptr,quests,models{maxId}.N,type);
    
else
    node_ptr.leafNodes(end+1).nodeId = nodeId;
    node_ptr.leafNodes(end).maxSplitLogL = max_inc;
    node_ptr.leafNodes(end).bestQues = maxId;
    node_ptr.leafNodes(end).model = initialModel;
end
end

function [model,logLY,logLN] = splitquestion(quest,phone,data,minFrameThreshold,initialModel,type)
% separate the data which given yes and no for a particular question
model = struct();
logLY = 0;
logLN = 0;
[data_y, data_n] = separatedatalf0bap(phone, data, quest.patterns);

min_data = min(getnmgcs(data_y,3),getnmgcs(data_n,3));

% if the minimum data in a partition is lesser than the threshold then
% dont split and change in log-likelihood is defined to be zero
if min_data > minFrameThreshold
    model = struct();
    % get likelihood for yes and no data
    [model.Y, logLY] = trainautoshannonlf0bap(data_y, initialModel,type);
    [model.N, logLN] = trainautoshannonlf0bap(data_n, initialModel,type);
end
end

function updatenodeptr(ptr,root_ind,y_node_id)
for i = 1:length(root_ind)
    ptr.node_id{root_ind(i)} = y_node_id;
end

end

function nLf0 = getnmgcs(data,minLf0)
nLf0 = 0;
for i = 1:length(data)
    len = size(data(i).lf0bap,2);
    if len > minLf0
        nLf0 = nLf0 + len;
    end
end
end