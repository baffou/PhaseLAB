.. _The_CGMinSilico_function:

The |c| CGMinSilico |/c| function
=================================

.. raw:: html
    
    <p class="title">Synthax</p>

.. code-block:: matlab

    % prototypes
    Itf = CGMinSilico(Im, Name, Value);

    % examples
    Itf = CGMinSilico(Im, `ShotNoise',true, 'Nimages', 30);


.. raw:: html
    
    <p class="title">Description</p>

The *CGMinSilico* function simulates the interferogram corresponding to the *ImageEM* object ``Im``. It baciscally considers ``Im`` as the image at the sample plane without |QLSI| grating, and compute the interferogram once the grating is placed. The function returns an *Interfero* object.


The interest of this function is that it can add shot noise on the interferogram. The amplitude of the noise is calculated from the full well capacity of the camera, and the number of averaged images, specified by the option :matlab:`Nimages`.

The option :matlab:`ShotNoise` tells whether the shot noise is included (``true``) or not (``false``).


.. raw:: html
    
    <p class="title">Example</p>

.. include:: /codeExamples/inSilicoSimu.rst