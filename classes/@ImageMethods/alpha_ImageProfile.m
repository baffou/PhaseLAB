function params = alpha_ImageProfile(IMlist,opt)
arguments
    IMlist
    opt.figure = matlab.ui.Figure.empty()
    opt.nmax = 40
    opt.nBkg = 3
    opt.Dz = 0
    opt.NNP = 1
    opt.zoom = 1
    opt.step = 1
    opt.keepPoint = false  % keep the same clicking point from one image to another
    opt.display = false
end

% alpha_ImagePorfile(app)
% alpha_ImageProfile(IM,hfigInit)
% alpha_ImageProfile(IM,nmax)
% alpha_ImageProfile(IM,nmax,Dz)
% alpha_ImageProfile(IM,nmax,Dz,nbgthick)
% NNP: number of nanoparticles to be measured in the image
% nmax: size of the max cropped area around the NP

if isempty(opt.figure)
    %    hfigInit = IMlist.figure;
    app = PhaseLABgui(IMlist);
    app.enableHandleVisibility()
elseif isa(opt.figure,'PhaseLABgui')
    app = opt.figure; % suppose here that IMlist == app.IM or app.IMcurrent !
    app.enableHandleVisibility()
else
    app = [];
    hfigInit = opt.figure;
end


zoom(opt.zoom)

%hand = hfigInit.UserData{8};
NNP=opt.NNP;
nmax0=opt.nmax;
Dz=opt.Dz;
n_bkg0=opt.nBkg;
step=opt.step;

Nim=numel(IMlist);

alphaNP = zeros(NNP,Nim);
OVNP = zeros(NNP,Nim);
OVwNP = zeros(NNP,Nim);


