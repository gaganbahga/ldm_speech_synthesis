function [bestModel, bestLogL] = EMalgorithmLDM(model, segments, maxIterations, state_list)
% Expectation maximization for LDM
%   train LDMs using expectation maximization algorithm
% Inputs:
%       model: structure containing the LDM parameters for each phone.
%       model(i).state gives the name of the phone in the ith postion.
%       model(i).F, model(i).H etc conatins the LDM parameters for the ith
%       phoneme
%       segment: MGCs from training data organized in segments for each
%       phone
%       maxItreations: maximum number of iterations for expaectation
%       maximization algorithm
%       state_list: (optional) train the models for these states only. If
%       none provided then LDMs are trained for all states.
% Outputs:
%       bestModel: structure containing trained LDM parameters. The
%       stucture is same as input 'model'
%       bestLogL: vector containing the maximum likelihood for the training
%       data using corresponding to each phone

% author : Gagandeep Singh 2017

if nargin == 3
    state_list = {segments.state};
end

% initialize
bestModel = model;
bestLogL  = -Inf * ones(length(model),1);

%wbar = waitbar(0,'Doing EM');

% change for to parfor to compute in parallel and vice-versa
parfor i_tri = 1:length(model)
    
    % train models only for states in state list
%     if ~any(ismember(state_list, model(i_tri).state ))
%         continue
%     end
    
    fprintf('Current triphone %s\n', model(i_tri).state)
    %waitbar(i_tri/length(tri_states))
    
    iter = 1;
     
    LDM_params = struct('g1',model(i_tri).g1, 'Q1', model(i_tri).Q1, 'F',...
        model(i_tri).F, 'g', model(i_tri).g, 'Q', model(i_tri).Q, 'H',...
        model(i_tri).H, 'mu', model(i_tri).mu, 'R', model(i_tri).R);

    
    % maximum number size of any segment for current phone
    max_T = max(segments(i_tri).duration(:,2) -...
        segments(i_tri).duration(:,1)) + 1;
    
    %         plot(mu)
    %         figure
    %         plot(g)
    %         figure
    while (iter <= maxIterations)
        pause(0.001)
        
        [LDM_params, logL] = EMIteration(segments(i_tri), max_T, LDM_params);
        
        disp(strcat('iteration = ', num2str(iter), ' , logL = ', num2str(logL)));
        
        % log likelihood of validation data of this phone given the current
        % parameters
        %validLogL = valid_logL(LDM_params, model(i_tri).state);
        %disp(strcat('iteration = ', num2str(iteration), ' , ValidlogL = ', num2str(validLogL)));
        
        if (logL > bestLogL(i_tri))
            bestModel(i_tri).g1 = LDM_params.g1;
            bestModel(i_tri).Q1 = LDM_params.Q1;
            bestModel(i_tri).F  = LDM_params.F;
            bestModel(i_tri).g  = LDM_params.g;
            bestModel(i_tri).Q  = LDM_params.Q;
            bestModel(i_tri).H  = LDM_params.H;
            bestModel(i_tri).mu = LDM_params.mu;
            bestModel(i_tri).R  = LDM_params.R;
            
            bestLogL(i_tri)  = logL;
        end
        
        %plot(LDM_params.g)
        %plot(sort(eig(LDM_params.R)))
        
        iter = iter + 1;
    end
    
end
%close(wbar)

end

function [LDM_params, logL] = EMIteration(segment, max_T, LDM_params)
% Expectation maximization iteration
%   One iteration of EM on an LDM
%       Inputs:
%           segment : data corresponding to phone state to which LDM
%           belongs
%           max_t : maximum duration of segment in the training data
%           LDM_params : LDM parameters
%       outputs:
%           LDM_params : updated LDM parameters
%           logL : loglikelihood of the training data given this LDM

% Kalman smoother (E-step):
% Compute the sufficient statistics of the joint distribution of
% X1, ..., XT given data y1, ..., yT and parameters g1, Q1, F, g,
% Q, H, mu, R

g1 = LDM_params.g1;
Q1 = LDM_params.Q1;
F  = LDM_params.F;
g  = LDM_params.g;
Q  = LDM_params.Q;
H  = LDM_params.H;
mu = LDM_params.mu;
R  = LDM_params.R;
n  = length(g1);
m  = length(mu);

% Initialize statistics
stats = initializeStats(n,m);

logL = 0;

% pre-calulate the forward-backward pass data that is not dependant
% upon the observations upto the length of maximum duration of any segment
preCalculated = independentFwdRecursions(Q1, F, Q, H, R, max_T, n, m);

numSegments = size(segment.duration,1);

for i_seg = 1:numSegments
    % get one segment of observations
    begin_frame = segment.duration(i_seg,1);
    end_frame   = segment.duration(i_seg,2);
    T = end_frame - begin_frame + 1; % T is the length of current segment
    Y = (segment.mgc(:,begin_frame:end_frame));
    
    % ignore for now
    %(mean_var.(model(i_tri).state).std*ones(1,end_frame-begin_frame+1));...
    % - model.(model(i_tri).state).mu*eye(1,T); % y is the current segment
    
    % Forward recursions for statistics that depend upon
    % observations
    [forwardParams, segmentLogL] = ...
        dependantFwdRecursions(g1, F, g, H, mu, Y, T, preCalculated);
    logL = logL + segmentLogL;
    
    % Backward Recursions
    backwardParams = backwardRecursions(forwardParams, T, preCalculated);
    
    % compute the sufficient statistics
    [z0, z1, z2, z3, z4, G0, G1, G2, G3, G4, G5, G6] = ...
        computeSufficientStatistics(backwardParams, Y, n, m, T);
    
    % accumulate statistics
    stats.z0 = stats.z0 + z0;
    stats.z1 = stats.z1 + z1;
    stats.z2 = stats.z2 + z2;
    stats.z3 = stats.z3 + z3;
    stats.z4 = stats.z4 + z4;
    stats.G0 = stats.G0 + G0;
    stats.G1 = stats.G1 + G1;
    stats.G2 = stats.G2 + G2;
    stats.G3 = stats.G3 + G3;
    stats.G4 = stats.G4 + G4;
    stats.G5 = stats.G5 + G5;
    stats.G6 = stats.G6 + G6;
    stats.numSamples = stats.numSamples + T;
    stats.numSegments = stats.numSegments + 1;
end

% Update papameters (M-step):
% Update LDM parameters such that expected log-likelihood is maximized
LDM_params = updateParameters(stats, n, m);
end

function stats = initializeStats(n,m)
% Initialize the stats
% Inputs:
%       n: state dimension
%       m: observation dimension
% outputs:
%       stats: initialized stats structure

stats.z0 = zeros(n, 1);
stats.z1 = zeros(n, 1);
stats.z2 = zeros(n, 1);
stats.z3 = zeros(n, 1);
stats.z4 = zeros(m, 1);
stats.G0 = zeros(n, n);
stats.G1 = zeros(n, n);
stats.G2 = zeros(n, n);
stats.G3 = zeros(n, n);
stats.G4 = zeros(n, n);
stats.G5 = zeros(m, n);
stats.G6 = zeros(m, m);
stats.numSamples = 0;
stats.numSegments = 0;
end
