%
%
%
%
%%


function [tdoa]=f_get_nominal_tdoa(pos,X,Y,Z)

num_bs = size(X,2);
tdoa = zeros(length(pos),num_bs-1);

rh = 0.12;

dist = zeros(length(pos),num_bs);
for i=1:num_bs
    %dist(:,i) = sqrt( (X(i)-pos(:,1)).^2 + (Y(i)-pos(:,2)).^2 + %(Z(i)-pos(:,3)).^2 );
    dist(:,i) = sqrt( (X(i)-pos(:,1)).^2 + (Y(i)-pos(:,2)).^2 + (Z(i)-rh).^2 );
end

for i=1:num_bs-1
    tdoa(:,i) = dist(:,i+1)-dist(:,1);
end

end