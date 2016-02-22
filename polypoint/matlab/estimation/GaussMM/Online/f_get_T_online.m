% 04.05.2012
% Amanda Prorok
%
%%

function [T] = f_get_T_online(par,x)

verbose = 0;
num_mod = 4;
t = zeros(num_mod,1);

p.m = par(1:num_mod);
p.s = par(num_mod+1:num_mod*2);
p.w = par(num_mod*2+1:end);

% check if sigma out of bounds
if(sum(p.s<0))
    p.s(p.s<0) = 1e-5;
end

for j=1:num_mod
    if(verbose)
        fprintf('P[%d]=%f  m=%f s=%f x=%f \n',j,normpdf(x,p.m(j),p.s(j)),p.m(j),p.s(j),x);
    end
    t(j) = p.w(j) * normpdf(x,p.m(j),p.s(j)) + 0.00001;
end
fprintf('\n');


T = t ./ sum(t);


end