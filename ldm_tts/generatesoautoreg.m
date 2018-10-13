% rough script

function xt = generatesoautoreg(a,b, g, T)
xt = [0.1 0.1];
for t = 3:T
xt = [xt (a*xt(end) + b*xt(end-1) + g)];
end
plot(xt)
end