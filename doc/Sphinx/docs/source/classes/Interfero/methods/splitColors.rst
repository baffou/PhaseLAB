.. dropdown:: splitColors |subTitle| Extract the two color interferograms from one interferogram acquired with a 2-color camera. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        [objG, objR] = splitColors(obj);

    .. raw:: html
      
        <p class="title">Description</p>

    This method creates two *Interfero* objects ``objG`` and ``objR``, corresponding respectively to the green and red channels of the *Interfero* object coming from the 2-color camera. Here is a code example:

    .. code-block:: matlab

        % define the microscope
        Cam = Camera('Silios');
        Grat = CrossGrating('Gamma',39e-6);
        CGcam=CGcamera(Cam,Grat,1.1931);
        MI=Microscope(100,200,CGcam,'PhaseLIVE');

        % import the images
        Ref = importItfRef(folder,MI);
        Itf = importItfRef(folder,MI);
        Itf.Reference(Ref);

        % create two corrected color images
        [ItfG,ItfR] = Itf.splitColors();
        [ItfGc, ItfRc] = crosstalkCorrection(ItfG, ItfR);
       

