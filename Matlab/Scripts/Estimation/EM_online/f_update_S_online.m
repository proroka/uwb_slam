%
%
%
%
%

function [s,sc]=f_update_S_online(T,x,sp)


s = zeros(11,1);
sc = zeros(2,1);

% f1
s(1) = T(1);
s(2) = T(1)*x^2;

% Update s 3-5 (corresponding to negative data points), f2
if(x>0) % propagate previous
    s(3:5) = sp(3:5);
    sc(1) = T(2); % BS1 is LOS
else
    sc(1) = T(2); % BS1 is NLOS
    s(3) = T(2);
    s(4) = T(2)*log(-x);
    s(5) = T(2)*log(-x)^2;
end

% Update s 6-8 (corresponding to positive data points), f3
if(x<0) % propagate previous
    s(6:8) = sp(6:8);
    sc(2) = T(3);
else
    sc(2) = T(3);
    s(6) = T(3);
    s(7) = T(3)*log(x);
    s(8) = T(3)*log(x)^2;
end

% f4
s(9) = T(4);
s(10) = T(4)*x;
s(11) = T(4)*x^2;

end



