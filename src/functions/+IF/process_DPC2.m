function [OPDsimu, Tsimu, IMout] = process_DPC2(IMq, shotNoise,opt)
arguments
    IMq (:,4) ImageEM
%    IMb (:,4) ImageEM    % blank images
    %NAobj     % numerical aperture of the illumination
    shotNoise (1,1) logical = false
    opt.Nim = 1    % Number of averaged images
    opt.alpha = 1e-3
end

Nphi = size(IMq,1); % number of theta incidences involved in the calculations.
%
quad = {'topLeft','topRight','bottomRight','bottomLeft'};

%%
if shotNoise,noiseFunction = @poissrnd;
else,        noiseFunction = @identity;
end



%%
% Don't sum the ImageEM object using the plus method, otherwise creates
% images with interferences
%% computation of the averaged OPD image
OPDmean = 0;

for ii = 1:4
    for ip = 1:Nphi
        if max(IMq(ip,ii).T(:))>1e-4 && ~isinf(max(IMq(ip,ii).T(:))) % if this spot is not croped by the NA of the objective, so that there is intensity on the camera
            OPDmean = OPDmean + IMq(ip,ii).OPD;
            max(IMq(ip,ii).OPD(:));
        end
    end
end

%IMmean  = IMq(:).sum();
OPDmean = OPDmean/(4*Nphi);

%IMq2    = reshape(ImageQLSI(IMq),size(IMq));

%IMmean2 = IMq2(:).sum();


%% computation of the I_DPC images
for ii = 1:4
    I.(quad{ii}) = 0;
    for ip = 1:Nphi
        I.(quad{ii}) = I.(quad{ii}) + IMq(ip,ii).E2;
    end
end

Ileft0   = I.topLeft    + I.bottomLeft;
Iright0  = I.topRight   + I.bottomRight;
Itop0    = I.topLeft    + I.topRight;
Ibottom0 = I.bottomLeft + I.bottomRight;

fwc=IMq(1).Microscope.CGcam.Camera.fullWellCapacity*opt.Nim;

corr = (fwc)/(max(Ileft0(:)));

Ileft   = noiseFunction(Ileft0*corr);
Iright  = noiseFunction(Iright0*corr);
Ibottom = noiseFunction(Ibottom0*corr);
Itop    = noiseFunction(Itop0*corr);

Tsimu    = (Itop + Ibottom + Ileft + Iright)/2;


I_DPCtb = (Itop-Ibottom)./(Itop+Ibottom);
I_DPClr = (Ileft-Iright)./(Ileft+Iright);

%% visualisation of the Fourier plane
    
for ii = 1:4
    E.(quad{ii}) = 0;
    for ip = 1:Nphi
        E.(quad{ii}) = E.(quad{ii}) + IMq(ip,ii).Ex;
    end
    FI.(quad{ii}) = log(abs(fftshift(fft2(E.(quad{ii})))));
    [ny.(quad{ii}), nx.(quad{ii})] = find(FI.(quad{ii})>floor(max(FI.(quad{ii})(:)))-1);
end

B = 4*numel(ny.(quad{ii})); % total energy crossing the system

 if numel(ny.(quad{ii})) ~= Nphi % means that some illumination angles are out of NAobj 
     figure
     imagegb(FI.(quad{ii}))
     disp([ny, nx])
     warning( "error in the localisation of the spots in the Fourier plane: " + num2str(numel(ny.(quad{ii}))) + "vs" + num2str(Nphi) )
 end

%% vizualisation of the pupil

Etot = E.topLeft + E.topRight + E.bottomLeft + E.bottomRight;


if 0
    figure, imagegb(log(abs(fftshift(fft2(Etot)))))
    [x0, y0] = ginput(1);
    
    Rc = sqrt( (x0-IMq(1).Nx/2)^2 + (y0-IMq(1).Ny/2)^2 );
disp("Measured Rc: "+num2str(Rc))
end

% theoretical Rc
NA = IMq(1).Microscope.Objective.NA;
lambda = IMq(1).Illumination.lambda;
Npx = IMq(1).Nx;
p = IMq(1).pxSize;
r0 = NA*Npx*p/lambda; % radius of the pupil, function of the NA_obj

disp("Theoretical Rc: "+num2str(r0))


%% Computation of the WOTF

% absorption image

x.left = [nx.topLeft; nx.bottomLeft] - IMq(1).Nx/2;
y.left = [ny.topLeft; ny.bottomLeft] - IMq(1).Ny/2;
mapPh.left = IF.DPC_Habs('ph',Npx, Npx, r0, [x.left,y.left]);
mapAbs.left = IF.DPC_Habs('abs',Npx, Npx, r0, [x.left,y.left]);

