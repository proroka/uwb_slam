% 6.04.2012
% Amanda Prorok
%
% For 1 robot:
% Create TDOA data along robot trajectory for simulator
% Define LOS-NLOS parts of robot trajectory (either manually or default)
%
% Sample tdoa data according to BS configuration for all
% trajectory positions
%
% -- In --
%
% -- Out --
% tdoa_dsamp          :         [t_max,num_bs-1] down-sampled tdoa (nan if no value)
% dtdoa_dsamp         :         [t_max,num_bs-1] down-samples dtdoa
% rob_nlos            :         [t_max,num_bs-1] 0 or 1 indeces if NLOS
%%


function [tdoa_dsamp dtdoa_dsamp rob_nlos_dsamp]=f_create_tdoa(default,bs_nlos,pos_rob,uwb_freq,num_bs,X,Y,Z,pn,pln,P,P_)

verbose = 0;

t_max = size(pos_rob,1)
tdoa = zeros(t_max,num_bs-1);
dtdoa = zeros(t_max,num_bs-1);

% For each BS, store trajectory points in NLOS
rob_nlos = zeros(t_max,num_bs);

% Define NLOS area for each BS
for i=1:num_bs
    % Only for NLOS base-stations
    if(bs_nlos(i))
        % Create figure and plot arena
        scr = get(0,'ScreenSize');
        f = 2/3;
        fig = figure('Position',[1 scr(4)*f scr(4)*f scr(4)*f]);
        hold on;
        axis([-0.5 3.5 -0.5 3.5]);
        plot([0 3 3 0 0],[0 0 3 3 0],'k');
        title(strcat('BASE-STATIONS: 1-',num2str(i)));
        axis equal
        ax = gca;
        % Create custom or default polygon
        if(~default)
            max_points = 100;
            fprintf('*************************\n');
            fprintf('Enter NLOS POLYGON and press return\n');
            fprintf('*************************\n\n');
            set(fig,'CurrentAxes',ax);
            plot(ax,pos_rob(:,1),pos_rob(:,2),'m');
            [x,y] = ginput(max_points);
            % Check if outside arena
            for k=1:length(x)
                if(x(k)<0), x(k)=0; end
                if(x(k)>3), x(k)=3; end
                if(y(k)<0), y(k)=0; end
                if(y(k)>3), y(k)=3; end
            end
            % Close the polygon
            x(end+1) = x(1);
            y(end+1) = y(1);
            np = length(x);
        else % use default pattern
            x = [0.01 3 3 0.01 0.01]';
            y = [0 0 2.75 2.75 0]';
            np = length(x);
        end
        % Show NLOS polygon
        mapshow(ax,x,y,'DisplayType','polygon','LineStyle','none');
        % Get points inside polygon
        [inp] = inpolygon(pos_rob(:,1),pos_rob(:,2),x,y);
        pos_rob_nlos = pos_rob(inp,:);
        plot(ax,pos_rob(:,1),pos_rob(:,2),'m');
        plot(ax,pos_rob_nlos(:,1),pos_rob_nlos(:,2),'g');
        rob_nlos(:,i) = inp;
    end
    
end % for all BS

if(verbose)
    fprintf('Number of NLOS points -- BS 1: %d\n',sum(rob_nlos(:,1)));
    fprintf('Number of NLOS points -- BS 2: %d\n',sum(rob_nlos(:,2)));
    fprintf('Number of NLOS points -- BS 3: %d\n',sum(rob_nlos(:,3)));
    fprintf('Number of NLOS points -- BS 4: %d\n',sum(rob_nlos(:,4)));
end


% Sample tdoa data for all BS pairs
for i=1:num_bs-1
    for t=1:t_max
        if(rob_nlos(t,1)==0 && rob_nlos(t,i+1)==0)        % LOS-LOS
           plos = [P P];  
        elseif(rob_nlos(t,1)==1 && rob_nlos(t,i+1)==0)    % NLOS-LOS
            plos = [P_ P]; 
        elseif(rob_nlos(t,1)==0 && rob_nlos(t,i+1)==1)    % LOS-NLOS
            plos = [P P_];
        else                                              % NLOS-NLOS
            plos = [P_ P_];
        end
        [tdoa(t,i) dtdoa(t,i)] = f_create_tdoa_data_approx(0,1,pn,pln,plos,pos_rob(t,1:2),X,Y,Z,i+1);
    end
end


% Down-sample UWB data (use uwb sampling frequency)
% Robot data resolution is highest freq. possible
tdoa_dsamp = nan(length(tdoa),num_bs-1);
dtdoa_dsamp = nan(length(dtdoa),num_bs-1);
rob_nlos_dsamp = nan(length(rob_nlos),num_bs);
for i=1:length(tdoa)
    if(mod(i,uwb_freq)==0)
        tdoa_dsamp(i,:) = tdoa(i,:);
        dtdoa_dsamp(i,:) = dtdoa(i,:);
        rob_nlos_dsamp(i,:) = rob_nlos(i,:);
    end
end

end




