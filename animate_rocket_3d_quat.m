function animate_rocket_3d_quat(filledTtFlightData, altitudeFeet)

% Creates a 3D animation of rocket trajectory and orientation using
% fused altitude and quaternion telemetry data. Velocity is integrated
% to derive downrange and crossrange position.

% Inputs:
    %   filledTtFlightData - timetable containing Velocity_DR, Velocity_CR,
    %                        and Quat_1..Quat_4 columns

    %   altitudeFeet       - fused altitude estimate in feet (Nx1 vector at
    %                        the same sample rate as filledTtFlightData)

%   Generates a MATLAB figure window with an animated 3D trajectory.


    % Time
    timeSeconds = seconds( ...
        filledTtFlightData.Time - filledTtFlightData.Time(1));

    % Reduce sample rate
    skipFactor = max(1, floor(length(timeSeconds) / 1000));

    timeSeconds   = timeSeconds(1:skipFactor:end);
    altitudeFeet  = altitudeFeet(1:skipFactor:end);

    % Velocity components
    velocityDownrangeFeetPerSecond = ...
        filledTtFlightData.Velocity_DR(1:skipFactor:end);

    velocityCrossrangeFeetPerSecond = ...
        filledTtFlightData.Velocity_CR(1:skipFactor:end);

    % Integrate velocity to derive horizontal position
    nFrames         = length(altitudeFeet);
    xPositionFeet   = zeros(nFrames, 1);
    yPositionFeet   = zeros(nFrames, 1);

    for iSample = 2:nFrames

        deltaTimeSeconds = ...
            timeSeconds(iSample) - timeSeconds(iSample - 1);

        xPositionFeet(iSample) = ...
            xPositionFeet(iSample - 1) + ...
            velocityDownrangeFeetPerSecond(iSample) * ...
            deltaTimeSeconds;

        yPositionFeet(iSample) = ...
            yPositionFeet(iSample - 1) + ...
            velocityCrossrangeFeetPerSecond(iSample) * ...
            deltaTimeSeconds;

    end

    % Quaternion components [w x y z]
    quatW = filledTtFlightData.Quat_1(1:skipFactor:end);
    quatX = filledTtFlightData.Quat_2(1:skipFactor:end);
    quatY = filledTtFlightData.Quat_3(1:skipFactor:end);
    quatZ = filledTtFlightData.Quat_4(1:skipFactor:end);

    % Normalize to unit quaternions
    quaternionNorm = sqrt( ...
        quatW.^2 + quatX.^2 + quatY.^2 + quatZ.^2);

    quaternionNorm(quaternionNorm == 0) = 1; % guard against zero norm

    quatW = quatW ./ quaternionNorm;
    quatX = quatX ./ quaternionNorm;
    quatY = quatY ./ quaternionNorm;
    quatZ = quatZ ./ quaternionNorm;

    % Axis limits
    axisMargin = 10; % ft

    xRange = [min(xPositionFeet) - axisMargin, ...
              max(xPositionFeet) + axisMargin];

    yRange = [min(yPositionFeet) - axisMargin, ...
              max(yPositionFeet) + axisMargin];

    % Create figure
    figure;

    hold on;
    grid on;
    axis equal;

    daspect([1 1 1]);

    xlim(xRange);
    ylim(yRange);
    zlim([0, max(altitudeFeet) * 1.1]);

    xlabel('Downrange Position (ft)');
    ylabel('Crossrange Position (ft)');
    zlabel('Altitude AGL (ft)');

    title('3D Rocket Flight Animation');

    view(3);

    % Rocket geometry
    rocketLengthFeet = 10;

    rocketBodyHandle = plot3( ...
        [0 0], ...
        [0 0], ...
        [0 rocketLengthFeet], ...
        'r', 'LineWidth', 3);

    trajectoryHandle = plot3(0, 0, 0, 'b');

    % Time label in top-left corner of axes
    timeTextHandle = text( ...
        xRange(1), yRange(2), max(altitudeFeet) * 1.05, ...
        't = 0.0 s', ...
        'FontSize', 9, ...
        'Color', [0.3 0.3 0.3]);

    % Animation loop
    for iSample = 2:nFrames

        xPos = xPositionFeet(iSample);
        yPos = yPositionFeet(iSample);
        zPos = altitudeFeet(iSample);

        % Convert quaternion to rotation matrix
        rotationMatrix = quat_to_rotm( ...
            [quatW(iSample), ...
             quatX(iSample), ...
             quatY(iSample), ...
             quatZ(iSample)]);

        bodyDirectionVector = rotationMatrix * [0; 0; 1];

        % Update rocket body line
        set(rocketBodyHandle, ...
            'XData', [xPos, xPos + rocketLengthFeet * bodyDirectionVector(1)], ...
            'YData', [yPos, yPos + rocketLengthFeet * bodyDirectionVector(2)], ...
            'ZData', [zPos, zPos + rocketLengthFeet * bodyDirectionVector(3)]);

        % Update trajectory trail
        set(trajectoryHandle, ...
            'XData', xPositionFeet(1:iSample), ...
            'YData', yPositionFeet(1:iSample), ...
            'ZData', altitudeFeet(1:iSample));

        % Update time label
        set(timeTextHandle, ...
            'String', sprintf('t = %.1f s', timeSeconds(iSample)));

        drawnow limitrate;

    end

end