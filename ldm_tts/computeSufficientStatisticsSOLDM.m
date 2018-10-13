function stats = computeSufficientStatisticsSOLDM(backwardParams, Y, n, m, T)
% compute sufficient statistics for second order LDMs 
%   Calculate the parameters in Forward recursions of Kalman filter.
%   Currently used only in validation and synthesis, not in training
%   
%   inputs :
%           backwardParams : parameters calculated from backward recursions
%           Y : sequence of observations
%           n : state space dimension
%           m : observation space dimension
%			T : no of observations
%
%   outputs :
%           stats : suficient stats

%   author : Gagandeep Singh 2017
z0 = backwardParams(1).x_tgT;
z1 = zeros(2*n, 1);
for t = 2:T-1
    z1 = z1 + backwardParams(t).x_tgT;
end

if (T > 1)
    z2 = z1 + backwardParams(T).x_tgT; % sum 2:T
    z1 = z1 + backwardParams(1).x_tgT; % sum 1:T-1
end
z3 = z1 + backwardParams(T).x_tgT; % sum 1:T
stats.z4 = sum(Y, 2); % sum 1:T

% in case of second order LDMs
stats.z5 = z0(n+1:end);
stats.z6 = z1(n+1:end);

stats.z0 = z0(1:n);
stats.z1 = z1(1:n);
stats.z2 = z2(1:n);
stats.z3 = z3(1:n);

G0 = backwardParams(1).P_tgT;
G1 = zeros(2*n, 2*n);
G4 = zeros(2*n, 2*n);
G5 = zeros(m, 2*n);
for t = 1:T-1
    G1 = G1 + backwardParams(t).P_tgT;          % sum 1:T-1
    G4 = G4 + backwardParams(t+1).P_t_tm1gT;    % sum 2:T
    G5 = G5 + Y(:, t)*backwardParams(t).x_tgT'; % sum 1:T-1
end
G3 = G1 + backwardParams(T).P_tgT; % sum 1:T
G2 = G3 - backwardParams(1).P_tgT; % sum 2:T
G5 = G5 + Y(:, T)*backwardParams(T).x_tgT'; % sum 1:T
stats.G6 = Y*Y'; % sum 1:T

% in case of second order LDMs
stats.G7  = G0(n+1:end,n+1:end);
stats.G10 = G1(n+1:end,n+1:end);
stats.G8  = G4(n+1:end,n+1:end);
stats.G9  = G4(1:n,n+1:end);

stats.G0 = G0(1:n,1:n);
stats.G1 = G1(1:n,1:n);
stats.G2 = G2(1:n,1:n);
stats.G3 = G3(1:n,1:n);
stats.G4 = G4(1:n,1:n);
stats.G5 = G5(1:m,1:n);

end