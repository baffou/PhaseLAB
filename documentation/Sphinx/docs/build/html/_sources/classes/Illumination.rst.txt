.. _The_Illumination_class:

The Illumination class
======================

*Illumination* is a handle class.

Attributes
----------

.. list-table:: Public attributes
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



.. list-table:: Dependent attributes
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - dependence
     - description
   * - ``n``
     - double
     - ``= Medium.n``
     - refractive index of the upper medium
   * - ``nS``
     - double
     - ``= Medium.nS``
     - refractive index of the lower medium
   * - ``e0``
     - double
     - ``= sqrt(2*I/(n*c*eps0));``
     - incident electric field
   * - ``k0``
     - double
     - ``= 2*pi./lambda;2*pi./lambda;``
     - wavevector in vacuum
   * - ``tr``
     - double
     - ``= 2*n/(n+nS);``
     - light transmission at the interface


.. include:: Illumination/Illumination_constructor.rst

.. include:: Illumination/Illumination_methods.rst

