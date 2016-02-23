%
% analyze polypoint ranges

close all
clear

load ../data/distances2d.mat
load ../data/AnchorsLocation.mat

% plot anchor nodes
ax = anchors(:,1);
ay = anchors(:,2);
num_anchors = length(ax);
a = [1:num_anchors]'; b = num2str(a); c = cellstr(b);
dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
scatter(ax,ay,'k.');
text(ax+dx, ay+dy, c);

% create range-data cell
combs = nchoosek(1:num_anchors,2);
ncombs = size(combs,1)*2; % number of combinations of anchor nodes, order dependent
range_data = cell(ncombs,1);
range_true = zeros(ncombs,1);
range_labels = cell(ncombs,1);
for i=1:ncombs/2
    lab = strcat('ranges',num2str(combs(i,1)),num2str(combs(i,2)));
    range_data{i} = eval(lab);
    % true range
    dx = ax(combs(i,1)) - ax(combs(i,2));
    dy = ay(combs(i,1)) - ay(combs(i,2));
    range_true(i) = norm([dx, dy]);
    range_labels{i} = lab;
end
for i=1:ncombs/2
    lab = strcat('ranges',num2str(combs(i,2)),num2str(combs(i,1)));
    range_data{ncombs/2+i} = eval(lab);
    range_true(ncombs/2+i) = range_true(i);
    range_labels{ncombs/2+i} = lab;
end
    

figure;
axes('position', [0 0 1 1]);
m = 2;
n = 10;
offset = 1.0;
% clean data
for i=1:ncombs
    subplot(m,n,i);
    hold on;
    a = range_data{i};
    nz = a(a~=0);
    nz = nz + offset;
    range_data{i} = nz;
    [counts, centers] = hist(nz,50);
    mc = max(counts);
    bar(centers,counts);
    plot([range_true(i), range_true(i)],[0,mc],'r--','linewidth',2);
    axis tight
    title(range_labels{i})
end



%range_data = ranges14;
%edges = linspace(-8,8,100);
%hist(range_data, edges)