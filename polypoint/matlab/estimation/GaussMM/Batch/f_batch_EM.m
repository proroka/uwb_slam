% 13.04.2012
% Amanda Prorok
%
% Batch EM for Gaussian Mixture Model 
%
% -- Out --
% parX.m
% parX.s
% parX.w
%%

function [parX]=f_batch_EM(data,num_mod,max_iter)

verbose = 0;
if(~nargin)
    verbose = 1;
    max_iter = 50;    
    % Define true parameters
    par.m = [-6 0 0 4];
    par.s = [1 4 0.1 1.5];
    par.w = [0.2 0.3 0.4 0.1];
    num_mod = length(par.m);
    % Create data
    N = 20;
    [data,~] = f_create_GaussMM_data(N,par.m,par.s,par.w,0);
end

N = length(data);

% Initialize EM
par0.m = [-1 -0.1 0.1 1];
par0.s = [1 1 1 1];
par0.w = 1/num_mod * ones(1,num_mod);
par0_ = [par0.m par0.s]';
num_par = length(par0_);

tau = zeros(num_mod,max_iter);
T = zeros(num_mod,N,max_iter);
parX_ = zeros(num_par,max_iter);
tau(:,1) = 1/num_mod .* ones(num_mod,1);
parX_(:,1) = par0_;

% Iterate
for t=1:max_iter-1
    if(verbose)
        fprintf('Iter: %d\n',t);
    end
    T(:,:,t) = f_get_T(tau(:,t),parX_(:,t),data);
    tau(:,t+1) = f_update_tau(T(:,:,t));
    parX_(:,t+1) = f_update_par(T(:,:,t),data);
end

parX.m = parX_(1:num_mod,max_iter);
parX.s = parX_(num_mod+1:2*num_mod,max_iter);
parX.w = tau(:,max_iter);



end
