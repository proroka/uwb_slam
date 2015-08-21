% 15.12.2011 (modified version)
% Amanda Prorok
%
% Reference base-station is index 1
% Takes into account when a base-station pair doesn't enter all modes
%
%%

function [par]=f_update_par(T,data,pns,ppar)


% f1
sn = pns;

% f2, reference station (negative)
ind = find(data<0);
xi = data(ind);
if(~isempty(ind))
    m1 = sum( T(2,ind).*log(-xi) ) ./ sum(T(2,ind));
    s1 = sqrt( (sum( T(2,ind) .* ( log(-xi)-m1 ).^2 )) ./  (sum(T(2,ind))) );
    if(s1<=0)
        s1 = 1e-5;
    end
else
    m1 = ppar(2);
    s1 = ppar(4);
end

% f3
ind = find(data>0);
xi = data(ind);
if(~isempty(ind))
    m2 = sum( T(3,ind).*log(xi) ) ./ sum(T(3,ind));
    s2 = sqrt( (sum( T(3,ind).*(log(xi)-m2).^2 )) ./ (sum(T(3,ind))) );
    if(s2<=0)
        s2 = 1e-5;
    end
else
    m2 = ppar(3);
    s2 = ppar(5);
end

% f4
mt = exp(m2+(s2^2/2)) - exp(m1+(s1^2/2));
st = sqrt((exp(2*m2+2*s2^2) - exp(2*m2+s2^2)) + (exp(2*m1+2*s1^2) - exp(2*m1+s1^2)));

par = [sn m1 m2 s1 s2 mt st]';

end