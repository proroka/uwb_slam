% 5.01.2012
% Amanda Prorok
%
% Online EM update function
% In:
% Previous estimates, given new datapoint
% Out: updated estimates
%%


function [par_opt,shat,schat] = f_online_EM_update(p_par_opt,datap,p_shat,p_schat,pn,gamma,n,mindp)

if(n<mindp) % empty updates
    gamma = 1/n;
    T = f_get_T_online(p_par_opt,datap);
    [sbar scbar] = f_update_S_online(T,datap,p_shat); 
    shat = p_shat + gamma * (sbar - p_shat);
    schat = p_schat + gamma * (scbar - p_schat);
    par_opt = p_par_opt;
else % parameter updates
    %fprintf('EM update\n');
    T = f_get_T_online(p_par_opt,datap);
    [sbar scbar] = f_update_S_online(T,datap,p_shat); 
    shat = p_shat + gamma * (sbar - p_shat);
    schat = p_schat + gamma * (scbar - p_schat);
    par_opt = f_update_par_online(shat,schat,pn.s,p_par_opt,n);
end


end