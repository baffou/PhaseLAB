.. _The_Microscope_class:

The Microscope class
====================

*Microscope* is a handle class.

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
   * - ``Objective``
     - *Objective*
     - 
     - Objective lens
   * - ``CGcam``
     - *CGcamera*
     - 
     - QLSI camera
   * - ``f_TL``
     - *double*
     - 180
     - Objective lens
   * - ``software``
     - *char*
     - 
     - software used with the microscope ('PhaseLIVE', 'Sid4Bio')
   * - ``zo``
     - *double*
     - 0
     - defocus


.. list-table:: Dependent properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - dependence
     - description
   * - ``M``
     - double
     - ``= -Mobj*f_TL/f_brand``
     - magnification of the microscope
   * - ``pxSize``
     - double
     - ``= abs( CGcam.dxSize()/M );``
     - pixel size of the image


.. include:: Microscope/Microscope_constructor.txt


.. include:: Microscope/Microscope_methods.txt

