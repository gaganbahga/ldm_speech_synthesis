function model = initializemodel(data,type,stateId,H)
% Initialize Model
%   Initialize the acoustic model (LDM, SO-LDM or autoregressive HMM)
%
%   inputs :
%          data : struct which has mgcs as field
%          stateId : used as random seed for initialization
%          H : if H has been tied
%
%   outputs :
%          model : struct containing initialized LDMs
%

%   author : Gagandeep Singh 2017
params = getparameters();
m = params.m;
n = params.n;
mgcs = [data.mgc];
rng(stateId);


if strcmp(type, 'basicLDM')
    model.g1 = zeros(n,1);
        
    model.Q1 = eye(n);
        
    model.F = 0.9*eye(n);
    
    model.g = zeros(n,1);
        
    model.Q = eye(n);
    
    if ~exist('H','var')
        model.H = normrnd(0,0.5,m,n);
    else
        model.H = H;
    end
    
    if size(mgcs,2) == 0
        model.mu = zeros(m,1);
    else
        model.mu = mean(mgcs, 2);
    end
    
    model.R = eye(m);
    
elseif strcmp(type, 'autoReg')
    model.g1 = zeros(2*m,1);
    
    model.Q1 = eye(2*m);
    
    model.F = [eye(m), -0.1*eye(m);eye(m) zeros(m)];
        
    model.Q = eye(2*m);
    
    model.H = [eye(m) zeros(m)];
    
    if size(mgcs,2) == 0
        model.g = zeros(2*m,1);
    else
        model.g = [mean(mgcs, 2);zeros(m,1)];
    end
    
    model.mu = zeros(m,1);
    
    model.R = eye(m);
    
    
elseif strcmp(type, '2ndOrderLDM')
    
    model.g1 = zeros(2*n,1);
    
    model.Q1 = eye(2*n);
    
    model.F = [eye(n), -0.1*eye(n);eye(n) zeros(n)];
    
    model.g = zeros(2*n,1);
    
    model.Q = eye(2*n);
    
    if exist('H','var')
        model.H = H;
    else
        model.H = [normrnd(0,0.5,m,n) zeros(m,n)];
    end
    
    if size(mgcs,2) == 0
        model.mu = zeros(m,1);
    else
        model.mu = mean(mgcs, 2);
    end
    
    model.R = eye(m);
else
    error('Model type %s is not supported.\nCurrently supported models are: basicLDM, autoreg, 2ndOrderLDM',type)
end

end