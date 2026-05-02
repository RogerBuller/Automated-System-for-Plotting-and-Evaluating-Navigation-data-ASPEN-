function [z_est, v_est, a_est] = kalmanAltitudeFusion6DOF(FilledTtFlightData)

%Time
t = seconds(FilledTtFlightData.Time - FilledTtFlightData.Time(1));
t = t(:);
dt = mean(diff(t));

%Measured Values
z_meas = FilledTtFlightData.("Baro_Altitude_AGL_(feet)");
z_meas = z_meas(:);

a_meas = FilledTtFlightData.("Accel_Z") - 32.174;
a_meas = a_meas(:);

% Light smoothing with a moving mean
a_meas = movmean(a_meas, 5);

N = length(t);

%State estimation
x = [z_meas(1); 0; 0; 0];
P = diag([10, 10, 10, 1]);

z_est = zeros(N,1);
v_est = zeros(N,1);
a_est = zeros(N,1);

% ---- Model ----
F = [1 dt 0.5*dt^2  -0.5*dt^2;
     0 1  dt        -dt;
     0 0  1         -1;
     0 0  0          1];

G = [0; 0; 1; 0];
H = [1 0 0 0];

Q = diag([0.01, 0.05, 0.5, 0.0005]);

R_base   = 12;
R_apogee = 2;


z_prev = z_meas(1);
descending = false;

for k = 1:N

    if k > 1 && z_meas(k) < z_prev
        descending = true;
    end
    z_prev = z_meas(k);

    near_apogee = abs(x(2)) < 25;   % low velocity

    if near_apogee
        u = 0; 
    else
        u = a_meas(k);
    end

    x = F*x + G*u;
    P = F*P*F' + Q;

    if near_apogee
        R = R_apogee;
    else
        R = R_base;
    end

    y = z_meas(k) - H*x;
    S = H*P*H' + R;
    K = P*H'/S;

    x = x + K*y;
    P = (eye(4) - K*H)*P;

    if near_apogee && ~descending
        x(2) = 0; 
    end

    % ---- Store ----
    z_est(k) = x(1);
    v_est(k) = x(2);
    a_est(k) = x(3);
end

end