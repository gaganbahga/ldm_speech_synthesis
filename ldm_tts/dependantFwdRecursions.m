function [forwardParams, logL] = dependantFwdRecursions(g1, F, g, H, mu, Y, T, preCalculatedParams)
% Dependent forward recursions
%   Calculate the parameters in Forward recursions of Kalman filter that
%   depend on the observations. The function calculates the error vector 
%   e_t, state vector x_tgt, x_tgtm1 given the observations till t and t-1
%   respectively. It also calculates the log-likelihood of the semgent of
%   observations
%   
%   inputs :
%           g1 : Initial state mean
%           F  : State transition matrix
%           H  : state space to observation space trasnform matrix
%           mu : mean of observation noise
%           T  : total number of recursions to do
%           preCalculatedParams : forward recursion parameters that have
%           been calculated in independentFwdRecursions
%
%   outputs :
%           forwardParams : structure of lenth T. forwardParams(t) contains
%           fields S_tgtm1, S_tgt, Se_t x_tgt and x_tgtm1
%           logL : log likelihood of the observations

%   author : Gagandeep Singh 2017

forwardInfo = struct('x_tgtm1', [], 'x_tgt', [], 'S_tgtm1', [], 'S_tgt', []);

x_tgtm1 = g1;     % Initialize.
logL = 0;

forwardParams(1:T) = forwardInfo;

for t = 1:T
    % Prediction
    if (t > 1)
        x_tgtm1 = F*x_tgt + g;
    end
    
    % Update
    e_t = Y(:, t) - H*x_tgtm1 - mu;
    
    Se_t = preCalculatedParams(t).Se_t;
    
    K_t = preCalculatedParams(t).K_t;
 
    x_tgt = x_tgtm1 + K_t*e_t;
    
    ct = gaussian_prob(e_t, zeros(1,length(e_t)), Se_t, 1);
    
    logL = logL + ct;

    % Store these values
    forwardParams(t).x_tgtm1 = x_tgtm1;
    forwardParams(t).x_tgt = x_tgt;
    forwardParams(t).S_tgtm1 = preCalculatedParams(t).S_tgtm1;
    forwardParams(t).S_tgt = preCalculatedParams(t).S_tgt;
end
if logL < 0
    a = 1;
end
end