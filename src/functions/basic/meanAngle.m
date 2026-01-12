function thetaMean = meanAngle(theta,n)
% compute the average value of an array of angles. Such a task yields
% problems when the angle values ranges over 0, ie 2*pi as well.
arguments
    theta double % angle map
    n = []
end


if isempty(n)
    thetaMean = angle(mean(exp(1i*theta(:))));
else
    thetaMean = angle(mean(exp(1i*theta),n));
end

