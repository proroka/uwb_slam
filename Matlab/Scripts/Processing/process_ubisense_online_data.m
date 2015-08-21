% 10.05.2011
% Amanda Prorok

% Process Ubisense data
% Order data into arrays
%
% Perl scrip reads .txt file, outputs matrix:
% time tag-ID x  y  z  ID zero-offset cable-offset event1 event2 raw demod  ID ...
%          (tag)       (sensor1)                                            (sensor2)...
%
%
%%

function [values,tag,sensors,time,tdoa_raw,tdoa_proc]=process_ubisense_online_data(fname,thresh)

save_file = false;
% Choose index: calculations for event 1 or event 2
event = 3; % event 1
%event = 4; % event 2

% Read data into cell array {column}(time-steps)
fid = fopen(fname);
% columns: 5 + 4*7 = 33
values = textscan(fid, '%f %s %f %f %f %s %f %f %f %f %f %f %s %f %f %f %f %f %f %s %f %f %f %f %f %f %s %f %f %f %f %f %f',...    
                 'delimiter', ' ', 'EmptyValue', NaN);
fclose(fid);

% initialize arrays
preamble = 5;  % data in preamble
max_data = 6;  % number of data values per sensor, not including ID
max_col = 4*(max_data+1)+preamble; % number of col. in values file
max_num_steps = length(values{1})-1;
tag.pos = zeros(max_num_steps,3);   % tag positions
sensors = zeros(max_num_steps,max_data,4); % data of all sensors

time = values{1};
tag.ID = values{2};
tag.pos = [values{3}(1:max_num_steps) values{4}(1:max_num_steps) values{5}(1:max_num_steps)]; 


% go through sensor data, order wrt sensor
% 3F:90 - 40:25 - 40:61 - 3F:F4 (master, then anti-clockwise)
for i=1:max_num_steps
    % copy sensor values into array
    for j=6:7:max_col
        
        if ( strcmp(values{j}(i),'11:ce:00:3f:90') ) % master
            v = [];
            for k=1:max_data
                v = [v values{j+k}(i)];
            end
            sensors(i,:,1) = v;
        end
        
        if ( strcmp(values{j}(i),'11:ce:00:40:25') )
            v = [];
            for k=1:max_data
                v = [v values{j+k}(i)];
            end
            sensors(i,:,2) = v;
        end
    
        if ( strcmp(values{j}(i),'11:ce:00:40:61') )
            v = [];
            for k=1:max_data
                v = [v values{j+k}(i)];
            end
            sensors(i,:,3) = v;
        end
        
        if ( strcmp(values{j}(i),'11:ce:00:3f:f4') )
            v = [];
            for k=1:max_data
                v = [v values{j+k}(i)];
            end
            sensors(i,:,4) = v;
        end
    
    end
end


e = reshape(sensors(:,event,1:4),size(sensors,1),4);
e(e==-9999) = NaN; % remove faulty data
o = reshape(sensors(:,2,1:4),size(sensors,1),4); % offsets (master has 0-offset)
tdoa_raw = zeros(length(e),3);
for i=1:3
    tdoa_raw(:,i) = e(:,i+1) - e(:,1) - o(:,i+1); % BS_i - BS_1
end
% filter measured TDOAs (safe threshold: cutoff -thresh<v<+thresh)
tdoa_proc = tdoa_raw;
tdoa_proc((tdoa_raw<-thresh)|(tdoa_raw>thresh)) = NaN;

if(save_file)
    matfile = strcat('../../Workspaces/',datafile,'.mat');
    save(matfile,'values', 'tag', 'sensors', 'time','tdoa_raw','tdoa_proc'); 
end
   
end
    
    
    