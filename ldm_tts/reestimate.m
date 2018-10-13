% rough script

frame_shift = 50000;
load('label_data_states.mat')
load('nick_clustered_model.mat')
load('mgc_data_nick.mat')

reEstimatedLabels = reestimatedurations(label_data_states,model,mgc_data,3,5);
save('reEstimatedLabels.mat','reEstimatedLabels');