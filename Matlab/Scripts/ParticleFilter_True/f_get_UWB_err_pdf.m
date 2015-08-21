% 09.04.2012
% Amanda Prorok
%
% Return an error-pdf for given parameters applied to 1 BS pair
%%

function [err_pdf] = f_get_UWB_err_pdf(ax,pn,pln,plos)

% Get approx. normal parameters
[pna_m pna_s] = f_get_approx_normal([pln.m(1) pln.m(2)],[pln.s(1) pln.s(2)]);
t1 = plos(2) * plos(1) * normpdf(ax,0,pn.s);
t2 = plos(2) * (1-plos(1)) * lognpdf(-ax,pln.m(1),pln.s(1)); % Negative Lognormal!
t3 = plos(1) * (1-plos(2)) * lognpdf(ax,pln.m(2),pln.s(2));
t4 =  (1-plos(2)) * (1-plos(1)) * normpdf(ax,pna_m,pna_s);

err_pdf = t1 + t2 + t3 + t4;


end