.. _The_CrossGrating_class:

The CrossGrating class
======================

*CrossGrating* is a handle class.

A *CrossGrating* object represents the QLSI grating used in the system.

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
  * - ``name``
    - *char*
    - 'undefined'
    - Reference of the grating
  * - ``Gamma``
    - *double*
    - 
    - Relay lens
  * - ``depth``
    - *double*
    - 
    - Etching depth of the :math:`0-\pi` patter.
  * - ``RI``
    - *double*
    - 1.46
    - Refractive index of the material
  * - ``lambda0``
    - *double*
    - 
    - Wavelength the grating is made for

.. include:: CrossGrating/CrossGrating_constructor.rst

