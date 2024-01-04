.. _The_ImageQLSI_class:

The ImageQLSI class
===================

*ImageQLSI* is a handle class.

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
    * - ``T``
      - double array
      - Intensity image
    * - ``OPD``
      - double array
      - OPD image
    * - ``DWx``
      - double array
      - OPD gradient along *x*
    * - ``DWy``
      - double array
      - OPD gradient along *y*
    * - name
      - type
      - description
    * - ``OPDnm``
      - double array
      - OPD in nm
    * - ``Ph``
      - double array
      - Phase image
    * - ``Nx``
      - double
      - Number of columns
    * - ``Ny``
      - double
      - Number of rows


.. include:: ImageQLSI/ImageQLSI_constructor.txt


.. include:: ImageQLSI/ImageQLSI_methods.txt

