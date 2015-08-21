% 18.11.2011 
% 09.04.2012
% Amanda Prorok
% 
% Create 'simulated' tdoa data from given delta-tdoa error model
% Approximated dtdoa model
%
% -- In --
% N          :      number of measurements
% pn         :      dtdoa model parameters
% pln        :      "
% plos       :      LOS probability of [BS1 BSx]
% robot_pos  :      true robot position (where UWB emitter lies)
% X,Y,Z      :      all base-station positions
% bs         :      chosen base-station
%
% -- Out -- 
% tdoa_mmnt  :      [N,1] nominal tdoa + tdoa error (drawn from model)
% dtdoa      :      [N,1] tdoa error (only) 
%%

function [tdoa_mmnt dtdoa] = f_create_tdoa_data_approx(plot_on,N,pn,pln,plos,robot_pos,X,Y,Z,bs)

if(~nargin)
    % Default parameters
    pn.s = 0.047;
    pln.m = [-0.43 -0.3];
    pln.s = [0.611 0.7];
    plos = [0.49 0.32];
    N = 4000;
    robot_pos = [1.5 1.5];
    % Base station positions
    X = [  3.31   3.39   0.46   0.46 ];
    Y = [ -0.25   3.86   3.77  -0.25 ];
    Z = [  2.47   2.46   2.47   2.5  ];
    plot_on = 1;
    % Choose BS pair (BSx-BS1)
    bs = 2;
end

% Add robot height as z
rh = 0.12;
pos = [robot_pos(1:2) rh];
% Distance: BSX - BS1 (reference station)
bs1_pos = [X(1) Y(1) Z(1)];
d1 = pos - bs1_pos;
d1 = sqrt(d1(1).^2 + d1(2).^2 + d1(3).^2);
% Get nominal TDOA value [m]
bs2_pos = [X(bs) Y(bs) Z(bs)];
dbs = pos - bs2_pos;
dbs = sqrt(dbs(1).^2 + dbs(2).^2 + dbs(3).^2);
% BSX - BS1 (reference station)
tdoa_mmnt  = repmat((dbs-d1),N,1);


% Get approx. normal parameters
[pna_m pna_s] = f_get_approx_normal([pln.m(1) pln.m(2)],[pln.s(1) pln.s(2)]);
% Get random delta-tau data following the model
% Differentiate 4 cases (Los-Los,Los-Nlos,Nlos-Nlos,Nlos-Los)
rp1 = rand(N,1);
rp2 = rand(N,1);
dtdoa = zeros(1,N);
for i=1:N
    if(rp1(i)<=plos(1) && rp2(i)<=plos(2))           % LOS-LOS
        dtdoa(i) = normrnd(0,2*pn.s);
    elseif(rp1(i)<=plos(1) && rp2(i)>plos(2))        % LOS-NLOS
        dtdoa(i) = lognrnd(pln.m(2),pln.s(2));
    elseif(rp1(i)>plos(1) && rp2(i)<=plos(2))        % NLOS-LOS
        dtdoa(i) = -lognrnd(pln.m(1),pln.s(1)); 
    else                                             % NLOS-NLOS
        dtdoa(i) = normrnd(pna_m,pna_s);             
    end
    % Add error to true tdoa
    tdoa_mmnt(i) = tdoa_mmnt(i) + dtdoa(i);
end

if(plot_on)
    figure
    subplot(1,2,1)
    hist(tdoa_mmnt,50);
    xlim([-4 4])
    title('TDOA');
    subplot(1,2,2)
    hist(dtdoa,50);
    xlim([-4 4])
    title('DTDOA');
end


end