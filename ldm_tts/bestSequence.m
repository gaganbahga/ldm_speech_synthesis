function [bestSeq, bestLogL] = bestSequence(Y,models,nSegments)
% best sequence
%   inds the best sequence of LDMs for a given set of observations
%   
%   inputs :
%           Y : matrix of observation vectors
%           T : cell array of potential LDMs in order
%           nSegments : total number of segments to divide to
%
%   outputs :
%           bestSeq : best LDM sequence
%			bestLogL : logL of this sequence

%   author : Gagandeep Singh 2017
n = 2*10;
T = size(Y,2);
if nSegments > T
    nSegments = T;
end

[g1,Q1,~,H,~,~,mu,R] = getparameters(models,1);
x_1g0 = g1;
S_1g0 = Q1;
e_1 = Y(:,1) - H*x_1g0 - mu;
Se_1 = H*S_1g0*H' + R;
Se_1 = (Se_1+Se_1')/2;
K_1 = (S_1g0*H')/Se_1;
x_1g1 = x_1g0 + K_1*e_1;
S_1g1 = (eye(n)-K_1*H)*S_1g0*(eye(n)-K_1*H)' + K_1*R*K_1'; % stabilized kalman filter
S_1g1 = (S_1g1 + S_1g1')/2;

logL_1 = gaussian_prob(e_1, zeros(1,length(e_1)), Se_1, 1);

possibleTransPlaces = 1:T-1;

transPlaces = nchoosek(possibleTransPlaces,nSegments-1)';

diffPathLogL = logL_1*ones(size(transPlaces,2),1);
pathId = 0;
for transPlace = transPlaces
    pathId = pathId + 1;
    path = getPath(transPlace,T-1,1,nSegments);
    prevSegment = 1;
    %[g1,Q1,F,H,g,Q,mu,R] = getparameters(models,path(1));
    x_tgt = x_1g1;
    S_tgt = S_1g1;
    
    for t = 2:T
        [g1,Q1,F,H,g,Q,mu,R] = getparameters(models,path(t));
        if path(t) ~= prevSegment
            x_tgtm1 = g1;
            S_tgtm1 = Q1;
        else
            x_tgtm1 = F*x_tgt + g;
            S_tgtm1 = F*S_tgt*F' + Q;
        end
        prevSegment = path(t);
        S_tgtm1 = (S_tgtm1+S_tgtm1')/2;
        e_t = Y(:, t) - H*x_tgtm1 - mu;
        Se_t = H*S_tgtm1*H' + R;
        Se_t = (Se_t+Se_t')/2;
        K_t = (S_tgtm1*H')/Se_t;
        x_tgt = x_tgtm1 + K_t*e_t;
        S_tgt = (eye(n)-K_t*H)*S_tgtm1*(eye(n)-K_t*H)' + K_t*R*K_t'; % stabilized kalman filter
        S_tgt = (S_tgt + S_tgt')/2;

        diffPathLogL(pathId) = diffPathLogL(pathId) + ...
            gaussian_prob(e_t, zeros(1,length(e_t)), Se_t, 1);
        
    end
end
[bestLogL,bestPathIndex] = max(diffPathLogL)  ;
bestSeq = getPath(transPlaces(:,bestPathIndex),T-1,1,nSegments);

end

function [g1,Q1,F,H,g,Q,mu,R] = getparameters(models,j)
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