function Y = generatemceps(numFrames, states, model,global_var)
% Generate Mel cepstral coeficients
%   generate the mel cepstral observations using LDMs
% Inputs:
%       numFrames: total nuumber of frames to be generated for each state
%       states: state sequence
%       model: LDM models struct array
%       global_var: global variance struct 
% Outputs:
%       Y: obbservation 

Y = [];
U = [];
params = getparameters();
m = params.m;

for k = 1:length(states)
    state = states{k};
    state_ind = find(strcmp({model.state},state));
    
    % not required
%     if k == 3
%         state_ind = 6949;
%     end
%     match = regexp(state,'([a-z1@\!]+)_([0-9]+)_[0-9]+','tokens');
%     phone = match{1}{1};
%     segment = match{1}{2};
%     segment = strcat('segment_',segment);
%     mu_ = normParams.(segment).(phone).mu;
%     sigma_ = normParams.(segment).(phone).sigma;
    
    duration = numFrames(k);
    
    g1 = model(state_ind).g1;
    F  = model(state_ind).F;
    g  = model(state_ind).g;
    H  = model(state_ind).H;
    mu = model(state_ind).mu;
    R  = model(state_ind).R;
    
    U = [U repmat(diag(R),1,duration)];
    
    if k == 1
        xt = g1;
    else
        % first state in non-first segment is a linear combination
        xt = params.lambda*g1 + (1-params.lambda)*xt;

    end
    for t = 1:duration

            yt = H*xt + mu;
            Y = [Y, yt];
            xt = F*xt + g;        
    end
end

if params.doMLPG
    Y = mlpgpython(Y,U);
end
    
if params.smoothen
    for k = 1:size(Y, 1)
        Y(k, :) = smooth(Y(k, :));
    end
end

% enhance the synthesize MGCs using global variance

if exist('global_var','v')
    Y_hat = Y;
    alpha_0 = params.alpha_0;
    weight = params.weight;
    eps_1 = params.eps_1;
    % In global variance paper they used eps_2 = 0.0001. This works when R
    % = I but not otherwise. 0.001 seems to work.
    eps_2 = params.eps_2;
    S_inv = inv(global_var.sigma + eps_1*eye(length(global_var.mu)));
    num_iterations = 50;
    for iter = 1:num_iterations
        alpha = alpha_0/sqrt(iter);
        v = var(Y,0,2);
        y_mean = mean(Y,2);
        B = S_inv*(v-global_var.mu);
        
        tau = 0;
        for i_state = 1:length(states)
            state = states{i_state};
            R_inv = inv( model(strcmp({model.state},state) ).R(1:m,1:m) ...
                + eps_2*eye(m));
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

end