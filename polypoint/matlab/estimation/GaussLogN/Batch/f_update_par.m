% 22.02.2016
% Amanda Prorok
% 
% 
%
%%

function [par]=f_update_par(T,data)

K = size(T,1);

m = nan(1,K);
s = nan(1,K);

% Gauss
i = 1;
m(i) = sum(T(i,:).*data) ./ sum(T(i,:));
s(i) = sqrt(sum( T(i,:).*(data-m(i)).^2 ) ./ sum(T(i,:)));
if(s(i)<0.001)
    s(i) = 0.001;
end

% Lognorm
i = 2;
m(i) = sum( T(i,:).*log(data) ) ./ sum(T(i,:));
s(i) = sqrt( (sum( T(i,:).*(log(data)-m(i)).^2 )) ./ (sum(T(i,:))) );
if(s(i)<=0)
    s(i) = 1e-5;
end

par = [m s]';

end