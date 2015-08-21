% test data creation

clear
close all

plot_on = 0;

bs_nlos = [0 1 0 0]; % BS in NLOS config
uwb_freq = 1; % for every robot position
num_bs = 4;
bs = 2;
num_robots = 2;
default = 1;
rb_freq = 1;

% Base station positions
X = [  3.31   3.39   0.46   0.46 ];
Y = [ -0.25   3.86   3.77  -0.25 ];
Z = [  2.47   2.46   2.47   2.5  ];
% Model
P = 0.9;   % LOS
P_ = 0.1;  % NLOS
pn.s = 0.047;
pln.m = [-0.3 -0.3];
pln.s = [0.4 0.7];


% Load all data
[robots]=f_load_simulated_data_structures(num_robots,default,bs_nlos,uwb_freq,X,Y,Z,pn,pln,P,P_,rb_freq);


if(plot_on)

for i=1:num_bs-1
    figure
    subplot(1,2,1);
    hist(robots{1}.tdoa(:,i),20);
    title(strcat('TDOA: 1-',num2str(i+1)));
    subplot(1,2,2);
    hist(robots{1}.dtdoa(:,i),20);
    title(strcat('DTDOA: 1-',num2str(i+1)));
    xlim([-3 3]);
    
end


end