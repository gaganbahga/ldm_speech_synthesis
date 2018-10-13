function createparpool(numWorkers)
% Create parallel pool
%   create pool of parallel workers
%   inputs :
%          numWorkers : number of CPU cores

% author : Gagandeep Singh 2017

if isempty(gcp('nocreate'))
    params = getparameters();
    numWorkers = min(params.maxNoWorkers,numWorkers);
    c = parcluster;
    c.NumWorkers = numWorkers;
    parpool(numWorkers)
else
    disp('parpool is already running. You may close it with ''delete(gcp(''nocreate''))'' and start again')
end
end