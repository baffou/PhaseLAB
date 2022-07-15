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


function [alpha,OV] = magicWandAlphaOV2(hfig)
%bkTh: thickness of the background ring in pixels
IM = hfig.UserData{5};
hand = hfig.UserData{8};

bkTh = str2double(get(hand.UIalpha_bkgThick,'String'));
step = str2double(get(hand.UIalpha_step,'String'));
NNP = str2double(get(hand.UIalpha_NNP,'String'));
nmax = str2double(get(hand.UIalpha_nmax,'String'));



n2 = IM.Illumination.nS;
Nim = numel(IM);
alpha = zeros(NNP,Nim,1);
OV = zeros(NNP,Nim,1);

for n = 1:Nim  % loop on the list of images
    
    OPD = IM(n).OPD;
    Ph = IM(n).Ph;
    T = IM(n).T;
    
    for iNP = 1:NNP  % loop on the list of particles
        
        fail = 1;
        while fail==1 % until space bar or c are pressed
            
            ha = gca;
            YLim = ha.YLim;
            XLim = ha.XLim;
            OPDcrop = OPD;
            Tcrop = T;
            Phcrop = Ph;
            
            [mask,maskRemove,fail,xList,yList] = magicWand_scrollbar(hfig);
        end %end while fail==1
        
        maskRef = mask;
        
        %% alpha calculation
        
        %when mask smaller than bacteria
        taillePx = IM(n).pxSize;
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
            
            backring = ringB.*Phcrop;
            background = sum(backring(:))/sum(ringB(:));
            Phn = Phcrop - background;
            
            backring = ringB.*Tcrop;
            background = sum(backring(:))/(sum(ringB(:))); %mean backgound over the ring
            Tn = Tcrop/background;
            
            backring = ringB.*OPDcrop;
            background = sum(backring(:))/(sum(ringB(:))); %mean backgound over the ring
            OPDn = OPDcrop-background;
            
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
            ringB = maskb-mask;
            
            backring = ringB.*Phcrop;
            background = sum(backring(:))/sum(ringB(:));
            Phn = Phcrop - background;
            
            backring = ringB.*Tcrop;
            background = sum(backring(:))/(sum(ringB(:))); %mean backgound over the ring
            Tn = Tcrop/background;
            
            backring = ringB.*OPDcrop;
            background = sum(backring(:))/sum(ringB(:));
            OPDn = OPDcrop - background;
            
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
        
         maxval = max(imgaussfilt(OPDn(:),10));
         minval = min(imgaussfilt(OPDn(:),10));
         
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
        close(hfig2)
        
        pxmin = round(min(N*xp));
        pxmax = min(round(max(N*xp)),length(alpha0)); % in case the user clicks too far in x
        if pxmax<pxmin
            error('The second click must correspond to a higher x value.')
        end
        alpha(iNP,n) = mean(alpha0(pxmin:pxmax));
        maskMeas = maskList{round(mean([pxmin pxmax]))};
        ringBMeas = ringBList{round(mean([pxmin pxmax]))};
        alphaRealMean = real(alpha(iNP,n));
        alphaImagMean = imag(alpha(iNP,n));
        
        OV(iNP,n) = mean(OV0(pxmin:pxmax));
        OVmin = min(OV0(pxmin:pxmax));
        OVmax = max(OV0(pxmin:pxmax));
        
        if alphaRealMean>1e-19 || alphaImagMean>1e-19
            efactor = 1e-18;
            if alphaImagMean<0
                alpha2print = sprintf('(%.4g-i*%.4g) x10^-18',1e18*alphaRealMean,-1e18*alphaImagMean);
            else
                alpha2print = sprintf('(%.4g+i*%.4g) x10^-18',1e18*alphaRealMean,1e18*alphaImagMean);
            end
            OV2print = sprintf('%.4ge-18',1e18*OV(iNP,n));
        else
            efactor = 1e-21;
            if alphaImagMean<0
                alpha2print = sprintf('(%.4g-i*%.4g) x10^-21',1e21*alphaRealMean,-1e21*alphaImagMean);
            else
                alpha2print = sprintf('(%.4g+i*%.4g) x10^-21',1e21*alphaRealMean,1e21*alphaImagMean);
            end
            OV2print = sprintf('%.4ge-21',1e21*OV(iNP,n));
        end
        fprintf([alpha2print '\n'])
        disp(IM.OPDfileName)
        fprintf('\t=COMPLEX(%.4g,%.4g)\n',1e21*alphaRealMean,1e21*alphaImagMean);
        clipboard('copy',sprintf('=COMPLEX(%.4g,%.4g)',1e21*alphaRealMean,1e21*alphaImagMean))
        fprintf('OV:\n')
        fprintf('\t%.4g\n',OV(iNP,n));

        
        prefix = get(hand.file,'String');
        folder = get(hand.folder,'String');
        if ~isfolder(folder)
            mkdir(folder)
        end
        
        fid = fopen([folder '/alphaOV_' prefix '.txt'],'a');
        fprintf(fid,[IM.OPDfileName '\t' alpha2print '\t' OV2print '\t' num2str(XLim) '\t' num2str(YLim)]);
        fclose(fid);
  
        
        %% save the images
        if ~isfolder([folder '/masks'])
            mkdir([folder '/masks'])
        end
        
        dlmwrite([folder '/masks/OPDcrop_' IM.OPDfileName '_' generateDatedFileName() '.txt'],OPDn,' ')
        dlmwrite([folder '/masks/Mask_' IM.OPDfileName '_' generateDatedFileName() '.txt'],maskMeas,' ')
        dlmwrite([folder '/masks/pcoord_' IM.OPDfileName '_' generateDatedFileName() '.txt'],xcoord,'\n')
        dlmwrite([folder '/masks/OVprofile_' IM.OPDfileName '_' generateDatedFileName() '.txt'],OV0,'\n')
        minOPD = min(imgaussfilt(OPDn(:),2));
        maxOPD = max(imgaussfilt(OPDn(:),2));
        imwrite((OPDn-minOPD)*255/(maxOPD-minOPD),phase1024(256),[folder '/masks/' generateDatedFileName() '_OPDcrop_' IM.OPDfileName '.tif'])
        imwrite(maskMeas*255,gray(256),[folder '/masks/' generateDatedFileName()  '_Mask_' IM.OPDfileName '.tif'])
        imwrite(ringBMeas*255,gray(256),[folder '/masks/' generateDatedFileName()  '_RingB_' IM.OPDfileName '.tif'])
        dlmwrite([folder '/masks/' generateDatedFileName()  '_pmean.txt'],[pxmin pxmax mean(pxmin:pxmax)],'\n')
        
        
        %% save the csv file
        % if csv file not already created, write the first line with the row's names.
        if ~exist([folder '/data.csv'],'file') 
            Tab0 = table({'file name','time','factor','alpha','OV','OVmin','OVmax','XY'});
            writetable(Tab0,[folder '/data.csv'],'WriteVariableNames',0);
        end
        
        % defines the line to write
        posList = [XLim(1)+xList,YLim(1)+yList].';
        date = generateDatedFileName();
        Tab = table({IM.OPDfileName},{date},efactor,{sprintf('=COMPLEX(%.4g,%.4g)',alphaRealMean/efactor,alphaImagMean/efactor)},{sprintf('%.4g',OV(iNP,n)/efactor)},{sprintf('%.4g',OVmin/efactor)},{sprintf('%.4g',OVmax/efactor)},{num2str(posList(:).')});
        % writes this line in a temporary csv file
        fileNamecsv = [folder '/data_' date '.csv'];
        writetable(Tab,fileNamecsv,'WriteVariableNames',0);
        % concatenates the current data.csv file with the new one 
        copyfile([folder '/data.csv'],[folder '/data_ref.csv'])
        command = ['cat ' folder '/data_ref.csv ' fileNamecsv ' > ' folder '/data.csv'];
        system(command);
        %delete(fileNamecsv)
        delete([folder '/data_ref.csv'])
        
        
        if nargin==2
            set(hand.UIresult,'String',sprintf([alpha2print '\n' OV2print]));
        end
        
    end
end
hfig.UserData{10} = alpha(iNP,n);
figure(hfig)

end



