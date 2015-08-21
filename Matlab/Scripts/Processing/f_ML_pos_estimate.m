% 05.12.2011
% Amanda Prorok
%
% In:
% ttdoa     :     Nx3 matrix of measured tdoa
% sig       :     vector, std. dev of tdoa error per base-station
% X,Y,Z     :     coordinates per base-station
%%

function [pos_opt]=f_ML_pos_estimate(ttdoa,sig,X,Y,Z)


if(~nargin)
    % Create random positions
    np = 10;
    rpos = rand(np,2) .* 3;
    rpos(:,3) = 0.12;
    
    % Base station positions
    X = [  3.57   3.61    0.10    0.065 ];
    Y = [ -0.196  3.7     3.704  -0.196 ];
    Z = [  2.474  2.469   2.485   2.495 ];
    
    % Nominal TOA
    ds = zeros(np,4);
    for i=1:4
        ds(:,i) = sqrt( (rpos(:,1)-X(i)).^2 + (rpos(:,2)-Y(i)).^2 + (rpos(:,3)-Z(i)).^2 );
    end
    
    % Nominal and noisy TDOA
    tdoa = zeros(np,3);
    ttdoa = tdoa;
    sig = [0.1 0.1 0.1];
    for i=1:3
        tdoa(:,i) = ds(:,i+1) - ds(:,1);
        % add noise
        ttdoa(:,i) = tdoa(:,i) + randn(np,1).*sig(i).*tdoa(:,i);
        
    end
    % Test no noise
    %ttdoa = tdoa;
end

np = size(ttdoa,1);
rh = 0.12; % robot-height
pos0 = [1.5 1.5 rh]; % default: center of arena
lb = [-3 -3];
ub = [6 6];

% Optimization options
options = optimset('Algorithm', 'active-set', 'Display','off','TolFun',1e-9,'TolCon',1e-9,...  % 'Display' ,'iter'
    'TolX',1e-9,'MaxFunEvals',3000);

% Optimize for all positions
for i=1:np
    f = @(pos)f_pos_error(pos,ttdoa(i,:),sig,X,Y,Z,rh);
    %fprintf('ttdoa(i,:): %f  %f  %f\n',ttdoa(i,1),ttdoa(i,2),ttdoa(i,3));
    pos_opt(i,:) = fmincon(f,pos0,[],[],[],[],lb,ub,[],options);
    %pos_opt(i,:) = fminunc(f,pos0,options);
end


% Plot
if(~nargin)
    figure, hold on
    for i=1:np
        scatter(rpos(i,1),rpos(i,2),30,'g');
        scatter(pos_opt(i,1),pos_opt(i,2),30,'mx');
        
        drawnow;
        axis equal
        line([0 3 3 0 0],[0 0 3 3 0]);
        axis([-0.5 3.5 -0.5 3.5]);
    end
    
end

end


% Maximum likelihood optimization
function [err]=f_pos_error(pos,ttdoa,sig,X,Y,Z,rh)

err = 0;
for i=1:3
    
    fi = sqrt((pos(1)-X(i+1)).^2 + (pos(2)-Y(i+1)).^2 + (rh-Z(i+1)).^2) - sqrt((pos(1)-X(1)).^2 + (pos(2)-Y(1)).^2 + (rh-Z(1)).^2);
    err = err +  ((ttdoa(i) - fi).^2 / sig(i)^2);
    
end



end



