% 22.02.2016
% Amanda Prorok
%
% Run batch EM for mixture of Gaussian and Lognormal
% Input: experimental data
%%

clear 
close all

% load LOS data, ExperimentX
load ranges_exp1.mat

plot_hist = false;
plot_all = true;

n = size(r,1);
if n < 6
    rows = 2;
else
    rows = 3;
end

if plot_hist
    for i = 1 : n
        subplot(rows,3,i)
        nbins = round(sqrt(length(r(i,:))));
        hist(r(i,:),nbins)
    end
end

% prepare data with manual offset
offset = [0.3 -0.2 -0.5 -1 -1.45 -1.9 -2.2 -3.25 -3.75];

for i=1:n
    fax = subplot(rows,3,i);
    
    % since data is bad, we need to remove offsets, 0s, nans
    data = r(i,:);
    d0 = data(~isnan(data)) + offset(i);
    d1 = d0((d0~=0));
    d = d1(d1>-0.4);

    max_iter = 100;
    parX = f_batch_EM(max_iter, d);
    
    if plot_all
        ax = min(d):0.02:max(d);
        % Plot data points
        f_plot_datapoints(fax,d);
        hold on;
        % Estimated curve in red
        f_plot_NormLogn(fax,ax,parX.m,parX.s,parX.w,'r');
    end

end

