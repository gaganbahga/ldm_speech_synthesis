% Script for training autoregressive HMMs for lf0 and BAP on Nick Hurricane dataset. Tree-based
% clustering is performed for each of the 3 states of every phone using
% autoregressive HMMs

% author : Gagandeep Singh 2017

clear

% initialize paths
labelDirectory = '../nick_voice/label_state_align';
bap_directory = '../nick_voice/data/bap';
lf0_directory = '../nick_voice/data/lf0';

createparpool(28);

labelData = read_full_labels(labelDirectory);
%load('label_data_full.mat')

lf0_data = read_lf0(lf0_directory, labelData);
bap_data = read_lf0(bap_directory, labelData);
[clusteredDataLf0,labelDataStatesLf0] = cluster_lf0(labelData, lf0_data,questionFilePath,nSegments, 0);
[clusteredDataBap,labelDataStatesBap] = cluster_bap(labelData, bap_data,questionFilePath,nSegments, 0);

[clusteredDataLf0,labelDataStatesLf0] = tree_2_clust_data_lf0(tree,labelData);
[clusteredDataBap,labelDataStatesBap] = tree_2_clust_data_bap(tree,labelData);

ldmModelsLf0 = train_all_states_lf0(clusteredDataLf0);
ldmModelsBap = train_all_states_bap(clusteredDataBap);