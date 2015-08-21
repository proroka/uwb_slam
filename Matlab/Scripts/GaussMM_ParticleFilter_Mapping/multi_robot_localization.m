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
addpath('../Estimation/GaussMM/Batch');

run = 7;
real = 1;


% General settings
plot_on = 1;
verbose = 1;
num_robots = 1;

UWB_model = 1;
RB_model = 0;
rb_inter = 5;    % R&B interval with respect to robot time resolution [robot time-steps] 
uwb_inter = 1;   % UWB interval with respect to robot time resolution [robot time-steps] 
nom_dtdoa = 1;   % use nominal dtdoa for all particles

% Particle filter settings
num_particles = 20;
random_init = 0;                 % local or global initialization
easy_init = 1;                   % initialization of 1 particle on robot
walls = 1;                       % true if using walls for particle weighting

% True UWB data settings (for data simulation)
bs_nlos = [0 1 0 0];
P = 0.9;   % LOS
P_ = 0.1;  % NLOS
pn.s = 0.047;
pln.m = [-0.3 -0.3];
pln.s = [0.4 0.7];

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

% EM settings
num_mod = 4;                     % number of modes in mixture model

% Load data
if(~real)
    default = 1;  % load default trajectory and default NLOS area
    robots = f_load_simulated_data_structures(num_robots,default,bs_nlos,uwb_inter,X,Y,Z,pn,pln,P,P_,rb_inter);
else
    load(strcat('../../Workspaces/synchronized_data_all_run',num2str(run),'.mat'));
end
interval = [1 robots{1}.t_rob(end)];



% Initialize particle structure
particles = f_initialize_particle_struct(num_robots,num_particles,num_bs,num_mod);

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
        f_plot_particles(ah,particles,a_lim,col,1);
        f_plot_ground_truth(ah,pos_st,col);
    end
    
    % Update particle positions for all robots (motion model)
    particles = f_motion_model_simple(particles,robots,t,a_lim,jitter_thresh,walls,motion_sigma);
    
    % UWB
    if(UWB_model)
        % Add new dtdoa data point (either nominal or estimate)
        particles = f_get_particle_dtdoa(particles,robots,X,Y,Z,t,nom_dtdoa);
        % Apply model
        particles = f_apply_UWB_model(particles,robots,t,X,Y,Z,a_lim,num_mod,0);
    end
    
    % Range & bearing
    if(RB_model)
        for rob=1:num_robots
            if(sum(~isnan(robots{rob}.r_range(t,:)))>=1)
                if(verbose)
                    fprintf('R[%d] Apply R&B\n',rob);
                end
            end
        end
    end
    
    % Resample particles
    if(UWB_model)
        particles = f_apply_resampling(particles,rand_bias,robots,t,num_bs);
    end
    
    if(plot_on)
        drawnow;
    end
    
    
end




