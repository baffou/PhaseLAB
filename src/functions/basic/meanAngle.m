function thetaMean = meanAngle(theta)
% compute the average value of an array of angles. Such a task yields
% problems when the angle values ranges over 0, ie 2*pi as well.
arguments
    theta (:,:) double % angle map
end

thetaMean = angle(mean(exp(1i*theta(:))));


