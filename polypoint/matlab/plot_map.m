close all
load('../data/AnchorsLocation.mat')

approx_anchors = [-0.8,3.7;-2,3.7 ];

plot(anchors(:,1),anchors(:,2),'o')
hold on
plot(approx_anchors(:,1),approx_anchors(:,2),'ro')

% wall
plot([-3,4],[3,3],'k-')
plot([-3,4],[2.7,2.7],'k-')


plot([-3,-1.5],[4.2,4.2],'k-')
plot([-0.2,4],[4.2,4.2],'k-')
plot([-3,-1.7],[4.4,4.4],'k-')
plot([0,4],[4.4,4.4],'k-')


plot([-1.5,-1.5],[4.2,5.4],'k-')
plot([-0.2,-0.2],[4.2,5.4],'k-')
plot([-1.7,-1.7],[4.4,5.4],'k-')
plot([0,0],[4.4,5.4],'k-')


text(-2.5,2.9,'wall')


for i = 1: length(anchors)
    text(anchors(i,1)+0.2,anchors(i,2),num2str(i))
end

for i = 1: length(approx_anchors)
    text(approx_anchors(i,1)+0.2,approx_anchors(i,2),num2str(i+ length(anchors)))
end

