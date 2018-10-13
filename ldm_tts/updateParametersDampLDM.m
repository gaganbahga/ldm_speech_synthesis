function LDM_params = updateParametersDampLDM(stats, n, m, FOld,diagonal,H)

params = getparameters();
GOld = FOld(1:n,n+1:end);
FOld = FOld(1:n,1:n);
numSamples = stats.numSamples;
numSegments = stats.numSegments;
z0 = stats.z0;
G0 = stats.G0;
z1 = stats.z1;
z2 = stats.z2;
z3 = stats.z3;
z4 = stats.z4;
z5 = stats.z5;
z6 = stats.z6;
G1 = stats.G1;
G2 = stats.G2;
G3 = stats.G3;
G4 = stats.G4;
G5 = stats.G5;
G6 = stats.G6;
G7 = stats.G7;
G8 = stats.G8;
G9 = stats.G9;
G10 = stats.G10;


% Initial and intermediate states
if params.g1_is_0
    g1 = zeros(n,1);
else
    g1 = z0/numSegments;
end

if params.g0_is_0
    g0 = zeros(n,1);
else
    g0 = z5/numSegments;
end

if params.Q1_is_I
    Q1 = eye(n);
else
    Q1 = G0/numSegments - g1*g1';
    Q1 = Q1.*eye(n);    
end

if params.Q0_is_I
    Q0 = eye(n);
else
    Q0 = G7/numSegments - g0*g0';
    Q0 = Q0.*eye(n);
end



% Dynamics

% [Fnum, Fdeno, Gnum, Gdeno] = getFGparam(FOld, GOld, z1, z2, z6,...
%     G1, G4, G8, G9, G10, numSamples, numSegments);
% 
% if diagonal
%     F = diag(diag(Fnum)./diag(Fdeno));
%     
%     G = diag(diag(Gnum)./diag(Gdeno));
% else
%     F = Fnum/Fdeno;
%     
%     G = Gnum/Gdeno;
%     
% end
% 
% [F,G] = tweak(F, G, FOld, GOld, z1, z2, z6, G1, G4, G8, G9, G10,n, numSamples, numSegments,diagonal);

if params.g_is_0
    g = zeros(n,1);
    nFGgIter = 1;
else
    g = 1/(numSamples - numSegments)*(z2 - FOld*z1 - GOld*z6);
    nFGgIter = 100;
end

