%
%
%
%%

function f_plot_imagesc_gridmap(dtdoa_grid,cmax)

num_bs = length(dtdoa_grid)+1;
num_cells = size(dtdoa_grid{1},1);

% Transpose for imagesc plotting
dtdoa_grid_t = cell(num_cells,1);
for i=1:num_bs-1
    dtdoa_grid_t{i} = dtdoa_grid{i}';
end

% define colormap
cm = flipud(hot);
cold_mat = flipud(bone);

for i=1:num_bs-1
    figure
    imagesc(dtdoa_grid_t{i});
    
    % Set symmetric scale
    maxv = max(max(dtdoa_grid_t{i}));
    minv = min(min(dtdoa_grid_t{i}));
    if(maxv>abs(minv))
        cut = floor(length(cm) * (abs(minv)/maxv));
        %map_minus = cm(1:cut,:);
        map_minus = cold_mat(1:cut,:);
        cmap = [flipud(map_minus);cm];
    elseif(maxv<=abs(minv))
        cut = floor(length(cm) * (maxv/abs(minv)));
        map_plus = cm(1:cut,:);
        %cmap = [flipud(cm); map_plus];
        cmap = [flipud(cold_mat); map_plus];
    end
    
    set(gca,'YDir','normal'); % flip the values
    title(strcat('DTDOA: BS1 - BS',num2str(i+1)));
    axis equal
    axis([1-0.5 num_cells+0.5 1-0.5 num_cells+0.5]);
    colorbar
    colormap(cmap);
    if(~isempty(cmax))
        caxis(cmax);
    end
end



end