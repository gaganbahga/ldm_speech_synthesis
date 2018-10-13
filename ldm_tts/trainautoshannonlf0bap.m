function [model, logL] = trainautoshannonlf0bap(data,model,type)
% Train an autoregressive HMM based on Matt Shannons implementation for lf0 and BAP.
%   All the notations correspond to the ones used in the thesis. The training method 
%   is the one followed by matt shannon et al., thus the name
% Inputs:
%       data : struct array with a field mgc that contains MGCs for a
%       particular segment of data
%       model : initial model. Doesn't serve much purpose in case of
%       autoregressive HMMs.
%       type : 'lf0' or 'bap'
% Outputs:
%       model: structure containing trained auoregressive HMM parameters
%       logL: maximum likelihood for data using the trained autoregressive
%       HMMs

% author : Gagandeep Singh 2017

params = getparameters();
%m = params.m;
m = params.(type).m;

w = [1 0; 0 1]; % each row corrsponds to a summarizer
wSize = size(w,2) + 1;
nSum = size(w,1);

R = zeros(nSum,nSum,m);
R_au = zeros(nSum,nSum,m);
r_d = zeros(m,nSum);
r_0 = zeros(m,1);
x_t = zeros(m,1);
f = zeros(m,nSum);
nUtt = 0;
T = 0;
maxlf0 = -Inf*ones(m,1);

for utt = 1:length(data)
    
    uttLen = size(data(utt).lf0bap,2);   % change here
    if uttLen < wSize
        continue
    else
        nUtt = nUtt + 1;
    end
    
    x_t_tau = zeros(m,uttLen - wSize + 1,wSize); %tau here refers to variable shift in the signal
    for shift = 1:wSize     % shift of 1 actually means no shift and so on
        x_t_tau(:,:,shift) = data(utt).lf0bap(wSize-shift+1:end-shift+1);
    end
    
    x_t = x_t + sum(x_t_tau(:,:,1),2);
    
    summary = zeros(m,uttLen - wSize + 1,nSum);
    for iSum = 1:nSum
        for shift = 1:wSize-1
            summary(:,:,iSum) = summary(:,:,iSum) + w(iSum,shift)*x_t_tau(:,:,shift+1) ;
        end
        f(:,iSum) = f(:,iSum) + sum(summary(:,:,iSum),2);
        r_d(:,iSum) = r_d(:,iSum) + sum(x_t_tau(:,:,1).*summary(:,:,iSum),2);
    end
    
    for dim = 1:m
        dimSum = squeeze(summary(dim,:,:));
        if size(dimSum,2) == 1
            dimSum = dimSum';
        end
        R(:,:,dim) = R(:,:,dim) + dimSum'*dimSum;
    end
    
    r_0 = r_0 + sum(x_t_tau(:,:,1).*x_t_tau(:,:,1),2);
    
    maxlf0 = max([maxlf0, abs(data(utt).lf0bap)]);
    
    T = T + size(x_t_tau,2);
    
end

if nUtt < 3
    R = 0.01*repmat(eye(2),1,1,m)+R;
end

R = R/T;
f = f/T;
r_0 = r_0/T;
r_d = r_d/T;
x_t = x_t/T;

r_d = r_d - (x_t * ones(1,nSum)).*f;
r_0 = r_0 - x_t.*x_t;

for dim = 1:m
    c = R(:,:,dim) - f(dim,:)'*f(dim,:);
    R_au(:,:,dim) = c;
    
end

R_au1 = R_au;

A = zeros(nSum,m);

for dim = 1:m
    A(:,dim) = inv(R_au(:,:,dim))*(r_d(dim,:))';
end

g = [x_t; zeros((wSize-2)*m,1)];

F = zeros((wSize-1)*m);
F(m+1:(wSize-1)*m,1:(wSize-2)*m) = eye((wSize-2)*m);
for i = 1:wSize-1
    for j = 1:nSum
        F(1:m,(i-1)*m+1:i*m) = F(1:m,(i-1)*m+1:i*m) + w(j,i)*diag(A(j,:));
    end
end

specRad = max(abs(eig(F)));
if specRad > 1
    numIts = 27;
    lambda = 0.01;
    it = 1;
    while ((it <= numIts) && (specRad > 1))
        R_au = R_au + lambda*repmat(eye(2),[1,1,m]);
        F = constructF(R_au, r_d);
        specRad = max(abs(eig(F)));
        it = it + 1;
        lambda = 2*lambda;
    end
    
    if (specRad < 1)
        lambda1 = lambda/2;
        while (lambda1 >= lambda/4)
            R_au = R_au + lambda1*repmat(eye(2),[1,1,m]);
            F = constructF(R_au, r_d);
            specRad = max(abs(eig(F)));
            if (specRad < 1)
                lambda1 = lambda1 - lambda/200;
            else
                lambda1 = lambda1 + lambda/200;
                R_au = R_au + lambda1*repmat(eye(2),[1,1,m]);
                F = constructF(R_au, r_d);
                specRad = max(abs(eig(F)));
                break;
            end
        end
        
    end
    
    if (specRad > 1)
        F1 = constructF(R_au1, r_d);
        if (max(abs(eig(F1))) < specRad)
            F = F1;
        end
        
    end
end

for i = 1:wSize-1
    g = -[F(1:m,(i-1)*m+1:i*m)*f(:,i); zeros((wSize-2)*m,1)] + g;
end

var = r_0 - sum(A'.*r_d,2);
logL = -0.5*T*sum(log(var));

if any(var < 0)
    a = 1;
end

model.F = F;
model.g = g;
model.R = diag(var);

return
end

function F = constructF(R_au, r_d)
m = size(R_au,3);
A = zeros(2,m);
for dim = 1:m
    A(:,dim) = inv(R_au(:,:,dim))*(r_d(dim,:))';
end
F = zeros(2*m);
F(m+1:2*m,1:m) = eye(m);
F(1:m,1:m) = diag(A(1,:));
F(1:m,m+1:2*m) = diag(A(2,:));
end

function target = gettarget(R, r_d, f,x_t)
deno = 1 - ( R(2,2)*r_d(1) - R(1,2)*r_d(2) - R(2,1)*r_d(1) + R(1,1)*r_d(2) )...
    /(R(1,1)*R(2,2) - R(1,2)*R(2,1));
A = pinv(R)*r_d';
num = -A(1)*f(1) - A(2)*f(2) + x_t;
target = num/deno;
end