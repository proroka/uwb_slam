% 14.12.2011 (modified) 
% Amanda Prorok
%
% Returns vector of ground truth dt-tdoa values (num_bs-1 x 1)
% In:
% tdoa      :     measured tdoa (1x3 non-empty values): BSX-BS1
% robot_pos :     ground truth robot position
% X,Y,Z     :     base-station positions
% Out:
% DTDOA     :     true delta-tdoa (true tdoa measurement error), 1x3
%%

function [DTDOA]=f_get_dtdoa(tdoa,robot_pos,X,Y,Z)

% Add robot height as z
rh = 0.12;
pos = [robot_pos(1:2) rh];

num_bs = length(X);
DTDOA = zeros(1,num_bs-1);

% Distance: BSX - BS1 (reference station)
bs1_pos = [X(1) Y(1) Z(1)];
d1 = pos - bs1_pos;
d1 = sqrt(d1(1).^2 + d1(2).^2 + d1(3).^2);

for bs = 2:num_bs
    % Get nominal TDOA value [m]
    bs_pos = [X(bs) Y(bs) Z(bs)];
    dbs = pos - bs_pos;
    dbs = sqrt(dbs(1).^2 + dbs(2).^2 + dbs(3).^2);
    % BSX - BS1 (reference station)
    nom_tdoa  = dbs - d1;
    DTDOA(bs-1) = tdoa(bs-1) - nom_tdoa; 
end

end
