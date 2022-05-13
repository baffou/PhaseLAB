function h = drawCircle(x,y,r,h)
% rather an ellipse. r can be a 2-vector to draw an ellipse.


if length(r)==1
    R = [r r];
elseif length(r)==2
    R = r;
end

figure(h)

hold on
th = 0:pi/50:2*pi;
R(1)
xunit = R(1) * cos(th) + x;
yunit = R(2) * sin(th) + y;
plot(xunit, yunit,'LineWidth',2);
hold off










