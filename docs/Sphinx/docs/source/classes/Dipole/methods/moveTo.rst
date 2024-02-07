.. dropdown:: **moveTo** |subTitle| move the dipole to aa given position. |/subTitle|
    
    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % general pattern
        obj2 = obj.moveTo([x, y, z]);
        obj2 = obj.moveTo(x, y, z);
        obj2 = obj.moveTo(Name, Value);

        % examples
        obj2 = obj.moveTo([0.1, 0.3, 0]*1e-6);  % moves the dipoles to the coordinates [0.1, 0.3, 0] µm.
        obj2 = obj.moveTo(0.1e-6, 0.3e-6, 0);  % moves the dipoles to the coordinates [0.1, 0.3, 0] µm.
        obj2 = obj.moveTo('x', 1e-6);  % change the *x*-coordinate to 1 µm
        obj2 = obj.moveTo('x', 1e-6, 'y', 1e-6);  % change the (x, y)-coordinate to [1, 1] µm.
        obj2 = obj.moveTo('z' = -1e-6, 'y', 0.5-6, 'x', 3e-6);  % moves the dipoles to the coordinates [-1, 0.5 3] µm.

    .. raw:: html
      
        <p class="title">Description</p>

    Move the dipole to a specific position in 3D. The motion is absolute, not relative to the original position. For a relative shift of the position, use the ``moveBy`` method.

    The arguments can be either the 3 shifts in :math:`x`, :math:`y`, and :math:`z` directions; or a 3-vector of these positions; or a Name-Value structure where the Names are ``'x'``, ``'y'``, and/or ``'z'``, in any order.
