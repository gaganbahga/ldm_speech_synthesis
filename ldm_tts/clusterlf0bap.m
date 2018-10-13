function [clusteredData,labelDataStates,models] = clusterlf0bap(labelData,lf0bapdata,type)
% Cluster lf0 and bap
%   Cluster the states for lf0 or bap (type) for all the segments of all the phones
% Inputs:
%       labelData : data with file_name, tri_phone(not a preclustered state),
%       begin and ending of each triphone
%       lf0bapdata : for each file in 1 X no_type matrix format
%       type : lf0 or bap

% Outputs:
%       clusteredData
%       labelDataStates : labelled data but labelled with clustered
%       states instead of full context phones
%       models : trained models

% author : Gagandeep Singh 2017

params = getparameters();
quests = readquestions(params.questionFilePath);
phones = getphonelist(params.phoneset);

if params.(type).loadTree
    load(params.(type).TreeFilePath);
else
    tree = struct();
end
tree = treeLf0;

for segmentId = 1:params.noSegments
    segment = strcat('segment_',int2str(segmentId));
    if ~isfield(tree,segment)
        tree.(segment) = struct();
    end
    for phnId = 1:length(phones)
        phone = phones{phnId};
        fprintf('phone : %s\n',phone)
        if isfield(tree.(segment),changephonename(phone))
            continue
        end
        
        if ~isvoiced(phone)
            continue
        end
        
        
        
        % used for setting the pointer of each data point to a particular
        % node in the tree. Also keeps track of the question used in each
        % node. Uses handle class in('tree_autoreg_11.mat','tree')order to enable to make each function
        % call to read and write from same data
        nodePtr = Node_ptr();
        % get the data for a particular segment of a given phone
        rootData = getrootdata(phone, labelData,lf0bapdata,segmentId,nodePtr,params.frameShift);
        %stats = getstats(root_data);
        initialModel = initializemodellf0bap(rootData);
        % get likelihood of unclustered data
        [initialModel,logLRoot] = trainautoshannonlf0bap(rootData,initialModel,type);
        clustersplitlf0bap(phone,rootData,logLRoot,'r',nodePtr,quests,initialModel,type);
        tree.(segment).(changephonename(phone)).node_ptr = nodePtr;
        tree.(segment).(changephonename(phone)).data = rootData;
        if params.(type).saveTree
            save(params.(type).TreeFilePath,'tree')
        end
    end
end

[clusteredData,labelDataStates,models] = tree2clustdatalf0bap(tree,labelData,type);
toc

end

function root_data = getrootdata(phone,labelData,lf0bapData,segmentId,node_ptr,frameShift)
full = true;
if full
    pattern = strcat('([a-z_@\!\^1]+-)',phone,'(\+[a-z_@\!\^1]+)');
else
    pattern = strcat('^([a-z_]+-)?',phone,'(\+[a-z_]+)?/[0-9]$');
end
root_data = struct('label', {},'lf0bap', {}, 'root_ind',[],'file_id',[],'label_id',[]);
step = 3;
ind = 1;
for file_id = 1:length(labelData)
    for label_id = segmentId:step:length(labelData(file_id).begin)
        %disp(label_data(file_id).tri_phone{label_id})
        %disp( patterns{pat_id} )
        if regexp(labelData(file_id).label{label_id}, pattern)   %in case of triphones it is tri_phone
            begin_index = 1+labelData(file_id).begin(label_id)/frameShift;
            end_index = labelData(file_id).ending(label_id)/frameShift;
            lf0 = lf0bapData{file_id}(begin_index:end_index);
            lf0 = lf0(lf0 > 0);

            root_data(end+1).label = labelData(file_id).label{label_id};
            root_data(end).lf0bap = lf0;
            root_data(end).root_ind = ind;
            root_data(end).file_id = file_id;
            root_data(end).label_id = label_id;
            node_ptr.node_id{end+1} = 'r';
            ind = ind+1;
        end
    end
end
end

function phone = changephonename(phone)
phone = regexprep(phone,'@','a1');
phone = regexprep(phone,'!','sc');
end