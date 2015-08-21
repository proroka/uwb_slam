% 6.04.2012
% Amanda Prorok
%
% Run particle filter
%
%%
clear
clear functions
close all

addpath ../Simulator
real = 1;

if (real)
    run = 7;
else
    run = [];
end

% General settings
plot_on = 1;
verbose = 1;
num_robots = 1;

UWB_model = 1;
RB_model = 0;
rb_inter = 1;    % interval with respect to robot time resolution [robot time-steps] 
uwb_inter = 1;   % interval with respect to robot time resolution [robot time-steps] 

% UWB settings
bs_nlos = [0 1 0 0];
ax = -5:0.05:5;
% Model
P = 0.9;   % LOS
P_ = 0.1;  % NLOS
pn.s = 0.047;
pln.m = [-0.3 -0.3];
pln.s = [0.4 0.7];

% Particle filter settings
num_particles = 50;
num_cells = 1;
random_init = 0;                 % local or global initialization
easy_init = 1;                   % initialization of 1 particle on robot
walls = 1;                       % true if using walls for particle weighting

% Constants
motion_sigma = 0.008;            % Std dev on dx dy for simple motion model
rand_bias = 0.05;                % percent of max weight added to all particles
jitter_thresh = 0.001;           % jitter if position variance to small
a_lim = [0 3 0 3];               % arena: xmin xmax ymin ymax
col  = [1 0 0;                   % robot colors
    0 0.7 0;
    0 0 1;
    0.6 0 0.7;
    0.1 0.9 0.1;
    0.9 0.8 0.1];
% Base station positions
X = [  3.31   3.39   0.46   0.46 ];
Y = [ -0.25   3.86   3.77  -0.25 ];
Z = [  2.47   2.46   2.47   2.5  ];
num_bs =  size(X,2);
err_pdf = zeros(length(ax),num_bs-1);

% Load data
default = 1;  % load default trajectory and default NLOS area
if(~real)
    robots = f_load_simulated_data_structures(num_robots,default,bs_nlos,uwb_inter,X,Y,Z,pn,pln,P,P_,rb_inter);
else
    load(strcat('../../Workspaces/synchronized_data_all_run',num2str(run),'.mat'));
end
interval = [1 robots{1}.t_rob(end)];

% Initialize particle structure
particles = cell(num_robots,1);

% Initialize particle position
if(~random_init) % Local localization
    for i=1:num_robots
        ipos = robots{i}.pos_st(interval(1),:);
        particles{i}.pos = repmat(ipos,num_particles,1);
        particles{i}.w = ones(num_particles,1);
    end
else % Global localization (random in arena)
    global_sigma_pos = 0.45;
    for i=1:num_robots
        ipos = robots{i}.pos_st(interval(1),:);
        particles{i}.pos = repmat(ipos,num_particles,1) + global_sigma_pos .* randn(num_particles,3);
        particles{i}.w = ones(num_particles,1);
        if(easy_init) % initialize 1 particle on the robot
            particles{i}.pos(1,:) = ipos;
        end
    end
end



%% Main loop

% Plot particles
if(plot_on)
    fig = figure; hold on
    ah = gca;
end

for t=interval(1):interval(2)-1
    
    if(verbose), fprintf('%d / %d\n',t,interval(2)); end
    
    % Plot current particles and ground truth
    if(plot_on && mod(t,1)==0)
        pos_st = [];
        for rob=1:num_robots
            pos_st = [pos_st robots{rob}.pos_st(t,:)];
        end
        f_plot_particles(ah,particles,a_lim,col,num_cells);
        f_plot_ground_truth(ah,pos_st,col);
    end
    
    % Update particle positions for all robots (motion model)
    particles = f_motion_model_simple(particles,robots,t,a_lim,jitter_thresh,walls,motion_sigma);
    
    % UWB
    if(UWB_model)
        for rob=1:num_robots
            % Check if UWB measurement available
            if(~isnan(robots{rob}.tdoa(t)))
                fprintf('[R %d] Apply UWB\n',rob);
                % Get ground truth UWB model
                plos_bool_1 = robots{rob}.nlos_ubi(t,1);
                for bs=2:num_bs
                    plos_bool_x = robots{rob}.nlos_ubi(t,bs);
                    % Assign ground truth NLOS config
                    if(plos_bool_1==0 && plos_bool_x==0)
                        plos_ = [P P];
                    elseif(plos_bool_1==1 && plos_bool_x==0)
                        plos_ = [P_ P];
                    elseif(plos_bool_1==0 && plos_bool_x==1)
                        plos_ = [P P_];
                    else
                        plos_ = [P_ P_];
                    end
                    err_pdf(:,bs-1) = f_get_UWB_err_pdf(ax,pn,pln,plos_);
                end
                % Apply model
                particles{rob} = f_apply_UWB_model(particles{rob},robots{rob}.tdoa(t,:),err_pdf,ax',X,Y,Z);
            end
        end
    end
    
    % Range & bearing
    if(RB_model)
        for rob=1:num_robots
            if(sum(~isnan(robots{rob}.r_range(t,:)))>=1)
                fprintf('[R %d] Apply R&B\n',rob);
            end
        end
    end
    
    % Resample particles
    if(UWB_model || RB_model)
        particles{rob} = f_apply_resampling(particles{rob},rand_bias);
    end
    
    if(plot_on)
        drawnow;
        %pause(0.05)
    end
    
    
end




