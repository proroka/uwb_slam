% 21.05.2011 
% Amanda Prorok
%
% Plot particles
% Input:   
% fig            :   figure handle
% pos            :   swistrack positions (for all robots)

function [robj]=f_plot_ground_truth_movie(a,pos,robj)

if(~isempty(robj))
    delete(robj);
end
for i=1:length(pos)/3 % for all robots
    x = pos((3*i)-2); 
    y = pos((3*i)-1);
    %scatter(a,x,y,[],col(i,:));
    robj=scatter(a,x,y,45,'k');
    % Leave trail
    scatter(a,x,y,12,'kx');
end

end