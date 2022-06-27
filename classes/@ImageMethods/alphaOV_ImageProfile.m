function [alphaNP,OVNP,OVNPn,OVNPn2,posList,pList] = alphaOV_ImageProfile(IM,opt)
arguments
    IM ImageMethods
    opt.fhandle =[] %matlab.ui.Figure
    opt.nmax (1,1)  {mustBeInteger} = 100
    opt.Dz  (1,1) {mustBeNumeric} = 0
    opt.bgThickness (1,1) {mustBeInteger} = 3
    opt.NNP (1,1) {mustBeInteger} = 1
    opt.OVnorm (1,1) logical = false
    opt.zoom (1,1) logical = true
    opt.fullscreen (1,1) logical = false
    opt.posList = []
    opt.pList = []
end

%alpha_ImageProfile(IM,hfigInit)
%alpha_ImageProfile(IM,nmax)
%alpha_ImageProfile(IM,nmax,Dz)
%alpha_ImageProfile(IM,nmax,Dz,nbgthick)
% NNP: number of nanoparticles to be measured in the image
% nmax: size of the max cropped area around the NP
if ~isempty(opt.fhandle)
    if ~ishandle(opt.fhandle)
        error('the argumet must be a number or a figure handle')
    end
    hfigInit = opt.fhandle;
    if ~strcmp(hfigInit.UserData{2},'px')
        error('Please select px units to use the alpha function')
    end
    hand = hfigInit.UserData{8};
    NNP = str2double(get(hand.UIalpha_NNP,'String'));
    nmax0 = str2double(get(hand.UIalpha_nmax,'String'));
    Dz = str2double(get(hand.UIalpha_Dz,'String'))*1e-9;
    n_bkg0 = str2double(get(hand.UIalpha_bkgThick,'String'));
else
    NNP = opt.NNP;
    nmax0 = opt.nmax;
    Dz = opt.Dz;
    n_bkg0 = opt.bgThickness;
end




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

alphaNP = zeros(NNP,1);
OVNP = zeros(NNP,1);
OVNPn = zeros(NNP,1);
OVNPn2 = zeros(NNP,1);

pxmin = zeros(NNP,1);
pxmax = zeros(NNP,1);

imph = IM.OPD;
imT = IM.T; %./imTref; %intensity normalization

