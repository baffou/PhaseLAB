.. dropdown:: **distance** |subTitle| Returns the effective grating-camera distance. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.distance();
        val = obj.distance(lambda);

    .. raw:: html
      
        <p class="title">Description</p>

    ``val = obj.distance();`` normally returns ``obj.CGpos``. However, when a |RL| is used, the effective grating-camera distance becomes dependent on the wavelength. In this latter case, one should write ``val = obj.distance(lambda);`` where ``lambda`` is the value of the wavelength.

