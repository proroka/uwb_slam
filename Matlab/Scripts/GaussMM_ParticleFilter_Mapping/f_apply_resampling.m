% 13.12.2011
% Amanda Prorok
%
% Particle sampling function
% In:
% particles    :    weighted old particle set (for all robots)
% rand_bias    :    add to all particles, to avoid particle collapse
% Out:
% particles    :    new particle set, equally weighted (=1)
%%


function [particles] = f_apply_resampling(particles,rand_bias,robots,t,num_bs)

num_particles = size(particles{1}.pos,1);
num_robots = size(particles,1);

for rob=1:num_robots
    if(sum(~isnan(robots{rob}.tdoa(t,:)))==num_bs-1)
        
        bias = rand_bias * max(particles{rob}.w);
        particles{rob}.w = particles{rob}.w + bias;
        
        % Standard resampling
        ind = f_low_variance_sampling(particles{rob}.w);
        
        % Copy all structure elements
        particles{rob}.pos = particles{rob}.pos(ind,:);
        
        for i=1:num_particles
            for bs=1:num_bs-1
                particles{rob}.dtdoa{bs}(i,:) = particles{rob}.dtdoa{bs}(ind(i),:);
                %particles{rob}.par{bs}.m(i,:) = particles{rob}.par{bs}.m(ind(i),:);
                %particles{rob}.par{bs}.s(i,:) = particles{rob}.par{bs}.s(ind(i),:);
                %particles{rob}.par{bs}.w(i,:) = particles{rob}.par{bs}.w(ind(i),:);
            end
        end
        
        % Reset weights
        particles{rob}.w = ones(num_particles,1);
        
    end
end

end

%%
% 31.05.2011
% Amanda Prorok
%
% Low variance resampling algorithm
% p.110 Thrun
%

function [indeces]=f_low_variance_sampling(weights) % 1:num_particles,num_particles,true,particles.w)

num_particles = length(weights);
sw = sum(weights);
r = rand() * (sw/num_particles);
c = weights(1);
j = 1;

indeces = [];
for m=0:num_particles-1
    U = r + m * (sw/num_particles);
    while(U > c)
        j = j+1;
        if (j > num_particles), j = num_particles; end
        c = c + weights(j);
    end
    indeces = [indeces; j];
end

end