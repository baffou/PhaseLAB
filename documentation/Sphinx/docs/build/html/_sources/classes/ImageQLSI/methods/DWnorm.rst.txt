.. dropdown:: **DWnorm** |subTitle| Returns the norm of the gradient of the OPD image of the *ImageQLSI* object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: python

        val = obj.D2Wnorm()

    .. caution:: 
        For this method to work, the *ImageQLSI* object had to be created using the :matlab:`obj = QLSIprocess(___, "saveGradients", true)`, so that the gradients of the OPD images are saved and stored in the attributes ``DWx`` and ``DWy``.




