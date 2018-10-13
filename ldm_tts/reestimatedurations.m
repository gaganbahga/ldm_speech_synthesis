function newLabelData = reestimatedurations(labelData,ldmModels,mgc)
% reestimate durations
%   reestimate the durations using the new LDM models
% Inputs:
%       labelData: old label data
%       ldmModels: ldm models struct array
%       mgc: mgc cell array
% Outputs:
%       newLabelData: newly estimated label data

%   author : Gagandeep Singh 2017

params = getparameters();
nSegments = params.noSegments;
depth = params.depth;
frameShift = params.frameShift;
switchThreshold = params.switchThreshold;
newLabelData = labelData;

if params.use_parfor
    parfor fileId = 1:length(labelData)
        disp(fileId)
        labels = labelData(fileId);
        mgcs = mgc{fileId};
        newLabelData(fileId) = getnewlabelseq(labels,mgcs,nSegments,...
            depth,frameShift,ldmModels,switchThreshold);
    end
else
    for fileId = 1:length(labelData)
        disp(fileId)
        labels = labelData(fileId);
        mgcs = mgc{fileId};
        newLabelData(fileId) = getnewlabelseq(labels,mgcs,nSegments,...
            depth,frameShift,ldmModels,switchThreshold);
    end
end

end

function newLabelData = getnewlabelseq(labels,mgc,nSegments,depth,frameShift,ldmModels,switchThreshold)
% constructed in order to create two types of loops
label = labels.label;
begin = labels.begin;
ending = labels.ending;
newStateSeq = cell(length(label)/nSegments,1);
for phoneId = 1:nSegments:length(label)
    modelSeg = struct('g1',num2cell(zeros(1,nSegments)),'Q1',[],...
        'F',[],'g',[],'Q',[],'H',[],'mu',[],'R',[],'state',[]);
    
    beginId = begin(phoneId)/frameShift + 1;
    endId = ending(phoneId+2)/frameShift ;
    
    Y = mgc(:,beginId:endId);
    for segmentId = 1:nSegments
        state = label{phoneId+segmentId-1};
        modelId = strcmp({ldmModels.state},state);
        modelSeg(segmentId) = ldmModels(modelId);
    end
    if size(Y,2) > switchThreshold
        [newSeq, newLogL] = viterbildm(Y,modelSeg,nSegments,depth);
    else
        [newSeq, newLogL] = bestSequence(Y,modelSeg,nSegments);
    end
    %if params.showIncrease
    % just for checking if new logL increased
    size1 = ending(phoneId)/frameShift - begin(phoneId)/frameShift;
    size2 = ending(phoneId + 1)/frameShift - begin(phoneId + 1)/frameShift;
    size3 = ending(phoneId + 2)/frameShift - begin(phoneId + 2)/frameShift;
    previousLogL = segmentlogl(Y,[size1 size2 size3],modelSeg);
    disp(newLogL - previousLogL)
    if newLogL > previousLogL
        newStateSeq{(phoneId+2)/3} = newSeq;
    else
        newStateSeq{(phoneId+2)/3} = [ones(size1,1); 2*ones(size2,1); ...
            3*ones(size3,1)];
    end
    %end
end
newLabelData = relabelData(labels,newStateSeq,frameShift,true,3);
end

function newLabels = relabelData(labels,stateSeq,frameShift,emptySegments,nSegments)
if nargin ~= 5
    emptySegments = false;
    nSegments = 3;
end
newLabels = struct('file_name',labels.file_name,'label',{labels.label},...
    'begin',[],'ending',[]);
tBegin = 0;
for phoneId = 1:length(stateSeq)
    prevState = stateSeq{phoneId}(1);
    newLabels.begin(end+1) = tBegin;
    nSameStates = 0;
    for mgcId = 1:length(stateSeq{phoneId})
        currentState = stateSeq{phoneId}(mgcId);
        if currentState ~= prevState
            newLabels.ending(end+1) = newLabels.begin(end) + ...
                nSameStates*frameShift;
            newLabels.begin(end+1) = newLabels.ending(end);
            nSameStates = 1;
        else
            nSameStates = nSameStates + 1;
        end
        prevState = currentState;
    end
    newLabels.ending(end+1) = newLabels.begin(end) + ...
        nSameStates*frameShift;
    tBegin = newLabels.ending(end);
    if emptySegments
        if length(stateSeq{phoneId}) < nSegments
            for i = length(stateSeq{phoneId})+1:nSegments
                newLabels.begin(end+1) = newLabels.ending(end);
                newLabels.ending(end+1) = newLabels.ending(end);
            end
        end
    end
end

newLabels.begin = newLabels.begin';
newLabels.ending = newLabels.ending';
end