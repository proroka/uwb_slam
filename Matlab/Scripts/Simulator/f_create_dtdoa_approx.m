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
% dtau.data    :      data vector of delta TDOA values, 1xN
% dtau.pdf     :      pdf, 1xdp
% dtau.cdf     :      cdf, 1xdp

function [dtau]=f_create_dtdoa_approx(ax,pn,pln,plos,N)

if(~nargin)
    % Axis
    dp = 10000;
    ax = linspace(-5,5,dp);
    % Parameters for BS 1 and 2
    pn.s = 0.047;
    range.m = [-0.5 0];                % range: log-normal mu
    range.s = [0.45 0.55];             % range: log-normal sigma
    range.los = [0.45 0.54];           % range: los probability
    
    [pln plos] = f_get_random_par(range);
    
    %pln.m = [-0.43 -0.3];
    %pln.s = [0.611 0.7];
    %plos = [0.49 0.32];
    %pln.m = [-2.873177 -2.057802];
    %pln.s = [0.455988 0.714281];
    %plos = [0.165866 0.172776];
    N = 4000;
end

% Get approx. normal parameters
[pna_m pna_s] = f_get_approx_normal([pln.m(1) pln.m(2)],[pln.s(1) pln.s(2)]);
t1 = plos(2) * plos(1) * normpdf(ax,0,pn.s);
t2 = plos(2) * (1-plos(1)) * lognpdf(-ax,pln.m(1),pln.s(1)); % Negative Lognormal!
t3 = plos(1) * (1-plos(2)) * lognpdf(ax,pln.m(2),pln.s(2));
t4 =  (1-plos(2)) * (1-plos(1)) * normpdf(ax,pna_m,pna_s);

% Get pdf and cdf
dx = ax(2) - ax(1);
dtau.pdf = t1 + t2 + t3 + t4;
dtau.cdf = cumsum(dtau.pdf) * dx;

% Dont return data if not needed
if (nargin<5)
    dtau.data = [];
else
    % Get random data following the model above
    rp1 = rand(N,1);
    rp2 = rand(N,1);
    dtau.data = zeros(1,N);
    % Differentiate 4 cases (Los-Los,Los-Nlos,Nlos-Nlos,Nlos-Los)
    for i=1:N
        if(rp1(i)<=plos(1) && rp2(i)<=plos(2))           % LOS-LOS
            dtau.data(i) = normrnd(0,2*pn.s);
        elseif(rp1(i)<=plos(1) && rp2(i)>plos(2))        % LOS-NLOS
            dtau.data(i) = lognrnd(pln.m(2),pln.s(2));
        elseif(rp1(i)>plos(1) && rp2(i)<=plos(2))        % NLOS-LOS
            dtau.data(i) = -lognrnd(pln.m(1),pln.s(1));
        else
            dtau.data(i) = normrnd(pna_m,pna_s);         % NLOS-NLOS
        end
    end
end

% plot
if(~nargin)
    figure
    fax = gca;
    f_plot_dtdoa_pdf(fax,ax,'r',dtau.pdf)
end

end







