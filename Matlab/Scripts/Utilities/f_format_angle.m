% 21.05.2011
% Amanda Prorok
%
% Format angles in vector a to fit in range -pi,pi

function a = f_format_angle(a)

g = a > pi;
s = a < -pi;
while (sum(sum(g))>0)
    a = a - 2*pi.*g;
    g = a > pi;
end
while (sum(sum(s))>0)
    a = a + 2*pi.*s;
    s = a < -pi;
end

end