function LDMParams = updateParametersLDM(stats, n, m)
% Update parameters of LDM
%   update the parameters of an LDM in the maximization step of EM
%   algorithm.
%
%   Inputs:
%           stats: sufficient statistics calculated in the expectation step
%           for the training data
%           n: dimension of state vector
%           m: dimension of observation vector
%
%   Outputs:
%           LDM_params : updated LDM parameters
%
%   author : Gagandeep Singh 2017

    In = eye(n);
    maxSpecRad = 1;

    numSamples = stats.numSamples;
    numSegments = stats.numSegments;
    r1 = stats.z0;
    R1 = stats.G0;
    z1 = stats.z1;
    z2 = stats.z2;
    z3 = stats.z3;
    z4 = stats.z4;
    G1 = stats.G1;
    G2 = stats.G2;
    G3 = stats.G3;
    G4 = stats.G4;
    G5 = stats.G5;
    G6 = stats.G6;
     

    % Initial and intermediate states
    g1 = r1/numSegments;
    
    %Q1 = R1/numSegments - g1*g1'; 
    Q1 = eye(n);
    
    
    % Dynamics
    F = (G4 - 1/(numSamples - numSegments)*z2*z1')/(G1 - 1/(numSamples - numSegments)*z1*z1');
    
    spectralRadious = max(abs(eig(F)));
    
    if (spectralRadious > maxSpecRad)
        numIts = 27;
        lambda = 0.01;
        it = 1;
        while ((it <= numIts) && (spectralRadious > 1))
            F = (G4 - 1/(numSamples - numSegments)*z2*z1')/(G1 - 1/(numSamples - numSegments)*z1*z1' + lambda*In);
            spectralRadious = max(abs(eig(F)));
            it = it + 1;
            lambda = 2*lambda; 
        end
    
        if (spectralRadious < maxSpecRad)
            lambda1 = lambda/2;
            while (lambda1 >= lambda/4)
                F = (G4 - 1/(numSamples - numSegments)*z2*z1')/(G1 - 1/(numSamples - numSegments)*z1*z1' + lambda1*In);
                spectralRadious = max(abs(eig(F)));
                if (spectralRadious < 1)
                    lambda1 = lambda1 - lambda/200;
                else
                    lambda1 = lambda1 + lambda/200;
                    F = (G4 - 1/(numSamples - numSegments)*z2*z1')/(G1 - 1/(numSamples - numSegments)*z1*z1' + lambda1*In);
                    spectralRadious = max(abs(eig(F)));
                    break;
                end
            end
         
        end
    
        if (spectralRadious > maxSpecRad)
            F1 = (G4 - 1/(numSamples - numSegments)*z2*z1')/(G1 - 1/(numSamples - numSegments)*z1*z1');
            if (max(abs(eig(F1))) < spectralRadious)
                F = F1;    
            end
            %disp(strcat('Spectral Radious 3 : ', num2str(spectralRadious)))
        end
    end
    
    g = 1/(numSamples-numSegments)*(z2 - F*z1);
    %Q = (1/(numSamples-numSegments))*(G2 - F*G4' - g*z2');
    Q = eye(n);
    
    % Observation - Factor analysis
   
    H = (G5 - 1/numSamples*z4*z3')/(G3 - 1/numSamples*z3*z3');
    
    mu = 1/numSamples*(z4 - H*z3);
    
    R = (1/numSamples)*(G6 - H*G5' - mu*z4');
    R = R.*eye(m);

    if (min(eig(R)) < 1e-7)
        R = R + 1e-7*eye(m);
    end
    
    
    
LDMParams.g1 = g1;
LDMParams.Q1 = Q1;
LDMParams.F  = F;
LDMParams.g  = g;
LDMParams.Q  = Q;
LDMParams.H  = H;
LDMParams.mu = mu;
LDMParams.R  = R;

end
 
    
    
    
