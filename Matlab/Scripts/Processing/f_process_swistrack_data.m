% 2.12.2012
% Amanda Prorok
%
% Process swistrack data
% Return time and position for each robot in robot structure
%
%%


function [robots] = process_swistrack_data(fname,robots)

plot_on = false;

if(~nargin)
    run = 1;
    base = '../../../Data/Swistrack/trueposmulti_run';
    fname = strcat(base,num2str(run),'.txt');
    robots = cell(5,1);
    plot_on = true;
end

data = load(fname); % time, x y th, x y th... for each robot
num_robots = size(robots,1);

t = cell(num_robots,1);
pos = cell(num_robots,1);

% Get raw data
shortest = inf;
si = 2; % skip first few lines 
for i=1:num_robots
    t{i} = data(si:end,1);
    pos{i} = data(si:end,2+(3*(i-1)):4+(3*(i-1))); % x y th
    if(length(pos{i})<shortest)
        shortest = length(pos{i});
    end
    fprintf('Processed Swistrack of R%d\n',i);

end
fprintf('\n');

for i=1:num_robots
    robots{i}.pos_st = pos{i};
    robots{i}.t_st = t{i};
end


if(plot_on)
    col = {'r','g','m','c','b','k'};
    figure, hold on
    
    for t=1:2:shortest
        for i=1:num_robots
            scatter(robots{i}.pos_st(t,1),robots{i}.pos_st(t,2),10,col{i});
        end
        drawnow;    
        axis equal
        line([0 3 3 0 0],[0 0 3 3 0]);
        axis([-0.5 3.5 -0.5 3.5]);
    
    end

    
end

end