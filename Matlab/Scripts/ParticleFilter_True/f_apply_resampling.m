% 13.12.2011
% Amanda Prorok
%
% Particle sampling function
% In:
% particles    :    weighted old particle set
% rand_bias    :    add to all particles, to avoid particle collapse
% Out:
% particles    :    new particle set, equally weighted (=1)
%%


function [particles] = f_apply_resampling(particles,rand_bias)

num_particles = size(particles.pos,1);

bias = rand_bias * max(particles.w);
particles.w = particles.w + bias;

% Standard resampling
ind = f_low_variance_sampling(particles.w);
particles.pos = particles.pos(ind,:);

particles.w = ones(num_particles,1);
         
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