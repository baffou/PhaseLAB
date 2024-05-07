%% MAIN PROGRAM THAT PROCESSES A TEMPERATURE IMAGE FROM AN OPD PHASE IMAGE.

function [tmp, hsd, GreenDbig, GreenT_z0, GreenT_3D] = opd2tmp0(ima0,MI,ME,opt)
arguments
    ima0 (:,:) double
    MI (1,1) Microscope
    ME (1,:) MediumT
    opt.g (1,1) double = 1
    opt.nLoop (1,1) double = 1
    opt.alpha (1,1) double = 1e-5
    opt.smoothing (1,1) double = 0
    opt.imExpander (1,1) logical = false
    opt.T0 (1,1) double = 22
    opt.zT (1,1) double = 0
    opt.GreenOPD (:,:) double
    opt.GreenT_z0 (:,:) double
    opt.GreenT_3D (:,:) double
end

pxSize = MI.pxSize;
nLoop = opt.nLoop;
gain = opt.g;
T0 = opt.T0;

[ny, nx] = size(ima0);

saveFolder = pwd;


m1 = ME(1);
m2 = ME(2);

if length(ME) == 3
    m3 = ME(3);
end
%% Check whether opt.GreenOPD has the proper size

if ~isempty(opt.GreenOPD)
    if any(size(opt.GreenOPD) ~= 2*size(ima0))
        opt.GreenOPD = [];
        opt.GreenT_z0 = [];
        opt.GreenT_3D = [];
    end
end



%% calculation of the Thermal Green's function

if isempty(opt.GreenOPD)

    if length(ME) == 3
        % construction of the thermal Green's function in the (rho,z) plane by extrapolation
        % Meshing(z1,z2,dz,npx)
        % z1: starting z
        % z2: final z
        % dz: starting increment
        % npx: (optional) Number of pixels. By default: h/dz+1.
        RHO = MeshingT(pxSize/2,pxSize*sqrt(nx*nx+ny*ny),pxSize,sqrt(nx*nx+ny*ny)/5);

        %greenT_RHOZ(RHO,ME,folder)
        % RHO: Meshing object, defining of the meshing in rho
        % ME: array of Medium objects defining the different layers
        % folder: (optional) Folder to save the Green's function and the figure
        GreenTRHOZ = greenT_RHOZ(RHO,ME,saveFolder);

        % interpolation of the thermal Green's function in the (x,y,z) plane by extrapolation
        Nz = size(GreenTRHOZ)*[1;0];
        GreenT_3D = zeros(2*ny,2*nx,Nz);

        fprintf('construction of the 3D thermal Green''s function\n')
        for iz = 1:Nz
            fprintf('iz:%d/%d\n',iz,Nz)
            tic
            GreenT_3D(:,:,iz) = transformR2XY(RHO,GreenTRHOZ(iz,:),nx,ny,MI.pxSize);
            toc
        end
        if opt.zT==0
            GreenT_z0 = GreenT_3D(:,:,ME(1).mesh.npx);
        else
            GreenTRHOZ_z0 = greenT_3layers(RHO.z,0*RHO.z,opt.zT*(0*RHO.z+1),ME);
            GreenT_z0 = transformR2XY(RHO,GreenTRHOZ_z0,nx,ny,MI.pxSize);
        end
    else % 2 layers
        if nLoop>1
            GreenT_3D = greenT_2layers(ME,nx,ny,MI);  % analytical expression for 2 layers
        end
        GreenT_z0 = greenT_2layers(ME,nx,ny,MI,opt.zT);
    end

    %% construction of the OPD Green's function
    GreenDbig = zeros(2*ny,2*nx);

    if length(ME) == 3

        for iz = 1:m1.mesh.npx-1
            dz = abs((m1.mesh.z(iz+1)-m1.mesh.z(iz)));
            dndT = (m1.b(1)+2*m1.b(2)*T0+3*m1.b(3)*T0*T0+4*m1.b(4)*T0*T0*T0);

            GreenDbig = GreenDbig+dndT*dz*(GreenT_3D(:,:,iz+1)+GreenT_3D(:,:,iz))/2;
        end

        for iz = 1:m2.mesh.npx-1
            dz = abs((m2.mesh.z(iz+1)-m2.mesh.z(iz)));
            dndT = (m2.b(1)+2*m2.b(2)*T0+3*m2.b(3)*T0*T0+4*m2.b(4)*T0*T0*T0);
            GreenDbig = GreenDbig+dndT*dz*(GreenT_3D(:,:,iz+m1.mesh.npx)+GreenT_3D(:,:,iz+m1.mesh.npx-1))/2;
        end

        for iz = 1:m3.mesh.npx-1
            dz = abs((m3.mesh.z(iz+1)-m3.mesh.z(iz)));
            dndT = (m3.b(1)+2*m3.b(2)*T0+3*m3.b(3)*T0*T0+4*m3.b(4)*T0*T0*T0);
            GreenDbig = GreenDbig+dndT*dz*(GreenT_3D(:,:,m1.mesh.npx+m2.mesh.npx-1+iz)+GreenT_3D(:,:,m1.mesh.npx+m2.mesh.npx-2+iz))/2;
        end

    else
        B1 = m2.b(1);
        B2 = m2.b(2);
        B3 = m2.b(3);
        B4 = m2.b(4);
        dndT = (B1+2*B2*T0+3*B3*T0*T0+4*B4*T0*T0*T0);

        Rbig.x = ( (1:2*nx)-nx-0.5 )*pxSize ;
        Rbig.y = ( (1:2*ny)-ny-0.5 )*pxSize ;
        yyBig = Rbig.y' * ones(1,2*nx) ;
        xxBig = ones(2*ny,1) * Rbig.x ;

        rhoBig = sqrt(xxBig.*xxBig+yyBig.*yyBig);
        GreenDbig = asinh(ME(2).h./rhoBig);
        GreenDbig = dndT*GreenDbig/(2*pi*(m1.kappa+m2.kappa));

    end

