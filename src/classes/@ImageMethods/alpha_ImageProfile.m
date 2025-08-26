function params = alpha_ImageProfile(IMlist,opt)
% ALPHA_IMAGEPROFILE returns the polarisability and dry mass of small
% objects, typically bacteria, nano- and microparticles.
%
% The algorithm involves a sum of the pixels on a circular area. The method
% opens a window with the image. First, click on the OPD image to zoom in
% on the particle of interest, and press ‘z’ when the zoom is correct.
% Second, click on the center of the particle. A new figure will show up,
% plotting the pixel summation as a function of the radius of the circular
% area, from 0 to 100 px. Finally, click two times on the graph to define
% the range of value corresponding to a proper convergence of the
% integration. In practice, the line shape should feature a plateau, and
% the user should click at the beginning and at the end of the plateau.
% Name, Value options:
%
%   opt.figure = matlab.ui.Figure.empty()
%   opt.nmax = 40
%   opt.nBkg = 3
%   opt.Dz = 0
%   opt.NNP = 1
%   opt.zoom = 1
%   opt.step = 1
%   opt.keepPoint = false  % keep the same clicking point from one image to another
%   opt.display = false


arguments
    IMlist
    opt.figure = matlab.ui.Figure.empty()
    opt.posList= [] % matrix, or cell array of Nim matrices
    opt.nmax (1,1) {mustBeInteger} = 40
    opt.nBkg (1,1) {mustBeInteger} = 3
    opt.Dz   (1,1) double = 0
    opt.NNP  (1,1) {mustBeInteger} = 1
    opt.zoom = 1
    opt.step (1,1) = 0.25
    opt.keepPoint   logical = false  % keep the same clicking center point from one image to another
    opt.keeppminmax logical = false  % keep the same clicking pmin and pmax from one image to another
    opt.pminpmax = []
    opt.display     logical = false
    opt.output = Data()
end


hfigInit = [];
if isempty(opt.figure)
    %    app = PhaseLABgui(IMlist);
    %    app.enableHandleVisibility()

    app = [];
    hfigInit = figure;
elseif isa(opt.figure,'PhaseLABgui') || isa(opt.figure,'PhaseLABgui_multiCanal')
    app = opt.figure; % suppose here that IMlist == app.IM or app.IMcurrent !
    app.enableHandleVisibility()
else
    app = [];
    hfigInit = opt.figure;
end



%hand = hfigInit.UserData{8};
NNP = opt.NNP;
nmax0 = opt.nmax;
Dz = opt.Dz;
n_bkg0 = opt.nBkg;
step = opt.step;

[Nim, Npol] = size(IMlist);

opt.output.data.names = ["#image","#NP","#polar"];
opt.output.data.inputs = [Nim,NNP,4];

if ~isfield(opt.output.data,'alpha') % if there is no info yet in the data
    opt.output.data.alpha = zeros(Nim,NNP,Npol);
    opt.output.data.OV  = zeros(Nim,NNP,Npol);
    opt.output.data.OVw = zeros(Nim,NNP,Npol);
end


xList = zeros(NNP,1);
yList = zeros(NNP,1);

