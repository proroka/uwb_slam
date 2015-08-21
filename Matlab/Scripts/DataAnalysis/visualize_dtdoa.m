% 12.04.2012
% Amanda Prorok
%
% Visualize experimental delta-TDOA data in 2D
% a) Imagesc
% b) Histogram plot per cell
%
%%

clear
clear functions
close all


plot_hist = 0;

% Base station positions
X = [  3.57   3.61    0.10    0.065 ];
Y = [ -0.196  3.7     3.704  -0.196 ];
Z = [  2.474  2.469   2.485   2.495 ];

num_bs =  size(X,2);

% Load experimental data
runs = 6;


for r=1:length(runs)
    clear robots
    load(strcat('../../Workspaces/synchronized_data_all_run',num2str(runs(r)),'.mat'));
    
    % Ubisense tdoa values and indeces
    ubi_ind = sum(~isnan(robots{1}.tdoa),2)==num_bs-1;
    ubi_tdoa = robots{1}.tdoa(ubi_ind,:);
    pos = robots{1}.pos_st(ubi_ind,:);
    
    % Get nominal and ubisense dtdoa
    nom_tdoa = f_get_nominal_tdoa(pos,X,Y,Z);
    
    % Delta-tdoa
    dtdoa = zeros(length(ubi_tdoa),num_bs-1);
    for bs=1:num_bs-1
        dtdoa(:,bs) = ubi_tdoa(:,bs) - nom_tdoa(:,bs);
    end
end

if(plot_hist)
for bs=1:num_bs-1
    figure
    [n,bins]=hist(dtdoa(:,bs),50);
    bar(bins,n,'facecolor',[0.3 0.3 0.3]);
    xlim([-2 5]);
    xlabel('TDOA error [m]','fontsize',14);
    ylabel('Number of datapoints','fontsize',14)
    title(strcat('BS1-',num2str(bs+1)))
end
end

%% Visualize

% Define gridmap
cmax = []; % cmax = [-0.5 2.5];
num_cells = 10;
xmax = 3;
dx = xmax/num_cells;
dtdoa_grid = cell(num_bs-1,1);
dtdoa_grid_std = cell(num_bs-1,1);
dtdoa_grid_array = cell(num_bs-1,num_cells,num_cells);
dtdoa_grid_t = cell(num_bs-1,1);
cnt_grid = cell(num_bs-1,1);
for bs=1:num_bs-1
    dtdoa_grid{bs} = zeros(num_cells);
    dtdoa_grid_std{bs} = zeros(num_cells);
    cnt_grid{bs} = zeros(num_cells);
    for i=1:num_cells
        for j=1:num_cells
            dtdoa_grid_array{bs,i,j} = [];
        end
    end
end

% Assign values to gridmap
for i=1:length(pos)
    xi = floor(pos(i,1)/dx)+1;
    yi = floor(pos(i,2)/dx)+1;
    for bs=1:num_bs-1
        dtdoa_grid{bs}(xi,yi) = dtdoa_grid{bs}(xi,yi) + dtdoa(i,bs);
        cnt_grid{bs}(xi,yi) = cnt_grid{bs}(xi,yi) + 1;
        dtdoa_grid_array{bs,xi,yi} = [dtdoa_grid_array{bs,xi,yi} dtdoa(i,bs)];
    end
end
for i=1:num_bs-1
    dtdoa_grid{i} = dtdoa_grid{i} ./ cnt_grid{i};
    for xi=1:num_cells
        for yi=1:num_cells
            dtdoa_grid_std{i}(xi,yi) = std(dtdoa_grid_array{i,xi,yi});
        end
    end
end



% Plot as mesh
%f_plot_mesh(xm,ym,dtdoa_grid);

%f_plot_imagesc_gridmap(dtdoa_grid,cmax);

% Plot refined imagesc
interpf = 10; % grid refinement factor
gsize = 5; % size of Gaussian Kernel
fi=f_plot_smooth(dtdoa_grid,dx,xmax,interpf,gsize);
f_plot_imagesc_gridmap(fi,cmax);

% Plot refined std imagesc
fi_std=f_plot_smooth(dtdoa_grid_std,dx,xmax,interpf,gsize);
f_plot_imagesc_gridmap(fi_std,cmax);

% Plot histogram per cell
%f_plot_hist_gridmap(dtdoa_grid_array);





