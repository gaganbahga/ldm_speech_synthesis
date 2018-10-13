function MGCData = readmgcs(mgcDirectory, labelData)
% Read Mel-generalized coefficients
%   Read the mel-generalized coefficients from the directory
%   
%   inputs :
%           mgcDirectory : directory containing the mgc files with
%           extension .mgc
%           labeData : structure containing labels for each file. This is
%           requried to match the number of frames in MGCs and the duration
%           of the file in label data. Discrepencies of upto 3 frames have
%           been observed. MGCs are trimmed in order to accomodate that.
%
%   outputs :
%           MGCData : cell vector of length equal to number of files.
%           Each cell is a matrix of size m X N where m is the number of 
%           mgc coeffients extracted from each frame and N are the number 
%           of frames.
%           

%   author : Gagandeep Singh 2017

   
    fileNames = {labelData.file_name};
    MGCData = cell(length(fileNames),1); 
    
    % frame shift time. Depends on the labels. Here in 100ns
    params = getparameters();
    frameShift = params.frameShift;
    m = params.m;
    
    % can be changed to parfor but it takes little time to read files, so
    % won't matter much
    for file_id = 1:length(fileNames)
        
        % read mgc data
        fileName = sprintf('%s/%s.mgc',mgcDirectory, fileNames{file_id});
        fid = fopen(fileName,'r','b');
        data = fread(fid,'float32','ieee-le');
        data = reshape(data,m,[]);
        fclose(fid);
        
        noFrameLabel = labelData(file_id).ending(end)/frameShift;
        diffFrames = round(length(data) - noFrameLabel);
        if diffFrames == 0
            MGCData{file_id} = data; 
        elseif diffFrames == 2
            MGCData{file_id} = data(:,2:end-1);
        elseif diffFrames == 1
            MGCData{file_id} = data(:,1:end-1);
        elseif diffFrames == 3
            MGCData{file_id} = data(:,2:end-2);
        else
            error('labels and MGCs dont match')
        end
        
    end
end