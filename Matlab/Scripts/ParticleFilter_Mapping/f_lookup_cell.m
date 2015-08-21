% 09.01.2012
% Amanda Prorok
%
% Return the cell indeces corr. to particle position
% ix,iy follow x and y axes
%%

function [ix iy oob] = f_lookup_cell(pos, num_cells, a_lim)

oob = false;
ix = [];
iy = [];
if(pos(1)<a_lim(1)||pos(1)>a_lim(2)||pos(2)<a_lim(1)||pos(2)>a_lim(2))
    oob = true;
else
    ds = (a_lim(2) - a_lim(1)) /num_cells;
    ix = floor(pos(1)/ds) + 1;
    iy = floor(pos(2)/ds) + 1;
end

end