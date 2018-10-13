function model = trainallstates(clustData,modelType,mgcData)
%   Train all states
%   main script for training all the clustered states. Uses parfor or training all in parallel
%   uses clustered data tree to find data associated with each state  
%   
%   inputs :
%           clustData: clustered tree root
%           modelType: autoReg basicLDM, 2ndOrderLDM
%           mgcData: MGC data cell array
%
%   outputs :
%           model: trained models struct array

%   author : Gagandeep Singh 2017

model = struct('g1',[],'Q1',[],'F',[],'g',[],'Q',[],'H',[],'mu',[],'R',[],'state',{clustData.state});

params = getparameters();
tie_all_H = params.tie_all_H;
tie_phone_H = params.tie_phone_H;
phones = getphonelist(params.phoneset);            % these 3 variables are not required
commonH = cell(3,length(phones));                  % here but parfor compalins if not initialized
H_1 = 0;

if tie_phone_H
    commonH = cell(3,length(phones));
    for segment = 1:params.noSegments
        % two types of for loops for 
        if params.use_parfor
            parfor phnId = 1:length(phones)
                phone = phones{phnId};
                commonH{segment,phnId} = getcommonphoneH(phone, segment, mgcData,1000,modelType,diagonal);
            end
        else
            for phnId = 1:length(phones)
                phone = phones{phnId};
                commonH{segment,phnId} = getcommonphoneH(phone, segment, mgcData,1000,modelType,diagonal);
            end
        end
    end
    
    for phnId = 1:length(phones)
        phones{phnId} = changephonename(phones{phnId});
    end
    
elseif tie_all_H
    H_1 = getcommonH(mgcData,50,modelType,diagonal);
end

if params.use_parfor
    parfor stateId = 1:length(clustData)
        disp(stateId)
        state = clustData(stateId).state;
        trainData = gettraindata(clustData(stateId).data);
        model(stateId) = getbestmodel(trainData,state,phones,tie_phone_H,...
            commonH,tie_all_H,H_1,modelType,stateId);
    end
else
    for stateId = 1:length(clustData)
        disp(stateId)
        state = clustData(stateId).state;
        trainData = gettraindata(clustData(stateId).data);
        model(stateId) = getbestmodel(trainData,state,phones,tie_phone_H,...
            commonH,tie_all_H,H_1,modelType,stateId);
    end
    
end

end

function bestModel = getbestmodel(trainData,state,phones,tie_phone_H,...
    commonH,tie_all_H,H_1,modelType,stateId)
% created just in order to call from within for as well as parfor loop

if tie_phone_H
    match = regexp(state,'([a-z1]+)_([0-9])_[0-9]+','tokens');
    phone = match{1}{1};
    phone = strcmp(phones,phone);
    segment = str2double(match{1}{2});
    H = commonH{segment,phone};
    initialModel = initializemodel(trainData,modelType,stateId,H);
    
elseif tie_all_H
    initialModel = initializemodel(trainData,modelType,stateId,H_1);
else
    initialModel = initializemodel(trainData,modelType,stateId);
end

if strcmp(modelType,'autoReg')
    bestModel = trainautoshannon(trainData,initialModel);
elseif strcmp(modelType,'basicLDM') || strcmp(modelType,'2ndOrderLDM')
    bestModel = trainldm(trainData,initialModel,modelType);
end

bestModel.state = state;
end

function trainData = gettraindata(data)
load('train_file_ids');
trainData = struct('label',{},'mgc',[],'root_ind',[],'file_id',[],'label_id',[]);
for i = 1:length(data)
    if sum(train_file_ids == data(i).file_id) == 1
        trainData(end+1) = data(i);
    end
end

end