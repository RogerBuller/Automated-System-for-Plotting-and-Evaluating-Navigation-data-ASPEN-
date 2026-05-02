function rocket = buildRocketModel(L, R, finParams)

rootChord = finParams(1);
tipChord  = finParams(2);
span      = finParams(3);

[XC, YC, ZC] = cylinder(R, 20);
ZC = ZC * (0.8 * L);

[XN, YN, ZN] = cylinder([R 0], 20);
ZN = ZN * (0.2 * L) + 0.8 * L;

z0 = 0;

finLocal = [ ...
    R, 0, z0; ...
    R, 0, z0 + rootChord; ...
    R + span, 0, z0 + tipChord; ...
    R + span, 0, z0 ...
]';

angles = deg2rad([0 90 180 270]);
finSet = cell(1,4);

for k = 1:4
    th = angles(k);
    Rz = [cos(th) -sin(th) 0;
          sin(th)  cos(th) 0;
          0        0       1];
    finSet{k} = Rz * finLocal;
end

rocket.XC = XC; rocket.YC = YC; rocket.ZC = ZC;
rocket.XN = XN; rocket.YN = YN; rocket.ZN = ZN;
rocket.fins = finSet;

end