function segments  = create_segments(mgc_data, label_data, triphone_states_file, num_train)
% Create segments
%   organize the MGCs according to segments for each phone
%   
%   inputs:
%           mgc_data: mgc_data{i} gives matrix containing MGCs for ith 
%           utterance. MGCs are arranged column-wise
%           label_data: label_data{i} contains structure for label of ith
%           utterance. fields are state which stores cell array of state
%           names; begin & end which give the begining and end time 
%           respectively of each state. The length of three vector is same.
%           triphone_states_file: path to file containing the names of all
%           triphone states.
%           num_train: (optional) number of training files to be used
%           default is 1000.
%
%   output:
%          segments: structure with fields state, mgc and duration.
%          segments(i).state gives the name of the ith triphone state,
%          segments(i).mgc is a matrix containing MGCs of that state in
%          columnwise fashion. segments(i).duration is a L X 2 matrix where
%          Lth row gives starting and ending index of Lth segment in
%          segments(i).mgc

%   author : Gagandeep Singh 2017

if nargin == 3
    num_train = 2700;
end

% read names of all triphone states 
file_id = fopen(triphone_states_file);
tri_state = fgetl(file_id);
i = 1;
while ischar(tri_state)
    tri_states{i,1} = tri_state;
    tri_state = fgetl(file_id);
    i = i+1;
end
fclose(file_id);

frame_shift = 50000;

% initialize
segments = struct('state',{},'mgc',{},'duration',{});

wbar = waitbar(0,'Creating Segments');

for i = 1:num_train
    waitbar(i/num_train)
    start_index = 1;
    for j = 1:length(label_data(i).state)
        state = label_data(i).state{j};
        state_ind = find(strcmp({segments.state},state));
        
        % if not encountered earlier, add the phone state to end of
        % structure
        if isempty(state_ind)
            segments(end+1).state = state;
            segments(end).mgc = [];
            segments(end).duration = [];
            state_ind = length(segments);
        end
        
        % get the data from label_data and mgc_data

        end_index = label_data(i).ending(j)/frame_shift;
        current_size = size(segments(state_ind).mgc,2);
        
        added_data_size = size(mgc_data{i}(:,start_index:end_index));
        segments(state_ind).duration = [segments(state_ind).duration;...
            (current_size+1), (current_size+added_data_size(2))];
        segments(state_ind).mgc = [segments(state_ind).mgc, ...
            mgc_data{i}(:,start_index:end_index)];
        
        % for future use in algorithm 2 phone level
%         if j == 1
%             segments.(state).prev_phone = 'none';
%         else
%             segments.(state).prev_phone = label_data(i).state{j-1};
%         end

        start_index = end_index;
    end
end

close(wbar)

end