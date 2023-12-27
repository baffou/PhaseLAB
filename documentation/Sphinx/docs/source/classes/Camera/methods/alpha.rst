.. dropdown:: **alpha** |subTitle| Compute the alpha value of the QLSI camera system. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.alpha();
        val = obj.alpha(lambda);

    .. raw:: html
      
        <p class="title">Description</p>

    ``val = obj.alpha();`` returns the *alpha* parameter of a QLSI system. The alpha parameter is defined by [#JPDAP54_294002]_:

    .. math::

        \alpha = \frac{\Gamma p}{4\pi d}

    where :math:`\Gamma`  is the pitch of the grating, :math:`p` is the dexel size of the camera and :math:`d` is the camera-grating distance.
    
    .. [#JPDAP54_294002] Quantitative phase microscopy using quadriwave lateral shearing interferometry (QLSI): principle, terminology, algorithm and grating shadow description, Baffou G., J. Phys. D: Appl. Phys. 54, 294002 (2021)

    Whe using a relay-lens, the *alpha* parameter depends on the wavelength, because of the imperfection of the relay-lens (the focal length of the relay lens slightly depends on the wavelength). In this case, the wavelength ``lambda`` should be indicated as an input argument:  ``val = obj.alpha(lambda);``.