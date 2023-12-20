.. dropdown:: **D2Wnorm**
    
    Returns the second derivative (Lapacian) of the ``OPD`` image of the *ImageQLSI* object.


    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.D2Wnorm()


    .. caution:: 
        For this method to work, the *ImageQLSI* object had to be created using the :matlab:`obj = QLSIprocess(___, "saveGradients", true)`, so that the gradients of the OPD images are saved and stored in the attributes ``DWx`` and ``DWy``.



