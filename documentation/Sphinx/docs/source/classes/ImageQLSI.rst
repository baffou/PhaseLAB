.. role:: matlab(code)
  :language: matlab
  :class: highlight


The ImageQLSI class
===================

*ImageQLSI* is handle class.

Attributes
----------


.. dropdown:: **Attributes**




  .. list-table:: Public attributes inherited from the superclass *ImageMethods*:
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




  .. list-table:: Public attributes
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
  
  .. list-table:: Read-only attributes
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
  


  .. list-table:: Dependent attributes
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


.. include:: ImageQLSI/ImageQLSI_constructor.rst


.. include:: ImageQLSI/ImageQLSI_methods.rst

