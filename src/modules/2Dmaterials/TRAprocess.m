function [T, R, A] = TRAprocess(tau,ME)
arguments
    tau
    ME Medium
end

n1 = ME.n;
n2 = ME.nS;

% Absolute transmittance
T0 = 4*n1*n2/(n1 + n2)^2;   % bare air/glass interface
T  = T0 * abs(tau).^2;

% Complex reflection coefficient
r = 2*n1*tau/(n1 + n2) - 1;

% Reflectance
R = abs(r).^2;

% Absorption
A = 1 - T - R;
