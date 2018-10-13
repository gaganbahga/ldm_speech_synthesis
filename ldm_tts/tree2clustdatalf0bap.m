function [clust_data,label_data,ldmModels] = tree2clustdatalf0bap(tree,label_data,type)
% Tree to clustered data lf0 BAP
%   Create a clustered Data struct array for lf0 or BAP from the tree such that all the data corresponding
%   to one state is kept at one place. 
% Inputs:
%       tree: root node of the tree
%       labelData: label data sruct data
%       type: 'lf0' or 'bap'
% Outputs:
%       clust_data: clustered data struct array
%       label_data: label data with clustered state labels instead of full context labels
%       ldmModels: autoregressive HMMs which we get for free from clustering.

% author : Gagandeep Singh 2017

clust_data = struct('state',{},'data',{},'maxSplitLogL',[],'bestQues',[]);
ldmModels = struct('g1',[],'Q1',[],'F',[],'g',[],'Q',[],'H',[],'mu',[],...
    'R',[],'state',{});
seg_ids = fields(tree);
for segment_id = 1:length(seg_ids)
    segment = seg_ids{segment_id};
    phones = fields(tree.(segment));    
    for phn_id = 1:length(phones)
        phone = phones{phn_id};
        [state_data,maxSplitLogL,bestQues,label_data,models] = get_clust_id(tree.(segment).(phone).node_ptr,...
            tree.(segment).(phone).data,segment_id,phone,label_data,type);
        state_names = fieldnames(state_data); % fieldnames is supposed to be ordered
        % by relying on this assumption, the order to states in data and
        % modelsstruct array is supposed to be same
        for i_clust = 1:length(state_names)

            clust_data(end+1).state = state_names{i_clust};
            clust_data(end).data = state_data.(state_names{i_clust});
            clust_data(end).maxSplitLogL = maxSplitLogL.(state_names{i_clust});
            clust_data(end).bestQues = bestQues.(state_names{i_clust});
            %modelId = find(strcmp(state_names{i_clust},{tree.(segment).(phone).node_ptr.leafNodes.nodeId}));
            %model = tree.(segment).(phone).node_ptr.leafNodes(modelId).model;
            %model.state = state_names{i_clust};
        end
        ldmModels = [ldmModels; models];
    end
end

end

function [clust_data,maxSplitLogL,bestQues,label_data,ldmModels] = ...
    get_clust_id(node_ptr,data,segment_id,phone,label_data,type)
clust_data = struct();%('root_id',{},data,{});
clust2state_map = struct();

i_clust = 1;
node_id = node_ptr.node_id;
for i = 1:length(node_id)
    if ~isfield(clust2state_map,node_id{i})
        new_state_id = strcat(phone,'_',int2str(segment_id),'_',int2str(i_clust));
        clust2state_map.(node_id{i}) = new_state_id;
        i_clust = i_clust+1;
        clust_data.(new_state_id) = struct('label',{},type,[],'root_ind',[],'file_id',[],'label_id',[]);
    end
    clust_data.(clust2state_map.(node_id{i}))(end+1) = data(i);
    
    label_data(data(i).file_id).label{data(i).label_id} = clust2state_map.(node_id{i});
end

keys = fieldnames(clust2state_map); % the order of states in ldmModels is
% in same odrder as the keys here
ldmModels = struct('g1',[],'Q1',[],'F',[],'g',[],'Q',[],'H',[],'mu',[],...
    'R',[],'state',keys); % initialized for keys here just to get the length

for i = 1:length(keys)
    id = strcmp(keys{i},{node_ptr.leafNodes.nodeId});
    maxSplitLogL.(clust2state_map.(keys{i})) = node_ptr.leafNodes(id).maxSplitLogL;
    bestQues.(clust2state_map.(keys{i})) = node_ptr.leafNodes(id).bestQues;
    model = node_ptr.leafNodes(id).model;
    model.state = clust2state_map.(keys{i});
    ldmModels(i) = model;
end

end