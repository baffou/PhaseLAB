function [alpha,OV] = roiAlphaOV(IM,hand)
% NNP: number of nanoparticles to be measured in the image
% size of the cropped area around the NP


%bkTh: thickness of the background ring in pixels

if isa(hand,"matlab.apps.AppBase")
    app = hand;
    hfig = app.UIFigure;
    bkTh = app.bkgRingEditField.Value;
    step = app.stepEditField.Value;
    NNP = 1;
    nmax = app.NmaxEditField.Value;
else
    app = [];
    hfig = hand.UIalpha_bkgThick.Parent.Parent;
    bkTh = str2double(get(hand.UIalpha_bkgThick,'String'));
    step = str2double(get(hand.UIalpha_step,'String'));
    NNP = str2double(get(hand.UIalpha_NNP,'String'));
    nmax = str2double(get(hand.UIalpha_nmax,'String'));
    UIresult = hand.UIresult;
end

if nargin==1 % thickness of the background ring in pixels
    bkTh = 2;
end

n2 = IM.Illumination.nS;
Nim = numel(IM);
alpha = zeros(NNP,Nim,1);
OV = zeros(NNP,Nim,1);

for io = 1:Nim  % loop on the list of images

    OPD = IM(io).OPD;
    Ph = IM(io).Ph;
    T = IM(io).T;

    for iNP = 1:NNP  % loop on the list of particles
        if isempty(app)
            figure(hfig)
            ha = gca;
            hf = gcf;
        else
            app.enableHandleVisibility()
            ha = app.AxesLeft;
            hf = app.UIFigure;
            axes(ha)
        end
        if io==1
            zoom on
            app.displayMessage('zoom and then press ''z'' key')
            waitfor(hf,'CurrentCharacter',char(122))
            app.clearMessageArea()
            YLim = round(ha.YLim);
            XLim = round(ha.XLim);
        else
            imagegb(OPD)
            ha.XLim = XLim;
            ha.YLim = YLim;
            zoom on
            waitfor(hf,'CurrentCharacter',char(122))
            YLim = ha.YLim;
            XLim = ha.XLim;
        end

        set(hf,'CurrentCharacter',char(0))
        zoom off
        app.disableHandleVisibility()

        [Ny,Nx] = size(OPD);
        OPDcrop = OPD(max([YLim(1),1]):min([YLim(2),Ny]),max([XLim(1),1]):min([XLim(2),Nx]));
        Tcrop = T(max([YLim(1),1]):min([YLim(2),Ny]),max([XLim(1),1]):min([XLim(2),Nx]));
        Phcrop = Ph(max([YLim(1),1]):min([YLim(2),Ny]),max([XLim(1),1]):min([XLim(2),Nx]));

        %            [mask,fail,xList,yList] = magicWand_scrollbar(OPDcrop);

        hfig1 = figure(MenuBar="none",ToolBar="none",Name="ROI selection",NumberTitle="off");
        fullscreen
        imageph(OPDcrop)
        axis equal

        roi = drawpolygon;
        Pos = roi.Position; % get the coordinate of the polygon
        S = size(OPDcrop);
        X = Pos(:,1);
        Y = Pos(:,2);
        delete(roi)


        mask = poly2mask(X,Y,S(1),S(2)); % computes a binary ROI mask from an ROI polygon

        maskRef = mask;

        close(hfig1)

        %% alpha & OV calculation

        %when mask smaller than bacteria
        taillePx = IM(io).pxSize;
        N = round(nmax/2);
        alpha0 = zeros(1,N+nmax);
        OV0 = zeros(1,N+nmax);
        xcoord = zeros(1,N+nmax);
        for i = 1:N  % loop over mask size from smallest to size of ref.
            Wb = wiener2(mask,[2*bkTh+1,2*bkTh+1]); %sets the width of the background
            Ws = wiener2(mask,[2*step+1,2*step+1]);       %sets the step for the calculations
            maskb = double(Wb==1);
            masks = double(Ws==1);
            %
            %             figure
            %             subplot(1,3,1)
            %             imagesc(mask)
            %             subplot(1,3,2)
            %             imagesc(maskb)
            %             subplot(1,3,3)
            %             imagesc(masks)
            %             drawnow
            %             pause(0.5)

            ringB = mask-maskb;  % mind the inversion

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
            mask = masks;
        end

        mask = maskRef;
        for i = N:N+nmax  % loop over mask size when mask bigger than the ref mask
            Wb = wiener2(mask,[2*bkTh+1,2*bkTh+1]);
            Ws = wiener2(mask,[2*step+1,2*step+1]);
            maskb = double(Wb>0);
            masks = double(Ws>0);
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
            mask = masks;

        end

        if ~isempty(app)
            app.disableHandleVisibility()
        end
        hfig2 = figure(MenuBar="none",ToolBar="none",Name="Plateau selection",NumberTitle="off");
        hold on
        plot(xcoord,real(alpha0))
        plot(xcoord,imag(alpha0))
        plot(xcoord,OV0)
        legend({'real(\alpha)','imag(\alpha)','OV'})
        pause(0.5)

        [xp,~] = ginput(2);
        close(hfig2)


        pxmin = round(min(N*xp));
        pxmax = min(round(max(N*xp)),length(alpha0)); % in case the user clicks too far in x
        if pxmax<pxmin
            error('The second click must correspond to a higher x value.')
        end
        alpha(iNP,io) = mean(alpha0(pxmin:pxmax));
        alphaRealMean = real(alpha(iNP,io));
        alphaImagMean = imag(alpha(iNP,io));

        OV(iNP,io) = mean(OV0(pxmin:pxmax));

        if alphaRealMean>1e-19 || alphaImagMean>1e-19
            if alphaImagMean<0
                alpha2print = sprintf('(%.4g-i*%.4g) x10^-18',1e18*alphaRealMean,-1e18*alphaImagMean);
            else
                alpha2print = sprintf('(%.4g+i*%.4g) x10^-18',1e18*alphaRealMean,1e18*alphaImagMean);
            end
            OV2print = sprintf('%.4ge-18',1e18*OV(iNP,io));
        else
            if alphaImagMean<0
                alpha2print = sprintf('(%.4g-i*%.4g) x10^-21',1e21*alphaRealMean,-1e21*alphaImagMean);
            else
                alpha2print = sprintf('(%.4g+i*%.4g) x10^-21',1e21*alphaRealMean,1e21*alphaImagMean);
            end
            OV2print = sprintf('%.4ge-21',1e21*OV(iNP,io));
        end
        fprintf([alpha2print '\n'])
        disp(IM.OPDfileName)
        fprintf('\t=COMPLEX(%.4g,%.4g)\n',1e21*alphaRealMean,1e21*alphaImagMean);
        clipboard('copy',sprintf('=COMPLEX(%.4g,%.4g)',1e21*alphaRealMean,1e21*alphaImagMean))
        fprintf('OV:\n')
        fprintf('\t%.4g\n',OV(iNP,io));

        if isempty(app)
            fid = fopen(generateDatedFileName('magicWandOV'),'a');
            fprintf(fid,'\t%g\n',OV(iNP,io));
            fclose(fid);
        else
            app.saveData('alpha',alphaRealMean+1i*abs(alphaImagMean),'OV',OV(iNP,io))
        end

        if nargin==2
            if isempty(app)
                set(UIresult,'String',sprintf([alpha2print '\n' OV2print]));
            else
                message = [alpha2print, ' ', OV2print];
                app.displayMessage(message)
            end
        end

    end
    if isempty(app)
        hfig.UserData{10} = alpha(iNP,io);
        figure(hfig)
    end
end

