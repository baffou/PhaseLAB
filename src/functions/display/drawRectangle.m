function h = drawRectangle(x,y,r,h)

if length(r)==1
    R = [r r];
elseif length(r)==2
    R = r;
end

figure(h)

hold on
xunit = zeros(5,1);
yunit = zeros(5,1);
xunit(1) = - R(1) + x;
xunit(2) =   R(1) + x;
xunit(3) =   R(1) + x;
xunit(4) = - R(1) + x;
xunit(5) = - R(1) + x;
yunit(1) = - R(2) + y;
yunit(2) = - R(2) + y;
yunit(3) =   R(2) + y;
yunit(4) =   R(2) + y;
yunit(5) = - R(2) + y;
plot(xunit, yunit,'LineWidth',2);
hold off