else
    GreenDbig = opt.GreenOPD;
    GreenT_z0 = opt.GreenT_z0;
end

%%  computation of the hsd and temperature images

% Modification de l'image de phase



ima = ima0-max(ima0(:));
ima = ima+0.1*mean(mean(ima(round(ny/2)-20:round(ny/2)+20,round(nx/2)-20:round(nx/2)+20)));
ima = ima/(MI.refl+1); % divide the phase image by a factor of two if in reflection mode.

if opt.imExpander == 1
    DexpBig = expandImage(ima);
else
    DexpBig = zeros(2*ny,2*nx);
    DexpBig(1+floor(ny/2):ny+floor(ny/2),1+floor(nx/2):nx+floor(nx/2))=ima;
end

if opt.smoothing~=0
    DexpBig = imgaussfilt(DexpBig,opt.smoothing);
end

tic

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%ALGORITHM%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% RETRIEVAL OF THE INITIAL SOURCE DISTRIBUTION

DcalcBig = zeros(size(DexpBig));
PrBigF = zeros(size(DexpBig));
GreenDbigF = fft2(GreenDbig);

if nLoop>1 % display the comparison figure
    screensize = get( groot, 'Screensize' );
    fid_comp=figure('name','comparison calculed OPD image and experimental OPD image','Position',[screensize(3)-900 screensize(4)-300 900 300]);
    subplot(1,2,1)
    imagegb(DexpBig)
    title('Experimental OPD')
    xlabel('x (px)') % x-axis label
    ylabel('y (px)')   % y-axis label
    subplot(1,2,2), imagegb(DcalcBig)
    title('Calculated OPD')
    xlabel('x (px)') % x-axis label
    ylabel('y (px)')   % y-axis label
    caxis([min(DexpBig(:)) max(DexpBig(:))])
end

