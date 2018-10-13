function globalVar = findglobalvar(mgcData)
% Find global variance
%   Find the global variance from the MGCs
%   
%   inputs :
%           mgcData : cell vector of length equal to number of files.
%           Each cell is a matrix of size m X N where m is the number of 
%           mgc coeffients extracted from each frame and N are the number 
%           of frames.
%   outputs :
%           globalVar : struct containing mean 'mu' and diagonal variance 
%           'sigma'

%   author : Gagandeep Singh 2017

v = zeros(size(mgcData{1},1),length(mgcData));

for iUtt = 1:length(mgcData)
    v(:, iUtt) = var(mgcData{iUtt},0,2);
end
globalVar.mu    = mean(v,2);
globalVar.sigma = diag(var(v,0,2));

end