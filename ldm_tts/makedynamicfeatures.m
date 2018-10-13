function data = makedynamicfeatures(data)
m = size(data{1},1);
for fId = 1:length(data)
    d2 = [data{fId}(:,2:end) zeros(m,1)];
    d1 = [zeros(m,1) data{fId}(:,1:end-1)];
    delta = 0.5*d2 - 0.5*d1;
    ddelta = -d2 - d1 + 2*data{fId};
    data{fId} = [data{fId}; delta; ddelta];

end



end