for loop = 1:nLoop
    fprintf(['loop: ' num2str(loop) '/' num2str(nLoop) '\n'])
    Dbig = DexpBig-DcalcBig;
    DbigF = fft2(Dbig);
    TikhBig = conj(GreenDbigF)./(GreenDbigF.*conj(GreenDbigF)+opt.alpha/(2*pi*(m1.kappa+m2.kappa))^2);
    PrBigF = gain*DbigF.*TikhBig + PrBigF;

    % Retrieval of the 3D temperature
    DcalcBig = zeros(2*ny,2*nx);
    c = zeros(4,1);

    if nLoop>1
        GreenTbigF0 = fft2(GreenT_3D(:,:,1));
        TrBig0 = ifft2(PrBigF.*GreenTbigF0);
        c(1) = m1.b(1)+2*m1.b(2)*T0+3*T0*T0*m1.b(3)+4*T0*T0*T0*m1.b(4);
        c(2) = (m1.b(2)+3*T0*m1.b(3)+6*T0*T0*m1.b(4));
        c(3) = (m1.b(3)+4*T0*m1.b(4));
        c(4) = m1.b(4);
        for iz = 1:m1.mesh.npx-1
            GreenTbigF1 = fft2(GreenT_3D(:,:,iz+1));
            TrBig1 = ifft2(PrBigF.*GreenTbigF1);
            dz = abs((m1.mesh.z(iz+1)-m1.mesh.z(iz)));

            DcalcBig = DcalcBig+(c(1)*(TrBig1+TrBig0)...
                +c(2)*(TrBig1.*TrBig1+TrBig0.*TrBig0)...
                +c(3)*(TrBig1.*TrBig1.*TrBig1+TrBig0.*TrBig0.*TrBig0)...
                +c(4)*(TrBig1.*TrBig1.*TrBig1.*TrBig1+TrBig0.*TrBig0.*TrBig0.*TrBig0))*dz/2;
            TrBig0 = TrBig1;
        end

        c(1) = m2.b(1)+2*m2.b(2)*T0+3*T0*T0*m2.b(3)+4*T0*T0*T0*m2.b(4);
        c(2) = (m2.b(2)+3*T0*m2.b(3)+6*T0*T0*m2.b(4));
        c(3) = (m2.b(3)+4*T0*m2.b(4));
        c(4) = m2.b(4);

        for iz = 1:m2.mesh.npx-1
            GreenTbigF1 = fft2(GreenT_3D(:,:,m1.mesh.npx+iz-1));
            TrBig1 = ifft2(PrBigF.*GreenTbigF1);
            dz = abs((m2.mesh.z(iz+1)-m2.mesh.z(iz)));

            DcalcBig = DcalcBig+(c(1)*(TrBig1+TrBig0)...
                +c(2)*(TrBig1.*TrBig1+TrBig0.*TrBig0)...
                +c(3)*(TrBig1.*TrBig1.*TrBig1+TrBig0.*TrBig0.*TrBig0)...
                +c(4)*(TrBig1.*TrBig1.*TrBig1.*TrBig1+TrBig0.*TrBig0.*TrBig0.*TrBig0))*dz/2;
            TrBig0=TrBig1;
        end

        if length(ME) == 3
            c(1) = m3.b(1)+2*m3.b(2)*T0+3*T0*T0*m3.b(3)+4*T0*T0*T0*m3.b(4);
            c(2) = (m3.b(2)+3*T0*m3.b(3)+6*T0*T0*m3.b(4));
            c(3) = (m3.b(3)+4*T0*m3.b(4));
            c(4) = m3.b(4);

            for iz = 1:m3.mesh.npx-1
                GreenTbigF1 = fft2(GreenT_3D(:,:,m1.mesh.npx+m2.mesh.npx+iz-2));
                TrBig1 = ifft2(PrBigF.*GreenTbigF1);
                dz = abs((m3.mesh.z(iz+1)-m3.mesh.z(iz)));

                DcalcBig = DcalcBig+(c(1)*(TrBig1+TrBig0)...
                    +c(2)*(TrBig1.*TrBig1+TrBig0.*TrBig0)...
                    +c(3)*(TrBig1.*TrBig1.*TrBig1+TrBig0.*TrBig0.*TrBig0)...
                    +c(4)*(TrBig1.*TrBig1.*TrBig1.*TrBig1+TrBig0.*TrBig0.*TrBig0.*TrBig0))*dz/2;
                TrBig0 = TrBig1;
            end
        end
        subplot(1,2,2), imagegb(DcalcBig)
        title(['Calculated OPD, loop #' int2str(loop) '/' int2str(nLoop) '' ])
        caxis([min(DexpBig(:)) max(DexpBig(:))])
        pause(1)

    end %if nLoop>1

end %for loop

if nLoop>1
    cd('_postprocess')
    saveas(fid_comp,['comp_exp_calc_' textk(im) '.png'])
    cd('..')
end

PrBig = ifftshift(ifft2(PrBigF));
hsd = PrBig(1+floor(ny/2):ny+floor(ny/2),1+floor(nx/2):nx+floor(nx/2));

% calculation of the temperature profile

GreenTbigF = fft2(GreenT_z0);
TrBig = ifft2(PrBigF.*GreenTbigF);
tmp = TrBig(1+floor(ny/2):ny+floor(ny/2),1+floor(nx/2):nx+floor(nx/2));

toc

if nargout == 5 && opt.nLoop > 1
    warning('no need to ask for GreenT_3D for a linear algo (nLoop = 1)')
end


