

function f_plot_mesh(dtdoa_grid)

num_bs = length(dtdoa_grid)+1;
for i=1:num_bs-1
    figure
    mesh(xm,ym,dtdoa_grid{i})
end

end