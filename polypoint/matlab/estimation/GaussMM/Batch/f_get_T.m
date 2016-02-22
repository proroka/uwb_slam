% 23.08.2011
% Amanda Prorok
% 
% Expectation step 
%
%%

function [T]=f_get_T(tau,par,data)

N = length(data);
num_mod = size(tau,1);
T = zeros(num_mod,N);

m = [];
s = [];
for i=1:num_mod
    m = [m par(i)];
    s = [s par(i+num_mod)];
end

t = nan(num_mod,length(data));
for i=1:num_mod
    t(i,:) = tau(i) * normpdf(data,m(i),s(i));
end

tsum = sum(t,1);
%size(tsum) %sum

for i=1:num_mod
    T(i,:) = t(i,:) ./ tsum;
end

%sum(T,1)
%T = T./repmat(sum(T,1),num_mod,1);


end

