% 13.04.2012
% Amanda Prorok
%
% Estimate Gaussian MM models
% For a given robot
% Return probabilities of all particles
%
% In:
%
% Out:
%%


function [particles] = f_apply_UWB_model(particles,robots,t,X,Y,Z,a_lim,num_mod,verbose)


num_bs = size(X,2);
num_robots = size(particles,1);
num_particles = size(particles{1}.w,1);

% EM
min_ndp = 4;
max_iter = 30;


% Get models for all particles and weight
for rob=1:num_robots
      
    % Apply UWB model
    tdoa = robots{rob}.tdoa(t,:);
    if(sum(~isnan(tdoa))==num_bs-1)
        if(verbose)
            fprintf('R[%d] Apply UWB\n',rob);
        end
        P = ones(num_particles,1);
        for i=1:num_particles
                ndp = length(particles{rob}.dtdoa{1}(i,:)); % use bs 1 (same for all)
                %disp(ndp)
                prev_par = cell(3,1); % struct with .m .s .w
                for bs=1:num_bs-1
                    % Store previous parameter values
                    prev_par{bs} = particles{rob}.par{bs};
                    % Run batch EM
                    if(ndp>=min_ndp)
                        particles{rob}.par{bs} = f_batch_EM(particles{rob}.dtdoa{bs}(i,:),num_mod,max_iter);
                    end
                end
                % Weight particles
                if(ndp>=min_ndp+1)
                    particle_dtdoa = f_get_dtdoa(tdoa,particles{rob}.pos(i,:),X,Y,Z);
                    P(i) = f_get_dtdoa_prob(prev_par,particle_dtdoa); 
                end      
        end
        % Normalize P for all particles
        P = P ./ sum(P);
        
        % Weight particles
        particles{rob}.w = particles{rob}.w .* P;
        
    end
   
end

end


