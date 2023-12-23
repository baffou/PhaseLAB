.. dropdown:: **mean** |subTitle| Computes the average interferogram from a series of interferograms. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj = mean(objList);

    .. raw:: html
      
        <p class="title">Description</p>

    ``objList`` is a vector of *Interferogram* images. ``mean(objList)`` returns a single interferogram where the attributes ``Itf`` is an image that is the average of the ``Itf`` images of all the interferograms of ``objList``. The method is also applied to the ``Itf.Ref`` *Interfero* object, so that the average is also performed on the reference images.
