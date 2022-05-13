function h = drawSquare(x,y,r,h)
% rather a rectangle. r can be a 2-vector to draw an ellipse.
% mimicks drawCircle function

if length(r)==1
    R = [r r];
elseif length(r)==2
    R = r;
end

figure(h)

hold on
width = 2*R(1);
height= 2*R(2);
lowCorner_x = x-R(1);
lowCorner_y = y-R(2);
rectangle('Position',[lowCorner_x lowCorner_y width height],'LineWidth',2)
hold off





