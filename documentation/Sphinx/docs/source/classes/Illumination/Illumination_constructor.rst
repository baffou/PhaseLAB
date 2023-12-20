

Constructor
-----------

.. code-block:: matlab
    :caption: Prototypes

    Illumination(lambda)
    Illumination(lambda,ME)
    Illumination(lambda,ME,I)
    Illumination(lambda,ME,I,polar)
            
. polar can be a 2- or 3-vector, not necessarily unitary.

where ``lambda`` is the illumination wavelength, ``ME`` is a *Medium* object, ``I`` is the illumination irradiance, ``polar`` is the light polarization vector. It can be a 2- or 3-vector, not necessarily unitary.
