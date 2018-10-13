function stats = computeSufficientStatisticsLDM(backwardParams, Y, n, m, T)
% compute sufficient statistics
%   Calculate the parameters in Forward recursions of Kalman filter.
%   Currently used only in validation and synthesis, not in training
%   
%   inputs :
%           backwardParams : parameters calculated from backward recursions
%           Y : sequence of observations
%           n : state space dimension
%           m : observation space 
%           T : number of observations
%
%   outputs :
%           stats : suficient stats

%   author : Gagandeep Singh 2017
    z1 = zeros(n, 1);
    for t = 2:T-1
        z1 = z1 + backwardParams(t).x_tgT;
    end 
    
    if (T > 1)
        z2 = z1 + backwardParams(T).x_tgT; % sum 2:T
        z1 = z1 + backwardParams(1).x_tgT; % sum 1:T-1
    end
    z3 = z1 + backwardParams(T).x_tgT; % sum 1:T
    z4 = sum(Y, 2); % sum 1:T

    G1 = zeros(n, n);
    G2 = zeros(n, n);
    G3 = zeros(n, n);
    G4 = zeros(n, n);
    G5 = zeros(m, n);
    for t = 1:T-1
        G1 = G1 + backwardParams(t).P_tgT;          % sum 1:T-1
        G4 = G4 + backwardParams(t+1).P_t_tm1gT;    % sum 2:T
        G5 = G5 + Y(:, t)*backwardParams(t).x_tgT'; % sum 1:T-1
    end
    G3 = G1 + backwardParams(T).P_tgT; % sum 1:T
    G2 = G3 - backwardParams(1).P_tgT; % sum 2:T 
    G5 = G5 + Y(:, T)*backwardParams(T).x_tgT'; % sum 1:T
    G6 = Y*Y'; % sum 1:T
    
    z0 = backwardParams(1).x_tgT;
    G0 = backwardParams(1).P_tgT;
    stats.z0 = z0;
    stats.z1 = z1;
    stats.z2 = z2;
    stats.z3 = z3;
    stats.z4 = z4;
    stats.G0 = G0;
    stats.G1 = G1;
    stats.G2 = G2;
    stats.G3 = G3;
    stats.G4 = G4;
    stats.G5 = G5;
    stats.G6 = G6;
end
