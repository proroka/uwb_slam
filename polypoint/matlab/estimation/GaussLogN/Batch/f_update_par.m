% 23.08.2011
% Amanda Prorok
% 
% 
%
%%

function [par]=f_update_par(T,data)

K = size(T,1);

m = nan(1,K);
s = nan(1,K);
for i=1:K
    m(i) = sum(T(i,:).*data) ./ sum(T(i,:));
    s(i) = sqrt(sum( T(i,:).*(data-m(i)).^2 ) ./ sum(T(i,:)));
    if(s(i)<0.001)
        s(i) = 0.001;
    end
end

par = [m s]';

end