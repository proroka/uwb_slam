% 13.04.2012
% Amanda Prorok
%
% Create Gaussian Mixture Model data
% K modes
% Return data and also axis handle
%%


function [data,fax]=f_create_GaussMM_data(N,m,s,w,plot_on)

if(~nargin) 
    plot_on = 1;
    N = 1000;                              % number of data points
    w = [0.25 0.25 0.25 0.25];             % mixture weights
    m = [-6 0 3 6];                        % mean values
    s = [1 1 1 1];                         % std dev
end
K = length(w);                             % number of modes
data = nan(1,N);

for i=1:N
    % Sample mode
    z = randsample(1:K,1,true,w);
    % Sample data point
    x = m(z) + s(z) *randn;
    data(i) = x;
end

fax = [];
if(plot_on)
    figure
    hold on
    fax = gca;
    % Histogram
    [x b] = hist(data,30);
    x = x ./ (sum(x)*(b(2)-b(1)));
    bar(fax,b,x);
    % PDF
    ax = -10:0.1:10;
    f_plot_GaussMM(fax,ax,m,s,w,[0 1 0]);
end


end