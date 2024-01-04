.. _The_CGcamera_class:

The CGcamera class
==================

*CGcamera* is a handle class.

The *CGcamera* object represents the imaging system. It is composed of a regular camera, a cross-grating, and possibly a relay lens in between. Each of these three components are also represented by objects, respectively from the classes *Camera*, *CrossGrating*, and *RelayLens*.

Properties
----------

.. list-table:: Public properties
    :widths: 30 30 30 100 
    :header-rows: 1
    :align: center
    :class: tight-table

    * - name
      - type
      - default
      - description
    * - ``Camera``
      - *Camera*
      - ``'Zyla'``
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
      - 0
      - Grating-camera distance :math:`d` \[m\]


.. list-table:: Read-only properties
    :widths: 30 30 130 
    :header-rows: 1
    :align: center

    * - name
      - type
      - description
    * - ``dxSize``
      - double
      - Effective dexel size (divided by the |RL| zoom) \[m\]
    * - ``zeta``
      - double
      - zeta factor :math:`\zeta=\Gamma Z/2p`
    * - ``zoom``
      - double
      - zoom of the |RL| system :math:`Z`

.. note::

    The property ``dxSize`` is a dependent attribute that returns the **effective** dexel size, which is not necessarily the actual dexel size of the camera sensor. When there is a |RL|, applying a zoom :math:`Z` to the system, the {|RL|, camera} system is equivalent to a single camera with a dexel size divided by the zoom. This method returns the dexel size fo this equivalent camera, called the effective dexel size.
    




.. include:: CGcamera/CGcamera_constructor.txt


.. include:: CGcamera/CGcamera_methods.txt