for io = 1:Nim
    IM=IMlist(io);

    if isa(IM,'ImageEM')
        if norm(IM.EE0)==0
            warning('As E0 is zero at the image plane, the T map is not normalized and the alpha won''t be absolutely measured.')
        end
    end

    if isempty(IM.Illumination.Medium)
        error('The illumination object is missing a Medium property. Please define your illumination object this way Illumination(lambda,ME) and not only this way Illumination(lambda).')
    end

    n1 = IM.Illumination.n;
    n2 = IM.Illumination.nS;
    taillePx = IM.pxSize;

    imOPD = IM.OPD;
    imT = IM.T; %./imTref; %intensity normalization

    xList = zeros(NNP,1);
    yList = xList;
    for iNP = 1:NNP

        fprintf(['Nanoparticle #' num2str(iNP) '/' num2str(NNP) '\n'])

        if  isempty(app) % if using the old gui version
            hfigInit = figure;
            imagesc(imT),colormap(gray),colorbar
            set(gca,'Ydir','normal')
            %% zoom on the particle of interest
            zoom on
            set(app.UIFigure,'currentch',char(1))
            get(gcf,'CurrentCharacter')
            waitfor(gcf,'CurrentCharacter',char(13))
            zoom reset
        else
            axes(app.AxesLeft)
            set(app.UIFigure,'currentch',char(1))
            get(app.UIFigure,'CurrentCharacter')
            zoom on
            app.displayMessage('zoom and then press ''z'' key')
            waitfor(app.UIFigure,'CurrentCharacter',char(122))  % char 'z'
            app.clearMessageArea()
            zoom reset
        end
        % press the central pixel of the particle

        button = 0;

        if nmax0==0  % sum over the whole image
            alphaNP(iNP,io) = IM.alpha(); %TODO: this method does not exist anymore
            realphamean = real(alphaNP(iNP));
            imalphamean = imag(alphaNP(iNP));
        else
            while(button~=1) % i.e. as long as pmax is not a mouse click it is not a mouse click
                if ~opt.keepPoint || (opt.keepPoint && io==1)
                    [x_px,y_px] = app.ginputUI(1,'outUnit','px');
                    app.disableHandleVisibility()
                    fprintf('x=%d, y=%d\n',x_px, y_px)
                    xList(iNP) = x_px;
                    yList(iNP) = y_px;
                    %% starting pixel for sum
                    %n = input('nothing');

                    nmax = min(round(y_px)-1, nmax0);
                    nmax = min(round(x_px)-1, nmax);
                    nmax = min(IM.Ny-round(y_px)-1,nmax);
                    nmax = min(IM.Nx-round(x_px)-1,nmax);

                end

                imOPDcrop = imOPD(round(y_px)-nmax:round(y_px)+nmax,round(x_px)-nmax:round(x_px)+nmax); %crop OPD image
                imTcrop = imT(round(y_px)-nmax:round(y_px)+nmax,round(x_px)-nmax:round(x_px)+nmax); %crop intensity image



                % create mask image

                %if strcmp(IM.processingSoftware,'PhaseLAB')
                %    dcoo=1;
                %else
                dcoo = step;
                %end
                coo = 0:dcoo:nmax; % integration radius
                Noo = numel(coo);
                sizeX = 2*nmax+1;
                sizeY = 2*nmax+1;
                [rows,columns] = meshgrid(1:sizeX, 1:sizeY);

                OV = zeros(Noo,1);
                OVw = zeros(Noo,1);  % weighted OV
                alpha = zeros(Noo,1);

                %% computation of alpha as a function of the summed pixel number
                for co = 1:Noo
                    rr = coo(co);
                    array2D = (rows - (nmax+1)).^2 + (columns - (nmax+1)).^2;
                    circle = array2D <= rr.^2; %mask circle for each cooeration
                    ring = array2D >= rr.^2 & array2D <= (rr+n_bkg0).^2; %mask ring

                    imOPDD = imOPDcrop.*circle;
                    imOPD_0 = imOPDcrop.*ring; %only the borders of background image are different from 0

                    backgroundOPD = sum(imOPD_0(:))/(sum(ring(:))); %mean backgound
                    OPDnorm = (imOPDD-backgroundOPD);
                    %figure,imagesc(OPDnorm),colorbar
                    Phnorm = 2*pi*OPDnorm./IM.lambda;

                    imTT = imTcrop.*circle;
                    imTcrop_0 = imTcrop.*ring;
                    backgroundT = sum(imTcrop_0(:))/(sum(ring(:)));
                    imTcropnorm = imTT./backgroundT;
                    %figure,imagesc(imTcropnorm),colormap(gray),colorbar

                    %% experimental polarizability
                    imTcropnormask = imTcropnorm(circle); %take only values included in the circle
                    Phnormask = Phnorm(circle); %take only values included in the circle

                    %imTcropnormask=imT(:);
                    %Phnormask=2*pi/IM.lambda*imOPD(:);
                    %imTcropnormask=imTcrop(:);
                    %Phnormask=2*pi/IM.lambda*imOPDcrop(:);

                    sqrtT = sqrt(imTcropnormask);
                    expPh = exp(1i*Phnormask);

                    alpha2D = 1i*IM.lambda*n2/(pi)*(1-sqrtT.*expPh);
                    alpha(co) = sum(alpha2D(:))*taillePx.*taillePx;

                    OV(co) = sum(Phnormask*IM.lambda/(2*pi))*taillePx.*taillePx;
                    OVw(co) = sum(sqrt(imTcropnormask).*Phnormask*IM.lambda/(2*pi))*taillePx.*taillePx;
                    %sqrtTsum(co) = sum(sqrtT(:));
                    %expPhsum(co) = sum(expPh(:));

                end

                %Correction of the particle height on alpha
                if Dz~=0
                    r12 = (n1-n2)/(n1+n2);
                    k0 = 2*pi/IM.Illumination.lambda;
                    Gamma = r12*exp(-2*1i*n1*k0*Dz);
                    alpha0 = 32*pi*Dz^3*(n2^2+n1^2)/(n2^2-n1^2);
                    alpha = alpha./(1+Gamma+alpha/alpha0);
                end

                realpha = real(alpha);
                imalpha = imag(alpha);
                hfigInit.Visible="off";
                hfig2 = figure();
                plot(coo,realpha)
                %save -ascii realpha_p250 realpha
                hold on
                plot(coo,imalpha)
                plot(coo,OV)
                plot(coo,OVw)
                legend({'Realpha(nm^3)';'Imalpha(nm^3)';'Optical Volume';'Weighted Optical Volume'},'Location','northwest')
                title('Click on two values xmin and xmax, or click twice the bar space to try again.')

                %% mean value of alpha and error bares
                %pxmin = input('valeur de pxmin'); %faire la moyene de alpha entre pxmin et pxmax
                %pxmax = input('valeur de pxmax');
                figure(hfig2)
                fullwidth
                [xp,~,button] = ginput(2);  % click twice on any key to restart the loop. Other, click twice with the mouse to keep on going.
                close(hfig2)
                hfigInit.Visible="on";

            end


            pxmin = round(min(xp/dcoo));
            pxmax = min(round(max(xp/dcoo)),length(realpha)); % in case the user clicks too far in x
            if pxmax<pxmin
                error('The second click must correspond to a higher x value.')
            end
            realphamean = mean(realpha(pxmin:pxmax));
            %realphaerror = std(realpha(pxmin:pxmax));
            imalphamean = mean(imalpha(pxmin:pxmax));
            %imalphaerror = std(imalpha(pxmin:pxmax));
            %argalphamean = mean(angalpha(pxmin:pxmax));
            %argalphaerror = std(angalpha(pxmin:pxmax));
            %            realphamean+1i*imalphamean;
            alphaNP(iNP,io) = realphamean+1i*imalphamean;
            OVNP(iNP,io) = mean(OV(pxmin:pxmax));
            OVwNP(iNP,io) = mean(OVw(pxmin:pxmax));
            %close(hfig)
        end %if nmax==0
        fprintf('alpha [x10^-21]:\n')
        if imalphamean<0
            fprintf('%d\t(%.4g-1i*%.4g)\n',iNP,1e21*realphamean,-1e21*imalphamean);
        else
            fprintf('%d\t(%.4g+1i*%.4g)\n',iNP,1e21*realphamean,1e21*imalphamean);
        end
        fprintf('=COMPLEX(%.4g,%.4g)\n',1e21*realphamean,1e21*imalphamean);
        clipboard('copy',sprintf('=COMPLEX(%.4g,%.4g)',1e21*realphamean,1e21*imalphamean))
        fprintf('OV [x10^-21]:')
        fprintf('\t%.4g\n',1e21*OVNP(iNP,io));
        fprintf('OVw [x10^-21]:')
        fprintf('\t%.4g\n',1e21*OVwNP(iNP,io));
    
        if isempty(app)
            hfigInit.UserData{10} = alphaNP;
            hfigInit.UserData{11} = [xList,yList];
            if get(hfigInit.UserData{8}.autosave,'value')
                if NNP>1
                    saveData(hfigInit,hc)
                else
                    saveData(hfigInit)
                end
            end
        else
            app.saveData('tech','radial','alpha',realphamean+1i*imalphamean,'OV',OVNP(iNP,io),'writeData',app.autoSave)
        end

    end %iNP


    if NNP>1
        hc = cplot(alphaNP(:,io));
    end

    if io~=Nim
        figure_callback(hfigInit,IMlist(1+str2double(get(hfigInit.UserData{8}.UIk,'String'))),hfigInit.UserData{2},hfigInit.UserData{3},hfigInit.UserData{4},str2double(get(hfigInit.UserData{8}.UIk,'String'))+1)
    end
end


params.alpha = alphaNP.';
params.OV    = OVNP.';
params.OVw   = OVwNP.';

if opt.display % makes sense only for multiple measurments
    figure
    hold on
    plot(real(params.alpha))
    plot(imag(params.alpha))
    plot(params.OV)
    plot(params.OVw)
    legend({'real alpha','imag alpha','OV','OV weighted'})
end