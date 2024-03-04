%magicWandOV calculate the Optical Volume (OV)con a serie of data from a video
%And so just by clicking on the center of the bacteria, and on the detached
%part of the bacteria if needed
%The contours of the bacteria is automatically calculated with the magic
%wand tool adapted from photoshop.
%The tolerance can be adapted when the red mask is superimposed with the
%phase image This is done using up/right arrow to increase and bottom/left arow
%to decrease the tolerance
%INPUT : IM = a list of QLSI object
%OUTPUT : DM =  values of the Optical Volume
%Maëlle Bénéfice - 18 Jan 2021
%Guillaume Baffou - 30 Apr 2021

function [alpha,OV,maskMeas,roiIN,roiOUT,masking] = magicWandAlphaOV(IM,opt)

% This code is meant to replace magicWandAlphaOV2, and to be used with the
% new gui interface PhaseLABgui

% magicWandAlphaOV(app)
% magicWandAlphaOV(IM)
% magicWandAlphaOV(IMlist)

arguments
    IM % ImageMethods
    opt.bkTh = 3
    opt.step = 1
    opt.NNP = 1
    opt.nmax = 200
    opt.roiIN = {}
    opt.roiOUT = {}
    opt.masking = []             % to keep the same mask as another crop
end

roiIN = opt.roiIN;
roiOUT = opt.roiOUT;

bkTh = opt.bkTh;
step = opt.step;
NNP = opt.NNP;
nmax = opt.nmax;

n2 = IM.Illumination.nS;
Nim = numel(IM);
alpha = zeros(NNP,Nim,1);
OV = zeros(NNP,Nim,1);

