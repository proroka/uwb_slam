% 23.08.2011
% Amanda Prorok
% 
% 
%
%%

function tau=f_update_tau(T) %T

% before
%p1 = sum(T(1,:) + T(2,:)) ./ sum(sum(T));
%p2 = sum(T(1,:) + T(3,:)) ./ sum(sum(T));

p1 = sum(T(1,:) + T(3,:)) ./ sum(sum(T));
p2 = sum(T(1,:) + T(2,:)) ./ sum(sum(T));
plos = [p1 p2];

tau = [plos(1)*plos(2) plos(2)*(1-plos(1)) plos(1)*(1-plos(2)) (1-plos(1))*(1-plos(2))];

end