% 09.04.2012
% Amanda Prorok
%
%
% -- In --
% particles
% tdoa          :       [1,num_bs-1]
% err_pdf       :       [length(ax) num_bs-1]
% X,Y,Z
% -- Out --
% particles     :       weighted for all BS pairs
%%

function [particles]=f_apply_UWB_model(particles,tdoa,err_pdf,ax,X,Y,Z)

num_particles = size(particles.pos,1);

% Robot height
rh = 0.12;
num_bs = length(X);
% Distance from BS1
bs1_pos = [X(1) Y(1) Z(1)];
d1 = [particles.pos(:,1:2), repmat(rh,num_particles,1)] - repmat(bs1_pos,num_particles,1);
d1 = sqrt(d1(:,1).^2 + d1(:,2).^2 + d1(:,3).^2);
    
P = ones(num_particles,1);
for bs = 2:num_bs
    % Get nominal TDOA value [m]
    bs_pos = [X(bs) Y(bs) Z(bs)];
    dbs = [particles.pos(:,1:2), repmat(rh,num_particles,1)] - repmat(bs_pos,num_particles,1);
    dbs = sqrt(dbs(:,1).^2 + dbs(:,2).^2 + dbs(:,3).^2);
    % Vector of 'nominal tdoa' given all particle positions
    nom_tdoa  = dbs - d1;
    
    % D is the delta-tdoa perceived by the particles [num_particles x 1]
    D = repmat(tdoa(bs-1),num_particles,1) - nom_tdoa;
    
    % Lookup probability of D in given dtdoa error model
    pLN = interp1([-10000; ax; 10000],[0; err_pdf(:,bs-1); 0],D);
    %if(isnan(pLN)) fprintf('bs %d D %f\n',bs,D);end
    P  = P .* pLN;
end

% Normalization
if(num_particles>1)
    tw = sum(P);
    P = P ./ tw;
end

particles.w = particles.w .* P;

end