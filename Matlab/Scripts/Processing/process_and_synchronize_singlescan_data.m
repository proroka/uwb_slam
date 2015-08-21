% 27.11.2011
% 21.04.2012 -- modified
% Amanda Prorok
%
% Process Ubisense and Swistrack data
% Synchronize data
%
% Data:
% Ubisense raw TDOA
% Swistrack ground truth
%
%%

clear;
close all;
clear functions

run = 8;

plot_on = 0;
save_data = 1;

% Tags assigned to robots
tag_ids = {'020-000-147-018'};
rob_ids = [212];
% Current robots in use
curr_ids = [1];  % robot 1 for single scan

tag_ids = tag_ids(curr_ids);
rids = rob_ids(curr_ids);
num_robots = length(rids);

% Base station positions
X = [  3.57   3.61    0.10    0.065 ];
Y = [ -0.196  3.7     3.704  -0.196 ];
Z = [  2.474  2.469   2.485   2.495 ];

%% Structure

robots = cell(num_robots,1);

for i=1:num_robots
    % Ubisense
    robots{i}.tdoa = []; % raw tdoa values
    %robots{i}.valid_tdoa = []; % NaN removal
    robots{i}.t_ubi = []; % time of ubi data points
    robots{i}.pos_ubi = []; % position inferred from 3D tdoa algorithm
    % Swistrack
    robots{i}.t_st = []; % time of st data points
    robots{i}.pos_st = []; % ground truth positioning
    robots{i}.index_st = []; % robot data index for matching st value
end



%% Process swistrack
    
base = '../../../Data/Swistrack/truepos_run';
fname = strcat(base,num2str(run),'.txt');

[robots] = f_process_swistrack_data(fname,robots);
    

%% Process Ubisense data

base = '../../../Data/Ubisense/ubidata_run';
fname = strcat(base,num2str(run),'.txt');
ML = true; % calculate max likelihood estimate

[robots] = f_process_ubisense_data(fname,robots,tag_ids,ML,X,Y,Z);


%% Sythesize robot data

[robots] = f_process_robot_data(robots); 


%% Synchronize data

   
% Synchronization
shortest = inf;
for i=1:num_robots
    % Interpolate ubi positions: st time index for each existing ubi value
    index_ubi = ceil(interp1(robots{i}.t_st,1:length(robots{i}.t_st),robots{i}.t_ubi(:)));
    index_ubi = index_ubi(~isnan(index_ubi));
    
    tdoa_ = robots{i}.tdoa;
    robots{i}.tdoa = nan(length(robots{i}.t_st),size(robots{i}.tdoa,2));
    robots{i}.tdoa(index_ubi,:) = tdoa_(1:length(index_ubi),:);
    
    pos_ = robots{i}.pos_ubi;
    robots{i}.pos_ubi = nan(length(robots{i}.t_st),size(robots{i}.pos_ubi,2));
    robots{i}.pos_ubi(index_ubi,:) = pos_(1:length(index_ubi),:);
    
    % Get shortest st time
    if (length(robots{i}.t_st)<shortest), shortest = length(robots{i}.t_st); end
end


%% Save data

if(save_data)
    fname = strcat('../../Workspaces/synchronized_data_all_run',num2str(run),'.mat');
    save(fname,'robots');
end


%% Plot

if(plot_on)
    num_bs = size(robots{1}.tdoa,2)+1;
    plot_st = 1;
    plot_ubi = 1;
    
    col = {'r','g','m','c','b','k'};
    figure, hold on
    axis equal
    line([0 3 3 0 0],[0 0 3 3 0]);
    axis([-1.5 4.5 -1.5 4.5]);
    for k=1:shortest
        for i=1:num_robots
            if(plot_st)
                scatter(robots{i}.pos_st(k,1),robots{i}.pos_st(k,2),15,'xk');
            end
            % If there is a ubisense data point for this robot time
            if(plot_ubi && sum(~isnan(robots{i}.tdoa(k,:)))==num_bs-1)
                scatter(robots{i}.pos_ubi(k,1),robots{i}.pos_ubi(k,2),15,col{i},'filled');
            end
        end
        drawnow;
    end 
end







