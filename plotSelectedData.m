function plotSelectedData(FilledTtFlightData, xVarName, yVarName)

xVarName = char(xVarName);
yVarName = char(yVarName);

if strcmp(xVarName, "Time")
    xData = FilledTtFlightData.Time;
else
    xData = FilledTtFlightData.(xVarName);
end

if strcmp(yVarName, "Time")
    yData = FilledTtFlightData.Time;
else
    yData = FilledTtFlightData.(yVarName);
end

if isdatetime(xData)
    xData = seconds(xData - xData(1));
end

if isdatetime(yData)
    yData = seconds(yData - yData(1));
end

figure;
plot(xData, yData, 'LineWidth', 1.5);

xlabel(xVarName, 'Interpreter', 'none');
ylabel(yVarName, 'Interpreter', 'none');
title([yVarName ' vs ' xVarName]);

grid on;

end