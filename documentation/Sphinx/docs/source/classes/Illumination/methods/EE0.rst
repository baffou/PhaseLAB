.. dropdown:: **EE0**
    

    .. code-block:: matlab

        pos = [0 1.2 0]*1e-6;
        IL.EE0(pos)

    returns the value of the electric field of the illumination, in the absence of the object, at the position ``pos`` (3-vector) taking into account the reflection on the interface.