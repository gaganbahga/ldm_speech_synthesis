function lf0bapdata = readlf0bap(directory,labelData,type)
% Read lf0 or bap
%   Read the lf0 or BAP from the directory
%   
%   inputs :
%           directory : directory containing the data files with
%           extension .bap or .lf0
%           labelData : structure containing labels for each file. This is
%           requried to match the number of frames and the duration
%           of the file in label data. Discrepencies of upto 2 frames have
%           been observed. MGCs are trimmed in order to accomodate that.
%           type: lf0 or bap
%
%   outputs :
%           lf0bapdata : cell vector of length equal to number of files.
%           Each cell is a matrix of size 1 X N where N are the number 
%           of frames.
%           

%   author : Gagandeep Singh 2017

    fileNames = {labelData.file_name};
    lf0bapdata = cell(length(fileNames),1); 
    params = getparameters();
    % frame shift time. Depends on the labels. Here in 100ns
    frameShift = params.frameShift;
    
    % can be changed to parfor but it takes little time to read files, so
    % won't matter much
    for fileId = 1:length(fileNames)
        
        % read mgc data
        if strcmp(type,'lf0')
            fileName = sprintf('%s/%s.lf0',directory, fileNames{fileId});
        elseif strcmp(type,'bap')
            fileName = sprintf('%s/%s.bap',directory, fileNames{fileId});
        end
        fid = fopen(fileName,'r','b');
        data = fread(fid,'float32','ieee-le')';
        fclose(fid);
        
        noFrameLabel = labelData(fileId).ending(end)/frameShift;
        diff_frames = round(length(data) - noFrameLabel);
        if diff_frames == 0
            lf0bapdata{fileId} = data; 
        elseif diff_frames == 2
            lf0bapdata{fileId} = data(2:end-1);
        elseif diff_frames == 1
            lf0bapdata{fileId} = data(1:end-1);
        elseif diff_frames == 3
            lf0bapdata{fileId} = data(2:end-2);
        else
            disp('labels and MGCs dont match')
        end
        
    end
end