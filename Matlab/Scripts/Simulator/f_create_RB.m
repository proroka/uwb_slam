% 09.04.2012
% Amanda Prorok
%
% Emulate noisy range and bearing measurements (at a given frequency,
% probabilistically)
% Return robot structure with R&B values
%
%%

function [robots]=f_create_RB(robots,rb_delay)

if(~nargin)
    num_robots = 2;
    robots = cell(num_robots,1);
    % Create robot data
    for i=1:num_robots
        [robots{i}.t_rob robots{i}.pos_rob robots{i}.delta] = f_create_trajectory(1);
    end
    f_rb = 1; % frequency of R&B measurements [Hz]
end

plot_on = 0;
num_robots = length(robots);


% Threshold beyond which robots dont detect each other
r_thresh = 2.5; % [m]
sig_r = 0.15;
sig_b = 0.15;


pf = 1/rb_delay; % probability of getting RB measurement
    

tmax= inf;
for i=1:num_robots
   tmax_ = length(robots{i}.pos_rob);
   if(tmax_<tmax)
       tmax = tmax_;
   end
   robots{i}.r_range = nan(length(robots{i}.t_rob),num_robots);
   robots{i}.r_bearing = nan(length(robots{i}.t_rob),num_robots);
end


for t=1:tmax
    % Check pairwise distances
    for i=1:num_robots
        for j=i+1:num_robots
            dist_ij = sqrt( (robots{i}.pos_rob(t,1)-robots{j}.pos_rob(t,1))^2 + (robots{i}.pos_rob(t,2)-robots{j}.pos_rob(t,2))^2 );
            if(dist_ij<=r_thresh)
                % Robots detect each other with probability pf
                rn = rand;
                if (rn <= pf) % i detect j
                    % Get nominal bearing
                    dx = robots{j}.pos_rob(t,1)-robots{i}.pos_rob(t,1);
                    dy = robots{j}.pos_rob(t,2)-robots{i}.pos_rob(t,2);
                    alpha = atan2(dy,dx);
                    bear_ij = f_format_angle(-(robots{i}.pos_rob(t,3) - alpha));
                    
                    robots{i}.r_range(t,j) = randn*sig_r*dist_ij  + dist_ij;
                    robots{i}.r_bearing(t,j) = randn* sig_b*bear_ij + bear_ij;
                end
                rn = rand;
                if (rn <= pf) % j detects i
                    dx = robots{i}.pos_rob(t,1)-robots{j}.pos_rob(t,1);
                    dy = robots{i}.pos_rob(t,2)-robots{j}.pos_rob(t,2);
                    alpha = atan2(dy,dx);
                    bear_ji = f_format_angle(-(robots{j}.pos_rob(t,3) - alpha));
                    
                    robots{j}.r_range(t,i) = randn*sig_r*dist_ij + dist_ij;
                    robots{j}.r_bearing(t,i) = randn*sig_b*bear_ji + bear_ji;
                end
            end
        end
        
    end
    
end


if(plot_on)
    col = {'r','g','m','c','b'};
    f1 = figure; hold on
    
    for k=1:1:tmax
        cla(f1)
        for i=1:num_robots
            % Plot robot trajectory (tracked by odometry)
            scatter(robots{i}.pos_rob(k,1),robots{i}.pos_rob(k,2),30,col{i},'filled');  
            % Draw range and bearing
            if(sum(robots{i}.r_range(k,:)>0))
                [ii jj vv] = find(robots{i}.r_range(k,:));
                for j=jj
                    if(j~=i)
                        % Global bearing of detected robot
                        phi = f_format_angle(robots{i}.r_bearing(k,j) + robots{i}.pos_rob(k,3));
                        xv = robots{i}.pos_rob(k,1) + cos(phi) * robots{i}.r_range(k,j);
                        yv = robots{i}.pos_rob(k,2) + sin(phi) * robots{i}.r_range(k,j);
                        X = [robots{i}.pos_rob(k,1) xv];
                        Y = [robots{i}.pos_rob(k,2) yv];
                        fprintf('From %d to %d -- range: %f\t bearing: %f\t phi: %f\t orient: %f\n',...
                            i,j,robots{i}.r_range(k,j),robots{i}.r_bearing(k,j),phi,robots{i}.pos_rob(k,3));
                        line(X,Y,'color',col{i},'linewidth',2);
                    end
                end
            end
        end
        drawnow;
        axis equal
        line([0 3 3 0 0],[0 0 3 3 0]);
        axis([-0.5 3.5 -0.5 3.5]);
        
        pause(0.05);
        %pause
    end
    
    
end



end

