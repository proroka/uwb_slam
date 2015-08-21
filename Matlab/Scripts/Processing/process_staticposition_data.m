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
%close all;
clear functions

addpath ../DataAnalysis

% static runs:  11:18
run = 20;

plot_on = 1;
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



%% Process Ubisense data

base = '../../../Data/Ubisense/ubidata_run';
fname = strcat(base,num2str(run),'.txt');
ML = false; % dont' calculate max likelihood positions

[robots] = f_process_ubisense_data(fname,robots,tag_ids,ML,X,Y,Z);

if(run==11)
    robots{1}.pos_st = repmat([1 2 0.12],length(robots{1}.tdoa),1);
elseif(run==12)
    robots{1}.pos_st = repmat([2 1 0.12],length(robots{1}.tdoa),1);
else
    robots{1}.pos_st = repmat([1.66 1 0.12],length(robots{1}.tdoa),1);
end



%% Save data

if(save_data)
    fname = strcat('../../Workspaces/synchronized_data_all_run',num2str(run),'.mat');
    save(fname,'robots');
end


%% Plot

if(plot_on)
    num_bs = size(robots{1}.tdoa,2)+1;
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
    dtdoa = dtdoa(~isnan(dtdoa(:,1)),:);
    
    
    % Plot over time
    for bs=1:num_bs-1
        figure
        plot(1:length(dtdoa),dtdoa(:,bs));
        xlabel('Time','fontsize',14);
        ylabel('TDOA error [n]','fontsize',14)
        title(strcat('BS1-',num2str(bs+1)))
    end
    
    % Plot histograms
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







