function val = fwhm(y)
% computes the full width half maximum of a Gaussian like y profile.
% Be careful, the Gaussian musn't be upside down, and musn't be too noisy

% works with an array of horizontal data
% y1(1) ... y1(end)
%       ...
% yn(1) ... yn(end)

if isvector(y) % transform y into an horizontal vector in case it is a vector
    y = y(:).';
end

[Nplots, Npoints] = size(y);

val = zeros(Nplots,1);

y = y - median(y,2);

for ip = 1:Nplots
x = 1:Npoints;
% Find the maximum value of the array
[maxValue, maxIndex] = max(y(ip,:));

% Determine the half-maximum value
halfMaxValue = maxValue / 2;

% Interpolate to find the precise indices where the array crosses half-maximum
interpBelowHalfMax = interp1(y(ip,1:maxIndex), x(1:maxIndex), halfMaxValue);
interpAboveHalfMax = interp1(y(ip,maxIndex:end), x(maxIndex:end), halfMaxValue);

% Calculate the FWHM
val(ip) = interpAboveHalfMax - interpBelowHalfMax;
end