function [bestModel, bestLogL] = trainldm(data,bestModel,modelType)
% Train Linear Dynamical Model
%   train a linear dynamical model given data
%   inputs:
%           data : struct array with a field mgc that contains MGCs for a
%           particular segment of data
%           bestModel : initial model
%           modelType : basicLDM or 2ndOrderLDM
%   outputs:
%           bestModel : structure containing trained LDM parameters
%           bestLogL : maximum likelihood for data using the trained LDM

% author : Gagandeep Singh 2017

params    = getparameters();
diagonal  = params.diagonalF;
tieH      = params.tieH;
damp_sys  = params.damp_sys;
bestLogL  = -Inf;

iterRemain = params.maxIterations;
maxBufIter = params.maxBufIter;
bufIterRem = Inf;
prevLogL   = intmin;

iter = 1;

LDMParams = bestModel;

% maximum size of any segment
max_T = max(cellfun('size',{data.mgc},2));
if max_T < 2
    return; % if none of the segments are larger than 1, model cannot be learned
end

while (min(iterRemain,bufIterRem) > 0)
    
    [LDMParams, logL] = EMIteration(data, max_T, LDMParams,modelType, diagonal,tieH,damp_sys);
    
    stopCrit = abs(2*(logL - prevLogL)/(logL + prevLogL));
    
    if stopCrit < 1e-4
        if bufIterRem == Inf
            bufIterRem = maxBufIter;
        else
            bufIterRem = bufIterRem - 1;
        end
    else
        bufIterRem = Inf;
    end
    
    disp(strcat('iteration = ', num2str(iter), ' , logL = ', num2str(logL)));
    
    if (logL > bestLogL)
        bestModel = LDMParams; 
        bestLogL  = logL;
    end
    
    prevLogL = logL;
    iter = iter + 1;
    iterRemain = iterRemain - 1;
end

end


function [LDMParams, logL] = EMIteration(data,max_T,LDMParams,modelType,diagonal,tieH,damp_sys)
% Expectation maximization iteration
%   One iteration of EM on an LDM
%       Inputs:
%           data
%           max_t : maximum duration of segment in the training data
%           LDMParams : LDM parameters
%       outputs:
%           LDMParams : updated LDM parameters
%           logL : loglikelihood of data given this LDM

% Kalman smoother (E-step):
% Compute the sufficient statistics of the joint distribution of
% X1, ..., XT given data y1, ..., yT and parameters g1, Q1, F, g,
% Q, H, mu, R

g1 = LDMParams.g1;
Q1 = LDMParams.Q1;
F  = LDMParams.F;
g  = LDMParams.g;
Q  = LDMParams.Q;
H  = LDMParams.H;
mu = LDMParams.mu;
R  = LDMParams.R;
m  = length(mu);
n  = length(g1);

% pre-calulate the forward-backward pass data that is not dependant
% upon the observations upto the length of maximum duration of any segment
preCalculated = independentFwdRecursions(Q1, F, Q, H, R, max_T, n, m);
    
if strcmp(modelType,'2ndOrderLDM')
    n  = length(g1)/2;
end

% Initialize statistics
stats = initializeStats(modelType,n,m);

logL = 0;

for i_seg = 1:length(data)

    T = size(data(i_seg).mgc,2);
    if T < 2
        continue
    end
    % Forward recursions for statistics that depend upon
    % observations
    [forwardParams, segmentLogL] = dependantFwdRecursions(g1, F, g, H, mu,...
        data(i_seg).mgc, T, preCalculated);
    logL = logL + segmentLogL;
    
    % Backward Recursions
    backwardParams = backwardRecursions(forwardParams, T, preCalculated);
    
    % compute the sufficient statistics
    if strcmp(modelType,'2ndOrderLDM')
        newStats = computeSufficientStatisticsSOLDM(backwardParams, data(i_seg).mgc, n, m, T);
    elseif strcmp(modelType,'basicLDM')
        newStats = computeSufficientStatisticsLDM(backwardParams, data(i_seg).mgc, n, m, T);
    end
    % accumulate statistics
    stats.z0 = stats.z0 + newStats.z0;
    stats.z1 = stats.z1 + newStats.z1;
    stats.z2 = stats.z2 + newStats.z2;
    stats.z3 = stats.z3 + newStats.z3;
    stats.z4 = stats.z4 + newStats.z4;
    stats.G0 = stats.G0 + newStats.G0;
    stats.G1 = stats.G1 + newStats.G1;
    stats.G2 = stats.G2 + newStats.G2;
    stats.G3 = stats.G3 + newStats.G3;
    stats.G4 = stats.G4 + newStats.G4;
    stats.G5 = stats.G5 + newStats.G5;
    stats.G6 = stats.G6 + newStats.G6;
    if strcmp(modelType,'2ndOrderLDM')
        stats.z5 = stats.z5 + newStats.z5;
        stats.z6 = stats.z6 + newStats.z6;
        stats.G7 = stats.G7 + newStats.G7;
        stats.G8 = stats.G8 + newStats.G8;
        stats.G9 = stats.G9 + newStats.G9;
        stats.G10 = stats.G10 + newStats.G10;
    end
    stats.numSamples = stats.numSamples + T;
    stats.numSegments = stats.numSegments + 1;
    
end

% Update papameters (M-step):
% Update LDM parameters such that expected log-likelihood is maximized

if strcmp(modelType, '2ndOrderLDM')
    if damp_sys
        if tieH
            %LDM_params = updateParametersVT(stats, n, m, F,diagonal,H);
            LDMParams = updateParametersDampLDM(stats, n, m, F,diagonal, H);
        else
            LDMParams = updateParametersDampLDM(stats, n, m, F,diagonal);
        end
    else
        if tieH
            LDMParams = updateParametersSOLDM(stats, n, m, F,diagonal, H);
        else
            LDMParams = updateParametersSOLDM(stats, n, m, F,diagonal);
            %LDM_params = updateParametersNew(stats, n, m,F,H,diagonal);
        end
    end
elseif strcmp(modelType, 'basicLDM')
    LDMParams = updateParametersLDM(stats, n, m);
end

end

function stats = initializeStats(modelType,n,m)
% Initialize the stats
% Inputs:
%       modelType
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

if strcmp(modelType,'2ndOrderLDM')
    stats.z5 = zeros(n, 1);
    stats.z6 = zeros(n, 1);
    stats.G7 = zeros(n, n);
    stats.G8 = zeros(n, n);
    stats.G9 = zeros(n, n);
    stats.G10 = zeros(n, n);
end

stats.numSamples = 0;
stats.numSegments = 0;
end