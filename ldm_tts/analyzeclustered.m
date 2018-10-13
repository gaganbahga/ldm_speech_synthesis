% rough script not required

% average number of phones in each utterance is 33 and average number of
% mgcs is 630
maxLength = zeros(length(clusteredData),1);
for stateId = 1:length(clusteredData)
    nMgcs = cellfun(@(x) size(x,2),{clusteredData(stateId).data.mgc} );
    maxLength(stateId) = max(nMgcs);
end
