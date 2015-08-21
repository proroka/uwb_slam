



function p1=f_motion_model(p0,robots,t,a_lim,jitter_thresh,walls)

p1 = p0;
num_particles = size(p0{1}.pos,1);
num_robots = size(p0,1);

% Noise factors
dt_enc = 0.05;
A1 = 0.2 * dt_enc; %0.5 * dt_enc;
A2 = 1 * dt_enc; %1.5625 * dt_enc;
A3 = 0.6 * dt_enc; %0.32 * dt_enc;
A4 = 0.14 * dt_enc; %0.12 * dt_enc;
xeps = 0; yeps = 0; theps = 0;

for i=1:num_robots
    % Relative changes in x,y,th
    delta = robots{i}.delta(t,:);   % dx dy dth
    
    %pth = p0{i}.pos(:,3); 
    %pth = robots{i}.pos_rob(t-1,3); % previous theta (global)
    pth = robots{i}.pos_st(t-1,3); % previous theta (global)
    
    dtrans = repmat(norm([delta(1) delta(2)]),num_particles,1);
    drot1 = -f_format_angle(pth - atan2(delta(2),delta(1)));
    drot2 = f_format_angle(delta(3) - drot1);
    
    v_drot1 = drot1 - (A1*abs(drot1) + A2*dtrans).*randn(num_particles,1);
    v_dtrans = dtrans - (A3*dtrans + A4*(abs(drot1)+abs(drot2)).*randn(num_particles,1));
    v_drot2 = drot2 - (A1*abs(drot2) + A2*dtrans).*randn(num_particles,1);
    
     % Jitter if cloud is collapsing
    if(f_pos_var(p1{i})<jitter_thresh)
        %fprintf('Jitter\n');
        xeps = 0.01 * randn(num_particles,1);
        yeps = 0.01 * randn(num_particles,1);
        theps = 0.03 * randn(num_particles,1);
    end
    
    s = sin(p0{i}.pos(:,3) + v_drot1);
    c = cos(p0{i}.pos(:,3) + v_drot1);
    p0{i}.pos(:,1) = p0{i}.pos(:,1) + v_dtrans.*c + xeps;
    p0{i}.pos(:,2) = p0{i}.pos(:,2) + v_dtrans.*s + yeps;
    p0{i}.pos(:,3) = p0{i}.pos(:,3) + v_drot1 + v_drot2 + theps;
    p0{i}.pos(:,3) = f_format_angle(p0{i}.pos(:,3));
    p1{i}.pos = p0{i}.pos;
    

    
    
    % Adapt weights if leaving arena
    if(walls)
        ind = p1{i}.pos(:,1)<a_lim(1);
        p1{i}.w(ind) =  0;
        ind = p1{i}.pos(:,1)>a_lim(2);
        p1{i}.w(ind) =  0;
        ind = p1{i}.pos(:,2)<a_lim(3);
        p1{i}.w(ind) =  0;
        ind = p1{i}.pos(:,2)>a_lim(4);
        p1{i}.w(ind) =  0;
    end
    
end



end



function [v]=f_pos_var(particles)

v = var(particles.pos,0,1);
v = v(1) + v(2); % variance in x and y
    
end

