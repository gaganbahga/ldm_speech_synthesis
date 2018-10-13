function [data_y, data_n] = separate_data(phone, data, patterns)
% separate data
%   separate the data into the yes and no bin according to a binary question
% Inputs:
%       phone
%       data: data sruct array
%       patterns: regex pattern arrays
% Outputs:
%       data_y: data which follows a pattern
%       data_n: data which doesn't follows a pattern

%   author : Gagandeep Singh 2017

for pat_id = 1:length(patterns)
    
    if ~isempty(strfind(patterns{pat_id},'+'))
        patterns{pat_id} = regexprep(patterns{pat_id},'\*\\\+',strcat(phone,'\\\+'));
        patterns{pat_id} = regexprep(patterns{pat_id},'\+\*','+[a-z_]\+');
        %patterns{pat_id} = strcat(patterns{pat_id},'/',int2str(state_id));
    elseif strfind(patterns{pat_id},'-')
        patterns{pat_id} = regexprep(patterns{pat_id},'\-\*',strcat('-',phone));
        patterns{pat_id} = regexprep(patterns{pat_id},'\*-','[a-z_]\+-');
    end
    %patterns{pat_id} = regexprep(patterns{pat_id},'*',phone);
    %patterns{pat_id} = strcat(patterns{pat_id},'/',int2str(state_id));
end
data_y = struct('label', {},'mgc', {});
data_n = struct('label', {},'mgc', {});
for label_id = 1:length(data)
    found = false;
    for pat_id = 1:length(patterns)
        %disp(label_data(file_id).tri_phone{label_id})
        %disp( patterns{pat_id} )
        if regexp(data(label_id).label, patterns{pat_id})
            data_y(end+1).label = data(label_id).label;
            data_y(end).mgc = data(label_id).mgc;
            data_y(end).root_ind = data(label_id).root_ind;
            found = true;
            break
        end
    end
    if ~found
        data_n(end+1).label = data(label_id).label;
        data_n(end).mgc = data(label_id).mgc;
        data_n(end).root_ind = data(label_id).root_ind;
    end
end

end