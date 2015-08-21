% 20.12.2011
% 11.04.2012
% Amanda Prorok
%
% Calculate nominal dtdoa
% For all robots
%
% --In--
% particles       :      particle stucture
% robots          :      robots structure
% X,Y,Z           :      base-station positions
% t               :      current time
% nom             :      boolean, use nominal dtdoa
%
% --Out--
% particles{rob}.dtdoa{bs}         :      [num_particles,3]
%                                  :      nominal dtdoa values; NaN
%                                  :      when no tdoa measures taken
%%



function [particles] = f_get_particle_dtdoa(particles,robots,X,Y,Z,t,nom)

verbose = 0;

num_robots = size(robots,1);
num_bs = size(X,2);
num_particles = size(particles{1}.pos,1);

for rob=1:num_robots
    if(sum(~isnan(robots{rob}.tdoa(t,:)))==num_bs-1)
        if(~nom) % use particle positions
            for i=1:num_particles
                % Get dtdoa (measured tdoa - tdoa perceived at particle position) , vector: 1x3
                pdtdoa = f_get_dtdoa(robots{rob}.tdoa(t,:),particles{rob}.pos(i,:),X,Y,Z);
                % Add a new dtdoa value to matrix
                for bs=1:num_bs-1
                    particles{rob}.dtdoa{bs}(i,end+1) = pdtdoa(bs);
                end
            end
        else  % use ground truth position
            % Get nominal dtdoa (measured tdoa - nominal tdoa) , vector: 1x3
            dtdoa = f_get_dtdoa(robots{rob}.tdoa(t,:),robots{rob}.pos_st(t,:),X,Y,Z);
            % Assign dtdoa value, same for all particles
            for bs=1:num_bs-1
                particles{rob}.dtdoa{bs}(:,end+1) = repmat(dtdoa(bs),num_particles,1);
            end
        end
        
        if(verbose)
            fprintf('R[%d] has %d dtdoa values\n',rob,length(particles{rob}.dtdoa{1}(1,:)));
        end
    end
end


end

