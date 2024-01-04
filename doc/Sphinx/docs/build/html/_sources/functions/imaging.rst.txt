.. _The_imaging_function:

The |c| imaging |/c| function
=============================


.. raw:: html
    
    <p class="title">Synthax</p>

.. code-block:: matlab

    % prototype
    IM = imaging(DIs,IL,MI,Npx)


.. raw:: html
    
    <p class="title">Description</p>

Function that computes the :math:`E` field at the imaging plane, corresponding to a given set of dipoles at the sample plane. The computation is based on :abbr:`DDA (discrete dipole approximation)` calculations, which take into account dipoles optical coupling.

|hr|

``DIs`` is an array of |Dipole| objects.

``IL`` and ``MI`` are respectively the |Illumination| and |Microscope| objects of the setup.

``Npx`` is the size of the image (width and height).


.. raw:: html
    
    <p class="title">Example</p>

.. include:: /codeExamples/imageSimulation.rst



