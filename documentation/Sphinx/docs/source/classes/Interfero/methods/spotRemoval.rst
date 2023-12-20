.. dropdown:: **spotRemoval**
    
    Removes undesired spots in the Interferogram Fourier space.

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.spotRemoval()
        obj.spotRemoval(mask)
        objList.spotRemoval(___)
        obj2 = obj.spotRemoval(___);
        [obj2, mask] = obj.spotRemoval();

    .. raw:: html
      
        <p class="title">Description</p>

    This methods opens a windows to diplay the Fourier transform of the interferogram. The user should then repeat 2-click sequences to remove all the undesired spots. The first click defines the position of the spot, and the second click defines the radius of the disc to be cropped. The sequence can be repeated many times and to stop it, any other key than the left-click should be pressed.

    .. image:: ../images/spotRemoval.png

    .. include:: ../hr.txt

    Alternatively, a mask can be specified at the input argument. In that case, no figure opens:``obj.spotRemoval(mask)``.

    .. include:: ../hr.txt

    If an *Interfero* object is specified as an output, ``obj2 = obj.spotRemoval(___);``; the original object is not modified, but duplicated.

   .. include:: ../hr.txt

    The mask defined by the user can also be returned as a second output argument, to possibly be used as an input for a forthcoming call of this method with another *Interfero* object.


