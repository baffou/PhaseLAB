.. dropdown:: **ZernikeRemove** |subTitle| Removes the Zernike moments of the OPD image of an ImageQLSI object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.ZernikeRemove()
        obj.ZernikeRemove(n);
        obj.ZernikeRemove(n,m,r);
        obj2 = obj.ZernikeRemove(___);


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.ZernikeRemove()`` removes, by default, the ``(n, m) = (1, 1)`` Zernike order from the ``OPD`` image of ``obj``.

    .. include:: ../hr.txt

    ``obj.ZernikeRemove(n);`` removes all the Zernike orders up to order ``n``. For instance, ``obj.ZernikeRemove(2)`` removes the orders :math:`(1,1)`, :math:`(1,-1)`, :math:`(2,-2)`, :math:`(2,0), :math:`(2,2)`` from the OPD image.
    
    .. include:: ../hr.txt

    In ``obj.ZernikeRemove(n,m,r);``, ``r`` is the radius of the disc over which the Zerninke moment is calculated. By default, it is half the size of the image (``r = min([obj.Nx, obj.Ny])/2-1``).
    
    .. include:: ../hr.txt

    If an output ``obj2`` is specified, IM is copied. If not, obj is modified.






