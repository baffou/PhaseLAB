.. dropdown:: **Reference**
    
    Defines the reference interferogram of an *Interferogram* object.

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: ruby

        obj.Reference(ref);
        objList.Reference(ref);
        objList.Reference(refList);

    .. raw:: html
      
        <p class="title">Description</p>

    ``ref`` is an *Interfero* object supposed to be the reference interferogram of the *Interfero* ``obj``. The method ``Reference`` assigns ``ref`` as the reference of ``obj``.

    .. include:: ../hr.txt

    ``obj`` can be a list (vector) of interferogram. In that case, ``ref`` is assigned to all of them, without being duplicated.

.. include:: ../hr.txt

    ``ref`` can be a list (vector) of interferogram, as long as it has the same number of objects as ``obj``. in that case, the reference interferograms are assigned one by one to the interferograms.