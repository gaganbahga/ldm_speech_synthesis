function p = gaussian_prob(x, m, C, use_log)
% GAUSSIAN_PROB Evaluate a multivariate Gaussian density.
% p = gaussian_prob(X, m, C)
% p(i) = N(X(:,i), m, C) where C = covariance matrix and each COLUMN of x is a datavector

% p = gaussian_prob(X, m, C, 1) returns log N(X(:,i), m, C) (to prevents underflow).
%

if nargin < 4, use_log = 0; end

x = x(:);

[d, ~] = size(x);
%assert(length(m)==d); % slow
m = m(:);
denom = (2*pi)^(d/2)*sqrt(abs(det(C)));

mahal = ((x-m)'/C)*(x-m);   
if any(mahal<0)
  warning('%f',mahal)
  warning('mahal < 0 => C is not psd')
end
if use_log
  p = -0.5*mahal - log(denom);
else
  p = exp(-0.5*mahal) / (denom+eps);
end
