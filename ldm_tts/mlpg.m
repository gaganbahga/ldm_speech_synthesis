function Y = mlpg(Y,var)
% maximum likelihood parameter generation
%   call a python script for mlpg
% Inputs:
%       Y: observation vectors
%       var: variance
% Outputs:
%       Y: observation vectors

%   author : Gagandeep Singh 2017

m = 40;
T = size(Y,2);
W = zeros(3*T,T);
W(1,1) = 1;
W(2,2) = -0.5;
W(3,1:2) = [2 -1];
W(end,end-1:end) = [-1 2];
W(end-1,end-1) = -0.5;
W(end-2,end) = 1;

for t = 1:T-2
    W(3*t+1,t:t+2) = [0 1 0];
    W(3*t+2,t:t+2) = [-0.5 0 0.5];
    W(3*t+3,t:t+2) = [-1 2 -1];
end

W = repelem(W,m,m);

Uinv = zeros(3*m*T);
for i = 0:size(var,2)-1
    Uinv(i*3*m+1:3*m*(i+1),i*3*m+1:3*m*(i+1)) = inv(diag(var(:,i+1)));
end

Y = reshape(Y,[3*m*T,1]);

Y = (W'*Uinv*W)\(W'*Uinv*Y');

end