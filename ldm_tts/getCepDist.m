function cepDist = getCepDist(mgc1, mgc2)
% Get cepstral distance
%   get the cestral distance between pair of MGC sequence
% Inputs:
%       mgc1: mgc sequence 1
%		mgc2: mgc sequence 2
% Outputs:
%       cepDist: cepstral distance 

diff = mgc1-mgc2;
sqDist = sum(diff.^2,1);
rootSq = sqrt(sqDist);
cepDist = sum(rootSq)*10/(size(mgc1,2)*log(10));
end