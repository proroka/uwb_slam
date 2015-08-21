% 04.05.2012
% Amanda Prorok
%
% Test online EM
%%


clear
close all


verbose = 1;
plot_on = 1;
plot_inter = 0;

% Define true parameters
par.m = [-3 0 3 6];
par.s = [0.1 0.5 1 2];
par.w = [0.2 0.3 0.4 0.1];
num_mod = length(par.m);
% Create data
N = 10000;
eit = 100;
fax = [];
if(plot_on)
    figure, hold on
    fax = gca;
end
[data,~] = f_create_GaussMM_data(N,par.m,par.s,par.w,plot_on,fax);
gfac = 0.65;
gconst = 0;

N = length(data);
ax = -10:0.1:10;

% Initialize EM
par0.m = par.m; % [-1 0 1 2];
par0.s = par.s; %[1 0.2 0.1 2];
par0.w = 1/num_mod * ones(1,num_mod);
par0_ = [par0.m par0.s par0.w]';
num_par = length(par0_);
num_s = 3*num_mod;

T = zeros(num_mod,N);
parX_ = zeros(num_par,N);
parX_(:,1) = par0_;

sbar = zeros(num_s,N);
shat = zeros(num_s,N);

% Empty iterations
for n=1:eit
    if(gconst)
        gamma = gconst;
    else
        gamma = 1/(n^gfac);
    end
    T(:,n+1) = f_get_T_online(parX_(:,n),data(n+1));
    sbar(:,n+1) = f_update_S_online(T(:,n+1),data(n+1));
    shat(:,n+1) = shat(:,n) + gamma * (sbar(:,n+1) - shat(:,n));
    parX_(:,n+1) = parX_(:,n);
    %pause
end

% Iterate
for n=eit+1:N-1
    if(verbose)
        fprintf('Iter: %d\n',n);
    end
    if(gconst)
        gamma = gconst;
    else
        gamma = 1/(n^gfac);
    end
    T(:,n+1) = f_get_T_online(parX_(:,n),data(n+1));
    sbar(:,n+1) = f_update_S_online(T(:,n+1),data(n+1));
    shat(:,n+1) = shat(:,n) + gamma * (sbar(:,n+1) - shat(:,n));
    parX_(:,n+1) = f_update_par_online(shat(:,n+1));
    
    if(plot_inter)
        parXi.m = parX_(1:num_mod,n+1);
        parXi.s = parX_(num_mod+1:num_mod*2,n+1);
        parXi.w = parX_(num_mod*2+1:end,n+1);
        scatter(data(n+1),1,'rx');
        f_plot_GaussMM(fax,ax,parXi.m,parXi.s,parXi.w,[0 0 1]);
        pause
        cla(fax)
    end
    
    %pause
end

parX.m = parX_(1:num_mod,N-1);
parX.s = parX_(num_mod+1:num_mod*2,N-1);
parX.w = parX_(num_mod*2+1:end,N-1);

%% Plot

if(plot_on)
    
%     figure, hold on
%     plot(1:N,parX_(1,:),'r');
%     plot(1:N,repmat(par.m(1),1,N),'g');
%     
%     figure, hold on
%     plot(1:N,parX_(5,:),'r');
%     plot(1:N,repmat(par.s(1),1,N),'g');
%     
    f_plot_GaussMM(fax,ax,parX.m,parX.s,parX.w,[1 0 0]);
    
    
end




