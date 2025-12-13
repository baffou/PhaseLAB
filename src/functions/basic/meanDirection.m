function thetaMean = meanDirection(theta)
% compute the average value of an array of angles, when this angle is a direction
% ie spanning from 0 to pi.

arguments
    theta (:,:) double % angle map
end

thetaMean = angle(mean(exp(2i*theta(:))))/2;
