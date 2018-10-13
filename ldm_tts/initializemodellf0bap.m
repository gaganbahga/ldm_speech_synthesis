function model = initializemodellf0bap(data)
% Initialize Model
%   Initialize the LDM
%
%   inputs :
%           segments: segments structure

%
%   outputs :
%           model : struct containing initialized LDMs
%

%   author : Gagandeep Singh 2017

lf0bap = [data.lf0bap];
lf0bap = lf0bap(lf0bap > 0);
if isempty(lf0bap)
    lf0bap = -1;
end


%-----------------  g1  ------------------------
g1 = 0;
t  = 0;
for i = 1:length(data)
    if data(i).lf0bap
        g1 = data(i).lf0bap(1) + g1;
        t = t + 1;
    end
end
g1 = g1/t;
model.g1 = [g1;g1];

%-----------------  Q1 -------------------------

model.Q1 = 0.2;

%-----------------  F   ------------------------

% normal case
model.F = [0.5, 0.5; 1, 0];

%-----------------  g   ------------------------

% zero initialization when n == m as well as general case
model.g = [mean(lf0bap, 2);0];

%-----------------  Q  -------------------------

model.Q = 0.2;



%-----------------  H   ------------------------

model.H = [1, 0];

%-----------------  mu   -----------------------

model.mu = 0;

%-----------------  R   ------------------------

model.R = 1;

end