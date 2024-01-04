.. dropdown:: **CrossSections** |subTitle| Return the polarisability and cross sections of a NP image. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.CrossSections()

    .. raw:: html
      
        <p class="title">Description</p>

    This function applies when dealing with the image of a single nanoparticle.

    ``obj`` can by a vector of *ImageEM* objects. In this case, the calculation will be performed on all the objects of the list.

    ``val = obj.CrossSections()`` return a *NPprop* object containing the complex optical polarisability of the NP, and the 3 cross-sections.


