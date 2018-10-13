% rough script
fileId = 1;
nSegments = length(label_data_states(fileId).tri_phone);
models = struct('g1',num2cell(zeros(1,nSegments)),'Q1',[],'F',[],'g',[],'Q',[],'H',[],'mu',[],'R',[],'state',[]);
for tpId = 1:nSegments
    state = label_data_states(fileId).tri_phone(tpId);
    modelId = find(strcmp({model.state},state));
    models(tpId) = model(modelId);
end

[subVitSeq, subVitLogL] = viterbildm(mgc_data{1},models,nSegments,3);