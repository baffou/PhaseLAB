.. dropdown:: crossTalkCorrection |subTitle| Correct for the crosstalk on 2-color cameras. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        [objG2, objR2] = crosstalkCorrection(obj1, obj2);
        [obj] = crosstalkCorrection(obj1, obj2);
        [obj] = crosstalkCorrection(obj0);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj1`` and ``obj2`` are supposed to be the two (vectors of) interferograms originating from the same 2-color camera sensor. Because of the cross-talk, some intensity of one color leaks over the dexels of the other color. To correct for this effect and retrieve the two original color images ``objG2`` and ``objR2``, there exists an algorithm that this method calls. The correction depends on two leakage parameters, which are contained in the ``MI.CGcam.Camera`` object. Hence, it is important to properly indicate the color camera when defining the microscope. For instance:

    .. code-block:: matlab

        CGcam=CGcamera('Silios_color');

    |hr|

    If only one output ``obj`` is specified, then the output consist of a 2-column array of |Interfero| objects, one column for each color.

    |hr|

    If only one input ``obj0`` is specified, then the |PhaseLAB| assumes it is a 2-column array of |Interfero| objects, one column for each color, and it returns also a 2-column array of |Interfero| objects ``obj``.



    .. code-block:: matlab

        % define the microscope
        CGcam=CGcamera('Silios_color');
        MI=Microscope(100,200,CGcam,'PhaseLIVE');

        % import the images
        Itf = importItfRef(folder,MI);
 
        % create two corrected color images
        Itf2 = Itf.splitColors();  % 2-column Interfero array
        Itf2c = crosstalkCorrection(Itf2); % 2-column Interfero array, where the crosstalk is corrected
       