x.right = [nx.topRight; nx.bottomRight] - IMq(1).Nx/2;
y.right = [ny.topRight; ny.bottomRight] - IMq(1).Ny/2;
mapPh.right = IF.DPC_Habs('ph',Npx, Npx, r0, [x.right,y.right]);
mapAbs.right = IF.DPC_Habs('abs',Npx, Npx, r0, [x.right,y.right]);

x.top = [nx.topLeft; nx.topRight] - IMq(1).Nx/2;
y.top = [ny.topLeft; ny.topRight] - IMq(1).Ny/2;
mapPh.top = IF.DPC_Habs('ph',Npx, Npx, r0, [x.top,y.top]);
mapAbs.top = IF.DPC_Habs('abs',Npx, Npx, r0, [x.top,y.top]);

x.bottom = [nx.bottomLeft; nx.bottomRight] - IMq(1).Nx/2;
y.bottom = [ny.bottomLeft; ny.bottomRight] - IMq(1).Ny/2;
mapPh.bottom = IF.DPC_Habs('ph',Npx, Npx, r0, [x.bottom,y.bottom]);
mapAbs.bottom = IF.DPC_Habs('abs',Npx, Npx, r0, [x.bottom,y.bottom]);


Hphlr = (mapPh.left - mapPh.right) / B;
Hphlr(isnan(Hphlr)) = 0;
Hphtb = (mapPh.top - mapPh.bottom) / B;
Hphtb(isnan(Hphtb)) = 0;

%% Tikhonov deconvolution

Htik = conj(Hphtb) ./ ( abs(Hphtb).^2 + opt.alpha );

figure
subplot(2,1,1)
imagegb(imag(Hphtb))
subplot(2,1,2)
imagegb(imag(Htik))

FI_DPCtb = ( fftshift(fft2(I_DPCtb)).*conj(Hphtb) + fftshift(fft2(I_DPClr)).*conj(Hphlr) )./ ...
            ( abs(Hphtb).^2 +abs(Hphlr).^2 + opt.alpha );

OPDsimu = ifft2(ifftshift(FI_DPCtb))*lambda/(2*pi);



%%
figure

subplot(3,3,4)
imagegb(imag(mapPh.right))
subplot(3,3,5)
imagegb(imag(mapPh.left))
subplot(3,3,6)
imagegb(imag(Hphlr))

subplot(3,3,7)
imagegb(imag(mapPh.top))
subplot(3,3,8)
imagegb(imag(mapPh.bottom))
subplot(3,3,9)
imagegb(imag(Hphtb))


linkAxes


%%
% crop = 50;
% figure
% subplot(1,2,1)
% imagegb(log(abs(fftshift(fft2(OPDsimu(end/2-crop:end/2+crop,end/2-crop:end/2+crop))))))
% 
% subplot(1,2,2)
% imagegb(log(abs(fftshift(fft2(IMq(60).OPD(end/2-crop:end/2+crop,end/2-crop:end/2+crop))))))
% linkAxes
% 

%% Theoretical images
lambda=IMq(1).Illumination.lambda;
avgPhiTheo = 0;
if numel(IMq) == 192
    for ii = [41 49 104 192]
        avgPhiTheo = avgPhiTheo + IMq(ii).Ph/4;
    end
else
    warning('normal average of the OPD images ,not supposed to give a consistent image')
    for ii=1:numel(IMq)
        avgPhiTheo = avgPhiTheo + IMq(ii).Ph/numel(IMq);
    end
end

IMout = ImageQLSI(Tsimu,avgPhiTheo*lambda/(2*pi),IMq(1).Microscope,IMq(1).Illumination);

% dynamicFigure('ph',OPDsimu,'ph',IMout.OPD),linkAxes
% figure, hold on, plot(36*OPDsimu(:,end/2+1)), plot(IMout.OPD(:,end/2+1)),legend({"simu","ground truth"})

%%

figure
ax1=subplot(2,3,1);
imagegb(OPDsimu)
title('DPC OPD')
ax2=subplot(2,3,2);
%imageph(OPDmean)
imagegb(IMout.OPD)
title('GTruth OPD')
subplot(2,3,3)
plot(OPDsimu(end/2+1,:))
hold on
plot(IMout.OPD(end/2+1,:))
legend({'DPC','GTruth'})

ax1=subplot(2,3,4);
imagegb(Tsimu/Tsimu(1,1))
title('DPC T')
ax2=subplot(2,3,5);
%imageph(OPDmean)
imagegb(IMout.T)
title('GTruth T')
subplot(2,3,6)
plot(Tsimu(end/2+1,:)/Tsimu(1,1))
hold on
plot(IMout.T(end/2+1,:))
legend({'DPC','GTruth'})


linkaxes([ax1,ax2])