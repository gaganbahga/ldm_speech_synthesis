function [forwardParams, logL] = forwardRecursions(g1, Q1, F, g, Q, H, mu, R, Y, T, n, m)
% forward recursions
%   Calculate the parameters in Forward recursions of Kalman filter.
%   Currently used only in validation, not in training
%   
%   inputs :
%           g1 : Initial state mean
%           Q1 : variance of inital state
%           F  : State transition matrix
%           g  : mean of state noise
%           Q  : variance of state noise
%           H  : state space to observation space trasnform matrix
%           mu : mean of observation noise
%           R  : variance of observation noise
%           Y  : observations
%           T  : total number of recursions to do
%
%   outputs :
%           forwardParams : forward recursions parameters
%           logL : log likelihood of the observations

%   author : Gagandeep Singh 2017

forwardInfo = struct('x_tgtm1', [], 'x_tgt', [], 'S_tgtm1', [], 'S_tgt', []);

x_tgtm1 = g1;     % Initialize.
S_tgtm1 = Q1;     % Initialize it to steady state value
logL    = 0;

forwardParams(1:T) = forwardInfo;

for t = 1:T
    % Prediction
    if (t > 1)
        x_tgtm1 = F*x_tgt + g;
        S_tgtm1 = F*S_tgt*F' + Q;
        S_tgtm1 = (S_tgtm1+S_tgtm1')/2; % ensure symmetric covariance if 
        % not due to numerical inaccuracies.
        % By structure should be positive definte.
        if rank(S_tgtm1) < n
            S_tgtm1 = S_tgtm1 + 0.01*eye(m);
        end
    end
    
    % Update
    e_t = Y(:, t) - H*x_tgtm1 - mu;
    
    Se_t = H*S_tgtm1*H' + R; % original one
    Se_t = (Se_t+Se_t')/2; % ensure symmetric covariance if 
    % not due to numerical inaccuracies.
    % By structure should be positive definte.
    
    if rank(Se_t) < m
        Se_t = Se_t + 0.01*eye(m);
    end
    
    K_t = (S_tgtm1*H')/Se_t; % original eqn

%----------------------------------------------------------------------    
    %S_tgt = eye(n)/(eye(n)/S_tgtm1 + (H'/R)*H); % bayes filter
    
    %K_t = S_tgt*H'/R; % bayes filter
%----------------------------------------------------------------------
    
    x_tgt = x_tgtm1 + K_t*e_t;
    
    %S_tgt = S_tgtm1 - K_t*H*S_tgtm1; % original eqn
    
    S_tgt = (eye(n)-K_t*H)*S_tgtm1*(eye(n)-K_t*H)' + K_t*R*K_t'; % stabilized kalman filter
    S_tgt = (S_tgt + S_tgt')/2;
    
    
    ct = gaussian_prob(e_t, zeros(1,length(e_t)), Se_t, 1);
    
    logL = logL + ct;

    % Store these values
    forwardParams(t).x_tgtm1 = x_tgtm1;
    forwardParams(t).x_tgt = x_tgt;
    forwardParams(t).S_tgtm1 = S_tgtm1;
    forwardParams(t).S_tgt = S_tgt;
end
end

