% 04.05.2012
% Amanda Prorok
%
%%

function [par] = f_update_par_online(s)


num_mod = 4;

for j=1:num_mod
    i = (j-1)*3+1;
    p.m(j) = s(i+1)/s(i);
    p.s(j) = sqrt( ((-s(i+1)^2)+s(i)*s(i+2)) / s(i));
    p.w(j) = s(i);
end

if(any(p.s<=0.01))
    p.s(p.s<=0.01) = 0.01;
end
if(any(p.w<=0.1))
    p.w(p.w<=0.1) = 0.1;
end

par = [p.m p.s p.w]';

end