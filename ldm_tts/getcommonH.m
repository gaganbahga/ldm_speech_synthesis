function H = getcommonH(mgcData, noFiles, modelType,diagonal)
% Get common H
%   get the an H matrix for some data
% Inputs:
%       mgcData
%       noFiles: number of files
%       modelType: not used here
%       diagonal: not used here 
% Outputs:
%       H: projection matrix

data = struct('mgc',[]);
for i = 1:noFiles
    data(i).mgc = mgcData{i};
end
initialModel = initialize_model(data,modelType,0);
model = train_2_LDM(data, initialModel, modelType,diagonal,false);
H = model.H;
end