xList = zeros(NNP,1);
yList = xList;
for iNP = 1:NNP
    
    fprintf(['Nanoparticle #' num2str(iNP) '/' num2str(NNP) '\n'])
    
    if ~exist('hfigInit','var')
        hfigInit = figure;
        imagesc(imT),colormap(gray),colorbar
        if opt.fullscreen
            hfigInit.WindowState = 'maximized';
        end
        if isempty(opt.fhandle) % if a figure handle was not primarily defined
            set(gca,'Ydir','normal')
            set(gca,'DataAspectRatio',[1 1 1])
        end
    end

    figure(hfigInit)
    title(['Nanoparticle #' num2str(iNP) '/' num2str(NNP)],'FontSize',20)
    if opt.zoom
        zoom on
        waitfor(gcf,'CurrentCharacter',char(13))
    end
    %zoom reset
    % press the central pixel of the particle
    
    button = 0;
    
    if nmax0==0  % sum over the whole image
        alphaNP(iNP) = IM.alpha();
        realphamean = real(alphaNP(iNP));
        imalphamean = imag(alphaNP(iNP));
    else
        while(button~=1) % i.e. as long as it is not a mouse click
            figure(hfigInit)
            if ~isempty(opt.posList)
                x = opt.posList.x(iNP);
                y = opt.posList.y(iNP);
            else
                [x,y] = ginput(1);
            end
            xList(iNP) = x;
            yList(iNP) = y;
            %% starting pixel for sum
            %n = input('nothing');
            
            nmax = min(round(y)-1, nmax0);
            nmax = min(round(x)-1, nmax);
            nmax = min(IM.Ny-round(y)-1,nmax);
            nmax = min(IM.Nx-round(x)-1,nmax);
            
            
            imPcrop = imph(round(y)-nmax:round(y)+nmax,round(x)-nmax:round(x)+nmax); %crop OPD image
            imTcrop = imT(round(y)-nmax:round(y)+nmax,round(x)-nmax:round(x)+nmax); %crop intensity image
            
            
            
            % create mask image
            
            %if strcmp(IM.processingSoftware,'PhaseLAB')
            %    dcoo=1;
            %else
            dcoo = 0.25;
            %end
            coo = 0:dcoo:nmax; % integration radius
            Noo = numel(coo);
            sizeX = 2*nmax+1;
            sizeY = 2*nmax+1;
            [rows,columns] = meshgrid(1:sizeX, 1:sizeY);
            
            OV = zeros(Noo,1);
            OVn = zeros(Noo,1);
            OVn2 = zeros(Noo,1);
            alpha = zeros(Noo,1);            
            
            %% computation of alpha as a function of the summed pixel number
            for co = 1:Noo
                rr = coo(co);
                array2D = (rows - (nmax+1)).^2 + (columns - (nmax+1)).^2;
                circle = array2D <= rr.^2; %mask circle for each cooeration
                ring = array2D >= rr.^2 & array2D <= (rr+n_bkg0).^2; %mask ring
                
                imP = imPcrop.*circle;
                imP_0 = imPcrop.*ring; %only the borders of background image are different from 0
                
                backgroundOPD = sum(imP_0(:))/(sum(ring(:))); %mean backgound
                OPDnorm = (imP-backgroundOPD);
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
                
                sqrtT = sqrt(imTcropnormask);
                expPh = exp(1i*Phnormask);
                
                alpha2D = 1i*IM.lambda*n2/(pi)*(1-sqrtT.*expPh);
                alpha(co) = sum(alpha2D(:))*taillePx.*taillePx;

                    OV(co) = sum(Phnormask*IM.lambda/(2*pi))*taillePx.*taillePx;
                    OVn(co) = sum(sqrtT.*Phnormask*IM.lambda/(2*pi))*taillePx.*taillePx;
                    OVn2(co) = sum(sqrtT.^2.*Phnormask*IM.lambda/(2*pi))*taillePx.*taillePx;
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
    
            hfig2 = figure();
            if opt.fullscreen
                hfig2.WindowState = 'maximized';
            end
            plot(coo,realpha)
            %save -ascii realpha_p250 realpha
            hold on
            plot(coo,imalpha)
            plot(coo,OV)
            plot(coo,OVn)
            legend({'Realpha(nm^3)';'Imalpha(nm^3)';'Optical Volume';'Optical Volume (norm)'},'Location','northwest')
            title('Click on two values xmin and xmax, or click twice the bar space to try again.')
            
            %% mean value of alpha and error bares
            %pxmin = input('valeur de pxmin'); %faire la moyene de alpha entre pxmin et pxmax
            %pxmax = input('valeur de pxmax');
            if ~isempty(opt.pList)
                xp = [opt.pList.min(iNP) opt.pList.max(iNP)];
                button = 1;
            else
                [xp,~,button] = ginput(2);  % click twice on any key to restart the loop. Other, click twice with the mouse to keep on going.
            end
            close(hfig2)
        end
        
        
        pxmin(iNP) = round(min(xp/dcoo));
        pxmax(iNP) = min(round(max(xp/dcoo)),length(realpha)); % in case the user clicks too far in x
        realphamean = mean(realpha(pxmin(iNP):pxmax(iNP)));
        %realphaerror = std(realpha(pxmin:pxmax));
        imalphamean = mean(imalpha(pxmin(iNP):pxmax(iNP)));
        %imalphaerror = std(imalpha(pxmin:pxmax));
        %argalphamean = mean(angalpha(pxmin:pxmax));
        %argalphaerror = std(angalpha(pxmin:pxmax));
        alphaNP(iNP) = realphamean+1i*imalphamean;
        OVNP(iNP) = mean(OV(pxmin(iNP):pxmax(iNP)));
        OVNPn(iNP) = mean(OVn(pxmin(iNP):pxmax(iNP)));
        OVNPn2(iNP) = mean(OVn2(pxmin(iNP):pxmax(iNP)));
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
    fprintf('OV [x10^-21]:\n')
    fprintf('\t%.4g\n',1e21*OVNP(iNP));
    fprintf('OVn [x10^-21]:\n')
    fprintf('\t%.4g\n',1e21*OVNPn(iNP));
    fprintf('OVn2 [x10^-21]:\n')
    fprintf('\t%.4g\n',1e21*OVNPn2(iNP));
    
set(gcf,'CurrentCharacter',char(1))
zoom out
end %iNP


if iNP == NNP
    close(hfigInit)
    clear hfigInit
%    hc=cplot(alphaNP);
end
if nargin>=2
    if ishandle(opt.fhandle) % if figure mode
        hfigInit.UserData{10} = alphaNP;
        hfigInit.UserData{11} = [xList,yList];
        if get(hfigInit.UserData{8}.autosave,'value')
            if NNP>1
                saveData(hfigInit,hc)
            else
                saveData(hfigInit)
            end
        end
    end
end
%if iNP == NNP
%    close(hc)
%end
posList.x = xList;
posList.y = yList;
pList.min = pxmin*dcoo;
pList.max = pxmax*dcoo;


end
