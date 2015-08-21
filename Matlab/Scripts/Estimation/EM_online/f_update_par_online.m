



function [par_opt] = f_update_par_online(s,sc,sn,par,n)

% We assume we know the noise value
par_opt(1) = sn;

% Mus
par_opt(2) = s(4)/ s(3);
par_opt(3) = s(7)/ s(6);
if(par_opt(2)<-2.9), par_opt(2) = -2.9; end
if(par_opt(3)<-2.9), par_opt(3) = -2.9; end
if(par_opt(2)>-0.01), par_opt(2) = -0.01; end
if(par_opt(3)>-0.01), par_opt(3) = -0.01; end

% Sigmas
par_opt(4) = sqrt(-(s(4)^2/s(3)^2) + s(5)/s(3));
par_opt(5) = sqrt(-(s(7)^2/s(6)^2) + s(8)/s(6));
if(par_opt(4)<0.1),par_opt(4) = 0.1; end
if(par_opt(5)<0.1),par_opt(5) = 0.1; end
if(par_opt(4)>0.8),par_opt(4) = 0.8; end
if(par_opt(5)>0.8),par_opt(5) = 0.8; end

m1 = par_opt(2);
m2 = par_opt(3);
s1 = par_opt(4);
s2 = par_opt(5);

% Our solution:
par_opt(6) = exp(m2+(s2^2/2)) - exp(m1+(s1^2/2));
par_opt(7) = sqrt((exp(2*m2+2*s2^2) - exp(2*m2+s2^2)) + (exp(2*m1+2*s1^2) - exp(2*m1+s1^2)));

% Ps
par_opt(8) = (s(1)+sc(2)) / (s(1)+sc(1)+sc(2)+s(9));
par_opt(9) = (s(1)+sc(1)) / (s(1)+sc(1)+sc(2)+s(9));
% Limit the LOS probabilities to avoid getting stuck in unilateral
% distributions
if(par_opt(8)<0.01), par_opt(8) = 0.01; end
if(par_opt(9)<0.01), par_opt(9) = 0.01; end
if(par_opt(8)>0.99), par_opt(8) = 0.99; end
if(par_opt(9)>0.99), par_opt(9) = 0.99; end

% Get old values if NaN
if(sum(isnan(par_opt))>0)
    fprintf('**** It: %d , isNaN in update_par **** \n',n);
end
par_opt(isnan(par_opt)) = par(isnan(par_opt));
% Get old values if imaginary
for i=1:length(par)
    if(~isreal(par_opt(i)))
        par_opt(i) = par(i); 
    end
end

end


