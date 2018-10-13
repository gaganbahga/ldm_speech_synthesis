function [bestModel, bestLogL] = trainautodamp(data,bestModel)
% Train Linear Dynamical Model
%   train a damped autoregressive HMM model given data. This hasn't been
%   studied thoroughly
% Inputs:
%       data : struct array with a field mgc that contains MGCs for a
%       particular segment of data
%       bestModel: initial model to initialize (not used much in autoregressive HMMs)
% Outputs:
%       bestModel: structure containing trained LDM parameters
%       bestLogL: maximum likelihood for data using the trained LDM

% author : Gagandeep Singh 2017


% initialize
%bestModel = initialize_model(data,m,n);
params = getparameters();
m = params.m;
bestLogL  = -Inf;

R = zeros(3,3,m);
x_t_T = zeros(m,3);
T = 0;
x_2 = zeros(2*m,length(data));

for utt = 1:length(data)
    
    if size(data(utt).mgc,2) < 3
        continue
    end
    x_t_2 = data(utt).mgc(:,1:end-2);
    x_t_1 = data(utt).mgc(:,2:end-1);
    x_t = data(utt).mgc(:,3:end);
    
    x_2(:,utt) = [x_t_1(:,1) ; x_t_2(:,1)] ;
    
    for dim = 1:m
        x_012 = [x_t(dim,:); x_t_1(dim,:); x_t_2(dim,:)];
        R(:,:,dim) = R(:,:,dim) + x_012*x_012';
    end
    
    x_t_T(:,1) = x_t_T(:,1) + sum(x_t,2);
    x_t_T(:,2) = x_t_T(:,2) + sum(x_t_1,2);
    x_t_T(:,3) = x_t_T(:,3) + sum(x_t_2,2);
    
    T = T + size(x_t,2);
    
end

R = R/T;
x_t_T = x_t_T/T;

gamma = 0.4*ones(m,1);
%tau = ones(m,1);

for iter = 1:10
    tau = ( (gamma.^2).* x_t_T(:,3) -2*gamma.*x_t_T(:,2) + x_t_T(:,1) )./(1-gamma.^2);
    
    a = squeeze(R(3,3,:)) - 2*tau.*x_t_T(:,3) + tau.^2;
    b = -3*squeeze(R(3,2,:)) + 3*T.*x_t_T(:,2) + 3*tau.*x_t_T(:,3) -3*tau.^(2);
    c = squeeze(R(3,1,:)) - tau.*x_t_T(:,1) + 2*squeeze(R(2,2,:)) - 4*tau.*x_t_T(:,2) - tau.*x_t_T(:,3) + 3*tau.^2;
    d = -squeeze(R(2,1,:)) + x_t_T(:,1).*tau + x_t_T(:,2).*tau - tau.^2;
    
    for dim = 1:m
        root  = roots([a(dim),b(dim),c(dim),d(dim)] );
        for i = 1:3
            if isreal(root(i)) && root(i)<1 && root(i) > 0
                gamma(dim) = root(i);
                break
            end
        end
    end
    
end

% A = zeros(2,m);
% 
% for dim = 1:m
%     A(:,dim) = inv(R_au(2:3,2:3,dim))*R_au(2:3,1,dim);
%     if abs(A(1,dim)+A(2,dim) - 1) < 1e-2
%         A(1,dim) = A(1,dim) + 0.02;
%     end
% end

g = [x_t_T(:,1); zeros(m,1)];

%mu = [x_t_T(:,2); x_t_T(:,3)];

F = [diag(2*gamma),diag(-gamma.^2); eye(m),zeros(m)];

%l1 = (a1 + sqrt(a1.^2 + 4*a2))/2;
%l2 = (a1 - sqrt(a1.^2 + 4*a2))/2;

g = (1-gamma).^2.*tau;
g = [g;zeros(m,1)];
% g = [-F(1:m,1:m)*x_t_T(:,2); zeros(m,1)] - [F(1:m,m+1:2*m)*x_t_T(:,3); zeros(m,1)] + g;

g1 = zeros(2*m,1);%mean(inv(F)*(x_2 - g*ones(1,length(data))), 2);

% a1 = diag(F(1:m,1:m));
% a2 = diag(F(1:m,m+1:2*m));
% 
% l1 = (a1 + sqrt(a1.^2 + 4*a2))/2;
% l2 = (a1 - sqrt(a1.^2 + 4*a2))/2;
% 
% l1 = 0.9*(l1 > 1) + (l1 < 1).*l1;
% l1 = -0.9*(l1 <-1) + (l1 > -1).*l1;
% 
% l2 = 0.9*(l2 > 1) + (l2 < 1).*l2;
% l2 = -0.9*(l2 <-1) + (l2 > -1).*l2;
% 
% a1 = l1 + l2;
% a2 = -l1.*l2;
% 
% F = [diag(a1), diag(a2);eye(m),zeros(m)];

bestModel.F = F;
bestModel.g = g;
bestModel.g1 = g1;

return
end