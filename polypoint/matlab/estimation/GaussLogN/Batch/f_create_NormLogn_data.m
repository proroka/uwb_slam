% 22.02.2016
% Amanda Prorok
%
% Create Gaussian Mixture Model data
% K modes
% Return data and also axis handle
%%

function [data,fax]=f_create_NormLogn_data(N,m,s,w,plot_on)

if(~nargin) 
    plot_on = 1;
    N = 1000;                              % number of data points
    w = [0.5 0.5];                         % mixture weights: [Gauss Lognormal]
    m = [0 1];                             % mean values
    s = [1 1];                             % std dev
end

num_mod = 2; % number of modes
data = nan(1,N);

for i=1:N
    % Sample mode
    z = randsample(1:num_mod,1,true,w);
    % Sample data point
    if z==1 % sample Gauss
        x = m(z) + s(z) *randn;
    else % sample Lognormal
        x = lognrnd(m(z),s(z));
    end
    data(i) = x;
end

fax = [];
if(plot_on)
    figure
    hold on
    fax = gca;
    % Histogram
    [x, b] = hist(data,30);
    x = x ./ (sum(x)*(b(2)-b(1)));
    bar(fax,b,x);
    % PDF
    ax = -10:0.1:10;
    f_plot_NormLogn(fax,ax,m,s,w,'g');
end


end