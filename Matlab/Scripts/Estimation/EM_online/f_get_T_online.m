



function [T] = f_get_T_online(par,x)

T = zeros(4,1);
t = T;

pn.s = par(1);
pln.m = [par(2) par(3)];
pln.s = [par(4) par(5)];
pnt.m = par(6);
pnt.s = par(7);
plos = [par(8) par(9)];

% check if out of bounds
if(sum(pln.s<0))
    pln.s(pln.s<0) = 1e-5;
end
if(pnt.s<0)
    pnt.s = 1e-5;
end

tau = [plos(1)*plos(2) plos(2)*(1-plos(1)) plos(1)*(1-plos(2)) (1-plos(1))*(1-plos(2))];

t(1) = tau(1) * normpdf(x,0,2*pn.s);
t(2) = tau(2) * lognpdf(-x,pln.m(1),pln.s(1));
t(3) = tau(3) * lognpdf(x,pln.m(2),pln.s(2));
t(4) = tau(4) * normpdf(x,pnt.m,pnt.s);

T(1) = t(1) ./ sum(t);
T(2) = t(2) ./ sum(t);
T(3) = t(3) ./ sum(t);
T(4) = t(4) ./ sum(t);



end