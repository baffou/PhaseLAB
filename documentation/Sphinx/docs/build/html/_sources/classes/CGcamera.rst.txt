.. _The_CGcamera_class:

The CGcamera class
==================

*CGcamera* is a handle class.

The CGcamera object represents the imaging system. It is composed of a regular camera, a cross-grating, and possibly a relay lens in between. Each of these three components are also represented by objects, respectively from the classes *Camera*, *CrossGrating*, and *RelayLens*.

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
  * - ``Camera``
    - *Camera*
    - 
    - Camera
  * - ``RL``
    - *RelayLens*
    - 
    - Relay lens
  * - ``CG``
    - *CrossGrating*
    - 
    - Cross-grating
  * - ``FileName``
    - *char*
    - 
    - FileName of the CGcamera, if any
  * - ``CGpos``
    - *double*
    - 
    - Cross-grating position


.. list-table:: Dependent properties
  :widths: 30 30 30 100 
  :header-rows: 1
  :align: center

  * - name
    - type
    - dependence
    - description
  * - ``dxSize``
    - double
    - ``= Camera.dxSize/abs(zoom);``
    - size of the camera pixel (dexel)
  * - ``zeta``
    - double
    - ``= abs(CG.Gamma/(2*dxSize));``
    - zeta factor
  * - ``zoom``
    - double
    - ``1`` or ``= -abs(RL.zoom);``.
    - zoom of the imaging system (in addition to the microscope system's)


.. include:: CGcamera/CGcamera_constructor.rst


.. include:: CGcamera/CGcamera_methods.rst

