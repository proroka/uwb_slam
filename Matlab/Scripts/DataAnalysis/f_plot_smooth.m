

function [fi]=f_plot_smooth(dtdoa_grid,dx,xmax,interpf,gsize)


if(~nargin)
    num_bs = 4;
    num_cells = 10;
    dtdoa_grid = cell(num_bs-1,1);
    for bs=1:num_bs-1
        dtdoa_grid{bs} = rand(num_cells);
    end
    x = 0.5:0.1:2.95;
    y = x;
    [xm ym] = meshgrid(x,y);
    interpf = 10;
    xmax = 3;
    dx = xmax/num_cells;
    gsize = 10;
end
num_cells = length(dtdoa_grid{1});
num_bs = length(dtdoa_grid)+1;

% Define meshgrid
xm_ = (dx/2):dx:(xmax-dx/2);
ym_ = xm_;
[xm ym] = meshgrid(xm_,ym_);

% Interpolate onto finer meshgrid
dxx = dx/interpf;
xmi_ = (dx/2):dxx:(xmax-dx/2);
ymi_ = xmi_;
[xmi ymi] = meshgrid(xmi_,ymi_);
dtdoa_grid_i = cell(num_bs-1,1);
for bs=1:num_bs-1
    dtdoa_grid_i{bs}=interp2(xm,ym,dtdoa_grid{bs},xmi,ymi);
end

% Gaussian Kernel
h = fspecial('gaussian',gsize);
fi = cell(num_bs-1,1);
for bs=1:num_bs-1
    i = dtdoa_grid_i{bs};
    fi{bs} = imfilter(i,h,'replicate');
end

if(~nargin)
    figure
    imagesc(fi{1});
    axis equal
end

end