.. dropdown:: **EE0n** |subTitle| Return the value of the norm of the incident field at the center of the field of view. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        val = obj.EE0n()

    .. raw:: html
      
        <p class="title">Description</p>

    This method returns the norm of the incident field at the center of the field of view, at the sample plane (not at the image plane). If ``obj`` is already an incident field, it simply returns the norm of the field at the center of the field of view.

    ``obj`` can by a vector of *ImageEM* objects. In that case, the treatment will be perform on all the objects of the list.


