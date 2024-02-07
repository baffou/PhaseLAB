In silico QLSI
==============

|PhaseLAB| enables not only to :ref:`process QLSI interferograms <process_experimental_images>`, it can also simulate the electromagnetic field at the image plane of a microscope, for a given object at the sample plane, and extract from it the theoretical intensity and wavefront images.

Moreover, it can also model the interferogram of this exact same object, and process this modelled interferogram as it it were a real experimental one.

This modality of |PhaseLAB|, called *in Silico QLSI*, enables the easy screening of parameters such as the wavelength, the grating pitch, the grating-camera distance, the dexel size, etc, and their effects on the image quality (signal to noise ratio, accuracy, artefacts, etc), without conduting any experiment.

This modality of |PhaseLAB| was introduced in Ref. [#OC521_128577]_ and widely used in Ref. [#QPIcomparison]_.

.. [#OC521_128577] *Cross-grating phase microscopy (CGM): In silico experiment (insilex) algorithm, noise and accuracy*, B. Marthy, G. Baffou, **Opt. Commun.** 521, 128577 (2022)  

.. [#QPIcomparison] *Quantitative phase microscopies: accuracy comparison*, P.Chaumet, P. Bon, G. Maire, A. Sentenac, G. Baffou, *submitted*  (2023)  


Model a nanoparticle
--------------------

The simplest object that can be modelled *in Silico* is a nanoparticle, or more precisely a dipole. Here is a code that models a microscope, and a dipole corresponding to a 100-nm gold nanoparticle placed on glass and immersed in water:

.. code-block:: matlab
    :linenos:

    %% code that simulates the image of a gold nanoparticle

    lambda = 530e-9;            % Illumination wavelength
    Npx = 300;                  % Final image with Npx*Npx pixels
    Mobj = 100                  % Objective magnification
    NA = 1.0                    % Objective numerical aperture

    radius = 60e-9;             % Nanoparticle radius

    % model the setup
    ME = Medium('water', 'glass');
    OB = Objective(Mobj,NA,'Olympus');
    CGcam = CGcamera('sC8-944');
    MI = Microscope(OB,'Olympus',CGcam);
    IL = Illumination(lambda,ME);

    % model the nanoparticle
    DI = Dipole('Au',radius);   % creation of the Dipole object
    DI = DI.shine(IL);          % illumination of the dipole

    % compute the images
    IM0 = imaging(DI,IL,MI,Npx);

    % display the images
    IM0.figure                  % display the images in the GUI




.. figure:: /images/NPinSilico_Ex.png
    :width: 600
    :align: center



In line 16, the dipole is illuminated. It means that the polarisation vector of the dipole is calculated, and assigned to the object property :matlab:`DI.p`:

.. code-block:: matlab

    >> DI.p

    ans =

        1.0e-30 *

        -0.7697 + 0.4309i   0.0000 + 0.0000i   0.0000 + 0.0000i

This dipole needs to be calculated before the :py:func:`imaging` function is called (line 19).

In line 19, the electromagnetic field is calculated using the ``imaging`` function (see :ref:`The imaging function <The_imaging_function>` section.) The first input is the |Dipole|  object, the second is the |Illumination| object, the third the |Microscope| object and the last one, :matlab:`Npx`, is the number of pixels (rows and columns) of the final (square) image. The function returs the electromagnetic field at the image plane of the microscope as an |ImageEM| object.


Model an interferogram
----------------------

In the presence of a QLSI grating at a millimetric distance from the image plane, the electromagnetic field gets modified to form an interferogram. This modification can be calculated using the :ref:`CGMinSilico function <The_CGMinSilico_function>`. Here is the synthax:

.. code-block:: matlab

    Itf = CGMinSilico(IM0,'shotNoise',true);

The keyword :matlab:`'shotNoise'` adds the natural shot noise of the selected camera specified in the Microscope object :matlab:`MI` (here an sC8 from Phasics). Other Name-value inputs can be specified. For more information, refer to :ref:`The_CGMinSilico_function`.


Process the interferogram
-------------------------

Finally the interferogram can be processed as if it were an experimental interferogram using :ref:`the QLSIprocess method <The_QLSIprocess_method>`:

.. code-block:: matlab

    IM = QLSIprocess(Itf,IL);

    dynamicFigure('gb', IM0, 'gb', IM)

Here is the displayed figure, comparing the theoretical OPD image, and the OPD image measured with the sC8 camera from Phasics, including the camera shot noise.

.. image:: /images/NPinSilico.png
    :width: 700


Model arbitrary objects
-----------------------

Objects of arbitrary geometry (big spheres, rods, biological cell, ...) can also be modelled using the *in Silico* algorithm. For this purpose, |PhaseLAB| should be coupled with the IFDDA toolbox.

*to be continued...*

