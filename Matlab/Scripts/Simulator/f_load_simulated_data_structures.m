% 6.04.2012
% Amanda Prorok
%
% Create simulation data
%
%%

function [robots]=f_load_simulated_data_structures(num_robots,default,bs_nlos,uwb_freq,X,Y,Z,pn,pln,P,P_,rb_freq)


% Data structure
robots = cell(num_robots,1);
num_bs = size(X,2);

for i=1:num_robots
    % Ubisense / UWB
    robots{i}.tdoa = []; % valid tdoa values
    robots{i}.dtdoa = []; % ground truth dtdoa values
    robots{i}.t_ubi = []; % time of ubi data points
    robots{i}.pos_ubi = []; % position inferred from 3D tdoa algorithm
    robots{i}.nlos_ubi = []; % ground truth nlos knowledge
    
    % Ground truth / swistrack
    robots{i}.t_st = []; % time of st data points
    robots{i}.pos_st = []; % ground truth positioning
    
    % Robots
    robots{i}.t_rob = []; % time of robot data points
    robots{i}.pos_rob = []; % position inferred from wheelspeed data [x y th]
    robots{i}.delta = []; % delta pos. [dx dy dth]
    robots{i}.r_range = []; % relative range
    robots{i}.r_bearing = []; % relative bearing
end


% Create data
for i=1:num_robots
    % Odometry
    static = 0;
    [robots{i}.t_rob robots{i}.pos_rob robots{i}.delta] = f_create_trajectory(default,static);
    
    % Ground truth = robot data
    robots{i}.pos_st = robots{i}.pos_rob;
    robots{i}.t_st = robots{i}.t_rob;
    
    % Create UWB tdoa
    [robots{i}.tdoa robots{i}.dtdoa robots{i}.nlos_ubi]=f_create_tdoa(default,bs_nlos,robots{i}.pos_st,uwb_freq,num_bs,X,Y,Z,pn,pln,P,P_);
    robots{i}.t_ubi = robots{i}.t_rob(1:uwb_freq:end);
    
end

% Range & bearing
[robots] = f_create_RB(robots,rb_freq);



end