% 13.04.2012
% Amanda Prorok
%
% Batch EM for Gaussian Mixture Model 
%%

clear 
clear functions
close all

max_iter = 100;
plot_on = 1;

% Define true parameters
par.m = [-2 -1 0 1] + randn;
par.s = [1 2 0.01 1] + abs(randn);
par.w = [0.2 0.3 0.3 0.2];
num_mod = length(par.m);
% Create data
N = 200;
[data,~] = f_create_GaussMM_data(N,par.m,par.s,par.w,0);

% Initialize EM
par0.m = [-1 0 0 1];%rand(1,4);
par0.s = [1 1 1 1];%rand(1,4);
par0.w = 1/num_mod * ones(1,num_mod);
%par0.w = rand(1,4);
%par0.w = par0.w ./ sum(par0.w);
par0_ = [par0.m par0.s]';
num_par = length(par0_);

tau = zeros(num_mod,max_iter);
T = zeros(num_mod,N,max_iter);
parX_ = zeros(num_par,max_iter);
parX_(:,1) = par0_;
tau(:,1) = par0.w;

% Iterate
for t=1:max_iter-1
    fprintf('Iter: %d\n',t);
    T(:,:,t) = f_get_T(tau(:,t),parX_(:,t),data);
    tau(:,t+1) = f_update_tau(T(:,:,t));
    parX_(:,t+1) = f_update_par(T(:,:,t),data);
end

parX.m = parX_(1:num_mod,max_iter);
parX.s = parX_(num_mod+1:2*num_mod,max_iter);
parX.w = tau(:,max_iter);

% Plot
ax = -5:0.1:5;
figure, hold on;
fax = gca;
% True curve in green
f_plot_GaussMM(fax,ax,par.m,par.s,par.w,[0 1 0]);
% Estimated curve in red
f_plot_GaussMM(fax,ax,parX.m,parX.s,parX.w,[1 0 0]);
% Plot data points
f_plot_datapoints(fax,data);




