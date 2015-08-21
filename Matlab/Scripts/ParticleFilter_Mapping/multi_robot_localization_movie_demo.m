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
addpath('../Estimation/EM_online');
addpath('../Estimation/EM_batch');

% Demo
rep_max = 10;      % learn model x times on this data point
resample_int = 8;  % resampling interval
take_im = 3;       % don't save all images for movie
batch_mode = true;
make_movie = 1;

% General settings
plot_on = 1;
verbose = 1;
num_robots = 1;

% Base station positions
X = [  3.57   3.61    0.10    0.065 ];
Y = [ -0.196  3.7     3.704  -0.196 ];
Z = [  2.474  2.469   2.485   2.495 ];
num_bs =  size(X,2);

% EM settings
num_params = 9;                  % number of parameters to estimate
num_s = 11;                      % number of S values in online EM
gfac = 0.35;                     % exponentional decay of gamma in function of n
%gconst = [];
gconst = 0.75;                   % constant gamma
%dampf = 0.8;                     % const. damping of gamma value

UWB_model = 1;
RB_model = 0;
rb_inter = 5;    % interval with respect to robot time resolution [robot time-steps]
uwb_inter = 1;   % interval with respect to robot time resolution [robot time-steps]
nom_dtdoa = 1;   % use nominal dtdoa for all particles


% Particle filter settings
num_particles = 200;
num_cells = 1;
random_init = 1;                 % local or global initialization
easy_init = 1;                   % initialization of 1 particle on robot
walls = 1;                       % true if using walls for particle weighting

% True UWB settings (for data simulation)
bs_nlos = [0 1 0 0];
P = 0.5;   % LOS
P_ = 0.5;  % NLOS
pn.s = 0.047;
pln.m = [-0.3 -0.3];
pln.s = [0.4 0.7];

% Constants
motion_sigma = 0.004;            % Std dev on dx dy for simple motion model
rand_bias = 0.05;                % percent of max weight added to all particles
jitter_thresh = 0.001;           % jitter if position variance to small
a_lim = [0 3 0 3];               % arena: xmin xmax ymin ymax
col  = [1 0 0;                   % robot colors
    0 0.7 0;
    0 0 1;
    0.6 0 0.7;
    0.1 0.9 0.1;
    0.9 0.8 0.1];


% Initialize particle structure
particles = f_initialize_particle_struct(num_robots,num_particles,num_bs,num_cells,num_s);

