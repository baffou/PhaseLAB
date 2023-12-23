.. dropdown:: **PDCM** |subTitle| Computes the PDCM (phase derivatives closure map) of the OPD image. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        val = obj.PDCM()

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.PDCM()`` computes the PDCM (phase derivatives closure map) of the ``OPD`` image, as introduced by J. Rizzi et al. [#OE21_17340]_. It is defines as

    .. math::

        \mathrm{PDCM}(x,y) = \frac{\partial \mathrm{DWx}}{\partial y} - \frac{\partial \mathrm{DWy}}{\partial x}


    .. caution:: 
        For this method to work, the *ImageQLSI* object had to be created using the ``obj = QLSIprocess(___, "saveGradients", true)``, so that the gradients of the OPD images are saved and stored in the attributes ``DWx`` and ``DWy``.



    .. [#OE21_17340] Opt. Express 21, 17340 (2013)






