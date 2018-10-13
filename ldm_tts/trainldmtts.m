% Script for training LDMs on Nick Hurricane dataset.
% All the configuration parameters are read from the config file
% getparameters.m
%
% author : Gagandeep Singh 2017

%clear

params = getparameters();

if params.use_parfor
    createparpool(params.noWorkers);
end

% read labels and MGCs of utterances
disp('Reading labels')
labelData = readlabels(params.labelDirectory);
if params.saveLabels
    save(labelFileName,'labelData')
end

disp('Reading MGCs')
MGCData = readmgcs(params.MGCDirectory, labelData);
if params.saveMGCs
    save(MGCFileName,'MGCData')
end



[clusteredData,labelDataStates,models] = clusterall(labelData, MGCData);

if ~strcmp(params.clusterModelType,params.trainModelType)
    models = trainallstates(clusteredData,params.trainModelType,MGCData);
end

if params.saveTrainedModels
    save(params.trainedModelsName,'models')
end

if params.reSegment
    for iter = 1:params.nRestimations
        labelDataStates = reestimatedurations(labelDataStates,models,MGCData);

        clusteredData = labels2clusterdata(labelDataStates, MGCData, clusteredData);

        models = trainallstates(clusteredData,params.trainModelType,MGCData);
    end
end

if params.saveTrainedModels
    save(params.trainedModelsName,'models')
end

if params.train_lf0
    disp('Reading lf0')
    type = 'lf0';
    lf0Data = readlf0bap(params.lf0Directory, labelData,type); 
    [clusteredDataLf0,labelDataStatesLf0,modelsLf0] = clusterlf0bap(labelData,lf0Data,type);
    if params.lf0.testGen
        synthesizefileslf0bap(modelsLf0,labelDataStatesLf0,test_file_ids,params.lf0.testGenPath,lf0Data)
    end
end

if params.train_bap
    disp('Reading BAP')
    type = 'bap';
    bapData = readlf0bap(params.bapDirectory, labelData,type);
    [clusteredDataBap,labelDataStatesBap,modelsBap] = clusterlf0bap(labelData,bapData,type);
    if params.bap.testGen
        synthesizefileslf0bap(modelsBap,labelDataStatesBap,test_file_ids,params.bap.testGenPath,bapData)
    end
end

if params.testGen
    load(params.testFileList)
    if params.use_global_var
        % calculate global variance of utterances
        globalVar = findglobalvar(MGCData);
        MCD = synthesizefiles(models,labelDataStates,test_file_ids,params.testGenPath,MGCData,globalVar);
    else
        MCD = synthesizefiles(models,labelDataStates,test_file_ids,params.testGenPath,MGCData);
    end
    fprintf('MCD of the test utterances %f\n',MCD);
end