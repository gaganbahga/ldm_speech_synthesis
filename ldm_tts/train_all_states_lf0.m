function model = train_all_states_lf0(clustData)
%   Train all states of lf0 or bap
%   main script for training all the clustered states of lf0 or BAP. 
%   Uses parfor or training all in parallel. Uses clustered data tree
%   to find the data associated with each state. The models are trained 
%   using autoregressive HMMs only because the data are scalar sequence
%   
%   inputs :
%           clustData: clustered tree root
%
%   outputs :
%           model: trained models struct array

%   author : Gagandeep Singh 2017

model = struct('g1',[],'Q1',[],'F',[],'g',[],'Q',[],'H',[],'mu',[],'R',[],'state',{clustData.state});
for state_id = 1:length(clustData)
    disp(state_id)
    train_data = get_train_data(clustData(state_id).data);
    %if nargin == 1
    initialModel = initialize_model_lf0(train_data);
    %else
    %    initialModel = models(state_id); % modelId is supposed to be same as
    % stateId
    %end
    best_model = trainautoshannonlf0(train_data,initialModel);
    best_model.state = clustData(state_id).state;
    model(state_id) = best_model;
end

end

function train_data = get_train_data(data)
load('train_file_ids');
train_data = struct('label',{},'lf0',[],'root_ind',[],'file_id',[],'label_id',[]);
for i = 1:length(data)
    if sum(train_file_ids == data(i).file_id) == 1
        train_data(end+1) = data(i);
    end
end

end