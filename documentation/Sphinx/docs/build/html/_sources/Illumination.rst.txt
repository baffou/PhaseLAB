.. include:: substitutions.rst


The Illumination class
----------------------

Properties
^^^^^^^^^^

.. list-table:: Public properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - default
     - description
   * - ``lambda``
     - *double*
     - 
     - illumination wavelength
   * - ``I``
     - *double*
     - 1
     - Illumination irradiance (power per unit area)
   * - ``direct``
     - (1,3) *double*
     - [0 0 1]
     - unit vector defining the direction of propagation
   * - ``polar``
     - (1,3) *char*
     - [1 0 0]
     - polarization unit vector
   * - ``NA``
     - *double*
     - 0
     - Numerical aperture of the illumination



.. list-table:: Dependent properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - dependence
     - description
   * - ``n``
     - double
     - ``= this.Medium.n``
     - refractive index of the upper medium
   * - ``nS``
     - double
     - ``= this.Medium.nS``
     - refractive index of the lower medium
   * - ``e0``
     - double
     - ``= sqrt(2*obj.I/(obj.n*obj.c*obj.eps0));``
     - incident electric field
   * - ``k0``
     - double
     - ``= 2*pi./obj.lambda;2*pi./obj.lambda;``
     - wavevector in vacuum
   * - ``tr``
     - double
     - ``= 2*obj.n/(obj.n+obj.nS);``
     - light transmission at the interface



Constructor
^^^^^^^^^^^
.. code-block:: python
    :caption: Prototypes

    Illumination(lambda)
    Illumination(lambda,ME)
    Illumination(lambda,ME,I)
    Illumination(lambda,ME,I,polar)
            
. polar can be a 2- or 3-vector, not necessarily unitary.

where ``lambda`` is the illumination wavelength, ``ME`` is a *Medium* object, ``I`` is the illumination irradiance, ``polar`` is the light polarization vector. It can be a 2- or 3-vector, not necessarily unitary.

Methods
^^^^^^^

EE0(pos) 
""""""""

.. code-block:: python

    pos = [0 1.2 0]*1e-6;
    IL.EE0(pos)

returns the value of the electric field of the illumination, in the absence of the object, at the position ``pos`` (3-vector) taking into account the reflection on the interface.

rotate(pos) 
"""""""""""

.. code-block:: python

    IL.rotate('z',30)
    IL.rotate('x',45,'y',30,'z',10)

rotates the ``polar`` and ``direct`` around the specified axes, *x*, *y*, and/or *z*.

 
Jones(pos) 
""""""""""

.. code-block:: python

    IL.Jones('P', 45, 'QWP',90, 'HWP',30, ...)

| Applies optical plates to the illumination beam, according to the Jones matrix formulation. The inputs are the rotation angles of the wave plates.
| ``'QWP'``: Quarter waveplate
| ``'HWP'``: Half waveplate
| ``'P'``: Linear polarizer

