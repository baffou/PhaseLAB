.. dropdown:: **Escat** |subTitle| Return the image of the scattered electric field as an *ImageEM* object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

            val = obj.Escat()

    .. raw:: html
      
        <p class="title">Description</p>

    This method returns the norm of the incident field at the center of the field of view. If ``obj`` is already an incident field, it simply returns the norm of the field at the center of the field of view.

    ``obj`` can by a vector of *ImageEM* objects. In that case, the treatment will be perform on all the objects of the list.


