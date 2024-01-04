.. _The_ImageEM_class:

The ImageEM class
=================

*ImageEM* is a handle class.

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
    * - ``Microscope``
      - *Microscope*
      - 
      - Microscope object
    * - ``Illumination``
      - *Illumination*
      - 
      - Illumination object
    * - ``comment``
      - char
      - 
      - Any comment on the image




.. list-table:: Read-only properties
    :widths: 30 30 100 
    :header-rows: 1
    :align: center

    * - name
      - type
      - description
    * - ``Ex``
      - double array
      - x component image of the electric field
    * - ``Ey``
      - double array
      - y component image of the electric field
    * - ``Ez``
      - double array
      - z component image of the electric field
    * - ``Einc``
      - *ImageEM*
      - Incident electric field  
    * - name
      - type
      - description
    * - ``Nx``
      - double
      - Number of columns
    * - ``Ny``
      - double
      - Number of rows
    * - ``E2``
      - double
      - Image of the Efield intensity
    * - ``E``
      - double
      - Amplitude of the Efield
    * - ``Ph``
      - double
      - Phase image


.. include:: ImageEM/ImageEM_constructor.txt


.. include:: ImageEM/ImageEM_methods.txt

