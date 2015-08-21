% 23.08.2011
% Amanda Prorok
% 
% 
%
%%

function [T]=f_get_T(tau,par,data)

N = length(data);
T = zeros(4,N);

pn.s = par(1);
pln.m = [par(2) par(3)];
pln.s = [par(4) par(5)];
pnt.m = par(6);
pnt.s = par(7);

% check if out of bounds
if(sum(pln.s<0))
    pln.s(pln.s<0) = 1e-5;
end
if(pn.s<0)
    pn.s = 1e-5;
end
if(pnt.s<0)
    pnt.s = 1e-5;
end

% before:
% t1 = tau(1) * normpdf(data,0,2*pn.s);
% t2 = tau(2) * lognpdf(-data,pln.m(2),pln.s(2));
% t3 = tau(3) * lognpdf(data,pln.m(1),pln.s(1));
% t4 = tau(4) * normpdf(data,pnt.m,pnt.s);

t1 = tau(1) * normpdf(data,0,2*pn.s);
t2 = tau(2) * lognpdf(-data,pln.m(1),pln.s(1)); % ref station NLOS
t3 = tau(3) * lognpdf(data,pln.m(2),pln.s(2));
t4 = tau(4) * normpdf(data,pnt.m,pnt.s);

tsum = t1+t2+t3+t4;

T(1,:) = t1 ./ tsum;
T(2,:) = t2 ./ tsum;
T(3,:) = t3 ./ tsum;
T(4,:) = t4 ./ tsum;


T = T + 1e-15; 
T = T./repmat(sum(T),4,1);



end

