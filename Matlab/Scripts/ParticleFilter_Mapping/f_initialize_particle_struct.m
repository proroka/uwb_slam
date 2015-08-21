% 10.04.2912
% Amanda Prorok
%
% Initialize particle structure:
% gridmap
%
%%

function [particles]=f_initialize_particle_struct(num_robots,num_particles,num_bs,num_cells,num_s)

% Initialize particle structure
particles = cell(num_robots,1);

% Initialize maps: use same initial parameter values for all maps, for all cells
pn.s = 0.047;
pln0.m = [-0.2 -0.2];
pln0.s = [0.5 0.5];
plos0 = [0.5 0.5];
[mt0 st0] = f_get_approx_normal(pln0.m,pln0.s);
par_opt0 = [pn.s pln0.m(1) pln0.m(2) pln0.s(1) pln0.s(2) mt0 st0 plos0(1) plos0(2)];
shat0 = zeros(num_s,1);
schat0 = zeros(2,1);

% Update first X 's' values for more robust EM
N = 1000;
dtdoa_sim = f_create_dtdoa_approx(linspace(-4,4,1500),pn,pln0,plos0,N); % 1xN
for its=1:N
    gamma = 1/(its^0.65);
    [~,shat0,schat0] = f_online_EM_update(par_opt0,dtdoa_sim.data(its),shat0,schat0,pn,gamma,1,100);
end
for rob=1:num_robots
    particles{rob}.pos = zeros(num_particles,2);
    particles{rob}.w = ones(num_particles,1);
    particles{rob}.pcell = ones(num_particles,2); 
    for i=1:num_particles
        for bs=1:num_bs-1
            particles{rob}.dtdoa{bs} = nan(i,1);
            for ix=1:num_cells
                for iy=1:num_cells
                    particles{rob}.maps{i,1,ix,iy}.ndp = 1; % use bs 1 (since all the same)
                    particles{rob}.maps{i,bs,ix,iy}.par_opt = par_opt0;
                    particles{rob}.maps{i,bs,ix,iy}.shat = shat0;
                    particles{rob}.maps{i,bs,ix,iy}.schat = schat0;
                end
            end
        end
    end
end



end