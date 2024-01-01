.. _The_ImageQLSI_class:

The ImageQLSI class
===================

*ImageQLSI* is a handle class.

Properties
----------


.. dropdown:: **Properties**




  .. list-table:: Public properties inherited from the superclass *ImageMethods*:
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




  .. list-table:: Public properties
    :widths: 30 30 30 100 
    :header-rows: 1
    :align: center

    * - name
      - type
      - default
      - description
    * - ``T``
      - double array
      - 
      - Intensity image
    * - ``OPD``
      - double array
      - 
      - OPD image
  
  .. list-table:: Read-only properties
    :widths: 30 30 30 100 
    :header-rows: 1
    :align: center

    * - name
      - type
      - default
      - description
    * - ``DWx``
      - double array
      - 
      - OPD gradient along *x*
    * - ``DWy``
      - double array
      - 
      - OPD gradient along *y*
  


  .. list-table:: Dependent properties
    :widths: 30 30 30 100 
    :header-rows: 1
    :align: center

    * - name
      - type
      - dependence
      - description
    * - ``OPDnm``
      - double array
      - ``= OPD*1e9``;
      - OPD in nm
    * - ``Ph``
      - double array
      - ``= 2*pi/lambda*obj.OPD;``
      - Phase image
    * - ``Nx``
      - double
      - ``= size(OPD,2);``
      - Number of columns
    * - ``Ny``
      - double
      - ``= size(OPD,1);``
      - Number of rows


.. include:: ImageQLSI/ImageQLSI_constructor.txt


.. include:: ImageQLSI/ImageQLSI_methods.txt

