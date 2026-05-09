function rotationMatrix = quat_to_rotm(quaternionVector)

% Converts a normalized scalar-first quaternion [w x y z] into a 3x3
% body-to-inertial rotation matrix using Euler's formula.

% Inputs:
%   quaternionVector - 1x4 or 4x1 vector formatted as [w x y z]

% Outputs:
%   rotationMatrix - 3x3 body-to-inertial rotation matrix

% Notes:
%   Input is normalized defensively before use so that minor floating-
%   point drift accumulated by the caller does not affect the result.

    % Validate input size
    if numel(quaternionVector) ~= 4
        error('quat_to_rotm: quaternion input must contain exactly four elements.');
    end

    % Normalization
    quaternionNorm = norm(quaternionVector);

    if quaternionNorm < eps
        error('quat_to_rotm: quaternion has zero norm.');
    end

    quaternionVector = quaternionVector / quaternionNorm;

    % Extract components
    quatW = quaternionVector(1);
    quatX = quaternionVector(2);
    quatY = quaternionVector(3);
    quatZ = quaternionVector(4);

    % Compute rotation matrix (scalar-first convention)
    rotationMatrix = [ ...
        1 - 2*(quatY^2 + quatZ^2), ...
        2*(quatX*quatY - quatZ*quatW), ...
        2*(quatX*quatZ + quatY*quatW); ...
        2*(quatX*quatY + quatZ*quatW), ...
        1 - 2*(quatX^2 + quatZ^2), ...
        2*(quatY*quatZ - quatX*quatW); ...
        2*(quatX*quatZ - quatY*quatW), ...
        2*(quatY*quatZ + quatX*quatW), ...
        1 - 2*(quatX^2 + quatY^2)];

end