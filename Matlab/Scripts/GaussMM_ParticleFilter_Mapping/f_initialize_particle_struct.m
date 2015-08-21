% 10.04.2912
% Amanda Prorok
%
% Initialize particle structure:
% gridmap
%
%%

function [particles]=f_initialize_particle_struct(num_robots,num_particles,num_bs,num_mod)

% Initialize particle structure
particles = cell(num_robots,1);

% Initialize maps: Gaussian Mixture Model
% Use same initial parameter values for all maps, for all cells
par0.m = [-1 -0.1 0.1 1];
par0.s = [1 1 1 1];
par0.w = 1/num_mod .* ones(1,num_mod);

for rob=1:num_robots
    particles{rob}.pos = zeros(num_particles,2);
    particles{rob}.w = ones(num_particles,1);
    for bs=1:num_bs-1
        particles{rob}.dtdoa{bs} = [];  % data used for EM: either nominal or estimate
        particles{rob}.par{bs}.m = par0.m;                % current parameter set: mean
        particles{rob}.par{bs}.s = par0.s;                % current parameter set: sigma
        particles{rob}.par{bs}.w = par0.w;                % current parameter set: weights
    end  
end


end