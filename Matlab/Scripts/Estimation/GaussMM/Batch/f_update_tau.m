% 23.08.2011
% Amanda Prorok
% 
% 
%
%%

function tau=f_update_tau(T)

N = size(T,2);
tau = (1/N) * sum(T,2);

end