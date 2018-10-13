function labelData = readlabels(labDir)
% Read labels and alignments
%   Read the labels and correspoding durations from the directory
%   
%   inputs :
%           labDir : directory containing aligned full context labels of 
%           each file in HTS format
%
%   outputs :
%           labelData : struct array containg file name, full-context
%           labels, beginning and ending of that subphone
%           

%   author : Gagandeep Singh 2017

params = getparameters();
frameShift = params.frameShift;
dirStruc = dir([labDir filesep '*.lab']);
noFiles = length(dirStruc);
labelData = struct('file_name', cell(noFiles,1),'label', cell(noFiles,1),...
    'begin',cell(noFiles,1),'ending',cell(noFiles,1));

dataPattern = '([0-9]+) ([0-9]+) ([^\n]+)';
if params.wbar
    wbar = waitbar(0, 'reading labels');
end
for fileId = 1:noFiles
    if params.wbar
        waitbar(fileId/noFiles)
    end
    file = fopen([labDir filesep dirStruc(fileId).name],'r');
    labelData(fileId).file_name = dirStruc(fileId).name(1:end-4);
    line = fgetl(file);
    
    beginTime = 0;
    
    while ischar(line)
        if strcmp(params.segmentation,'equalSegments')
            noLabelStates = params.noLabelStates;
            endSegment = strcat('[',num2str(noLabelStates+1),']');
            if strcmp(line(end-2:end),'[2]')
                values = regexp(line,dataPattern,'tokens');
                beginTime = str2double(values{1}{1});
                labelData(fileId).begin = [labelData(fileId).begin; beginTime];
                label = values{1}(3);
                labelData(fileId).label = [labelData(fileId).label; {strcat(label{1}(1:end-3),'/1')}];
                labelData(fileId).label = [labelData(fileId).label; {strcat(label{1}(1:end-3),'/2')}];
                labelData(fileId).label = [labelData(fileId).label; {strcat(label{1}(1:end-3),'/3')}];
            elseif strcmp(line(end-2:end), endSegment)
                values = regexp(line,dataPattern,'tokens');
                endTime = str2double(values{1}{2});
                noFrames = (endTime - beginTime)/frameShift;
                labelData(fileId).ending = [labelData(fileId).ending; beginTime...
                    + frameShift*floor((noFrames+2)/3) ];

                beginTime = labelData(fileId).ending(end);
                labelData(fileId).begin = [labelData(fileId).begin; beginTime];
                labelData(fileId).ending = [labelData(fileId).ending; beginTime...
                    + frameShift*floor((noFrames+1)/3) ];

                beginTime = labelData(fileId).ending(end);
                labelData(fileId).begin = [labelData(fileId).begin; beginTime];
                labelData(fileId).ending = [labelData(fileId).ending; beginTime...
                    + frameShift*floor((noFrames)/3) ];

            end
        elseif strcmp(params.segmentation, 'hmmSegments')
            values = regexp(line,dataPattern,'tokens');
            labelData(fileId).begin  = [labelData(fileId).begin ; str2double(values{1}{1})];
            labelData(fileId).ending = [labelData(fileId).ending; str2double(values{1}{2})];
            labelData(fileId).label  = [labelData(fileId).label; values{1}(3)]; 
        else
            Error('Segmentation: %s is not supported.\nAccepted segmentations: equalSegments, hmmSegments')
        end
        line = fgetl(file);
    end
    fclose(file);
end
if params.wbar
    close(wbar)
end