% 13.04.2012
% Amanda Prorok
%
% Plot Gaussian Mixture Model
%%


function []=f_plot_GaussMM(fax,ax,m,s,w,col)

K = length(m);
P = zeros(K,length(ax));
for f=1:K
    P(f,:) = w(f) .* 1/(sqrt(2*pi)*s(f)) .* exp(-(ax-m(f)).^2 ./ (2*s(f)^2));
end
F = sum(P,1);

plot(fax,ax,F,'color',col,'linewidth',2);

end