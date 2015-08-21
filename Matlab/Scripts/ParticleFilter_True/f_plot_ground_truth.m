% 21.05.2011 
% Amanda Prorok
%
% Plot particles
% Input:   
% fig            :   figure handle
% pos            :   swistrack positions (for all robots)

function []=f_plot_ground_truth(a,pos,col)


for i=1:length(pos)/3 % for all robots
    x = pos((3*i)-2); 
    y = pos((3*i)-1);
    scatter(a,x,y,[],col(i,:));
end

end