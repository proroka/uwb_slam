% 23.08.2011
% Amanda Prorok
% 
% Expecation Maximization Algorithm
% Batch mode (offline)
% 
% In:
% par0         :     initial guess
% pn           :     normal noise component (pn.s)
% data         :     1xN true delta-tdoa data
% pdf_axis     :     
%%

function [par_hat] = f_batch_EM(par0,pn,data,pdf_axis,plot_on)

% Iterations needed to converge (heuristic)
max_iter = 100;

num_par = 9;

if(~nargin)
    plot_on = 1;
    addpath('../../TDOAModeling');
    dp = 10000;
    pdf_axis = linspace(-5,5,dp);
    
    % True parameters, BSX (index 2) - BS1 (index 1)
    pn.s = 0.047;
    pln.m = [-0.4 -0.2];
    pln.s = [0.6 0.7];
    plos = [0.8 0.2];
    [mt st] = f_get_approx_normal(pln.m,pln.s);
    % order: sn m1 m2 s1 s2 mt st p1 p2
    par_true = [pn.s pln.m(1) pln.m(2) pln.s(1) pln.s(2) mt st plos(1) plos(2)]'; 
    par0 = [0.05 -0.5 -0.5 0.5 0.5 0 1 0.7 0.3]';
    N = 4000;
    dtau_sim = f_create_dtdoa_approx(pdf_axis,pn,pln,plos,N);
    data = dtau_sim.data; % 1xN
end
N = length(data);

% Initialization
plos0 = par0(8:9);
% LOS-LOS NLOS-LOS LOS-NLOS NLOS-NLOS
tau0 = [plos0(1)*plos0(2) plos0(2)*(1-plos0(1)) plos0(1)*(1-plos0(2)) (1-plos0(1))*(1-plos0(2))];
tau = zeros(4,max_iter);
T = zeros(4,N,max_iter);
par_opt = zeros(num_par,max_iter);
tau(:,1) = tau0; 
par_opt(:,1) = par0(1:num_par);

for t=1:max_iter
    T(:,:,t) = f_get_T(tau(:,t),par_opt(:,t),data);
    tau(:,t+1) = f_update_tau(T(:,:,t));
    par_opt(1:7,t+1) = f_update_par(T(:,:,t),data,pn.s,par_opt(:,t));
    par_opt(8:9,t+1) = [tau(1,t+1)/(tau(1,t+1)+tau(2,t+1)) (tau(1,t+1)+tau(2,t+1))];
end

if(plot_on)
    % Plot convergence
    figure
    tit = {'sn','m1','m2','s1','s2','mt','st','p1','p2'};
    for k=1:num_par
        subplot(1,num_par,k), hold on
        plot(1:max_iter,par_opt(k,1:max_iter),'r','linewidth',2);
        if(~nargin)
            plot([1 max_iter],[par_true(k) par_true(k)],'g','linewidth',2);
        end
        title(tit{k});
    end
    
    % Plot PDF of estimated and real/simulated data
    figure, hold on;
    fax = gca;
    pn.s = par_opt(1,max_iter);
    pln.m = [par_opt(2,max_iter) par_opt(3,max_iter)];
    pln.s = [par_opt(4,max_iter) par_opt(5,max_iter)];
    plos = [par_opt(8,max_iter) par_opt(9,max_iter)];
    
    dtau_opt = f_create_dtdoa_approx(pdf_axis,pn,pln,plos,N);
    f_plot_dtdoa_pdf(fax,pdf_axis,[1 0 0],dtau_opt.pdf);
    if(~nargin)
        f_plot_dtdoa_pdf(fax,pdf_axis,[0 1 0],dtau_sim.pdf);
    end
    
    [n,x] = hist(data,30);
    dx = x(2)-x(1);
    n = n ./ (dx*sum(n));
    bar(x,n);
end

par_hat = par_opt(:,max_iter);


end



