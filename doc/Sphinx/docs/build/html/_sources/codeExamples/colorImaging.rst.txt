Color imaging
+++++++++++++

.. dropdown:: **Color imaging** |subTitle|  Code to process QLSI data acquired with a color-camera |/subTitle|
    :open:


    .. code-block:: matlab

        %% MICROSCOPE
        ME=Medium('water','glass');
        OB=Objective(60,0.7,'Olympus');
        Cam = Camera('Silios');
        Gr = CrossGrating('Gamma',39e-6);
        CGcam=CGcamera(Cam,Gr,1.1931);
        MI=Microscope(OB,200,CGcam,'PhaseLIVE');

        CGcam.setDistance(0.8e-3);

        lambda=680e-9;
        IL=Illumination(lambda,ME);

        folder = 'GeobColor';

        %% Import interferos

        Itf = importItfRef(folder,MI,"nickname","geobSyto9");
        Bkg = importItfRef(folder,MI,"nickname","geobSyto9Bkg");
        Ref = importItfRef(folder,MI,"nickname","geobSyto9Ref");

        Itf.Reference(Ref.mean())

        %% Process interferos

        Itf.removeOffset(Bkg.mean());

        Itf.crop(Size=1200)

        %% color images processing

        Itfs = Itf.splitColors();
        Itfsc = crosstalkCorrection(Itfs);

        %% process fluo and OPD images
        IMG=QLSIprocess(Itfsc(:,1),IL,"Tnormalisation",'subtraction');
        IMR=QLSIprocess(Itfsc(:,2),IL);

        dynamicFigure('fl',{IMG.T}, 'ph', {IMR.OPD})

        %% merge green and red channels to be displayed with the figure method

        IM = [IMG, IMR];

        IM.figure

    .. figure:: /images/fluoCGM.png
        :width: 550 
        :align: center

        Left: fluorescence image of bacteria. Right: corresponding OPD image.
