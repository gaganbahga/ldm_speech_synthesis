function LDM_params = updateParameters(stats, n, m)
%Update parameters
%   update the parameters of an LDM in the maximization step of EM
%   algorithm.
%
%   Inputs:
%           stats: sufficient statistics calculated in the expectation step
%           for the training data
%           n: dimension of state vector
%           m: dimension of observation vector
%
%   Outputs:
%           LDM_params : updated LDM parameters

numSamples = stats.numSamples;
numSegments = stats.numSegments;
z0 = stats.z0;
z1 = stats.z1;
z2 = stats.z2;
z3 = stats.z3;
z4 = stats.z4;
G0 = stats.G0;
G1 = stats.G1;
G2 = stats.G2;
G3 = stats.G3;
G4 = stats.G4;
G5 = stats.G5;
G6 = stats.G6;

% inital state parameters
g1 = z0/numSegments;
%g1 = zeros(n,1);

Q1 = G0/numSegments - g1*g1';
% enforce symmetricity if violated by numerical inaccuracies
Q1 = (Q1+Q1')/2;
Q1 = Q1.*eye(n);

%Q1 = eye(n);

% Dynamics
F = (G4 - 1/(numSamples - numSegments)*z2*z1')/...
    (G1 - 1/(numSamples - numSegments)*(z1*z1'));



% ensuring that spectral radius of F is at most one
[u,s,v] = svd(F);
if any(any(s>1))
    s = s.*(s<1) + eye(n).*(s>1);
    F = u*s*v';
end
F = F.*eye(n);

% state noise
g = 1/(numSamples-numSegments)*(z2 - F*z1);
%g = zeros(n,1);

Q_temp = (1/(numSamples-numSegments))*(G2 - F*G4' - g*z2');
Q_temp = (Q_temp+Q_temp')/2;
[v,d] = eig(Q_temp);

% if Q is not positive-definite, change the eigenvalues to positive
if ~any(any(d<0))    
    Q = Q_temp;
else
    warning('Q is not positive-definite')
    d = d.*(d>0) + 0.001*eye(n).*(d<0);
    Q = v*d/v;
end
Q = Q.*eye(n);

% Q = eye(n);


% Observation - Factor analysis
% actual expression for H
H = (G5 - 1/numSamples*z4*z3')/(G3 - 1/numSamples*(z3*z3'));
% H tied to identity gives better results
% H = eye(m);

%mu = 1/numSamples*(z4 - H*z3);
mu = zeros(m,1);

% actual expression for R
R = (1/numSamples)*(G6 - H*G5' - mu*z4').*eye(m);
[~,d] = eig(R);
if any(any(d<0))
    warning('R is not positive-definite')
end
R = R.*(R > 0) + (R < 0).*eye(m)*0.001;
% Tying R to identity leads to reasonable log-likelihood values and
% convergence
% R = eye(m);


LDM_params.g1 = g1;
LDM_params.Q1 = Q1;
LDM_params.F  = F;
LDM_params.g  = g;
LDM_params.Q  = Q;
LDM_params.H  = H;
LDM_params.mu = mu;
LDM_params.R  = R;
end
