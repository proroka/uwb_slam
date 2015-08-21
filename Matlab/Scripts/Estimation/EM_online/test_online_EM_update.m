% 5.01.2012
% Amanda Prorok
%
% Test online_update script

clear
close all

addpath('../../Simulator');
dp = 10000;
pdf_axis = linspace(-5,5,dp);


plot_on = 1;
num_mod = 4;   % number of summands in mixture model
num_par = 9;   % number of model parameters to optimize
num_s = 11;    % number of s values in (see ICRA 2012 paper for formalism)
gfac = 0.7;

% Target distribution: (4 humps)
range.m = [-0.5 0];              % range: log-normal mu
range.s = [0.45 0.55];           % range: log-normal sigma
range.los = [0.45 0.54];         % range: los probability

% True parameters, BSX (index 2) - BS1 (index 1)
pn.s = 0.047;
%[pln plos] = f_get_random_par(range);
pln.m = [-0.3 -0.4];
pln.s = [0.5 0.5];
plos = [0.5 0.5];
[mt st] = f_get_approx_normal(pln.m,pln.s);
% order: sn m1 m2 s1 s2 mt st p1 p2
par_true = [pn.s pln.m(1) pln.m(2) pln.s(1) pln.s(2) mt st plos(1) plos(2)]';

% Initial EM conditions
%pln.m = [-0.2 -0.2];
%pln.s = [0.5 0.5];
%plos = [0.05 0.05];
par0 = [0.05 -0.2 -0.2 0.5 0.5 0 1 0.05 0.05]';

N = 1050;
em_max = 50;

dtau_sim = f_create_dtdoa_approx(pdf_axis,pn,pln,plos,N);
data = dtau_sim.data; % 1xN

% Initialization
T = zeros(num_mod,1);
par_opt = zeros(num_par,1);
par_opt(:,1) = par0';
sbar = zeros(num_s,1);
shat = zeros(num_s,1);
scbar = zeros(2,1);
schat = zeros(2,1);

fprintf('Running EM...\n');
for n=1:N-em_max
    gamma = 1/(n^gfac);
    %gamma = 0.1;
    if(n==1)
        % Run empty updates on 1st datapoint to update ses
        for em=1:em_max
            gamma = 1/(em^0.65);
            [~,shat,schat] = f_online_EM_update(par_opt(:,1),data(em),shat,schat,pn,gamma,1,100);
        end
    end
    [par_opt(:,n+1),shat,schat] = f_online_EM_update(par_opt(:,n),data(n+1),shat,schat,pn,gamma,n,0);
    if(sum(isnan(par_opt(:,n+1)))>0)
        fprintf('*** Iteration %d isNaN  ***\n',n);
    end
end
parhat = par_opt(:,end);

if(plot_on)
    figure
    tit = {'sn','m1','m2','s1','s2','mt','st','p1','p2'};
    
    % Plot evolution
    for k=2:num_par
        subplot(1,num_par,k),hold on
        plot(1:N-em_max,par_opt(k,1:N-em_max),'r','linewidth',2);
        plot([1 N],[par_true(k) par_true(k)],'g','linewidth',2);
        xlim([0 N-em_max]);
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
    f_plot_dtdoa_pdf(fax,pdf_axis,[0 1 0],dtau_sim.pdf);

end





