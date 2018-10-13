function root_data = getrootdata(phone, label_data, mgc_data, segment_id,node_ptr)
% Get root data
%   get the root data of a phone
% Inputs:
%       phone
%       label_data: label data struct array
%       mgc_data: mgc_data cell array
%       segment_id
%       node_ptr: node pointer for the cluster 
% Outputs:
%       root_data

%   author : Gagandeep Singh 2017

frame_shift = 50000;
full = true;
if full
    pattern = strcat('([a-z_@\!\^1]+-)',phone,'(\+[a-z_@\!\^1]+)');
else
    pattern = strcat('^([a-z_]+-)?',phone,'(\+[a-z_]+)?/[0-9]$');
end
root_data = struct('label', {},'mgc', {}, 'root_ind',[],'file_id',[],'label_id',[]);
step = 3;
ind = 1;
for file_id = 1:length(label_data)
    for label_id = segment_id:step:length(label_data(file_id).begin)
        %disp(label_data(file_id).tri_phone{label_id})
        %disp( patterns{pat_id} )
        if regexp(label_data(file_id).label{label_id}, pattern)   %in case of triphones it is tri_phone
            root_data(end+1).label = label_data(file_id).label{label_id};
            begin_index = 1+label_data(file_id).begin(label_id)/frame_shift;
            end_index = label_data(file_id).ending(label_id)/frame_shift;
            root_data(end).mgc = mgc_data{file_id}(:,begin_index:end_index);
            root_data(end).root_ind = ind;
            root_data(end).file_id = file_id;
            root_data(end).label_id = label_id;
            if nargin == 5
                node_ptr.node_id{end+1} = 'r';
            end
            ind = ind+1;
        end
    end
end
end