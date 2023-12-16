.. include:: substitutions.rst


The Microscope class
====================

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
     - ``= -this.Mobj*m.f_TL/this.f_brand``
     - magnification of the microscope
   * - ``pxSize``
     - double
     - ``= abs( this.CGcam.dxSize()/this.M );``
     - pixel size of the image


