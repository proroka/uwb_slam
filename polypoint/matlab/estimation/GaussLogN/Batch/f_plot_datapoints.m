% 19.04.2012
% Amanda Prorok
%
%
%%



function f_plot_datapoints(fax,data)

scatter(fax,data,zeros(length(data),1),40,'x');
% Histogram
[x, b] = hist(data,30);
x = x ./ (sum(x)*(b(2)-b(1)));
bar(fax,b,x);

end