coeff3 = diag(G10/8);
coeff2 = diag(-G8/2 - G8'/4);

for k = 1:nFGgIter
    coeff1 = diag(G9/2 + G1 - g*z6'/2);
    coeff0 = diag(-G4 + g*z1');

    phi = zeros(n,1);
    for i = 1:n
        root = roots([coeff3(i), coeff2(i), coeff1(i), coeff0(i)]);
        root = root(imag(root) == 0);
        [~,index] = min(abs(root));
        
        if root(index) >= 2
            phi(i) = 1.9;
        elseif root(index) <= -2
            phi(i) = -1.9;
        else
            phi(i) = root(index);
        end
    
    end

    F = diag(phi);
    G = -diag((phi.^2)/4);
    if ~params.g_is_0
        g = 1/(numSamples-numSegments)*(z2 - F*z1 - G*z6);
    end
end

if params.Q_is_I
    Q = eye(n);
else
    Q = (1/(numSamples-numSegments))*(G2 - F*G4' - G*G9' - g*z2');
    Q = Q.*eye(n);
    Q(Q < 0) = 0.01; 
end


% Observation - Factor analysis
% if nargin == 5
%     H = (G5 - 1/numSamples*z4*z3')/(G3 - 1/numSamples*(z3*z3'));
% else
%     H = H(:,1:n);
% end
if params.same_state_obs
    H = eye(m);
elseif nargin == 6
    H = H(:,1:n);
else
    H = (G5 - 1/numSamples*z4*z3')/(G3 - 1/numSamples*(z3*z3'));
end

if params.mu_is_0
    mu = zeros(m,1);
else
    mu = 1/numSamples*(z4 - H*z3);
end


if params.R_is_I
    R = eye(m);
else
    R = (1/numSamples)*(G6 - H*G5' - mu*z4');
    R = R.*eye(m);

    if (min(eig(R)) < 1e-7)
        R = R + 1e-7*eye(m);
    end
end
% combining matrices for second order LDM

g1 = [g1;g0];
Q1 = [Q1 zeros(n); zeros(n) Q0];

g = [g; zeros(n,1)];
Q = [Q zeros(n); zeros(n,n) ones(n)];
F = [F G; eye(n) zeros(n)];
H = [H zeros(m,n)];

% autoregressive
%     R = R.*eye(m);
%     H(:,m+1:n) = zeros(m);
%     %F(1:m,1:m) = F(1:m,1:m).*eye(m);
%     %F(1:m,m+1:n) = -(F(1:m,1:m)/2)^2;
%     F(m+1:n,1:m) = eye(m);
%     F(m+1:n,m+1:n) = zeros(m);
%     %mu = zeros(m,1);
%     Q = eye(n);
%     Q1 = eye(n);


LDM_params.g1 = g1;
LDM_params.Q1 = Q1;
LDM_params.F  = F;
LDM_params.g  = g;
LDM_params.Q  = Q;
LDM_params.H  = H;
LDM_params.mu = mu;
LDM_params.R  = R;

%R = diag(R);

%if (min(R) < 1e-7)
%    R = R + 1e-7;
%end

%R = diag(R);

end

function [F,G] = tweak(F, G, FOld, GOld, z1, z2, z6, G1, G4, G8, G9, G10,...
    n, numSamples, numSegments,diagonal)
In = eye(n);
spectralRadius = max(abs(eig([F G; eye(n) zeros(n)])));
if (spectralRadius > 1)
    numIts = 27;
    lambda = 0.01;
    it = 1;
    while ((it <= numIts) && (spectralRadius > 1))
        
        [Fnum, Fdeno, Gnum, Gdeno] = getFGparam(FOld, GOld, z1, z2, z6,...
            G1, G4, G8, G9, G10, numSamples, numSegments);
        
        if diagonal
            F = diag(diag(Fnum)./(diag(Fdeno)+lambda*ones(n,1)));
            
            G = diag(diag(Gnum)./(diag(Gdeno)+lambda*ones(n,1)));
        else
            F = Fnum/(Fdeno + lambda*In);
            
            G = Gnum/(Gdeno + lambda*In);
        end
        
        spectralRadius = max(abs(eig([F G; eye(n) zeros(n)])));
        it = it + 1;
        lambda = 2*lambda;
    end
    
    if (spectralRadius < 1)
        lambda1 = lambda/2;
        while (lambda1 >= lambda/4)
            
            [Fnum, Fdeno, Gnum, Gdeno] = getFGparam(FOld, GOld, z1, z2, z6,...
                G1, G4, G8, G9, G10, numSamples, numSegments);
            
            if diagonal
                F = diag(diag(Fnum)./(diag(Fdeno)+lambda1*ones(n,1)));
                
                G = diag(diag(Gnum)./(diag(Gdeno)+lambda1*ones(n,1)));
            else
                F = Fnum/(Fdeno + lambda1*In);
                
                G = Gnum/(Gdeno + lambda1*In);
            end
            
            
            spectralRadius = max(abs(eig([F G; eye(n) zeros(n)])));
            
            if (spectralRadius < 1)
                lambda1 = lambda1 - lambda/200;
            else
                lambda1 = lambda1 + lambda/200;
                [Fnum, Fdeno, Gnum, Gdeno] = getFGparam(FOld, GOld, z1, z2, z6,...
                    G1, G4, G8, G9, G10, numSamples, numSegments);
                if diagonal
                    F = diag(diag(Fnum)./(diag(Fdeno)+lambda1*ones(n,1)));
                    
                    G = diag(diag(Gnum)./(diag(Gdeno)+lambda1*ones(n,1)));
                else
                    F = Fnum/(Fdeno + lambda1*In);
                    
                    G = Gnum/(Gdeno + lambda1*In);
                end
                
                spectralRadius = max(abs(eig([F G; eye(n) zeros(n)])));
                break;
            end
        end
        
    end
    
    if (spectralRadius > 1)
        
        
            [Fnum, Fdeno, Gnum, Gdeno] = getFGparam(FOld, GOld, z1, z2, z6,...
                G1, G4, G8, G9, G10, numSamples, numSegments);
            
            if diagonal
                F1_ = diag(diag(Fnum))./diag(diag(Fdeno));
                
                G1_ = diag(diag(Gnum))./diag(diag(Gdeno));
            else
                F1_ = Fnum/(Fdeno);
                
                G1_ = Gnum/(Gdeno);
            end
        
        if (max(abs(eig([F1_ G1_; eye(n) zeros(n)]))) < spectralRadius)
            F = F1_;
            G = G1_;
        end
        %disp(strcat('Spectral Radious 3 : ', num2str(spectralRadious)))
    end
end
end

function [Fnum, Fdeno, Gnum, Gdeno] = getFGparam(FOld, GOld, z1, z2, z6,...
    G1, G4, G8, G9, G10, numSamples, numSegments)
Fnum = (G4 - 1/(numSamples - numSegments)*z2*z1'...
    + GOld*(z6*z1'/(numSamples - numSegments) - G8'));
Fdeno = (G1 - 1/(numSamples - numSegments)*(z1*z1'));

Gnum = (G9 - 1/(numSamples - numSegments)*z2*z6'...
    + FOld*(z1*z6'/(numSamples - numSegments) - G8'));

Gdeno = (G10 - 1/(numSamples - numSegments)*(z6*z6'));
end