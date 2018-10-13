function [clusteredData,labelDataStates,ldmModels] = clusterall(labelData,mgcData)
% Cluster all states
%   Cluster the states for all the segments of all the phones
%   inputs :
%          labelData : data with file_name, tri_phone(not a preclustered state),
%          begin and ending of each triphone
%          mgcData : for each file in 40 X no_mgc matrix format
%   outputs:
%          clusteredData
%          labelDataStates : labelled data but labelled with clustered
%          states ids instead of full context labels

% author : Gagandeep Singh 2017

params = getparameters();
quests = readquestions(params.questionFilePath);
phones = getphonelist(params.phoneset);
clusterModelType = params.clusterModelType;

if params.loadTree
    load(params.TreeFilePath);
else
    tree = struct();
end

for segmentId = 1:params.noSegments
    segment = strcat('segment_',int2str(segmentId));
    if ~isfield(tree,segment)
        tree.(segment) = struct();
    end
    for phnId = 1:length(phones)
        phone = phones{phnId};
        fprintf('phone : %s\n',phone);
        
        if isfield(tree.(segment),changephonename(phone))
            continue
        end
        
        % used for setting the pointer of each data point to a particular
        % node in the tree. Also keeps track of the question used in each
        % node. Uses handle class inorder to enable to make each function
        % call to read and write from same data
        nodePtr = Node_ptr();
        % get the data for a particular segment of a given phone
        rootData = getrootdata(phone,labelData,mgcData,segmentId,nodePtr);
        
        initialModel = initializemodel(rootData,clusterModelType,phnId);
        % get likelihood of unclustered data
        if strcmp(clusterModelType,'autoReg')
            [initialModel,logLRoot] = trainautoshannon(rootData,initialModel);
        elseif strcmp(clusterModelType,'basicLDM') || strcmp(clusterModelType,'2ndOrderLDM')
            [initialModel,logLRoot] = trainldm(rootData,initialModel,clusterModelType);
        else
            error('Cluster model type %s not valid.',clusterModelType)
        end
        
        
        clustersplit(phone,rootData,logLRoot,'r',nodePtr,quests,initialModel);
        tree.(segment).(changephonename(phone)).node_ptr = nodePtr;
        tree.(segment).(changephonename(phone)).data = rootData;

        if params.saveTree
            save(params.TreeFilePath,'tree')
        end
    end
end

[clusteredData,labelDataStates,ldmModels] = tree2clustdata(tree,labelData);


end