% 22.02.2016
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

i =1; % Gauss
t(i,:) = tau(i) * normpdf(data,m(i),s(i));
i = 2; % Lognormal
t(i,:) = tau(i) * lognpdf(data,m(i),s(i));


tsum = sum(t,1);
%size(tsum) %sum

for i=1:num_mod
    T(i,:) = t(i,:) ./ tsum;
end

%sum(T,1)
%T = T./repmat(sum(T,1),num_mod,1);


end