for iim = 1:Nim

    if ~isempty(opt.posList)
        if iscell(opt.posList) % transform the cell array into a matrix
            if numel(opt.posList) == Nim
                posList = opt.posList{iim};
            else
                error('there should be as posList as number of images')
            end
        else
            posList = opt.posList;
        end
    else % keep it empty
        posList = opt.posList;
    end

    IM = IMlist(iim,:);

    if isa(IM,'ImageEM')
        if norm(IM(1).EE0)==0
            warning('As E0 is zero at the image plane, the T map is not normalized and the alpha won''t be absolutely measured.')
        end
    end

    if isempty(IM(1).Illumination.Medium)
        error('The illumination object is missing a Medium property. Please define your illumination object this way Illumination(lambda,ME) and not only this way Illumination(lambda).')
    end

    n1 = IM(1).Illumination.n;
    n2 = IM(1).Illumination.nS;
    taillePx = IM(1).pxSize;



    for iNP = 1:NNP
        for ipol = 1:Npol
            imOPD = IM(ipol).OPD;
            imT = IM(ipol).T; %./imTref; %intensity normalization

            fprintf(['Nanoparticle #' num2str(iNP) '/' num2str(NNP) '\n'])

            if ( ~opt.keepPoint || iim==1 ) && ipol == 1
                if  isempty(app)
                    figure(hfigInit);
                    imagesc(imT),colormap(gray),colorbar
                    set(gca,'Ydir','normal')
                    %% zoom on the particle of interest
                    if opt.zoom
                        zoom on
                        set(gcf,'currentch',char(1))
                        get(gcf,'CurrentCharacter')
                        waitfor(gcf,'CurrentCharacter',char(122))
                        zoom reset
                    end
                else
                    axes(app.AxesLeft)
                    set(app.UIFigure,'currentch',char(1))
                    get(app.UIFigure,'CurrentCharacter')
                    if opt.zoom
                        zoom on
                        app.displayMessage('zoom and then press ''z'' key')
                        waitfor(app.UIFigure,'CurrentCharacter',char(122))  % char 'z'
                        app.clearMessageArea()
                        zoom reset
                    end
                end
            end
            % press the central pixel of the particle

            button = 0;

            if nmax0 == 0  % sum over the whole image
                opt.output.data.alpha(iim,iNP,ipol) = IM(1).alpha(); %TODO: this method does not exist anymore
                realphamean = real(opt.output.data.alpha(iim,iNP,ipol));
                imalphamean = imag(opt.output.data.alpha(iim,iNP,ipol));
            else
                while(button ~= 1)
                    if (~opt.keepPoint || iim==1)
                        if  ipol ~= 1
                            %do nothing to keep x_px and y_px unchanged
                        elseif isempty(posList)
                            if isempty(app)
                                [x_px,y_px] =ginput(1);
                            else
                                [x_px,y_px] = app.ginputUI(1,'outUnit','px');
                                app.disableHandleVisibility()
                            end
                            fprintf('x=%d, y=%d\n',x_px, y_px)
                        else
                            if opt.NNP == size(posList,1)
                                x_px = posList(iNP,1);
                                y_px = posList(iNP,2);
                            else
                                error('The number of NP positions ("center" value) must equal the number of NPs "NNP" value).')
                            end
                            hold on
                            plot(x_px,y_px,'ro','LineWidth',2)
                            pause(1)
                        end
                        xList(iNP) = x_px;
                        yList(iNP) = y_px;
                        %% starting pixel for sum
                        %n = input('nothing');

                        nmax = min(round(y_px)-1, nmax0);
                        nmax = min(round(x_px)-1, nmax);
                        nmax = min(IM(1).Ny-round(y_px)-1,nmax);
                        nmax = min(IM(1).Nx-round(x_px)-1,nmax);

                    end

                    if opt.keepPoint
                        x_px = xList(iNP);
                        y_px = yList(iNP);                       
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
                        Phnorm = 2*pi*OPDnorm./IM(1).lambda;

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

                        alpha2D = 1i*IM(1).lambda*n2/(pi)*(1-sqrtT.*expPh);
                        alpha(co) = sum(alpha2D(:))*taillePx.*taillePx;

                        OV(co) = sum(Phnormask*IM(1).lambda/(2*pi))*taillePx.*taillePx;
                        OVw(co) = sum(sqrt(imTcropnormask).*Phnormask*IM(1).lambda/(2*pi))*taillePx.*taillePx;
                        %sqrtTsum(co) = sum(sqrtT(:));
                        %expPhsum(co) = sum(expPh(:));

                    end

                    %Correction of the particle height on alpha
                    if Dz ~= 0
                        r12 = (n1-n2)/(n1+n2);
                        k0 = 2*pi/IM(1).Illumination.lambda;
                        Gamma = r12*exp(-2*1i*n1*k0*Dz); 
                        alpha0 = 32*pi*Dz^3*(n2^2+n1^2)/(n2^2-n1^2);
                        alpha = alpha./(1+Gamma+alpha/alpha0);
                    end

                    realpha = real(alpha);
                    imalpha = imag(alpha);
                    if ~isempty(hfigInit)
                        hfigInit.Visible="off";
                    end

                    %% mean value of alpha and error bares
                    %pxmin = input('valeur de pxmin'); %faire la moyene de alpha entre pxmin et pxmax
                    %pxmax = input('valeur de pxmax');
                    if  ipol ~= 1
                        button = 1;
                    elseif ~isempty(opt.pminpmax)
                        xp = opt.pminpmax;
                        button=1;
                    elseif ~opt.keeppminmax || (iim == 1 && iNP == 1)
                        drawnow
                        pause(1)
                        hfig2 = figure(MenuBar="none",ToolBar="none",Name="Particle selection",NumberTitle="off");
                        plot(coo,realpha)
                        %save -ascii realpha_p250 realpha
                        hold on
                        plot(coo,imalpha)
                        plot(coo,OV)
                        plot(coo,OVw)
                        legend({'Realpha(nm^3)';'Imalpha(nm^3)';'Optical Volume';'Weighted Optical Volume'},'Location','northwest')
                        title('Click on two values xmin and xmax, or click twice the bar space to try again.')
                        fullwidth
                        [xp,~,button] = ginput(2);  % click twice on any key to restart the loop. Other, click twice with the mouse to keep on going.
                        close(hfig2)
                        if ~isempty(hfigInit)
                            hfigInit.Visible="on";
                        end
                    else
                        button = 1;
                    end



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
                opt.output.data.alpha(iim,iNP,ipol) = realphamean+1i*imalphamean;
                opt.output.data.OV(iim,iNP,ipol) = mean(OV(pxmin:pxmax));
                opt.output.data.OVw(iim,iNP,ipol) = mean(OVw(pxmin:pxmax));
                %close(hfig)
            end %if nmax==0
        end %ip
        fprintf('alpha [x10^-21]:\n')
        if imalphamean<0
            fprintf('%d\t(%.4g-1i*%.4g)\n',iNP,1e21*realphamean,-1e21*imalphamean);
        else
            fprintf('%d\t(%.4g+1i*%.4g)\n',iNP,1e21*realphamean,1e21*imalphamean);
        end
        fprintf('=COMPLEX(%.4g;%.4g)\n',1e21*realphamean,1e21*imalphamean);
        clipboard('copy',sprintf('=COMPLEX(%.4g;%.4g)',1e21*realphamean,1e21*imalphamean))
        fprintf('OV [x10^-21]:')
        fprintf('\t%.4g\n',1e21*opt.output.data.OV(iim,iNP,1));
        fprintf('OVw [x10^-21]:')
        fprintf('\t%.4g\n',1e21*opt.output.data.OVw(iim,iNP,1));

        if isempty(app)
            hfigInit.UserData{10} = opt.output.data.alpha;
            hfigInit.UserData{11} = [xList,yList];
            if ~isempty(get(hfigInit.UserData{8}))
                if get(hfigInit.UserData{8}.autosave,'value')
                    if NNP>1
                        saveData(hfigInit,hc)
                    else
                        saveData(hfigInit)
                    end
                end
            end
        else
            app.saveData('tech','radial','alpha',realphamean + 1i*imalphamean,'OV',opt.output.data.OV(iim,iNP,1),'writeData',app.autoSave)
        end

    end %iNP


    if NNP > 1
        hc = cplot(opt.output.data.alpha(iim,:,1));
    end

    if ~isempty(hfigInit) && ~isempty(hfigInit.UserData{8})
        if iim~=Nim
            figure_callback(hfigInit,IMlist(1+str2double(get(hfigInit.UserData{8}.UIk,'String'))),hfigInit.UserData{2},hfigInit.UserData{3},hfigInit.UserData{4},str2double(get(hfigInit.UserData{8}.UIk,'String'))+1)
        end
    end
end


%params.center = [x_px,y_px];
opt.output.data.posList = [xList, yList];
opt.output.data.profiles = [coo',realpha,imalpha] ;
opt.output.data.pminpmax = xp;
params = opt.output.data;


if opt.display % makes sense only for multiple measurments
    figure
    hold on
    plot(real(params.alpha(:,:,1)))
    plot(imag(params.alpha(:,:,1)))
    plot(params.OV(:,:,1))
    plot(params.OVw(:,:,1))
    legend({'real alpha','imag alpha','OV','OV weighted'})
end

