function H = getcommonphoneH(phone, segment_id, mgcData, nUtt, modelType,diagonal)
% Get common phone H 
%   get the an H matrix for data of one phone
% Inputs:
%       mgcData
%       noFiles: number of files
%       modelType: not used here
%       diagonal: not used here 
% Outputs:
%       H: projection matrix
load('label_data_full.mat');
data = get_root_data(phone, labelData, mgcData, segment_id);
if length(data) > nUtt
    data = data(1:nUtt);
end

initialModel = initialize_model(data,modelType,0);
model = train_2_LDM(data, initialModel, modelType,diagonal,false);
H = model.H;
end