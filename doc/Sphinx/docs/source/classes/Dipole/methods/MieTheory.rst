.. dropdown:: **MieTheory** |subTitle| Return the polarisability and cross sections. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.MieTheory();
        valList = objList.MieTheory();

    .. raw:: html
      
        <p class="title">Description</p>

    Returns a (list of) *NPprop* object(s) that contains the properties of the nanoparticles, namely the complex optical polarisability and the three cross sections.

    .. warning::

        The dipole must be illuminated before using this method, using ``obj.shine``.
    
    .. code:: matlab

        >> DI.shine()
        >> DI.MieTheory()

        ans = 

        NPprop with properties:

            alpha: -7.0163e-22 + 4.1500e-21i
            Cext: 3.9468e-14
            Csca: 1.8666e-14
            Cabs: 2.0802e-14
