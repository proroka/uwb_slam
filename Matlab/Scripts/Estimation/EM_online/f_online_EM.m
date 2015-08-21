% 23.08.2011
% Amanda Prorok
% 
% Expecation Maximization Algorithm
% Online mode
%%

function [parhat]=f_online_EM(par0,pn,data,pdf_axis,mindp)


plot_on = 1;

num_mod = 4;   % number of summands in mixture model
num_par = 9;   % number of model parameters to optimize
num_s = 11;    % number of s values in (see ICRA 2012 paper for formalism)
gconst = 1;    % constant gamma (not function of n)
gc = 1/20;     % constant gamma
gfac = 0.65;

if(~nargin)
    addpath('../../TDOAModeling');
    dp = 10000;
    pdf_axis = linspace(-5,5,dp);
    mindp = 30;
    
    % True parameters, BSX (index 2) - BS1 (index 1)
    pn.s = 0.047;
    pln.m = [-2.4 -1.2];
    pln.s = [0.26 0.3];
    plos = [0.3 0.3];
    [mt st] = f_get_approx_normal(pln.m,pln.s);
    % order: sn m1 m2 s1 s2 mt st p1 p2
    par_true = [pn.s pln.m(1) pln.m(2) pln.s(1) pln.s(2) mt st plos(1) plos(2)]'; 
    par0 = [0.05 -0.5 -0.5 0.5 0.5 0 1 0.5 0.5]';
    
    N = 4000;
    dtau_sim = f_create_dtdoa_approx(pdf_axis,pn,pln,plos,N);
    data = dtau_sim.data; % 1xN
end

N = length(data);

% Initialization
empty_it = 30;  % iterations without update
T = zeros(num_mod,N);
par_opt = zeros(num_par,N);
par_opt(:,1) = par0';
sbar = zeros(num_s,N);
shat = zeros(num_s,N);
scbar = zeros(2,N);
schat = zeros(2,N);

if(length(data)<mindp)
fprintf(strcat('Too little data points!! (Less than: ',num2str(mindp),')\n'));
	return
end
	
% Empty updates
for n=1:empty_it
    %disp(n)
    gamma = 1/n;
    T(:,n+1) = f_get_T_online(par_opt(:,n),data(n+1));
    [sbar(:,n+1) scbar(:,n+1)] = f_update_S_online(T(:,n+1),data(n+1),shat(:,n)); 
    shat(:,n+1) = shat(:,n) + gamma * (sbar(:,n+1) - shat(:,n));
    schat(:,n+1) = schat(:,n) + gamma * (scbar(:,n+1) - schat(:,n));
    par_opt(:,n+1) = par_opt(:,n);
end
% EM
for n=empty_it+1:N-1
    %disp(n)
    gamma = 1/(n^gfac);
    if(gconst)
        gamma = gc;
    end
    T(:,n+1) = f_get_T_online(par_opt(:,n),data(n+1));
    [sbar(:,n+1) scbar(:,n+1)] = f_update_S_online(T(:,n+1),data(n+1),shat(:,n)); 
    shat(:,n+1) = shat(:,n) + gamma * (sbar(:,n+1) - shat(:,n));
    schat(:,n+1) = schat(:,n) + gamma * (scbar(:,n+1) - schat(:,n));
    par_opt(:,n+1) = f_update_par_online(shat(:,n+1),schat(:,n+1),pn.s,par_opt(:,n));
end

% Average final values
% parhat = sum(par_opt(:,N-empty_it:N),2)./empty_it;
% mmse = (par_true - parhat).^2; % return mse
parhat = par_opt(:,N-1);

if(plot_on && ~nargin)
    figure
    tit = {'sn','m1','m2','s1','s2','mt','st','p1','p2'};
    
    % Plot evolution
    for k=2:num_par
        subplot(1,num_par,k),hold on
        plot(1:N,par_opt(k,1:N),'r','linewidth',2);
        plot([1 N],[par_true(k) par_true(k)],'g','linewidth',2);
        title(tit{k});
    end
    pn.s = parhat(1);
    pln.m = [parhat(2) parhat(3)];
    pln.s = [parhat(4) parhat(5)];
    plos = [parhat(8) parhat(9)];
    
    % Plot pdfs
    figure, hold on;
    fax = gca;
    dtau_opt = f_create_dtdoa_approx(pdf_axis,pn,pln,plos,N);
    f_plot_dtdoa_pdf(fax,pdf_axis,[1 0 0],dtau_opt.pdf);
    if(~nargin)
        f_plot_dtdoa_pdf(fax,pdf_axis,[0 1 0],dtau_sim.pdf);
    end
    
   
end


end





