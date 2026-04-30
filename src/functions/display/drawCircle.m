function h0 = drawCircle(x,y,r,h,color)
arguments
    x
    y
    r
    h
    color = 'w'
end
% rather an ellipse. r can be a 2-vector to draw an ellipse.


if length(r)==1
    R = [r r];
elseif length(r)==2
    R = r;
else
    pause(1)
end

if isa(h,'matlab.ui.Figure')
    figure(h)
elseif  isa(h,'matlab.graphics.axis.Axes') || isa(h,'matlab.ui.control.UIAxes')
    axes(h)
else
    error('not a proper input class')
end


hold on
th = 0:pi/50:2*pi;
xunit = R(1) * cos(th) + x;
yunit = R(2) * sin(th) + y;
plot(xunit, yunit,'LineWidth',2,'Color',color);
hold off


if nargout
    h0 = h;
end