for io = 1:Nim  % loop on the list of images
    
    OPD = IM(io).OPD;
    Ph = IM(io).Ph;
    T = IM(io).T;
    
    for iNP = 1:NNP  % loop on the list of particles
        
        if isempty(opt.masking)
            fail = 1;
            while fail==1 % until space bar or c are pressed
                                
                [mask,maskRemove,fail,roiIN,roiOUT] = magicWand_scrollbar(OPD,roiIN,roiOUT);
    
            end %end while fail==1
        else
            mask = opt.masking.mask;
            maskRemove = opt.masking.maskRemove;
        end

        maskRef = mask;
        
        %% alpha calculation
        
        %when mask smaller than bacteria
        taillePx = IM(io).pxSize;
        N = round(nmax/2);
        alpha0 = zeros(1,N+nmax);
        OV0 = zeros(1,N+nmax);
        xcoord = zeros(1,N+nmax);
        maskList = cell(N+nmax,1);
        ringBList = cell(N+nmax,1);
        for i = 1:N  % loop over mask size from smallest to size of ref.
            Wb = wiener2(mask,[2*bkTh+1,2*bkTh+1]); %sets the width of the background
            Ws = wiener2(mask,[2*step+1,2*step+1]);       %sets the step for the calculations
            maskb = double((Wb>0).*maskRemove);
            masks = double((Ws==1).*maskRemove);
            ringB = maskb-mask;
            
            backring = ringB.*Ph;
            background = sum(backring(:))/sum(ringB(:));
            Phn = Ph - background;
            
            backring = ringB.*T;
            background = sum(backring(:))/(sum(ringB(:))); %mean backgound over the ring
            Tn = T/background;
            
            backring = ringB.*OPD;
            background = sum(backring(:))/(sum(ringB(:))); %mean backgound over the ring
            OPDn = OPD-background;
            
            sqrtT = sqrt(Tn);
            expPh = exp(1i*Phn);
            alpha2D = 1i*IM.lambda*n2/(pi)*(1-sqrtT.*expPh).*mask;
            alpha0(N-i+1) = sum(alpha2D(:))*taillePx.*taillePx;
            OV0(N-i+1) = sum(OPDn(:).*mask(:))*taillePx.*taillePx;
            xcoord(N-i+1) = (N-i+1)/N;
            maskList{N-i+1} = mask;
            ringBList{N-i+1} = ringB;
            mask = masks;
        end
        
        mask = maskRef;
        for i = N:N+nmax  % loop over mask size when mask bigger than the ref mask
            Wb = wiener2(mask,[2*bkTh+1,2*bkTh+1]);
            Ws = wiener2(mask,[2*step+1,2*step+1]);
            maskb = double((Wb>0).*maskRemove);
            masks = double((Ws>0).*maskRemove);
            ringB = maskb - mask;
            
            backring = ringB.*Ph;
            background = sum(backring(:))/sum(ringB(:));
            Phn = Ph - background;
            
            backring = ringB.*T;
            background = sum(backring(:))/(sum(ringB(:))); %mean backgound over the ring
            Tn = T/background;
            
            backring = ringB.*OPD;
            background = sum(backring(:))/sum(ringB(:));
            OPDn = OPD - background;
            
            sqrtT = sqrt(Tn);
            expPh = exp(1i*Phn);
            alpha2D = 1i*IM.lambda*n2/(pi)*(1-sqrtT.*expPh).*mask;
            alpha0(i) = sum(alpha2D(:))*taillePx.*taillePx;
            
            OV0(i) = sum(OPDn(:).*mask(:))*taillePx.*taillePx;
            xcoord(i) = (i)/N;
            maskList{i} = mask;
            ringBList{i} = ringB;
            mask = masks;
        end
        %LOOP TO BE REMOVED
        %for ij=1:10
        
        if isempty(opt.masking)
            hfig2 = figure;
            hfig2.UserData.goon = 0;
            hfig2.UserData.p1 = [];
            fullwidth
            ha1 = subplot(1,2,1);
            hold on
            plot(xcoord,real(alpha0))
            plot(xcoord,imag(alpha0))
            plot(xcoord,OV0)
            legend({'real(\alpha)','imag(\alpha)','OV'})
            ha2 = subplot(1,2,2);
            A = zeros([size(OPDn) 3]);
            
            maxval = max(max(imgaussfilt(OPDn,10)));
            minval = min(max(imgaussfilt(OPDn,10)));
             
            A(:,:,1) = (OPDn-minval)/(maxval-minval);
            A(:,:,2) = (OPDn-minval)/(maxval-minval);
            A(:,:,3) = (OPDn-minval)/(maxval-minval);
    
            A(:,:,1) = (mask~=0); % pixel corresponding to the mask set to 1 in red channel
            image(A)
            set(gca,'YDir','Reverse')
            drawnow
            hfig2.UserData.ha1 = ha1;
            hfig2.UserData.ha2 = ha2;
            set(ha1,'ButtonDownFcn',@(src,evt)setp1p2(ha1));
            set(ha1.Children,'PickableParts','none');
            %set(hfig2,'WindowButtonMotionFcn','disp(get (gca, ''CurrentPoint''))')
            set(hfig2,'WindowButtonMotionFcn',@(src,evt)LiveMaskDisplay(ha1,ha2,maskList,N))
            %[xp,~] = ginput(2);
    
            
    
            pause(0.1)
            while(hfig2.UserData.goon==0)
            pause(0.1)
            end
            
            xp(1) = hfig2.UserData.p1;
            xp(2) = hfig2.UserData.p2;
    
    %         warning('pmin and pmax forced to 1')
    %         xp(1)=1;
    %         xp(2)=1;
            
            close(hfig2)
            pxmin = round(min(N*xp));
            pxmax = min(round(max(N*xp)),length(alpha0)); % in case the user clicks too far in x
            if pxmax<pxmin
                error('The second click must correspond to a higher x value.')
            end
        else
            pxmin = opt.masking.p(1);
            pxmax = opt.masking.p(2);
        end

        masking.p = [pxmin, pxmax];

        alpha(iNP,io) = mean(alpha0(pxmin:pxmax));
        maskMeas = maskList{round(mean([pxmin pxmax]))};

        OV(iNP,io) = mean(OV0(pxmin:pxmax));

        masking.mask = maskRef;
        masking.maskRemove = maskRemove;

    end
end

end



