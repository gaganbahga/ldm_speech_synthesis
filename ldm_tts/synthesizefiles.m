function cepDist = synthesizefiles (model, labelData, fileIds, outputPath, MGCData, globalVar)
% Synthesize
%   synthesize observations
%   Inputs:
%       model : structure containing trained model of all phone states
%       labelData : struct containing label data for whole database
%       fileIds : array of file ids in labelData to be synthesised
%       outputPath : path for output file directory
%       globalVar : global variance structure
%
%   Outputs:
%       cepDist: cepstral distance

% Author : Gagandeep Singh 2017

params = getparameters();
frameShift = params.frameShift;
cepDist = zeros(length(fileIds),1);
f0Path = params.f0Directory; % used just in order to check that the no of 
% mcep vectors are the same as the no of f0 points

for fileId = 1:length(fileIds)
    fIndex = fileIds(fileId);
    fileName = labelData(fIndex).file_name;
    disp(fileName)

    if fIndex > length(labelData)
        disp(strcat('Labels for file : ',fileName,' are not available'))
    else
        Y = [];
        fromFrame = labelData(fIndex).begin/frameShift;
        toFrame = labelData(fIndex).ending/frameShift;
        numFrames = toFrame-fromFrame;
        states = labelData(fIndex).label;

        if exist('globalVar','var')
            Y = generatemceps(numFrames,states,model,globalVar);
        else
            Y = generatemceps(numFrames,states,model);
        end
        
        cepDist(fileId) = getCepDist(Y, MGCData{fIndex});
        f0fid = fopen(strcat(f0Path,filesep,fileName,'.f0'), 'r');
        f0Len = length(fread(f0fid,'float64','ieee-le'));
        fclose(f0fid);
        
        if f0Len == size(Y,2) + 1
            Y = [Y Y(:,end)];
            
        elseif f0Len == size(Y,2) + 2
            Y = [Y(:,1) Y Y(:,end)];
        end
        
        synfid = fopen(strcat(outputPath,filesep,fileName,'.mcep'), 'wb');
        fwrite(synfid, Y, 'float32');
        fclose(synfid);
    end
    
end

end