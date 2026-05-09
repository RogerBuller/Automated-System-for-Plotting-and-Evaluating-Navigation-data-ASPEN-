function [estimatedAltitudeFeet, ...
          estimatedVelocityFeetPerSecond, ...
          estimatedAccelerationFeetPerSecond2] = ...
          kalman_altitude_fusion_6dof(filledTtFlightData)

% Fuses barometric AGL altitude with body-axis acceleration to produce
% smoothed altitude, velocity, and acceleration estimates.

% Inputs:
%   filledTtFlightData - timetable containing flight telemetry. Must
%                        include Baro_Altitude_AGL_(feet) and Accel_X.

% Outputs:
%   estimatedAltitudeFeet              - Kalman-fused altitude (ft AGL)
%   estimatedVelocityFeetPerSecond     - Kalman-fused vertical velocity (ft/s)
%   estimatedAccelerationFeetPerSecond2 - Gravity-compensated acceleration (ft/s^2)
    

    % Time
    timeSeconds = seconds( ...
        filledTtFlightData.Time - ...
        filledTtFlightData.Time(1));

    timeSeconds = timeSeconds(:);
    nSamples    = length(timeSeconds);

    % Measurements

    measuredAltitudeFeet = ...
        filledTtFlightData.("Baro_Altitude_AGL_(feet)");

    measuredAltitudeFeet = measuredAltitudeFeet(:);

    measuredAccelerationG = ...
        filledTtFlightData.Accel_X - 1.0;

    % Convert g to ft/s^2
    measuredAccelerationFeetPerSecond2 = ...
        measuredAccelerationG * 32.174;

    measuredAccelerationFeetPerSecond2 = ...
        movmean(measuredAccelerationFeetPerSecond2, 5);

    % Baro outlier threshold
    baroOutlierThresholdFeet = 500;

    % Initial State
    estimatedAltitudeFeet               = zeros(nSamples, 1);
    estimatedVelocityFeetPerSecond      = zeros(nSamples, 1);
    estimatedAccelerationFeetPerSecond2 = zeros(nSamples, 1);

    estimatedAltitudeFeet(1)               = measuredAltitudeFeet(1);
    estimatedAccelerationFeetPerSecond2(1) = ...
        measuredAccelerationFeetPerSecond2(1);

    % Kalman Variables
    altitudeVariance    = 25;
    processVariance     = 2;
    measurementVariance = 15;

    % Main Filter Loop
    for iSample = 2:nSamples

        deltaTimeSeconds = ...
            timeSeconds(iSample) - timeSeconds(iSample - 1);

        % Current acceleration (clamp spikes)
        currentAcceleration = ...
            measuredAccelerationFeetPerSecond2(iSample);

        currentAcceleration = ...
            max(min(currentAcceleration, 200), -200);

        % Predict

        predictedVelocity = ...
            estimatedVelocityFeetPerSecond(iSample - 1) + ...
            currentAcceleration * deltaTimeSeconds;

        predictedAltitude = ...
            estimatedAltitudeFeet(iSample - 1) + ...
            estimatedVelocityFeetPerSecond(iSample - 1) * ...
            deltaTimeSeconds + ...
            0.5 * currentAcceleration * deltaTimeSeconds^2;

        % Kalman Gain
        altitudeVariance = ...
            altitudeVariance + processVariance;

        kalmanGain = ...
            altitudeVariance / ...
            (altitudeVariance + measurementVariance);

        baroMeasurement = measuredAltitudeFeet(iSample);

        if abs(baroMeasurement - predictedAltitude) > ...
                baroOutlierThresholdFeet

            baroMeasurement = predictedAltitude;

        end

        % Residual
        altitudeResidual = baroMeasurement - predictedAltitude;

        estimatedAltitudeFeet(iSample) = ...
            predictedAltitude + kalmanGain * altitudeResidual;

        velocityKalmanGain = kalmanGain * deltaTimeSeconds;

        estimatedVelocityFeetPerSecond(iSample) = ...
            predictedVelocity + ...
            velocityKalmanGain * altitudeResidual;

        altitudeVariance = ...
            (1 - kalmanGain) * altitudeVariance;

        % Store acceleration output
        estimatedAccelerationFeetPerSecond2(iSample) = ...
            currentAcceleration;

    end

    % Final Smoothing
    estimatedAltitudeFeet = ...
        sgolayfilt(estimatedAltitudeFeet, 3, 21);

    estimatedVelocityFeetPerSecond = ...
        sgolayfilt(estimatedVelocityFeetPerSecond, 3, 11);

    estimatedAccelerationFeetPerSecond2 = ...
        sgolayfilt(estimatedAccelerationFeetPerSecond2, 3, 11);

end