% 10.04.2012
% Amanda Prorok
%
% Calculate online models
% For a given robot
% Return probabilities of all particles
%
% In:
%
% Out:
%%


function [particles] = f_apply_UWB_model(particles,robots,pn,t,X,Y,Z,gfac,gconst,a_lim,verbose)


num_bs = size(X,2);
num_robots = size(particles,1);
num_particles = size(particles{1}.w,1);
num_cells = size(particles{1}.maps,4);


% Get models for all particles and weight
for rob=1:num_robots
    
    % Store the previously occupied cells
    for i=1:num_particles
        % Lookup cell corr. to particle pos
        [curr_ix curr_iy oob] = f_lookup_cell(particles{rob}.pos(i,:),num_cells,a_lim);
        if(~oob)
            % Previous cell
            prev_ix = particles{rob}.pcell(i,1);
            prev_iy = particles{rob}.pcell(i,2);
            % If current is new, unvisited cell, assign parameters of previous cell
            if((curr_ix~=prev_ix || curr_iy~=prev_iy) && particles{rob}.maps{i,1,curr_ix,curr_iy}.ndp==1)
                for bs=1:num_bs-1
                    particles{rob}.maps{i,bs,curr_ix,curr_iy}.par_opt = particles{rob}.maps{i,bs,prev_ix,prev_iy}.par_opt;
                end
            end
            particles{rob}.pcell(i,:) = [curr_ix curr_iy];
        end
    end
    
    tdoa = robots{rob}.tdoa(t,:);
    if(sum(~isnan(tdoa))==num_bs-1)
        if(verbose)
            fprintf('R[%d] Apply UWB\n',rob);
        end
        P = ones(num_particles,1);
        for i=1:num_particles
            % Lookup cell corr. to particle pos
            [ix iy oob] = f_lookup_cell(particles{rob}.pos(i,:),num_cells,a_lim);
            % Make sure particle is not out-of-bounds
            if(~oob)
                ndp = particles{rob}.maps{i,1,ix,iy}.ndp; % use bs 1 (same for all)
                particles{rob}.maps{i,1,ix,iy}.ndp = ndp+1;
                
                ppln = cell(3,1);
                pplos = cell(3,1);
                for bs=1:num_bs-1
                    % Get datapoint
                    datap = particles{rob}.dtdoa{bs}(i);
                    % Get stored parameters of current grid cell
                    p_par_opt = particles{rob}.maps{i,bs,ix,iy}.par_opt;
                    p_shat = particles{rob}.maps{i,bs,ix,iy}.shat;
                    p_schat = particles{rob}.maps{i,bs,ix,iy}.schat;
                    
                    gamma = 1/(ndp^gfac);
                    if(gconst)
                        
                        gamma = gconst;
                        
                    end
                    
                    [par_opt shat schat] = f_online_EM_update(p_par_opt,datap,p_shat,p_schat,pn,gamma,ndp,0);
                    
                    particles{rob}.maps{i,bs,ix,iy}.par_opt = par_opt;
                    particles{rob}.maps{i,bs,ix,iy}.shat = shat;
                    particles{rob}.maps{i,bs,ix,iy}.schat = schat;
                    % Use previous model values to update probability
                    ppln{bs}.m = p_par_opt(2:3);
                    ppln{bs}.s = p_par_opt(4:5);
                    pplos{bs} = p_par_opt(8:9);
                end
                
                % Weight particles
                P(i) = f_get_dtdoa_pdf_and_prob(pn,ppln,pplos,particles{rob}.pos(i,:),tdoa,X,Y,Z); % * log(ndp)
            else
                % Remove out of bounds particles
                P(i) = 0;
            end
            
        end
        
        % Normalize P for all particles
        P = P ./ sum(P);
        % Weight particles
        particles{rob}.w = particles{rob}.w .* P;
        
    end
    
end

end



