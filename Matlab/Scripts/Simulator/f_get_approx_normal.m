% 11.08.2011
% Amanda Prorok
%
% Calculate expected Normal params for approximated Logn-Logn convolution
% variable 2 - variable 1
%
%%

function [m s] = f_get_approx_normal(ms,ss)

m1 = ms(1);
m2 = ms(2);
s1 = ss(1);
s2 = ss(2);

%m = exp(m1+(s1^2/2)) - exp(m2+(s2^2/2));
%s = sqrt((exp(2*m1+2*s1^2) - exp(2*m1+s1^2)) + (exp(2*m2+2*s2^2) - exp(2*m2+s2^2)));

m = exp(m2+(s2^2/2)) - exp(m1+(s1^2/2));
s = sqrt((exp(2*m2+2*s2^2) - exp(2*m2+s2^2)) + (exp(2*m1+2*s1^2) - exp(2*m1+s1^2)));

end