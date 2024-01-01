.. dropdown:: crossTalkCorrection |subTitle| Correct for the crosstalk on 2-color cameras. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        [objG2, objR2] = crosstalkCorrection(obj1, obj2);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj1`` and ``obj2`` are supposed to be the two (vectors of) interferograms originating from the same 2-color camera sensor. Because of the cross-talk, some intensity of one color leaks over the dexels of the other color. To correct for this effect and retrieve the two original color images ``objG2`` and ``objR2``, there exists an algorithm that this method calls. The correction depends on two leakage parameters, which are contained in the ``MI.CGcam.Camera`` object. Hence, it is important to properly indicate the color camera when defining the microscope. Here is an example:

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
       

