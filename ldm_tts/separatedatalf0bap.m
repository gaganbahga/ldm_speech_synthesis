function [data_y, data_n] = separatedatalf0bap(phone, data, patterns)
% separate lf0 or BAP data
%   separate the data into the yes and no bin according to a binary question
% Inputs:
%       phone
%       data: data sruct array
%       patterns: regex pattern arrays
% Outputs:
%       data_y: data which follows a pattern
%       data_n: data which doesn't follows a pattern

%   author : Gagandeep Singh 2017

%patterns = quest(1).patterns;

for patId = 1:length(patterns)
    
    if ~isempty(strfind(patterns{patId},'+'))
        patterns{patId} = regexprep(patterns{patId},'\*\\\+',strcat(phone,'\\\+'));
        patterns{patId} = regexprep(patterns{patId},'\+\*','+[a-z_]\+');
        %patterns{pat_id} = strcat(patterns{pat_id},'/',int2str(state_id));
    elseif strfind(patterns{patId},'-')
        patterns{patId} = regexprep(patterns{patId},'\-\*',strcat('-',phone));
        patterns{patId} = regexprep(patterns{patId},'\*-','[a-z_]\+-');
    end
    %patterns{pat_id} = regexprep(patterns{pat_id},'*',phone);
    %patterns{pat_id} = strcat(patterns{pat_id},'/',int2str(state_id));
end
data_y = struct('label', {},'lf0bap', {});
data_n = struct('label', {},'lf0bap', {});
for label_id = 1:length(data)
    found = false;
    for patId = 1:length(patterns)
        %disp(label_data(file_id).tri_phone{label_id})
        %disp( patterns{pat_id} )
        if regexp(data(label_id).label, patterns{patId})
            data_y(end+1).label = data(label_id).label;
            data_y(end).lf0bap = data(label_id).lf0bap;
            data_y(end).root_ind = data(label_id).root_ind;
            data_y(end).file_id = data(label_id).file_id;
            data_y(end).label_id = data(label_id).label_id;
            found = true;
            break
        end
    end
    if ~found
        data_n(end+1).label = data(label_id).label;
        data_n(end).lf0bap = data(label_id).lf0bap;
        data_n(end).root_ind = data(label_id).root_ind;
        data_n(end).file_id = data(label_id).file_id;
        data_n(end).label_id = data(label_id).label_id;
    end
end

end