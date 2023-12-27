The Dipole class
================

*Dipole* is a variable class (not a handle class!).

Attributes
----------

.. list-table:: Public properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - default
     - description
   * - ``mat``
     - *char*
     - 'none'
     - nanoparticle material
   * - ``r``
     - double
     - 0
     - nanoparticle radius  
   * - ``eps``
     - *double*
     - 
     - complex permittivity of the material
   * - ``n``
     - *double*
     - 
     - complex refractive index of the material
   * - ``p``
     - *double*
     - 
     - electric dipolar moment
   * - ``EE0``
     - *double*
     - 
     - local electric field experienced by the dipole
   * - ``x``
     - *double*
     - 0
     - x position of the dipole [m]
   * - ``y``
     - *double*
     - 0
     - y position of the dipole [m]
   * - ``z``
     - *double*
     - ``r``
     - z position of the dipole [m]
   * - ``n_ext``
     - *double*
     - 
     - refractive index of the surroundings


.. list-table:: Dependent properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - dependence
     - description
   * - ``lambda``
     - double
     - 
     - wavelength of illumination
   * - ``pos``
     - (3,1) double
     - 
     - position vector [x,y,z]
   * - ``alphaMie``
     - complex
     - 
     - Mie complex polarizability
   * - ``CextMie``
     - double
     - 
     - Mie extinction cross section
   * - ``CscaMie``
     - 
     - 
     - Mie scattering cross section
   * - ``CabsMie``
     - double
     - 
     - Mie absprotion cross section


.. include:: Dipole/Dipole_constructor.rst


.. include:: Dipole/Dipole_methods.rst

