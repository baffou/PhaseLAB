.. dropdown:: **alpha_ImageProfile** |subTitle| Return the polarisability, optical volume and dry mass of small objects. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        val = obj.alpha_ImageProfile();

    .. raw:: html
      
        <p class="title">Description</p>

    This method of the |ImageEM| and |ImageQLSI| classes returns the polarisability, |OV| and |DM| of small objects, using a radial profile method. The algorithm involves a sum of the pixels on a circular area. The method opens a window with the image. First, click on the OPD image to zoom in on the particle of interest, and press 'z' when the zoom is correct. Second, click on the center of the particle. A new figure will show up, plotting the pixel summation as a function of the radius of the circular area, from 0 to 100 px. Finally, click two times on the graph to define the range of value corresponding to a proper convergence of the integration. In practice, the line shape should feature a plateau, and the user should click at the beginning and at the end of the plateau. For instance, in this example, the user could click on :math:`x=18` and :math:`x=40`:

    .. image:: /images/GUI_alphaImageWindow.png
        :width: 450
        :align: center

    Finally, the values of polarisability, and optical volume are returned as a structure, containing the fields alpha, OV and OVw. OVw is the weighted optical volume as defined in Ref. [#BOE13_6550]_.

    .. [#BOE13_6550] *Biomass measurements of single neurites in vitro using optical wavefront microscopy*, L. Durdevic, A. Resano Gines, A. Roueff, G. Blivet, G. Baffou, **Biomedical Optics Express** 13, 6550-6560 (2022) 


    .. raw:: html
      
        <p class="title">Name-Value inputs</p>

    Several Name-Value inputs can be used to adjust the way the procedure works:


    - :matlab:`'nmax'`, default value: ``40``

        Maximum radius of the integration area.

    - :matlab:`'nBkg'`, default value: ``3``

        Width of the boundary considered to calculate the zero value of the background.

    - :matlab:`'NNP'`, default value: ``1``
    
        Number of particles to be clicked on the image. The procedure will stoped after ``N`` particles will be processed, and the returned data will be an array of values.

    - :matlab:`'zoom'`, default value: :matlab:`true`

        Enables the user to first zoom before clicking on the particle
 
    - :matlab:`'step'`, default value: ``1``

        The integration as a function of the radius will be calculated only every ``N`` pixels, where ``N`` is the step value. Specifying a value larger than 1 can make the processing faster. 


    - :matlab:`'keepPoint'`, default value: :matlab:`false`

        Keeps the same clicking point from one image to another. It can save time if many images need to be processed, and if the NP does not move from one image to another.
    
    - :matlab:`'display'`, default value: :matlab:`false`
    
        Displays the results of all the measurements in a single graph. Makes sense only if multiple measurements are made within a single call of the function.



   

