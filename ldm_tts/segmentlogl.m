function logL = segmentlogl(Y, duration, models)
% segment log-likelihood
%   calculate the loglikelihood of a segment
% Inputs:
%       Y: observation sequence
%       duration: duration array of three states
%       models: model of three states
% Outputs:
%       logL: log likelihood

%   author : Gagandeep Singh 2017

logL = 0;
begin = 1;
for i = 1:3
    data = Y(:,begin:begin + duration(i) - 1);
    begin = begin + duration(i);
    g1 = models(i).g1;
    Q1 = models(i).Q1;
    F = models(i).F;
    g = models(i).g;
    Q = models(i).Q;
    H = models(i).H;
    mu = models(i).mu;
    R = models(i).R;
    n = length(g);
    m = length(mu);
    maxT = size(data,2);
    preCalculated = independentFwdRecursions(Q1, F, Q, H, R, maxT, n, m);
    [~, subsegLogL] = dependantFwdRecursions(g1, F, g, H, mu,...
            data, maxT, preCalculated);
    logL = logL + subsegLogL;
end
end