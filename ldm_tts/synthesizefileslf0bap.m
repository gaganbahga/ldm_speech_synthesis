function synthesizefileslf0bap (model, labelData, fileIds, outputPath,type)
% Synthesize
%   synthesize lf0 and BAP observations
%   Inputs:
%       model : structure containing trained model of all phone states
%       labelData : struct containing label data for whole database
%       fileIds : array of file ids in labelData to be synthesised
%       outputPath : path for output file directory
%       globalVar : global variance structure

% Author : Gagandeep Singh 2017

params = getparameters();
frameShift = params.frameShift;

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
        if nargin == 5
            Y = generatelf0(numFrames,states,model);
        elseif nargin == 6
            Y = generatelf0(numFrames,states,model,globalVar);
        end
        if strcmp(type,'lf0')
            synfid = fopen(strcat(outputPath,filesep,fileName,'.lf0'), 'wb');
        else
            synfid = fopen(strcat(outputPath,filesep,fileName,'.bap'), 'wb');
        end
        fwrite(synfid, Y, 'float32');
        fclose(synfid);
    end
    
end

end