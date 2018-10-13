function backwardParams = backwardRecursions(forwardParams, T, preCalculatedParams)
% forward recursions
%   Calculate the parameters in Forward recursions of Kalman filter.
%   Currently used only in validation and synthesis, not in training
%   
%   inputs :
%           forwardParams : parameters calculated from forward recursions
%           T : number of observations
%           precalculatedParams : (optional) struct that contains reverse 
%           Kalman gain Jt. If not given then calculated in this function
%
%   outputs :
%           backwardParams : backward recursions parameters

%   author : Gagandeep Singh 2017

    backwardInfo = struct('x_tgT', [], 'P_tgT', [], 'P_t_tm1gT', []);
    
    x_tgT = forwardParams(T).x_tgt;
    S_tgT = forwardParams(T).S_tgt; 

    backwardParams(1:T) = backwardInfo;
    
    for t = T:-1:2
        backwardParams(t).x_tgT = x_tgT;
        P_tgT = S_tgT + x_tgT*x_tgT';
        P_tgT = (P_tgT + P_tgT')/2;
        backwardParams(t).P_tgT = P_tgT;

        % Forward values
        x_tm1gtm1 = forwardParams(t-1).x_tgt;
        x_tgtm1 = forwardParams(t).x_tgtm1; 
        S_tm1gtm1 = forwardParams(t-1).S_tgt;
        S_tgtm1 = forwardParams(t).S_tgtm1;
        
        if nargin == 3
            Jt = preCalculatedParams(t).J_t;
        else
            Jt = S_tm1gtm1*F'/S_tgtm1;
        end
        
        % Compute x_tm1gT
        x_tm1gT = x_tm1gtm1 + Jt*(x_tgT - x_tgtm1); 

        S_t_tm1gT = S_tgT*Jt'; 
        backwardParams(t).P_t_tm1gT = S_t_tm1gT + x_tgT*x_tm1gT';  

        % Compute S_tm1gT and store it in S_tgT
        S_tgT = S_tm1gtm1 + Jt*(S_tgT - S_tgtm1)* Jt'; 
        S_tgT = (S_tgT+S_tgT')/2;
        
        % Store x_tm1gT in x_tgT for the next iteration
        x_tgT = x_tm1gT; 
    end   

    backwardParams(1).x_tgT = x_tgT;
    backwardParams(1).P_tgT = S_tgT + x_tgT*x_tgT';

end