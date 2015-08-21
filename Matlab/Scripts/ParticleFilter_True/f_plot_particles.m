% 21.05.2011
% 09.04.2012
% Amanda Prorok
%
% Plot particles
% Input:   
% fig           :   figure handle
% particles     :   cell array for all robots
%
%%
function []=f_plot_particles(ax,particles,a_lim,col,num_cells)

s = 4;  % scatter size
cla(ax);
axis(ax,'equal');

plot(ax,[a_lim(1) a_lim(2) a_lim(2) a_lim(1) a_lim(1)],[a_lim(3) a_lim(3) a_lim(4) a_lim(4) a_lim(3)],'color', 'k');
ds = (a_lim(2)-a_lim(1))/num_cells;
dsi = ds;
for ix=1:num_cells-1
    plot(ax,[dsi dsi],[a_lim(1) a_lim(2)],'color','k');
    dsi = dsi+ds;
end
dsi = ds;
for iy=1:num_cells-1
    plot(ax,[a_lim(1) a_lim(2)],[dsi dsi],'color','k');
    dsi = dsi+ds;
end
 
for i=1:size(particles,1)
    scatter(ax,particles{i}.pos(:,1),particles{i}.pos(:,2),s,col(i,:),'filled');
end

axis(ax,[a_lim(1)-0.5 a_lim(2)+0.5 a_lim(3)-0.5 a_lim(4)+0.5]);

end