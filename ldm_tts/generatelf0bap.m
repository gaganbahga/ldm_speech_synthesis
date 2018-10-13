function Y = generatelf0bap(numFrames,states,model,global_var)
% Generate lf0 or BAP
%   generate the lf0/bap observations using LDMs
% Inputs:
%       numFrames: total nuumber of frames to be generated for each state
%       states: state sequence
%       model: LDM models struct array
%       global_var: global variance struct 
% Outputs:
%       Y: obbservation sequence

% author : Gagandeep Singh 2017

Y = [];
for k = 1:length(states)
    state = states{k};
    duration = numFrames(k);
    if length(state) > 15
        Y = [Y -1e+10*ones(1,duration)];
        xt = [-1;-1];
        continue
    end
    
    state_ind = find(strcmp({model.state},state));
    
    g1 = model(state_ind).g1;
    F  = model(state_ind).F;
    g  = model(state_ind).g;
    H  = model(state_ind).H;
    mu = model(state_ind).mu;
    
    
    if (k == 1) || (xt(1) < 0)
        xt = g1;
    end
    for t = 1:duration
        yt = H*xt + mu;
        Y = [Y, yt];
        xt = F*xt + g;
        if xt(1) < 0
            a = 1;
        end
    end
end

% call the mlpg here

% enhance the synthesize MGCs using global variance

if nargin == 4
    Y_hat = Y;
    alpha_0 = 0.001;
    weight = 1;
    eps_1 = 0.00002;
    % In global variance paper they used eps_2 = 0.0001. This works when R
    % = I but not otherwise. 0.001 seems to work.
    eps_2 = 0.001;
    S_inv = inv(global_var.sigma + eps_1*eye(length(mu)));
    num_iterations = 50;
    for iter = 1:num_iterations
        alpha = alpha_0/sqrt(iter);
        v = var(Y,0,2);
        y_mean = mean(Y,2);
        B = S_inv*(v-global_var.mu);
        
        tau = 0;
        for i_state = 1:length(states)
            state = states{i_state};
            R_inv = inv( model(strcmp({model.state},state) ).R ...
                + eps_2*eye(length(mu)));
            duration = numFrames(i_state);
            for t = 1:duration
                tau = tau + 1;
                y = Y(:,tau);
                y_hat = Y_hat(:,tau);
                dL(:,tau) = -R_inv*(y-y_hat) - 2*weight*B.*(y-y_mean);
            end
        end
        Y = Y + alpha*dL;
    end
end


% Naive method to smooth the discontinuities between segments

for k = 1:size(Y, 1)
    Y(k, :) = smooth(Y(k, :));
end

end