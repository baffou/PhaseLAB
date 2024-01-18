.. dropdown:: QLSIprocess |subTitle| Process and return the intensity and wavefront images. |/subTitle|
    
    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % prototypes
        Im = QLSIprocess(Itf, IL);
        ImList = QLSIprocess(ItfList, IL);
        ImList = QLSIprocess(___, Name, Value);

        % examples
        Im = QLSIprocess(Itf, IL,...
                "Fcrops", [], ...
                "method", 'Tikhonov', ...  % 'Tikhonov', 'Errico', or 'CPM'
                "defintion"; 'high', ...  % 'high' or 'low'}
                "Fcropshape", 'disc', ...  %'disc' or 'square'
                "Smatrix", [], ...
                "apodization", [], ... % true, 1, or the width of the apodization in px
                "saveGradients", false, ...
                "remotePath", [], ...
                "Tnormalisation", true, ... % or false or 'subtraction'
                "RemoveCameraOffset", false, ...
                "auto", true, ...   % Find automatically the spot of highest intensity
                "noRef", false, ... % Do not consider the Ref interferogram to compute the DW and OPD images
                "CGdistanceList", [], ...
                "resetCrops",  false );
        

    .. raw:: html
      
        <p class="title">Description</p>

    Method of the class *Interfero* that transforms the interferograms into intensity and wavefront images. As aa second input, the illumination must be specified.

    |hr|

    The method also work with a *Interfero* array, and returns an *ImageQLSI* array: :matlab:`ImList = QLSIprocess(ItfList, IL);`

    .. raw:: html
      
        <p class="title">Name-value inputs</p>

    | **Name**: :matlab:`"Fcrops"`
    | |gr| **Value**: 3-cell of *FcropParameters* objects. |/gr|

    Enables the use of predefined crops in the Fourier space, meaning that the automatic detection of the diffraction orders is cancelled. Predefined crops normally originate from a previous *QLSIprocess* use. When processing an *Interfero* object using *QLSIprocess*, the crops are saved as a property of the returned |ImageQLSI| object. Here is an example:

    .. code-block:: matlab

        IM1 = QLSIprocess(Itf1, IL);
        IM2 = QLSIprocess(Itf2, IL, "Fcrops", IM1.Fcrops);

    |hr|

    | **Name**: :matlab:`"method"`
    | |gr| **Value**: |c| 'Tikhonov' |/c|  (default) \| |c| 'Errico' |/c| \| |c| 'CPM' |/c| |/gr|

    Selects the integration method used to get the wavefront image from the two gradients.

    The Tikhonov method uses the `grad2surf <https://www.mathworks.com/matlabcentral/fileexchange/43149-surface-reconstruction-from-gradient-fields-grad2surf-version-1-0>`_ toolbox developed by  Matthew Harker and Paul O'Leary. It is fast and does not create artefacts on the borders of the images.

    The Errico method uses the `intgrad2 <https://www.mathworks.com/matlabcentral/fileexchange/9734-inverse-integrated-gradient>`_ toolbox developed by John D'Errico. It is slower than Tikhonov.

    The CPM method uses the standard integration algorithm based on Fourier tranforms:

    .. math::
        
        W = \mathcal{F}^{-1}\left[\displaystyle\frac{ \mathcal{F}(\partial_xW + i\partial_yW)}{2i\pi(k_x/N_x + ik_y/N_y)}\right]

    It is fast, but occasionally creates rebounds on the boundaries of the wavefront images:

    |hr|

    | **Name**: :matlab:`"defintion"`
    | |gr| **Value**: |c| 'high' |/c|  (default) \| |c| 'low' |/c| |/gr|

    Tells whether the process gives high definition of low definition images.

    | **High definition**: the intensity and wavefront images have the same number of pixels as the interferogram
    | **Low definition**: the width and height of the intensity and wavefront images are reduced by a factor :math:`\zeta` (zeta), that is the size of the grating unit size in camera dexels (usually, :math:`\zeta=3`).

    There is neither more information nor more spatial resolution in the high-definition images. However, the images look much better in this mode. Here is an example of high versus low definition images:

    .. figure:: /images/lowvshighdefinitions.png
        :align: center

        High- versus low-definition algorithm, with the wavefront image of a nanoparticle.

    |hr|

    | **Name**: :matlab:`"Fcropshape"`
    | |gr| **Value**: |c| 'disc' |/c|  (default) \| |c| 'square' |/c| |/gr|

    Tells whether the crops in the Fourier space are circular (by default) or square. Does not change much the processed images.


    |hr|

    | **Name**: :matlab:`"apodization"`
    | |gr| **Value**: |c| false |/c|  (default) \| |c| true |/c| \| |c| 20 |/c| |/gr|

    Performs an apodization on the interferogram images to avoid possible artefacts after Fourier transforms. By default, when the value is ``1`` or ``true``, the apodization is 20 px wide. For another width, the value should equal the width in pixels. Here are some examples:

    .. code-block:: matlab

        Im = QLSIprocess(Itf, IL, "apodization", false); % no apodization
        Im = QLSIprocess(Itf, IL, "apodization", true);  % apodization of 20 px
        Im = QLSIprocess(Itf, IL, "apodization", 40);    % apodization of 40 px

    |hr|

    | **Name**: :matlab:`"saveGradients"`
    | |gr| **Value**: |c| false |/c|  (default) \| |c| true |/c|

    Save the gradients with the properties ``DWx`` and ``DWy`` of the returned |ImageQLSI| object.

    .. code-block:: matlab

        Im = QLSIprocess(Itf, IL, "saveGradients", true);
        dynamicFigure('ph', Im.DWx, 'ph', Im.DWy)


    |hr|

    | **Name**: :matlab:`"remotePath"`
    | |gr| **Value**: |c| [ ] |/c|  (default) \| *char* \| *string*

    If not empty, the intensity and wavefront images are not saved in the RAM of the comptuer, but on the hard disk. The value of |c| remotePath |/c| specifies the folder where the images should be saved. It is useful when working with a large set of images, likely to saturate the RAM.

    |hr|

    | **Name**: :matlab:`"Tnormalization"`
    | |gr| **Value**: |c| true |/c|  (default) \| |c| false |/c| \| |c| 'subtraction' |/c|

    Sets the way the intensity image is normalized. By default, it is divided by the intensity image of the reference image. To avoid that, one can set the value to ``false``. One can also choose to normalize by *subtracting* the intensity image of the reference, using the value ``'subtraction'`` (relevant when working with fluorescence images for instance).

    |hr|

    | **Name**: :matlab:`"RemoveCameraOffset"`
    | |gr| **Value**: |c| false |/c|  (default) \| |c| true |/c|

    Removes the offset on the interferogram images, set by the camera constructor. Useless for the reconstruction of the wavefront image. Relevant when quantitative intensity images are seeked. The offset value to substract is indicated in the specification file of the camera included when building the |Microscope| object.


    |hr|

    | **Name**: :matlab:`"auto"`
    | |gr| **Value**: |c| true |/c|  (default) \| |c| false |/c|

    If true, finds automatically the 0 and 1st order spots in the Fourier space. If false, a window opens to ask the user to click on the spots. See the :ref:`Process experimental images <process_experimental_images>` section for more details.

    |hr|

    | **Name**: :matlab:`"noref"`
    | |gr| **Value**: |c| false |/c|  (default) \| |c| true |/c|

    If true, forgets about the reference interferogram in the intensity and wavefront images processing.

    |hr|

    | **Name**: :matlab:`"CGdistanceList"`
    | |gr| **Value**: |c| [ ] |/c|  (default) \| |c| *double* array |/c|

    If the input is an *Interfero* array, and if the images have been acquired with various values of grating-camera distances :math:`d`, the list of :math:`d` values can be indicated as a *double* array here. The array must have as many values as the number of *Interfero* objects.

    |hr|

    | **Name**: :matlab:`"resetCrops"`
    | |gr| **Value**: |c| false |/c|  (default) \| |c| true |/c|

    Resets the crops between each processed interferogram, to make sure the algorithm enables the user to click for each image when ``"auto = false"``.











