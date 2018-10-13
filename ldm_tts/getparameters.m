function params = getparameters()
% Get parameters
%   Get all the variables and hyperparameters for the model. Currently a
%   struct is created which contains each variable

% author : Gagandeep Singh 2017

% label data parameters
params.labelDirectory = '../nick_voice/label_state_align';
params.questionFilePath = '../nick_voice/questions_discrete.hed';
params.noLabelStates = 5;       % number of hmm-states from which labels are created
params.phoneset = 'unilex';     % options : unilex, cmu (will not work properly without changes)
params.saveLabels = false;      % save the labels as a mat file
params.labelFileName = 'labelData.mat';% name of the mat file

% acoustic data parameters
params.MGCDirectory = '../nick_voice/data/mgc';
params.f0Directory  = '../nick_voice/data/f0';
params.lf0Directory = '../nick_voice/data/lf0';
params.BAPDirectory = '../nick_voice/data/bap';
params.saveMGCs = false;            % save the MGCs as a mat file
params.MGCFileName = 'MGCData.mat'; % name of the mat file

% train f0 and bap
params.trainlf0 = true;
params.trainbap = true;

% clustering parameters
params.loadTree = true;        % if a preclustered tree is to be loaded from TreeFilePath
params.saveTree = false;         % save the clustered tree
params.TreeFilePath = 'clusteredTree.mat'; % name of the tree file
params.clusterModelType = 'basicLDM';   % options: autoReg, basicLDM, 2ndOrderLDM
params.minFrameThreshold = 100;      % minimum frames in a node     
%params.minIncLogL = 20;             % threshold logL increase to stop clustering
params.rho = 0.05;                   % used to find threshold for logL increase

% LDM parameters
params.n = 10;
params.m = 40;
params.frameShift = 50000;      % in 0.1 microsecs (HTK convention)
params.maxIterations = 100;       % max iterations for EM
params.maxBufIter = 5;          % if EM is appearing to converge, wait for maxBufIter to see if it starts increasing again

params.trainModelType = '2ndOrderLDM';  % options: autoReg, basicLDM, 2ndOrderLDM

% LDM constraints 
params.diagonalF = false;
params.damp_sys = false;                % critically damped system assumption
params.tie_all_H = false;               % tie H of all states
params.tie_phone_H = false;             % tie H of all states of particular phone
params.tieH = params.tie_all_H || params.tie_phone_H;
params.Q_is_I = true;
params.Q1_is_I = true;
params.Q0_is_I = true;
params.R_is_I = false;
params.g_is_0 = false;
params.g1_is_0 = false;
params.g0_is_0 = false;
params.mu_is_0 = false;

%params.maxNoStates = 3000;

% segmentation parameters
params.noSegments = 3;          % no of subphone segments
params.segmentation = 'hmmSegments'; % segmentation to be used. options : hmmSegments, equalSegments
params.reSegment = true;             % if resegmentation is to be done
params.nRestimations = 5;
params.depth = 5;                    % depth of viterbi like search
params.switchThreshold = 35;         % threshold length after which switch to approximate viterbi

%params.same_state_obs = false;

params.saveTree = false;
params.saveTrainedModels = false;
params.trainedModelsName = 'SOLDMModels.mat';

% gebneration parameters
params.testGen = true;
params.testFileList = 'test_file_ids.mat';
params.testGenPath = '../nick_voice/synthesis/test_synthesis_mcep';
params.lambda = 1;   % linear combination param for first state of new segment
params.use_global_var = true;
params.alpha_0 = 0.001; % global var params
params.weight = 1;
params.eps_1 = 0.002;
params.eps_2 = 0.1;
params.doMLPG = false;    % if using dynamic features. calls a python function underneath
params.smoothen = true;   % smoothen the generated parameters with a moving average

% lf0 parameteres
params.train_lf0 = true;
params.lf0.loadTree = true;
params.lf0.m = 1;
params.lf0.rho = 1;
params.lf0.minFrameThreshold = 100;
params.lf0.saveTree = true;
params.lf0.TreeFilePath = 'tree_lf0.mat';
params.lf0.testGen = true;
params.lf0.testGenPath = '../nick_voice/synthesis/test_synthesis_lf0';

% bap parameters
params.train_bap = true;
params.bap.loadTree = false;
params.bap.m = 1;
params.bap.rho = 1;
params.bap.minFrameThreshold = 100;
params.bap.saveTree = true;
params.bap.TreeFilePath = 'tree_bap.mat';
params.bap.testGen = true;
params.bap.testGenPath = '../nick_voice/synthesis/test_synthesis_bap';

% parallel preferences
params.use_parfor = true;   % parallelize on multiple workers
params.noWorkers = 28;      % number of workers to spawn
params.maxNoWorkers = 28;   % max. no of allowed workers. adviced to be lesser than no. cores

params.wbar = false;        % display waitbar when reading labels etc

% if f0 etc are also used
end
