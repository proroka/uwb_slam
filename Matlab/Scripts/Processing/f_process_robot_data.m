


function robots=f_process_robot_data(robots)

num_robots = length(robots);
t_max = length(robots{1}.pos_st);

for rob=1:num_robots
    robots{rob}.t_rob = [1 length(robots{1}.t_st)];
    for t=2:t_max
        dx = robots{rob}.pos_st(t,1) - robots{rob}.pos_st(t-1,1);
        dy = robots{rob}.pos_st(t,2) - robots{rob}.pos_st(t-1,2);
        dth = robots{rob}.pos_st(t,3) - robots{rob}.pos_st(t-1,3);
        robots{rob}.delta(t,:) = [dx dy dth];
    end
end



end