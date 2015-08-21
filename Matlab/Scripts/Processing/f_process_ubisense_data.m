% 2.12.2012
% Amanda Prorok
%
% Process Ubisense data
% Return time and valid tdoa for each robot in robot structure
%
%%


function [robots] = f_process_ubisense_data(fname,robots,tag_ids,ML,X,Y,Z)

plot_on = false;

if(~nargin)
    run = 1;
    base = '../../../Data/Ubisense/ubimulti_run';
    fname = strcat(base,num2str(run),'.txt');
    rob_ids = [202 204 212 213 214];
    tag_ids = {'020-000-147-018','020-000-147-006','020-000-147-009','020-000-147-190','020-000-147-081'};
    robots = cell(length(rob_ids),1);
    plot_on = true;
end

num_robots = size(robots,1);
t = cell(num_robots,1);
pos = cell(num_robots,1);


thresh = 80;  % cutoff value, tdoa range = [-80,80]
[~,tag,~,t_ubi,~,tdoa_proc] = process_ubisense_online_data(fname,thresh);

pos_ubi = [];
% calc. position from tdoa

fac = 0.06; % [m] in between 2 samples
% Means that Ubisense does about 5 GHz signal sampling

tdoa = tdoa_proc .* fac;
% separate by tag ID
shortest = inf;
for i=1:num_robots
    ind = strcmp(tag.ID(1:size(tdoa,1)),tag_ids(i));
    robots{i}.tdoa = tdoa(find(ind),:);
    robots{i}.t_ubi = t_ubi(find(ind));
    % save ubisense position
    robots{i}.pos_ubisense = tag.pos(find(ind),:);
    robots{i}.t_ubisense = t_ubi(find(ind));
    if (size(robots{i}.t_ubi,1) < shortest)
        shortest = size(robots{i}.t_ubi,1);
    end
end
tmax_ubi = shortest;

% Filter outliers and estimate max. likelihood positions
sig = [0.1 0.1 0.1];
for i=1:num_robots
    valid_rows = [];
    for t=1:tmax_ubi
        if (~any(isnan(robots{i}.tdoa(t,:))))
            fprintf('%d / %d\n',t,tmax_ubi);
            if(ML)
                robots{i}.pos_ubi(t,:) = f_ML_pos_estimate(robots{i}.tdoa(t,:),sig,X,Y,Z);
            end
            valid_rows = [valid_rows t];
        end
    end
    fprintf('Processed UWB of R%d\n',i);
    % remove NaN rows
    robots{i}.tdoa = robots{i}.tdoa(valid_rows,:);
    if(ML)
        robots{i}.pos_ubi = robots{i}.pos_ubi(valid_rows,:);
    end
    robots{i}.t_ubi = robots{i}.t_ubi(valid_rows);
    if (size(robots{i}.t_ubi,1) < shortest)
        shortest = size(robots{i}.t_ubi,1);
    end
end
fprintf('\n');

if(plot_on)
    col = {'r','g','m','c','b','k'};
    figure, hold on
    
    for t=1:1:shortest
        for i=1:num_robots
            scatter(robots{i}.pos_ubi(t,1),robots{i}.pos_ubi(t,2),10,col{i});
        end
        drawnow;
        axis equal
        line([0 3 3 0 0],[0 0 3 3 0]);
        axis([-0.5 3.5 -0.5 3.5]);
        
    end
    
    
end

