.. dropdown:: **applyPCmask** |subTitle| Returns a re-calculated image with a phase contrast mask in the objective lens. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj = obj0.applyPCmask(mask);
        objList = objList0.applyPCmask(mask);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj = obj0.applyPCmask(mask);`` recalculate the :math:`E` field at the image plane when adding a phase mask at the pupil of the objective. It is used to model Zernike phase-contrast microscopy. ``mask`` is a *PCmask* object.

    |hr|

    ``objList = objList0.applyPCmask(mask);``: *ImageEM* object *vectors* can also be used with this method. The transformation applies then to all the objects of the vector.
    

     

