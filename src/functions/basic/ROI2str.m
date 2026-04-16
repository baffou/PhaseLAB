function str = ROI2str(ROI)
arguments
    ROI (1,4) double
end
str = ['crop:' num2str(ROI(1)) '_' num2str(ROI(2)) '_' num2str(ROI(3)) '_' num2str(ROI(4))];