% Get batch estimate on full scan
if(batch_mode)
    load(strcat('../../Workspaces/synchronized_data_all_run',num2str(6),'.mat'));
    tdoa_data = robots{1}.tdoa(~isnan(robots{1}.tdoa(:,1)),:);
    dtdoa = zeros(size(tdoa_data));
    for dp=1:length(tdoa_data)
        if(~isnan(robots{1}.tdoa(dp,1)))
            dtdoa(dp,:)=f_get_dtdoa(robots{1}.tdoa(dp,:),robots{1}.pos_st(dp,:),X,Y,Z);
        end
    end
    par0 = particles{1}.maps{1,1,1,1}.par_opt';
    pdfax = -4:0.1:4;
    par_batch = cell(3,1);
    for bs=1:3
        par_batch{bs} = f_batch_EM(par0,pn,dtdoa(:,bs)',pdfax,1);
        ppln{bs}.m = par_batch{bs}(2:3);
        ppln{bs}.s = par_batch{bs}(4:5);
        pplos{bs} = par_batch{bs}(8:9);
    end
    clear robots
end

run = 7;
real = 1;


% Load data
if(~real)
    default = 1;  % load default trajectory and default NLOS area
    robots = f_load_simulated_data_structures(num_robots,default,bs_nlos,uwb_inter,X,Y,Z,pn,pln,P,P_,rb_inter);
else
    load(strcat('../../Workspaces/synchronized_data_all_run',num2str(run),'.mat'));
end

interval = [80 robots{1}.t_rob(end)];

% Initialize particle position
if(~random_init) % Local localization
    for i=1:num_robots
        ipos = robots{i}.pos_st(interval(1),:);
        particles{i}.pos = repmat(ipos,num_particles,1);
        particles{i}.w = ones(num_particles,1);
    end
else % Global localization (random in arena)
    global_sigma_pos = 0.25;
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

scr = get(0,'ScreenSize');
f = 2/3;
fig = figure('Position',[1 scr(4)*f scr(4)*f scr(4)*f]); hold on
ah = gca;
axis equal
xlabel('X [m]','FontSize',12);
ylabel('Y [m]','FontSize',12);
box on;
% Metal sheets
line([2.85 3.8],[3.55 3.55],'color',[0.8 0.2 0.4],'linewidth',6); % metal sheets
text(2.8,3.55,'Metal sheet \rightarrow','horizontalalignment','right','FontSize',12);
axis([-0.5 4.2 -2 4.2]);
set(gca,'xtick',0:4);
set(gca,'ytick',-2:4);
w = 0.15;
for bs=1:num_bs
    patch([X(bs) X(bs)+w X(bs)+w X(bs) X(bs)],[Y(bs) Y(bs) Y(bs)+w Y(bs)+w Y(bs)],'k');
    % Labels
    if(bs==1||bs==4)
        text(X(bs)-1.5*w,Y(bs)-2*w,strcat('BS-',num2str(bs)),'verticalalignment','bottom','FontSize',12);
    else
        text(X(bs)-1.5*w,Y(bs)+2.8*w,strcat('BS-',num2str(bs)),'verticalalignment','top','FontSize',12);
    end
end
% Movie
mname = 'PFilter_NLOS.avi';
pobj = [];
robj = [];
k_ = 1;
for t=interval(1):interval(2)-1
    
    if(verbose), fprintf('%d / %d\n',t,interval(2)); end
    
    % Plot current particles and ground truth
    if(plot_on && mod(t,1)==0)
        pos_st = [];
        for rob=1:num_robots
            pos_st = [pos_st robots{rob}.pos_st(t,:)];
        end
        pobj=f_plot_particles_movie(ah,particles,a_lim,col,num_cells,pobj);
        robj=f_plot_ground_truth_movie(ah,pos_st,robj);
    end
    
    % Update particle positions for all robots (motion model)
    %particles = f_motion_model_simple(particles,robots,t,a_lim,jitter_thresh,walls,motion_sigma);
    particles = f_motion_model(particles,robots,t,a_lim,jitter_thresh,walls);
    
    % UWB
    if(UWB_model)
        % Apply model
        
        if(~batch_mode)
            % Get DTDOA data
            particles = f_get_particle_dtdoa(particles,robots,X,Y,Z,t,nom_dtdoa);
            if(t>300)
                gconst = 0.85;
            end
            if(t>1050)
                gconst = 0.15;
            end
            for rep=1:rep_max
                particles = f_apply_UWB_model(particles,robots,pn,t,X,Y,Z,gfac,gconst,a_lim,verbose);
            end
        elseif(~isnan(robots{1}.tdoa(t,1)))
            P = ones(num_particles,1);
            for pi=1:num_particles
                P(pi) = f_get_dtdoa_pdf_and_prob(pn,ppln,pplos,particles{rob}.pos(pi,:),robots{1}.tdoa(t,:),X,Y,Z);
            end
            % Normalize P for all particles
            P = P ./ sum(P);
            % Weight particles
            particles{1}.w = particles{1}.w .* P;
        end
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
    if(UWB_model && mod(t,resample_int)==0)
        particles = f_apply_resampling(particles,rand_bias);
    end
    drawnow;
    if (mod(t,take_im)==0 && make_movie)

        fname = sprintf('im_%04d',k_);
        print('-dpng',fname);
        movefile(strcat(fname,'.png'),'./Images_BatchModel_Demo');
        k_ = k_+1;
    end
    
end

% To create mp4 movie, run in terminal:
% Crop images tightly:
% mogrify -crop 650x910+270+10 im_*.png
% Create movie:
% ffmpeg -qscale 1 -r 55 -b 9600 -i im_%04d.png movie.mp4



