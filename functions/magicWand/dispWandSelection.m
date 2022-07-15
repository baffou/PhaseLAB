function dispWandSelection(tolerance, image0, ylist, xlist ,hfig1, ha1)
hfig1.UserData.tolerance = tolerance;
xlim0 = ha1.XLim;
ylim0 = ha1.YLim;

bin_mask = magicWand(image0, ylist, xlist, tolerance);
mask = double(bin_mask.*hfig1.UserData.maskManual);

 maxval = max(imgaussfilt(image0(:),10));
 minval = min(imgaussfilt(image0(:),10));
 A1 = (image0-minval)/(maxval-minval);
 A2 = A1;
 A3 = A1; 
    
A1(mask~=0) = 1;
%A2(mask~=0) = 0;
%A3(mask~=0) = 0;
A(:,:,1) = A1;
A(:,:,2) = A2;
A(:,:,3) = A3;
figure(hfig1);
imagegb(A)
ha1.XLim = xlim0;
ha1.YLim = ylim0;
hfig1.UserData.maskMW = mask;
