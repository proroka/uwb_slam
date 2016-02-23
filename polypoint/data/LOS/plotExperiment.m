function [ output_args ] = plotExperiment( num )
if ~nargin
    num = 1;
end
%PLOTEXPERIMENT 
% plot 1 of the 5 experiments
% input: number from 1 to 5
% 1 experiment1 between tag A and B
% 2 experiment1b between tag A and B,again
% 3 experiment2 between tag C and D
% 4 experiment3 between tag C and A
% 5 experiment3 between tag D and B
Experiment = [];
switch num
    case 1       
        fprintf('\n Experiment 1: 2 Nodes; Ranges between Tags A and B \n Los. variable distance \n');
        load('Experiment1.mat');
        Experiment = Experiment1;
    case 2
        fprintf( '\n Experiment 1b: 2 Nodes; Ranges between Tags A and b (again) \n Los. variable distance \n');
        load('Experiment1b.mat');
        Experiment = Experiment1b;
    case 3
        fprintf( '\n Experiment 2: 2 Nodes; Ranges between Tags C and D (different pair) \n Los. variable distance \n');
        load('Experiment2.mat');
        Experiment = Experiment2;
        
    case 4
        fprintf( '\n Experiment 3: 2 Nodes; Ranges between Tags A and C (cross) \n Los. variable distance \n');
        load('Experiment3.mat');
        Experiment = Experiment3;
        
    case 5
        fprintf( '\n Experiment 4: 2 Nodes; Ranges between Tags B and D (cross) \n Los. variable distance \n');
        load('Experiment4.mat');
        Experiment = Experiment4;
    
    otherwise
        fprintf('\n Please choose a number from 1 to 5');
        return; 
end

fprintf([' Anchor id: ' Experiment.anchorName '\n']);
fprintf([' Tag id: ' Experiment.tagName '\n']);

n = size(Experiment.ranges,1);

fprintf(['a maximum of ' num2str(length(Experiment.ranges)) ' ranges where' ...
    ' collected at ' num2str(n) ' different increasing distances\n']);
fprintf(['results are shown in figure(' num2str(num) ') \n\n']);
fprintf(' Note: some ranges are qeual to zero even for distances far from 0. maybe is a type of error.');
fprintf('I kept them for now. Wrong ranges value are expressed as nan \n \n');

if n < 6
    rows = 2;
else
    rows = 3;
end

figure(num)    
for i = 1 : n
    subplot(rows,3,i)
    nbins = round(sqrt(length(Experiment.ranges(i,:))));
    hist(Experiment.ranges(i,:),nbins)
    hold on
    plot([Experiment.gt(i) Experiment.gt(i)],[0 100],'g')
    hold off
end

r = Experiment.ranges;

filename = strcat('ranges_exp',num2str(num));
save(filename, 'r')

end

