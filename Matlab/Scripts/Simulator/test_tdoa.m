% test tdoa data

clear
close all

pn.s = 0.047;
pln.m = [-0.3 -0.3];
pln.s = [0.4 0.7];
bs = 2;

N = 600;
robot_pos = [3 0];
% Base station positions
X = [  3.31   3.39   0.46   0.46 ];
Y = [ -0.25   3.86   3.77  -0.25 ];
Z = [  2.47   2.46   2.47   2.5  ];

% LOS
plos = [0.9 0.9];
[tdoa dtdoa] = f_create_tdoa_data_approx(1,N,pn,pln,plos,robot_pos,X,Y,Z,bs);

% NLOS
plos = [0.9 0.1];
[tdoa dtdoa] = f_create_tdoa_data_approx(1,N,pn,pln,plos,robot_pos,X,Y,Z,bs);