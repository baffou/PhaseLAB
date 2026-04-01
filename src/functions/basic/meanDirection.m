function thetaMean = meanDirection(theta,n)
% compute the average value of an array of angles, when this angle is a direction
% ie spanning from 0 to pi.
% mean over the n th dimension
arguments
    theta double % angle map
    n = []
end

if isempty(n)
    thetaMean = angle(mean(exp(2i*theta)))/2;
else
    thetaMean = angle(mean(exp(2i*theta),n))/2;
end
