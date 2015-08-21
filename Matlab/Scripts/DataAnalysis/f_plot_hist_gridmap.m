% 12.04.2012
% Amanda Prorok
%
%
%%


function f_plot_hist_gridmap(dtdoa_grid)

num_bs = size(dtdoa_grid,1)+1;
num_cells = size(dtdoa_grid,2);

% Flip up-down for plotting
% dtdoa_grid_ud = cell(num_bs-1,num_cells,num_cells);
% for bs=1:num_bs-1
%     dtdoa_grid_ud{bs,:,:} = flipud(dtdoa_grid{bs,:,:});
% end

for bs=1:num_bs-1
    % Create figure and plot arena
    scr = get(0,'ScreenSize');
    f = 2/3;
    figure('Position',[1 scr(4)*f scr(4)*f scr(4)*f]);
    hold on;
    for fi=1:num_cells
        for fj=1:num_cells
            subplot(num_cells,num_cells,((fi-1)*num_cells+fj));
            hist(dtdoa_grid{bs,fi,fj});
            xlim([-1 4]);
        end
    end
end






end