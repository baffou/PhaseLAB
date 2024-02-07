.. _The_Camera_class:

The Camera class
================

*Camera* is a handle class.

The *Camera* object represents the basis camera.

Properties
----------

.. list-table:: Public properties
  :widths: 30 30 30 100 
  :header-rows: 1
  :align: center

  * - name
    - type
    - default
    - description
  * - ``dxSize``
    - *double*
    - 6.5e-6
    - dexel size :math:`p` \[m\]
  * - ``Nx``
    - *integer*
    - 600
    - number of columns :math:`N_x`
  * - ``Ny``
    - *integer*
    - 600
    - number of columns :math:`N_y`
  * - ``fullWellCapacity``
    - *integer*
    - 25000
    - Full-well-capacity :math:`w`
  * - ``model``
    - *char*
    - 
    - Model of the camera
  * - ``colorChannels``
    - 1, 2, 3
    - 1
    - Number of color channels
  * - ``crosstalk12``
    - *double*
    - 0
    - Crosstalk from dexel 1 to 2
  * - ``crosstalk21``
    - *double*
    - 0
    - Crosstalk from dexel 2 to 1

 
.. include:: Camera/Camera_constructor.txt


.. include:: Camera/Camera_methods.txt

