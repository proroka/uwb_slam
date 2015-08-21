% 04.05.2012
% Amanda Prorok
%
%%

function [s]=f_update_S_online(T,x)

num_mod = 4;
s = zeros(3*num_mod,1);


for j=1:num_mod
    s((j-1)*3+1) = T(j);
    s((j-1)*3+2) = T(j)*x;
    s((j-1)*3+3) = T(j)*x^2;
end


end