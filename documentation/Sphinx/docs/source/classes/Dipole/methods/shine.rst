.. dropdown:: **shine** |subTitle| Illuminate a dipole. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % general pattern
        obj2 = obj.shine(IL);
        objList2 = objList.shine(IL);

    .. raw:: html
      
        <p class="title">Description</p>

    Run a DDA numerical simulation of the electromgnetic field generated inside a dipole, or inside a set of dipoles (*Dipole* vector). In the latter case, the interaction between the dipoles is taken into account. The presence of a substrate is also taken into account. This method provides values to all the missing attributes, namely:
    
    - ``p``, the electric dipolar moment of the object(s),
    - ``EE0``, the local electric field vector of the incident illumination at the location of the dipole(s).
    - ``n_ext`` the refractive index of the surroundings

    .. warning::

        *Dipole* is not a handle class. An output argument must be returned when using the *shine* method, otherwise the object is not modified.
