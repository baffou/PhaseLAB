Multichannel imaging
====================

Some articles published in 2024 reported the use QLSI with multichannel cameras, in particular with a 2-color camera [#colorCGM]_, and a 4-polarisation camera [#polarCGM]_. For these implementations, 2 to 4 interferograms shall be extracted from the raw camera image.

.. [#colorCGM] *Single-shot quantitative phase-fluorescence imaging using cross-grating wavefront microscopy*, B. Marthy, M. Benefice, G. Baffou, **Sci. Rep.** (2024)  

.. [#polarCGM] *Capturing the Full Electromagnetic Field of Light using Polarization-Resolved Cross-Grating Wavefront Microscopy*, B. Marthy, M. Benefice, G. Baffou, *submitted*  (2024)  

Multicolor imaging
------------------

If the interferogram arises from a 2-color camera, the two interferograms can be extracted using the :ref:`splitColors <The_splitColors_method>` method:

.. code-block:: matlab

    Itf0 = importItfRef(folder,MI);
    Itf = Itf0.splitColors();

If the input :matlab:`Itf0` is a list (an array) or :math:`N` |Interfero| objects, then the output :matlab:`Itf` is a :math:`N\times2` array of |Interfero| objects, where each column is one color.

Some color cameras suffer from crosstalk between neighboring dexels of different colors. To correct for this crosstalk, use the |Interfero| method :ref:`crosstalkCorrection <The_crosstalkCorrection_method>`:

.. code-block:: matlab

    Itf0 = importItfRef(folder,MI);
    Itf = Itf0.splitColors();


Then, :matlab:`Itf` can be processed like a normal |Interfero| object array using the :ref:`QLSIprocess <The_QLSIprocess_method>` method:

.. code-block:: matlab

    IM = QLSIprocess(Itf, IL);

and just like :matlab:`Itf`, :matlab:`IM` is a :math:`N\times2` |ImageQLSI| object array.


Multipolar imaging
------------------

If the interferogram arises from a 4-polarisation camera, the 4 interferograms can be extracted using the method :ref:`splitPolars <The_splitPolars_method>` method:

.. code-block:: matlab

    Itf0 = importItfRef(folder,MI);
    Itf = Itf0.splitPolars();

If the input :matlab:`Itf0` is a list (an array) or :math:`N` |Interfero| objects, then the output :matlab:`Itf` is a :math:`N\times4` array of |Interfero| objects, where each column is one polarisation.

Then, :matlab:`Itf` can be processed like a normal |Interfero| object using the :ref:`QLSIprocess <The_QLSIprocess_method>` method:

.. code-block:: matlab

    IM = QLSIprocess(Itf, IL);

and just like :matlab:`Itf`, :matlab:`IM` is a :math:`N\times4` |ImageQLSI| objects.

Then, the polarisation maps can be extracted using the :ref:`CGMpolar <The_CGMpolar_Method>` method:

.. code-block:: matlab

    polarImages = IMmulti.CGMpolar();

The output ``polarImages`` is a structure containing the fields ``theta0``, ``phibar``, ``dphi``, and ``rgbImage``. They can be displayed using:

.. code-block:: matlab

    figure,
    subplot(2,2,1)
    imagegb(polarImages.theta0)
    set(gca,'Colormap',hsv)
    title("\theta_0")
    subplot(2,2,2)
    imagegb(polarImages.phibar)
    title("\bar\phi")
    subplot(2,2,3)
    imageph(polarImages.dphi)
    title("\delta\phi")
    subplot(2,2,4)
    imagegb(polarImages.rgbImage)
    colormap(gca,hsv)
    fullscreen



