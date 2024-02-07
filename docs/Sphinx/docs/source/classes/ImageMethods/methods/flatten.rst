.. dropdown:: **flatten** |subTitle| Flatten the background of the OPD image. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        % general form
        obj.flatten()
        obj.flatten(method)
        obj.flatten(___, Name, Value)
        objList.flatten(___)
        obj2 = obj.flatten(___);

        % examples
        obj.flatten('Zernike')
        obj.flatten('Legendre', 'mnax', 3, 'threshold', 1.2);
        obj.flatten('Chebyshev', 'kind', 1, 'mnax', 3)
        obj.flatten('Gaussian', 'nGauss', 100);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.flatten()`` removes the tilt and coma aberration of the image, by an image moment calculation.

    |hr|

    ``obj.flatten(method)`` removes the tilt and coma aberration of the image, where the image momenst belong to a specific class of polynomials. The possible values are 'Waves','Zernike','Chebyshev','Hermite','Legendre','Gaussian'. The default value is 'Gaussian'. In this latter case, no moment is calculated. The process just consists in removing a blurred image to the image.

    |hr|

    ``obj.flatten(___, Name, Value)`` enables the use of optional inputs, defined by keywords 'Name'. The possibles Names are:
    
    - :matlab:`'nmax'`

        Tells until which order the image moments are calculated. Unless when method='Gaussian'. For instance,

        .. code-block:: matlab

            obj.flatten('Legendre', 'nmax', 2)
            
        removes all the :math:`(n,m)` Legendre moments from the image such that :math:`n+m\le n_\mathrm{max}=2`, i.e., (0, 0), (1, 0), (0, 1), (1, 1), (2, 0), (0, 2). Here is a repesentation of the Legendre polynomials.

        .. image:: /images/LegendrePolynomials.png
            :width: 400
            :align: center



        .. code-block:: matlab

            obj.flatten('Zernike', 'nmax', 2)
            
        removes all the :math:`(n,m)` Zernike moments from the image up to :math:`n=n_mathrm{max}=2`, i.e., (0, 0), (1, -1), (1, 1), (2, -2), (2, 0), (2, 2). Here is a representation of th Zernike polynomials.

        .. image:: /images/ZernikePolynomials.png
            :width: 400
            :align: center





    - :matlab:`'threshold'`

        Models the application of a half wave plate. The associated value is the angle of the fast axis of the wave plate.

    - :matlab:`'kind'`

        Models the application of a quarter wave plate. The associated value is the angle of the fast axis of the wave plate.

    - :matlab:`'display'`

        Models the application of a quarter wave plate. The associated value is the angle of the fast axis of the wave plate.

    - :matlab:`'nGauss'`

        Models the application of a quarter wave plate. The associated value is the angle of the fast axis of the wave plate.


