function val = meanAngle(val0)
% compute the average value of an array of angles. Such a task yields
% problems when the angle values ranges over 0, ie 2*pi as well.


meanc = mean(cos(val0(:)));
means = mean(sin(val0(:)));


val = angle(meanc + 1i*means);


