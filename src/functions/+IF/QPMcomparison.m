% Program that aims at modelling and comparing many different QPM
% techniques.

% Main Matlab file used in
% Quantitative phase microscopies: accuracy comparison
% P. C. Chaumet, P. Bon, G. Maire, A. Sentenac, G. Baffou
% arXiv , 2403.11930 (2024)

clear
%cd('/home/baffou/Documents/_SIMUS_ifddam/230210_QPIcomparison')
addpath(genpath('/home/baffou/Documents/MATLAB/PhaseLAB'))
%%
objectList = ["graphene","NP","bacteria","cell"];%,"microbead","Gaussian"]; % blank
%objectList = ["cell"];%,"microbead","Gaussian"]; % blank
QPIlist = ["CGM", "FPM", "DPM", "DPC", "DHM", "DRIMAPS", "SLIM","TIE"];
QPIlist = ["DPC"];
shotNoiseList = [true, false];
shotNoiseList = true;

%objectList = ["NP","bacteria","cell"];%,"microbead","Gaussian"]; % blank

%objectList = ["bacteria"];
%QPIlist = ["TIE"];
%shotNoiseList = true;

%NAill = 0;
theta0 = 0;
NAill = 0.25;  % Numerical aperture of illumination of 4-quadrants
NAill_DPC = 0.375;  % Numerical aperture of illumination of a ring or disc
% or angle of incidence for a plane wave illumination
Ntheta = 16; % Used only or a disc illumination. odd number: naturally places a source at (0, 0)
alphaDPC = 1e-5;

zShift = 500e-9; % +/- zShift for TIE
saveNickname= '230719';%%
saveNickname= '240301';%% noise study
suff0 = '_noise1e5_'; % suffix to append to the object name to give another name to the files; For instance "10" to get cell10.

NAobj_DPC = 0.4;

% if several noise instances, tell how many:
Ninst = 12;

