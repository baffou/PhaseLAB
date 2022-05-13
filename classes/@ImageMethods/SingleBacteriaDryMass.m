%SIngleBacteriaDryMass calculate the Optical Volume (OV)con a serie of data from a video
%And so just by clicking on the center of the bacteria, and on the detached
%part of the bacteria if needed
%The contours of the bacteria is automatically calculated with the magic
%wand tool adapted from photoshop.
%The tolerance can be adapted when the red mask is superimposed with the
%phase image This is done using up/right arrow to increase and bottom/left arow
%to decrease the tolerance
%INPUT : IM = a list of QLSI object
%OUTPUT : DM =  value of the Optical Volume
%Maëlle Bénéfice - 18 Janvier 2021


function DM = SingleBacteriaDryMass(IM)

Nim = numel(IM);
DM = zeros(Nim,1);

for n = 1:Nim
    
    PHA = IM(n).OPD;
    Nx = IM(n).Nx;
    Ny = IM(n).Ny;
    
    %% Define the tolerance and deltaTolerance used to start as : (OPD90 - OPD10)
    [y,edge] = histcounts(PHA,Nx);
    Ntot = Nx*Ny;
    
    m = 0;
    a = 0;
    ok = 0;
    while ok == 0
        m = m+1;
        a = a + y(m);
        if a > 0.95*Ntot
            ok = 1;
            
        end
    end
    OPD90 = edge(m);
    
    
    m = 0;
    a = 0;
    ok = 0;
    while ok == 0
        m = m+1;
        a = a + y(m);
        if a > 0.1*Ntot
            ok = 1;
            
        end
    end
    OPD10 = edge(m);
    
    toleranceStart = OPD90-OPD10;
    deltaTol = toleranceStart/10;
    
    %% To zoom on the particle on interest and keep the zoomed images for the following images
    fail = 1;
    while fail==1
        hfig1 = figure();
        imagegb(PHA)
        h = gca;
        if n==1
            zoom on
            waitfor(gcf,'CurrentCharacter',char(13))
            YLim = h.YLim;
            XLim = h.XLim;
        else
            imagegb(PHA)
            h.XLim = XLim;
            h.YLim = YLim;
            zoom on
            waitfor(gcf,'CurrentCharacter',char(13))
            YLim = h.YLim;
            XLim = h.XLim;
        end
        
        
        %% press the central pixel of the particle and apply magic wand
        
        title('click on all the particules of interest, press space when done')
        %press the central pixel of the particle of interest
        [x,y] = ginput(1); 
        %To allow to click on multiple part of the particle of interest
        button = 0;
        ni = 1;
        while(button~=32) % 32 correspond to space bar
            [x1,y1,button] = ginput(1);
            x(ni+1) = x1;
            y(ni+1) = y1;
            ni = ni+1;
        end
        
        ylist = round(y);
        xlist = round(x);
        bin_mask = magicwand(PHA, ylist, xlist, toleranceStart);
        mask = double(bin_mask);
        imagegb(mask)
        title('bin mask')
        
        
        %% Red bin_mask superimposed on phase image to adjust magicwand mask
        
        A = zeros(Ny, Nx, 3);
        A1 = PHA/max(PHA(:));
        A2 = PHA/max(PHA(:));
        A3 = PHA/max(PHA(:)); %To obtain a grayscale image of the phase
        
        A1(find(mask)) = 1; % pixel corresponding to the mask set to 1 in red channel
        A2(find(mask)) = 0; % pixel corresponding to the mask set to 0 in green channel
        A3(find(mask)) = 0; % pixel corresponding to the mask set to 0 in blue channel
        A(:,:,1) = A1;
        A(:,:,2) = A2;
        A(:,:,3) = A3;
        imagegb(A)
        title('switch tolerance with arrows, press space when satisfied, press c to redo')
        h.XLim = XLim;
        h.YLim = YLim;
        
        
        %% To adapt the tolerance if the magic wand fit of the bacteria is not good
        
        tolerance = toleranceStart;
        button = 0;
        while(button~=32 && button~=99) % 32 correspond to space bar  % 99 correspond to c
            [~,~,button] = ginput(1);
            
            switch button
                
                case 30 % up arrow to increase the tolerance
                    tolerance = tolerance + deltaTol;
                    bin_mask = magicwand(PHA, ylist, xlist, tolerance);
                    mask = double(bin_mask);
                    
                    A1 = PHA/max(PHA(:));
                    A2 = PHA/max(PHA(:));
                    A3 = PHA/max(PHA(:));
                    
                    A1(find(mask)) = 1;
                    A2(find(mask)) = 0;
                    A3(find(mask)) = 0;
                    A(:,:,1) = A1;
                    A(:,:,2) = A2;
                    A(:,:,3) = A3;
                    imagegb(A)
                    title('switch tolerance with arrows, press space when satisfied, press c to redo')
                    h.XLim = XLim;
                    h.YLim = YLim;
                    
                case 31  %bottom arrow to decrease the tolerance
                    tolerance = tolerance - deltaTol;
                    bin_mask = magicwand(PHA, ylist, xlist, tolerance);
                    mask = double(bin_mask);
                    
                    A1 = PHA/max(PHA(:));
                    A2 = PHA/max(PHA(:));
                    A3 = PHA/max(PHA(:));
                    
                    A1(find(mask)) = 1;
                    A2(find(mask)) = 0;
                    A3(find(mask)) = 0;
                    A(:,:,1) = A1;
                    A(:,:,2) = A2;
                    A(:,:,3) = A3;
                    imagegb(A)
                    title('switch tolerance with arrows, press space when satisfied, press c to redo')
                    h.XLim = XLim;
                    h.YLim = YLim;
                    
                case 29 % right arrow to increase the tolerance x5
                    tolerance = tolerance + 5*deltaTol;
                    bin_mask = magicwand(PHA, ylist, xlist, tolerance);
                    mask = double(bin_mask);
                    
                    A1 = PHA/max(PHA(:));
                    A2 = PHA/max(PHA(:));
                    A3 = PHA/max(PHA(:));
                    
                    A1(find(mask)) = 1;
                    A2(find(mask)) = 0;
                    A3(find(mask)) = 0;
                    A(:,:,1) = A1;
                    A(:,:,2) = A2;
                    A(:,:,3) = A3;
                    imagegb(A)
                    title('switch tolerance with arrows, press space when satisfied, press c to redo')
                    h.XLim = XLim;
                    h.YLim = YLim;
                    
                case 28 % left arrow to decrease the tolerance x5
                    tolerance = tolerance - 5*deltaTol;
                    bin_mask = magicwand(PHA, ylist, xlist, tolerance);
                    mask = double(bin_mask);
                    
                    A1 = PHA/max(PHA(:));
                    A2 = PHA/max(PHA(:));
                    A3 = PHA/max(PHA(:));
                    
                    A1(find(mask)) = 1;
                    A2(find(mask)) = 0;
                    A3(find(mask)) = 0;
                    A(:,:,1) = A1;
                    A(:,:,2) = A2;
                    A(:,:,3) = A3;
                    imagegb(A)
                    title('switch tolerance with arrows, press space when satisfied, press c to redo')
                    h.XLim = XLim;
                    h.YLim = YLim;
                case 32 %space bar : to get out of the loop if the selection and the magic wand are ok
                    fail = 0;
                    
                case 99 %c key: to redo the particle selection if needed
                    fail = 1;
                    close(hfig1)
            end %end switch button  
        end %end while(button~=32 || button~=99)
    end %end while fail
   
    maskRef = mask;
    toleranceRef = tolerance;
    close(hfig1)
    
    %% OV calculation
    
    %when mask smaller than bacteria
    lambda = IM(n).Illumination.lambda;
    NA = IM(n).Microscope.NA;
    taillePx = IM(n).pxSize;
    res = (1.22*lambda/2*NA);
    Npxlim = 10*(res/taillePx); % Npxlim correspond to the xlim for OV integration curve
    N = 10;
    OV = zeros(1,round(Npxlim));
    factor = toleranceRef/N:toleranceRef/N:toleranceRef;
    
    for i = 1:N
        j = factor(i);
        mask = magicwand(PHA,ylist,xlist,j);
        
        W = wiener2(mask,[2,2]);
        mask2 = double(W>0);
        ringB = mask2-mask;
        backringB = ringB.*PHA;
        backgroundB = sum(backringB(:))/sum(ringB(:));
        
        Bacteria = PHA - backgroundB;
        RealBacteria = Bacteria.*mask;
        OV(i) = sum(RealBacteria(:))*taillePx.*taillePx;
        
    end
    
    %when mask bigger than the bacteria
    mask = maskRef;
    for j = N:N+round(Npxlim)
        
        W = wiener2(mask,[2,2]);
        mask2 = double(W>0);
        ringA = mask2-mask;
        backringA = ringA.*PHA;
        backgroundA = sum(backringA(:))/sum(ringA(:));
        
        Bacteria = PHA - backgroundA;
        RealBacteria = Bacteria.*mask;
        OV(j) = sum(RealBacteria(:))*taillePx*taillePx;
        mask = mask2;
        
    end
    
    hfig2 = figure();
    plot(OV)
    
    [xp,~] = ginput(2);
    close(hfig2)
    
    pxmin = round(min(xp));
    pxmax = min(round(max(xp)));
    
    OVmean = mean(OV(pxmin:pxmax));
    DM(n) = OVmean
end

end



