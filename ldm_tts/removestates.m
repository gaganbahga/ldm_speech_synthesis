% rough script. It was planned to remove the states with very less amount of data
% after duration reestimations but was not implemented
function [labelData,removedStates] = removestates(clusteredData, labelData)

minMgcThr = 30;
minMaxSegLen = 2;
removedStates = {};
for i = 1:length(clusteredData)
    totalMgc = size([clusteredData(i).data.mgc],2);
    maxSegLen = max(cellfun(@(x) size(x,2),{clusteredData(i).data.mgc} ));
    if (totalMgc < minMgcThr) || maxSegLen <= minMaxSegLen
        disp(i)
%         removedStates{end + 1} = clusteredData(i).state;
%         for j = 1:length(clusteredData(i).data)
%             fileId = clusteredData(i).data(j).file_id;
%             labelId = clusteredData(i).data(j).label_id;
%             labelData(fileId) = removestate(labelData(fileId), labelId);
%         end
    end
end
end

function uttData = removestate(uttData, labelId)

frameShift = 50000;
state = uttData.tri_phone(labelId);
segment = regexp(state,'[a-z_]+_([0-9]+)+_[0-9]+','tokens');
segment = str2num(segment{1}{1}{1});

if segment == 1
    uttData.ending(labelId) = uttData.begin(labelId);
    uttData.begin(labelId+1) = uttData.begin(labelId);
elseif segment == 2
    duration = uttData.ending(labelId) - uttData.begin(labelId);
    uttData.ending(labelId-1) = uttData.ending(labelId-1) + ceil(duration/(2*frameShift))*frameShift;
    uttData.begin(labelId) = uttData.ending(labelId-1);
    uttData.ending(labelId) = uttData.ending(labelId-1);
    uttData.begin(labelId+1) = uttData.ending(labelId-1);
elseif segment == 3
    uttData.begin(labelId) = uttData.ending(labelId);
    uttData.ending(labelId-1) = uttData.ending(labelId);
end

end