saveTheo = 1;
%%
for object = objectList(4:end)

    %object='cell'; % 'NP','graphene','microbead','bacteria','cell','cell2'
    if object=="cell"
        lambda=600e-9;
    else
        lambda=532e-9;
    end

    NimRef = Inf;
    if object=="graphene"
        Nim = 25;
    elseif object=="NP"
        Nim = 1;
    else
        Nim = 1;
    end

    if any(QPIlist == "CGM") || any(QPIlist == "DPM")
        %if NAill == 0
        illuminationType = 'circular';
        %else
        %    illuminationType = 'disc';
        %end
        IMc=waveComputation(object,illuminationType,lambda,"theta0",theta0,"Ntheta",Ntheta); % circular polarization
    end
    if any(QPIlist == "DHM") || any(QPIlist == "FPM") || any(QPIlist == "DRIMAPS") || any(QPIlist == "TIE")
        illuminationType = 'linear';
        IMp=waveComputation(object,illuminationType,lambda,"theta0",theta0); % linear polarization
    end
    if any(QPIlist == "SLIM")
        illuminationType = 'ring';
        IMr=waveComputation(object,illuminationType,lambda,"NAill",NAill); % annular circular polarization
    end
    if any(QPIlist == "TIE")
        illuminationType = 'circular';
        IMs=ImageEM(3);
        IMs(1)=waveComputation(object,illuminationType,lambda,"focus",zShift); % annular circular polarization
        IMs(2)=waveComputation(object,illuminationType,lambda,"focus",0); % annular circular polarization
        IMs(3)=waveComputation(object,illuminationType,lambda,"focus",-zShift); % annular circular polarization
    end
    if any(QPIlist == "DPC")
        illuminationType = '4-quadrants';
        IMq=waveComputation(object,illuminationType,lambda,"NAill",NAill_DPC,"Ntheta",Ntheta,"NAobj",NAobj_DPC);
    end
    %%
    for QPItechnique = QPIlist
        for shotNoise = shotNoiseList
            for iii = 1:Ninst
                if Ninst ~= 1
                    suff = [suff0  textk(iii)];
                else
                    suff = suff0;
                end

                switch QPItechnique
                    case 'CGM'     % CGM computation
                        IM=IMc;
                        d = 0.6e-3; % CG distance
                        %if shotNoise
                        %    res = "low";% 'high' or 'low'
                        %else
                        res = "high";
                        %end
                        [OPDsimu, Tsimu, IMout] = IF.process_CGM(IM, 'shotNoise',shotNoise, 'CGdistance',d, 'definition',res,'Nim',Nim,'NimRef',NimRef);

                    case 'DHM'     % DHM computation
                        IM=IMp;
                        freq=3;
                        thetaGrating=45;
                        [OPDsimu, Tsimu, IMout] = IF.process_DHM(IM, 'shotNoise', shotNoise, 'freq', freq, 'thetaGrating',thetaGrating,'Nim',Nim);

                    case 'DPM'     % DPM computation
                        IM=IMc;
                        crop0 = 2; % size of the center crop [px]
                        [OPDsimu, Tsimu, IMout] = IF.process_DPM(IM, 'shotNoise',shotNoise, 'r0',crop0, 'auto',true,'Nim',Nim,'NimRef',NimRef);

                    case 'SLIM'    % SLIM computation
                        
                        IM = IMr;
                        [OPDsimu, Tsimu, IMout] = IF.process_SLIM(IMr, shotNoise,'Nim',Nim/4);
                    case 'FPM'     % FPM computation
                        IM=IMp;
                        [OPDsimu, Tsimu, IMout] = IF.process_FPM(IM, shotNoise,'Nim',Nim/4);

                    case 'DRIMAPS' % DRIMAPS computation
                        IM=IMp;
                        [OPDsimu, Tsimu, IMout] = IF.process_DRIMAPS(IM, shotNoise,'Nim',Nim/4);

                    case 'TIE' % DRIMAPS computation
                        IM=IMs;
                        [OPDsimu, Tsimu, IMout] = IF.process_TIE(IM, zShift, shotNoise,'Nim',Nim/3);

                    case 'DPC' % DRIMAPS computation
                        IM=IMq;

                        %[OPDsimu, Tsimu, IMout] = IF.process_DPC(IM, NAill, shotNoise,'Nim',Nim/4);
                        [OPDsimu, Tsimu, IMout] = IF.process_DPC2(IM, shotNoise,'Nim',Nim/4,'alpha',alphaDPC);

                end

                %% display data
                IMsimu = ImageQLSI(Tsimu, OPDsimu,IM(1).Microscope,IM(1).Illumination);
                IMout0 = IMout.mean();
                if shotNoise

                    noiseText = 'yes';
                else
                    noiseText='no';
                end


                hfig = figure('Name',strcat('noise:',num2str(double(shotNoise)),'_', QPItechnique,'_',object));
                ax1 = subplot(2,3,1);
                imagegb(IMout0.OPD)
                title('theory')
                ax2 = subplot(2,3,2);
                imagegb(OPDsimu)
                title('simus')
                clim(ax1.CLim)
                ax3 = subplot(2,3,3);
                hold on
                plot(IMout0.OPD(ceil(end/2),:))
                plot(OPDsimu(ceil(end/2),:))
                legend({'theory','simus'})
                fullwidth
                ax4 = subplot(2,3,4);
                imagegb(IMout0.T)
                title('theory')
                ax5 = subplot(2,3,5);
                imagegb(Tsimu)
                title('simus')
                clim(ax4.CLim)
                ax6 = subplot(2,3,6);
                hold on
                plot(IMout0.T(ceil(end/2),:))
                plot(Tsimu(ceil(end/2),:))
                legend({'theory','simus'})
                fullwidth
                linkaxes([ax1, ax2, ax4, ax5])
                linkaxes([ax3, ax6],'x')

                %% save data
                if saveTheo  == 1
                    saveFolderTheo=strcat('results/',saveNickname,'/theo/');
                    mkdir(saveFolderTheo)

                    writematrix(IMc(1).OPD,strcat(saveFolderTheo,'/',object,'_OPDtheo.txt'),Delimiter=' ')
                    writematrix(IMc(1).T,strcat(saveFolderTheo,'/',object,'_Ttheo.txt'),Delimiter=' ')
                  
                    copyfile('waveComputation.m',saveFolderTheo)
                    copyfile('MAIN3.m',saveFolderTheo)
                    close(hfig)                    
                end
                    
                if shotNoise
                    saveFolder=strcat('results/',saveNickname,'/noisy/',QPItechnique,'/',object,suff);
                else
                    saveFolder=strcat('results/',saveNickname,'/nonoise/',QPItechnique,'/',object,suff);
                end
                mkdir(saveFolder)

                % simus
                writematrix(OPDsimu,strcat(saveFolder,'/',object,'_OPD.txt'),Delimiter=' ')
                writematrix(Tsimu,strcat(saveFolder,'/',  object,'_T.txt'),Delimiter=' ')
                writematrix(OPDsimu(ceil(end/2),:)', strcat(saveFolder,'/OPD_profile.txt'))
                writematrix(  Tsimu(ceil(end/2),:)', strcat(saveFolder,'/T_profile.txt'))

                % theo
                writematrix(IMout0.OPD,strcat(saveFolder,'/',object,'_OPDtheo.txt'),Delimiter=' ')
                writematrix(IMout0.T,strcat(saveFolder,'/',  object,'_Ttheo.txt'),Delimiter=' ')
                writematrix(IMout0.OPD(ceil(end/2),:)',strcat(saveFolder,'/OPDtheo_profile.txt'))
                writematrix(IMout0.T(ceil(end/2),:)'  ,strcat(saveFolder,'/Ttheo_profile.txt'))

                % x axis
                writematrix(IMout0.pxSize*1e6*( (0:IM(1).Nx-1)- IM(1).Nx/2 )',strcat(saveFolder,'/pxSize.txt'))

                % figures png
                saveas(hfig,strcat(saveFolder,'/figure.fig'))
                saveas(hfig,strcat(saveFolder,'/figure.png'))

                copyfile('waveComputation.m',saveFolder)
                copyfile('MAIN3.m',saveFolder)
                close(hfig)

            end
        end
    end
end

