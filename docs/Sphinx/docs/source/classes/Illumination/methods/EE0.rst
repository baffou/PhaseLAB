.. dropdown:: **EE0** |subTitle| Return the value of the incident electric field at a given position. |/subTitle|
    
    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % prototype
        obj.EE0(pos)

    .. raw:: html
      
        <p class="title">Description</p>

    This method returns the value of the electric field of the illumination, in the absence of the object, at the sample plane, at the position ``pos`` (3-vector) taking into account the reflection on the interface. For instance:
   

    .. code-block:: matlab

        >> IL = Illumination(632e-9);
        >> pos = [1 1.2 1]*1e-6;
        >> IL.EE0(pos)

        ans =

            17.6637 +15.4410i   0.0000 + 0.0000i   0.0000 + 0.0000i

