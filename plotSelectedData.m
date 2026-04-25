function plotSelectedData(FilledTtFlightData, xVar, yVar)

if xVar == "Time"
    xData = FilledTtFlightData.Time;
else
    xData = FilledTtFlightData.(xVar);
end

if yVar == "Time"
    yData = FilledTtFlightData.Time;
else
    yData = FilledTtFlightData.(yVar);
end

figure;
plot(xData, yData, 'LineWidth', 1.5);

xlabel(xVar, 'Interpreter', 'none');
ylabel(yVar, 'Interpreter', 'none');
title(yVar + " vs " + xVar);

grid on;

end