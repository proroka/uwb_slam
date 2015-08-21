% 6.04.2012
% Amanda Prorok
%
% Create robot trajectory 
% Manually: with help of user inputs
% Default also available
%
% -- Out --
% t_rob        :      index of rob data points [t_max,1]
% pos_rob      :      robot positions [tmax,3]
% delta        :      delta values [tmax,3]
%
%%

function [t_rob pos_rob delta]=f_create_trajectory(default,static)

addpath ../Utilities

% Create custom or default trajectory
if(~default)
    % Create figure and plot arena
    scr = get(0,'ScreenSize');
    f = 2/3;
    fig = figure('Position',[1 scr(4)*f scr(4)*f scr(4)*f]);
    hold on;
    axis([-0.5 3.5 -0.5 3.5]);
    plot([0 3 3 0 0],[0 0 3 3 0],'k');
    axis equal
    ax = gca;
    
    max_points = 100;
    fprintf('*************************\n');
    fprintf('Enter ROBOT TRAJECTORY and press return\n');
    fprintf('*************************\n\n');
    set(fig,'CurrentAxes',ax);
    [x,y] = ginput(max_points);
    np = length(x);
    plot(ax,x,y,'m')
else
    x = [0.6258 1.2194 1.9484 2.3419 2.5484 2.1742 1.2710 0.7161 0.6129 1.0387]';
    y = [1.9355 2.2774 2.3806 1.8903 0.9742 0.4065 0.2968 0.6581 0.9935 1.2258]';
    np = length(x);
end

% Iterpolate trajectory for approx. ds
ds = 0.01; % [m]
xi = x(1);
yi = y(1);
thi = 0;
delta = [];
for i = 1:np-1
    dx_ = (x(i+1)-x(i));
    dy_ = (y(i+1)-y(i));
    ds_ = sqrt(dx_^2+dy_^2);
    nds = floor(ds_ / ds);
    dx = dx_ / nds;
    dy = dy_ / nds;
    for j = 1:nds
        xi = [xi; xi(end)+dx]; % global pos x
        yi = [yi; yi(end)+dy]; % global pos y
        thi = [thi; f_format_angle(atan2((yi(end)-yi(end-1)),(xi(end)-xi(end-1))))]; % global angle
        delta = [delta; (xi(end)-xi(end-1)) (yi(end)-yi(end-1)) (thi(end)-thi(end-1))];
    end
end

if(~default)
    plot(ax,xi,yi,'.g');
end

% Static
if(static)
    np = 1000;
    xi = repmat(1.5,np,1);
    yi = repmat(1.5,np,1);
    thi = repmat(0,np,1);
    delta = repmat([0 0 0],np,1);
end

t_rob = 1:length(xi);
pos_rob = [xi yi thi];

end


