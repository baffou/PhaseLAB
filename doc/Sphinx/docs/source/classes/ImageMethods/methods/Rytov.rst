.. dropdown:: **Rytov** |subTitle| Return the Rytov image. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        val = obj.Rytov();

    .. raw:: html
      
        <p class="title">Description</p>

    Method that returns the Rytov image, defined by \ [#ACSP10_322]_

    .. math::
        
        I_\mathrm{Rytov} = \left\vert\frac{\lambda n}{\pi}\left[\frac{ln(T)}{2}+i\varphi\right]\right\vert^2


    where :math:`\lambda` is the wavelength, :math:`n` the refractive index of the surrounding medium, :math:`T` the intensity image and :math:`\varphi` the phase image.

    .. [#ACSP10_322] *Label-Free Single Nanoparticle Identification and Characterization in Demanding Environment, Including Infectious Emergent Virus*, Nguyen et al., **Small** 2304564 (2023)


