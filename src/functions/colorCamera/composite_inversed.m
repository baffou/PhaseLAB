% Creates a composite image from an OPD and a fluo images

function RGB_composite = composite_inversed(IM1, IM2, LUT1, LUT2)
RGB_composite = uint8(zeros(size(IM1,1), size(IM1,2), 3));
for x = 1:size(RGB_composite,1)
    for y = 1:size(RGB_composite,2)
            currentColor_OPD = uint8(LUT1(IM1(x,y)+1,:) * 255);
            currentColor_FLUO = uint8(LUT2(IM2(x,y)+1,:) * 255);

            color = 255 - (currentColor_OPD + currentColor_FLUO);
            color = [color(2) color(1) color(3)];

            RGB_composite(x,y,:) = color;
    end
end
end