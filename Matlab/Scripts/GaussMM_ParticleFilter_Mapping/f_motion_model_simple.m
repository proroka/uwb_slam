% 13.12.2011 (modified from previous)
% Amanda Prorok
% 
% Apply motion model to particle positions
% Input:     p0            :  current particle positions
%            robots        :  robot structure 
%            robots.delta  :  [dx dy dth] 
% Ouput:     p1            :  new particle positions

function [p1] = f_motion_model_simple(p0,robots,t,a_lim,jitter_thresh,walls,mov_sig)

p1 = p0;
num_particles = size(p0{1}.pos,1);
num_robots = size(p0,1);

xeps = 0;
yeps = 0;

for i=1:num_robots
    % Relative changes in x,y,th
    delta = robots{i}.delta(t,:);   % dx dy dth

    % Jitter if cloud is collapsing
    if(f_pos_var(p1{i})<jitter_thresh)
        xeps = 0.015 * randn(num_particles,1);
        yeps = 0.015 * randn(num_particles,1);
    end

    dx = delta(1) + randn(num_particles,1)*mov_sig + xeps;
    dy = delta(2) + randn(num_particles,1)*mov_sig + yeps;
    p1{i}.pos = p0{i}.pos + [dx dy zeros(num_particles,1)];
    
   
    
    % Adapt weights if leaving arena
    if(walls)
        ind = p1{i}.pos(:,1)<a_lim(1);
        p1{i}.w(ind) =  0;
        p1{i}.pos(ind,1) = p0{i}.pos(ind,1);
        
        ind = p1{i}.pos(:,1)>a_lim(2);
        p1{i}.w(ind) =  0;
        p1{i}.pos(ind,1) = p0{i}.pos(ind,1);
        
        ind = p1{i}.pos(:,2)<a_lim(3);
        p1{i}.w(ind) =  0;
        p1{i}.pos(ind,2) = p0{i}.pos(ind,2);
        
        ind = p1{i}.pos(:,2)>a_lim(4);
        p1{i}.w(ind) =  0;
        p1{i}.pos(ind,2) = p0{i}.pos(ind,2);
    end
    
end


end


function [v]=f_pos_var(particles)

v = var(particles.pos,0,1);
v = v(1) + v(2); % variance in x and y
    
end



