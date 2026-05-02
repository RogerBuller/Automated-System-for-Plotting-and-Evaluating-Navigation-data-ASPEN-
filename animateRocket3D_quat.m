function animateRocket3D_quat(FilledTtFlightData, z_fused)

%Time
t = seconds(FilledTtFlightData.Time - FilledTtFlightData.Time(1));

%Lower data rate for quicker plot creation
skip = max(1, floor(length(t)/800));
t = t(1:skip:end);
z = z_fused(1:skip:end);

%x,y position from data
v_dr = FilledTtFlightData.Velocity_DR(1:skip:end); % downrange
v_cr = FilledTtFlightData.Velocity_CR(1:skip:end); % crossrange

x = zeros(size(z));
y = zeros(size(z));

for k = 2:length(z)
    dt = t(k) - t(k-1);

    x(k) = x(k-1) + v_dr(k) * dt;
    y(k) = y(k-1) + v_cr(k) * dt;
end

%Quaternions
q1 = FilledTtFlightData.Quat_1(1:skip:end);
q2 = FilledTtFlightData.Quat_2(1:skip:end);
q3 = FilledTtFlightData.Quat_3(1:skip:end);
q4 = FilledTtFlightData.Quat_4(1:skip:end);

qnorm = sqrt(q1.^2 + q2.^2 + q3.^2 + q4.^2);
q1 = q1 ./ qnorm;
q2 = q2 ./ qnorm;
q3 = q3 ./ qnorm;
q4 = q4 ./ qnorm;

%Figure
figure;
hold on
grid on
axis equal
daspect([1 1 1])

xlim([min(x) max(x)])
ylim([min(y) max(y)])
zlim([0 max(z)*1.1])

xlabel('X')
ylabel('Y')
zlabel('Altitude (ft)')
title('3D Rocket Flight (Quaternion Attitude)')

view(3)

%Rocket body
L = 10;
rocket = plot3([0 0],[0 0],[0 L],'r','LineWidth',3);
trail  = plot3(0,0,0,'b');

%Animation loop
for k = 2:length(z)

    px = x(k);
    py = y(k);
    pz = z(k);

    % Quaternion → direction vector
    R = quatToRotm([q1(k) q2(k) q3(k) q4(k)]);
    dir = R * [0;0;1];

    set(rocket, ...
        'XData',[px px+L*dir(1)], ...
        'YData',[py py+L*dir(2)], ...
        'ZData',[pz pz+L*dir(3)]);

    set(trail, ...
        'XData', x(1:k), ...
        'YData', y(1:k), ...
        'ZData', z(1:k));

    drawnow limitrate
end

end