function clusteredData = labels2clusterdata(labels, mgc, clusteredData)
% Labels to clustered data
%   refresh the clustered data struct from label data struct
% Inputs:
%       labels: label data
%       mgc: mgc cell array
%       clusteredData: clustered data structure old
% Outputs:
%       clusteredData: refreshed clustered data structure

%   author : Gagandeep Singh 2017

params = getparameters();
frameShift = params.frameShift;
for stateId = 1:length(clusteredData)
    for segmentId = 1:length(clusteredData(stateId).data)
        fileId = clusteredData(stateId).data(segmentId).file_id;
        labelId = clusteredData(stateId).data(segmentId).label_id;
        beginId = labels(fileId).begin(labelId)/frameShift + 1;
        endingId = labels(fileId).ending(labelId)/frameShift;
        clusteredData(stateId).data(segmentId).mgc = mgc{fileId}(:,beginId:endingId);
    end
end
end