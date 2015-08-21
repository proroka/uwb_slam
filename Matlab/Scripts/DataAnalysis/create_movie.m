% 22.04.2012
% Amanda Prorok
%
%%

clear 
clear functions
close all


% Base station positions
X = [  3.57   3.61    0.10    0.065 ];
Y = [ -0.196  3.7     3.704  -0.196 ];
Z = [  2.474  2.469   2.485   2.495 ];
num_bs = length(X);

run = 10; % run 7: NLOS run 10: LOS
load(strcat('../../Workspaces/synchronized_data_all_run',num2str(run),'.mat'));

% Figure
scr = get(0,'ScreenSize');
f = 2/3;
fig = figure('Position',[1 scr(4)*f scr(4)*f scr(4)*f]); hold on

axis equal
xlabel('X [m]','FontSize',12);
ylabel('Y [m]','FontSize',12);
box on;
if(run==7)
    line([2.85 3.8],[3.55 3.55],'color',[0.8 0.2 0.4],'linewidth',6); % metal sheets
    text(2.8,3.55,'Metal sheet \rightarrow','horizontalalignment','right','FontSize',12);
end
axis([-0.5 4.2 -2 4.2]);
set(gca,'xtick',0:4);
set(gca,'ytick',-2:4);
w = 0.15;
for bs=1:num_bs
    patch([X(bs) X(bs)+w X(bs)+w X(bs) X(bs)],[Y(bs) Y(bs) Y(bs)+w Y(bs)+w Y(bs)],'k');
    % Labels
    if(bs==1||bs==4)
        text(X(bs)-1.5*w,Y(bs)-2*w,strcat('BS-',num2str(bs)),'verticalalignment','bottom','FontSize',12);
    else
        text(X(bs)-1.5*w,Y(bs)+2.8*w,strcat('BS-',num2str(bs)),'verticalalignment','top','FontSize',12);
    end
end

% Movie
if(run==7)
    mname = 'trajectory_NLOS.avi';
else
    mname = 'trajectory_LOS.avi';
end

i = 1;
interval = 2; 
k_ = 1;
rob = [];
if(run==7)
    stt = 50;
else
    stt = 120;
end
for k=stt:interval:length(robots{1}.pos_ubi)
    % Erase previous robot
    delete(rob);
    % Draw robot
    rob = scatter(robots{i}.pos_st(k,1),robots{i}.pos_st(k,2),50,'k');
    % Trajectory
    scatter(robots{i}.pos_st(k,1),robots{i}.pos_st(k,2),15,'xk');
    
    % If there is a ubisense data point for this robot time
    if(sum(~isnan(robots{i}.tdoa(k,:)))==num_bs-1)
        scatter(robots{i}.pos_ubi(k,1),robots{i}.pos_ubi(k,2),15,'r','filled');

    end
    drawnow;
    
    fname = sprintf('im_%04d',k_);
    print('-dpng',fname);
    if(run==7)
        movefile(strcat(fname,'.png'),'./images_NLOS');
    else
        movefile(strcat(fname,'.png'),'./images_LOS');
    end
    k_ = k_+1;
end

% To create mp4 movie, run in terminal:
% Crop images tightly:
% mogrify -crop 650x910+270+10 im_*.png
% Create movie:
% ffmpeg -qscale 1 -r 55 -b 9600 -i im_%04d.png movie.mp4

