function forwardParams = independentFwdRecursions( Q1, F, Q, H, R, T, n, m)
% Independent forward recursions
%   Calculate the parameters in Forward recursions of Kalman filter that
%   are indepepndent of the observations. The function calculates the state
%   vector co-variances S_tgtm1 and S_tgt given the observations till t-1
%   and t respectively, error covariance Se_t and Kalman
%   Kalman gain K_t and backwards gain J_t
%   
%   inputs :
%           Q1 : Initial state co-variance
%           F  : State transition matrix
%           Q  : State noise process co-variance
%           H  : state space to observation space trasnform matrix
%           R  : observation noise process co-variance
%           T  : total number of recursions to do
%           n  : dimension of state vector
%           m  : dimension of observation vector
%
%   outputs :
%           forwardParams : structure of lenth T. forwardParams(t) contains
%           fields S_tgtm1, S_tgt, Se_t and K_t

%   author : Gagandeep Singh 2017
      



forwardInfo = struct('S_tgtm1', [], 'S_tgt', [], 'Se_t', [], 'K_t', [], 'J_t', []);

S_tm1gtm1 = eye(n);

S_tgtm1 = Q1;     % Initialize it to steady state value

forwardParams(1:T) = forwardInfo;

for t = 1:T
    % Prediction
    if (t > 1)
        S_tgtm1 = F*S_tgt*F' + Q;
        S_tgtm1 = (S_tgtm1+S_tgtm1')/2; % ensure symmetric covariance if 
        % not due to numerical inaccuracies.
        % By structure should be positive definte.
        
        if rank(S_tgtm1) < n
            S_tgtm1 = S_tgtm1 + 0.01*eye(2*n);
        end
    end
    
    
    Se_t = H*S_tgtm1*H' + R; % original one
    Se_t = (Se_t+Se_t')/2; % ensure symmetric covariance if 
    % not due to numerical inaccuracies.
    % By structure should be positive definte.
    
    if rank(Se_t) < m
        Se_t = Se_t + 0.01*eye(m);
    end
    
    if min(eig(Se_t)) < 0
        a = 1;
    end
    
    K_t = (S_tgtm1*H')/Se_t; % original eqn

%----------------------------------------------------------------------    
    %S_tgt = eye(n)/(eye(n)/S_tgtm1 + (H'/R)*H); % bayes filter
    
    %K_t = S_tgt*H'/R; % bayes filter
%----------------------------------------------------------------------
    % original eqn
    %S_tgt = S_tgtm1 - K_t*H*S_tgtm1; 
    
    % stabilized kalman filter
    S_tgt = (eye(n)-K_t*H)*S_tgtm1*(eye(n)-K_t*H)' + K_t*R*K_t'; 
    S_tgt = (S_tgt + S_tgt')/2;
    
    J_t = S_tm1gtm1*F'/S_tgtm1;
    
    % Store these values
    forwardParams(t).S_tgtm1 = S_tgtm1;
    forwardParams(t).S_tgt = S_tgt;
    forwardParams(t).Se_t = Se_t;
    forwardParams(t).K_t = K_t;
    forwardParams(t).J_t = J_t;
    
    S_tm1gtm1 = S_tgt;
end
end
