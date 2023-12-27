

Constructor
-----------

.. code-block:: matlab
    :caption: Prototypes

    % possible forms
    Illumination(lambda)
    Illumination(lambda,ME)
    Illumination(lambda,ME,I)
    Illumination(lambda,ME,I,polar)
            
    % possible forms
    Illumination(650e-9)
    Illumination(530e-9,ME)
    Illumination(530e-9,ME,1)
    Illumination(580e-9,ME,I,[1 1])
    Illumination(580e-9,ME,I,[1 1i 0])



. polar can be a 2- or 3-vector, not necessarily unitary.

where ``lambda`` is the illumination wavelength, ``ME`` is a *Medium* object, ``I`` is the illumination irradiance, ``polar`` is the light polarization vector. It can be a 2- or 3-vector, not necessarily unitary.
