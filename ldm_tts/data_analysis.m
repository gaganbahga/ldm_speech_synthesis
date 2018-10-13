% rough script

minimum = Inf;

all_state_list = {bestModel.state};
phone_state = struct();
for i_state = 1:length(all_state_list)
    phone = regexp(all_state_list{i_state},'([A-Za-z]+)\_s[0-9]+','tokens');
    if ~isfield(phone_state,phone{1})
        phone_state.(phone{1}{1}) = struct();
    end
    if ~isfield(phone_state.(phone{1}{1}),all_state_list{i_state})
        val = size(segments.(all_state_list{i_state}).mgc,2);
        phone_state.(phone{1}{1}).(all_state_list{i_state}) = val;
        if val < minimum
            minimum = val;
            state = all_state_list{i_state};
        end
    end
end