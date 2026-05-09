function plot_selected_data( ...
    filledTtFlightData, ...
    xVariableName, ...
    yVariableName)

% Creates a 2D line plot using two user-selected timetable variables.
% Datetime row times are converted to elapsed seconds before plotting
% so the x-axis shows flight time rather than a wall-clock value.

% Inputs:
%   filledTtFlightData - timetable containing telemetry data
%   xVariableName      - string name of the x-axis variable, or "Time"
%   yVariableName      - string name of the y-axis variable, or "Time"

%   Generates a MATLAB figure window.


    % Both names must be non-empty
    if strtrim(xVariableName) == "" || strtrim(yVariableName) == ""
        warning('plot_selected_data: variable name is empty — skipping plot.');
        return;
    end

    % Extract x-axis data
    if strcmp(xVariableName, "Time")
        xDataValues = filledTtFlightData.Time;
    else
        xDataValues = filledTtFlightData.(xVariableName);
    end

    % Extract y-axis data
    if strcmp(yVariableName, "Time")
        yDataValues = filledTtFlightData.Time;
    else
        yDataValues = filledTtFlightData.(yVariableName);
    end

    % Convert datetime to elapsed seconds
    if isdatetime(xDataValues)
        xDataValues  = seconds(xDataValues - xDataValues(1));
        xAxisLabel   = 'Flight Time (s)';
    else
        xAxisLabel   = char(xVariableName);
    end

    if isdatetime(yDataValues)
        yDataValues  = seconds(yDataValues - yDataValues(1));
        yAxisLabel   = 'Flight Time (s)';
    else
        yAxisLabel   = char(yVariableName);
    end

    % Generate plot
    figure;

    plot(xDataValues, yDataValues, 'LineWidth', 1.5);

    xlabel(xAxisLabel, 'Interpreter', 'none');
    ylabel(yAxisLabel, 'Interpreter', 'none');

    title( ...
        [char(yVariableName) ' vs ' char(xVariableName)], ...
        'Interpreter', 'none');

    grid on;

end