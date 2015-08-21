% 14.12.2011
% Amanda Prorok
%
% Create simulated TDOA error data values -- *approximated model*
% Important: basestations -> BSX (index 2) - BS1 (index 1) for TDOA
%
% In:
% ax           :      axis, 1xdp
% N            :      number of data points
% pn           :      normal distribution parameters
% pln          :      lognormal distr. parameters
% plos         :      prob. of LOS
%
% Out:


function [P]=f_get_dtdoa_pdf_and_prob(pn,pln,plos,ppos,tdoa,X,Y,Z)

if(~nargin)
    addpath('../TDOAModeling');
    
    % Base station positions
    X = [  3.31   3.39   0.46   0.46 ];
    Y = [ -0.25   3.86   3.77  -0.25 ];
    Z = [  2.47   2.46   2.47   2.5  ];
    
    pn.s = 0.047;
    range.m = [-0.5 0];                % range: log-normal mu
    range.s = [0.45 0.55];             % range: log-normal sigma
    range.los = [0.45 0.54];           % range: los probability
    pln = cell(3,1);
    plos = cell(3,1);
    for bs=1:3
        % Parameters for BS pair
        [pln{bs} plos{bs}] = f_get_random_par(range);
    end
    
    % Input values
    tdoa = [-0.1 -0.2 -0.31];
    ppos = [1.5 1.5];
    
end


% Robot height
rh = 0.12;
num_bs = length(X);
% Distance from BS1
bs1_pos = [X(1) Y(1) Z(1)];
ppos = [ppos(1:2), rh];
d1 = ppos - bs1_pos;
d1 = sqrt(d1(1)^2 + d1(2)^2 + d1(3)^2);
    
P = 1;
for bs = 2:num_bs
    
    % Get approx. normal parameters
    [pna_m pna_s] = f_get_approx_normal([pln{bs-1}.m(1) pln{bs-1}.m(2)],[pln{bs-1}.s(1) pln{bs-1}.s(2)]);

    % Get nominal TDOA value [m]
    bs_pos = [X(bs) Y(bs) Z(bs)];
    dbs = ppos - bs_pos;
    dbs = sqrt(dbs(1)^2 + dbs(2)^2 + dbs(3)^2);
    % Vector of 'nominal' given all particle positions
    nom_tdoa  = dbs - d1;
    % dtdoa is the delta-tdoa perceived by the given particle
    dtdoa = tdoa(bs-1) - nom_tdoa;

    t1 = plos{bs-1}(2) * plos{bs-1}(1) * normpdf(dtdoa,0,pn.s);
    t2 = plos{bs-1}(2) * (1-plos{bs-1}(1)) * lognpdf(-dtdoa,pln{bs-1}.m(1),pln{bs-1}.s(1)); % Negative Lognormal!
    t3 = plos{bs-1}(1) * (1-plos{bs-1}(2)) * lognpdf(dtdoa,pln{bs-1}.m(2),pln{bs-1}.s(2));
    t4 =  (1-plos{bs-1}(2)) * (1-plos{bs-1}(1)) * normpdf(dtdoa,pna_m,pna_s);
    p = t1 + t2 + t3 + t4;
    P = p * P;
end


end







