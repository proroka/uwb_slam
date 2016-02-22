% 22.02.2016
% Amanda Prorok
%
% Plot mixture of Gauss and Lognormal
%%


function []=f_plot_NormLogn(fax,ax,m,s,w,col)

num_mod = 2;
P = zeros(num_mod,length(ax));

f = 1; % normal
P(f,:) = w(f) .* normpdf(ax,m(f),s(f));

f = 2; % lognormal
P(f,:) = w(f) .* lognpdf(ax,m(f),s(f));

F = sum(P,1);

plot(fax,ax,F,'color',col,'linewidth',2);

end