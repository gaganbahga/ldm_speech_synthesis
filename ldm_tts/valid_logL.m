function logL = valid_logL(LDM_params, phone_state)
% Validation Data log likelihood
%   Find the log likelihood of validation data
%   Inputs:
%       LDM_params : parameters of the LDM
%       current_state : phone state for which to evaluate logL
%
%   Outputs:
%       logL : log likelihood of the observations for the given phone state

%   Author : Gagandeep Singh 2017

% for now these have been kept global
global label_data
global mgc_data

g1 = LDM_params.g1;
Q1 = LDM_params.Q1;
F  = LDM_params.F;
g  = LDM_params.g;
Q  = LDM_params.Q;
H  = LDM_params.H;
mu = LDM_params.mu;
R  = LDM_params.R;
n  = length(g1);
m  = length(mu);

logL = 0;

% validation files are from 1001 to 1100. Will write a configuration file
% later
for iUtt = 1001:1100
    uttLogL = 0;
    labels = label_data(iUtt).state;
    for iState = 1:length(labels)
        if strcmp(labels{iState}, phone_state)
            start_index = label_data(iUtt).begin(iState)/50000;
            end_index = label_data(iUtt).ending(iState)/50000;
            T = end_index - start_index + 1;
            Y = mgc_data{iUtt}(:,start_index:end_index);
            [~, segmentLogL] = forwardRecursions(g1, Q1, F, g, Q, H, mu, R, Y, T, n, m);
            uttLogL = uttLogL + segmentLogL;
        end
    end
    logL = logL + uttLogL;
    
end
end