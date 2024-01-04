.. dropdown:: **dxSize** |subtitle| Return the dexel size. |/subtitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.dxSize();

    .. raw:: html
      
        <p class="title">Description</p>

    Returns the dexel size (i.e. the camera pixel size), ``val = obj.Microscope.CGcam.dxSize;``.

    .. note::

        This method returns the **effective** dexel size, which is not necessarily the actual dexel size of the camera sensor. When there is a |RL|, applying a zoom :math:`Z` to the system, the {|RL|, camera} system is equivalent to a single camera with a dexel size divided by the zoom. This method returns the dexel size fo this equivalent camera, called the effective dexel size.
    




