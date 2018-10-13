function [bestSeq, finalLogL] = viterbildm(Y,models,nSegments,depth)
% Viteri LDM
%   Find the best sequence of LDM states using a viterbi like alggorithm
%   The obsertion sequence is assumed to be generated by a three LDMs taken in order
%   (no repetition). Each observation is produced by one of these 3 LDMs which
%   we calculate along with the logL o generating this sequence. 
%   
%   inputs :
%           Y : Observation sequence
%           models : struct array of LDM models 
%           nSegments: number of segments (3 by default) 
%           depth: how far back in time to go in the algorithm to find the likelihood
%           at a particular point of time
%
%   outputs :
%           bestSeq : sequence of LDMs which provides maximum log-likelihood
%           finalLogL: final (best) log likelihood of the sequence

%   author : Gagandeep Singh 2017

% the code is a little convoluted, try not to mess much
params = getparameters();
n = 2*params.n;
T = size(Y,2);

delta = -Inf*ones(T,nSegments);
psi = zeros(T,nSegments);
xMeans = zeros(n,T,nSegments);
xCovariances = zeros(n,n,T,nSegments);

%for j = 1:nSegments
j = 1;
[g1,Q1,~,H,~,~,mu,R] = getparameters_(models,j);
x_tgtm1 = g1;
S_tgtm1 = Q1;
e_t = Y(:,1) - H*x_tgtm1 - mu;
Se_t = H*S_tgtm1*H' + R;
Se_t = (Se_t+Se_t')/2;
K_t = (S_tgtm1*H')/Se_t;
x_tgt = x_tgtm1 + K_t*e_t;
S_tgt = (eye(length(g1))-K_t*H)*S_tgtm1*(eye(length(g1))-K_t*H)' + K_t*R*K_t'; % stabilized kalman filter
S_tgt = (S_tgt + S_tgt')/2;

xMeans(:,1,j) = x_tgt;
xCovariances(:,:,1,j) = S_tgt;
delta(1,j) = gaussian_prob(e_t, zeros(1,length(e_t)), Se_t, 1);
%end

for j = 2:nSegments
    delta(1,j) = -Inf;
end

for t = 2:T

    %wbar = waitbar(t/T);
    actDepth = min(depth,t-1);         % actual depth will be less in the beginning
    for endState = 1:min(nSegments,t)  % at time t, the segments cannot be greater than t
        minBeginState = max(endState-actDepth,1);
        diffBeginStateLogL = zeros(1,endState-minBeginState+1);
        diffBeginStateXMean = zeros(n,endState-minBeginState+1);
        diffBeginStateXCov  = zeros(n,n,endState-minBeginState+1);
        bestPaths = zeros(actDepth+1,endState-minBeginState+1);
        beginStateId = 0;
        for beginState = minBeginState:endState
            beginStateId = beginStateId + 1;
            
            nTransitions = endState-beginState;
            possibleTransPlaces = 1:actDepth;
            
            transPlaces = nchoosek(possibleTransPlaces,nTransitions);
            if isempty(transPlaces)
                transPlaces = zeros(actDepth,1);
            end
            diffPathXMean = zeros(n,size(transPlaces,1));
            diffPathXCov  = zeros(n,n,size(transPlaces,1));
            diffPathLogL = zeros(size(transPlaces,1),1);
            for pathId = 1:size(transPlaces,1)
                path = getPath(transPlaces(pathId,:),actDepth,beginState,endState);
                x_tgt = xMeans(:,t-actDepth,beginState);
                S_tgt = xCovariances(:,:,t-actDepth,beginState);
                prevSegment = beginState;
                %[g1,Q1,F,H,g,Q,mu,R] = getparameters_(models,path(1));
                for k = 2:actDepth+1
                    [g1,Q1,F,H,g,Q,mu,R] = getparameters_(models,path(k));
                    
                    if path(k) ~= prevSegment
                        x_tgtm1 = g1;
                        S_tgtm1 = Q1;
                    else
                        x_tgtm1 = F*x_tgt + g;
                        S_tgtm1 = F*S_tgt*F' + Q;
                    end
                    prevSegment = path(k);
                    S_tgtm1 = (S_tgtm1+S_tgtm1')/2;
                    e_t = Y(:, t-actDepth+k-1) - H*x_tgtm1 - mu;
                    Se_t = H*S_tgtm1*H' + R;
                    Se_t = (Se_t+Se_t')/2;
                    K_t = (S_tgtm1*H')/Se_t;
                    x_tgt = x_tgtm1 + K_t*e_t;
                    S_tgt = (eye(n)-K_t*H)*S_tgtm1*(eye(n)-K_t*H)' + K_t*R*K_t'; % stabilized kalman filter
                    S_tgt = (S_tgt + S_tgt')/2;
                    
                    diffPathLogL(pathId) = diffPathLogL(pathId) + ...
                        gaussian_prob(e_t, zeros(1,length(e_t)), Se_t, 1);
                    
                end
                diffPathXMean(:,pathId)  = x_tgt;
                diffPathXCov(:,:,pathId) = S_tgt;
            end
            [diffBeginStateLogL(beginStateId),bestPathIndex] = max(diffPathLogL)  ;
            bestPaths(:,beginStateId) = getPath(transPlaces(bestPathIndex,:),actDepth,beginState,endState);
            diffBeginStateXMean(:,beginStateId)  = diffPathXMean(:,bestPathIndex);
            diffBeginStateXCov(:,:,beginStateId) = diffPathXCov(:,:,bestPathIndex);
        end
        [bestLogL,bestInitialState] = max(diffBeginStateLogL + delta(t-actDepth,minBeginState:endState));
        bestPreviousState = bestPaths(max(1,end-1),bestInitialState);
        delta(t,endState) = bestLogL;
        psi(t,endState) = bestPreviousState;
        xMeans(:,t,endState) = diffBeginStateXMean(:,bestInitialState);
        xCovariances(:,:,t,endState) = diffBeginStateXCov(:,:,bestInitialState);
    end
end
%close(wbar)

finalLogL = delta(T,nSegments);

bestSeq = backTrack(psi,T,nSegments);

end

function states = backTrack(psi,T,nSegments)
    states = zeros(T,1);
    states(T) = min(nSegments,T);
    for t = T-1:-1:1
        states(t) = psi(t+1,states(t+1));
    end
end

function [g1,Q1,F,H,g,Q,mu,R] = getparameters_(models,j)
g1 = models(j).g1;
Q1 = models(j).Q1;
F = models(j).F;
H = models(j).H;
g = models(j).g;
Q = models(j).Q;
mu = models(j).mu;
R = models(j).R;
end

function path = getPath(transPlaces,depth,beginState,endState)

if isequal(transPlaces, zeros(depth,1) )
    path = beginState*ones(depth+1,1);
    return
end

path = zeros(depth+1,1);
transDone = 0;
pathFilled = 0;
currentState = beginState;
while transDone < length(transPlaces)
    path(pathFilled+1:transPlaces(transDone+1)) = currentState;
    transDone = transDone+1;
    pathFilled = transPlaces(transDone);
    currentState = currentState+1;
end
path(pathFilled+1:end) = endState;
%path = path(2:end);
end