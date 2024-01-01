.. dropdown:: **matList** |subTitle| Returns the list of available materials. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.matList()
        val = obj.matList();

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.matList()`` displays the list of available materials.

    ``val = obj.matList();`` returns a cell vector of available materials.

    This list represents the possible input arguments for the ``mat`` value of the constructor.
    
    .. code:: matlab

        >> DI.matList
            Ag
            Ag_Palik
            Al_rakic
            Au
            Au_Guler
            BK7
            Co
            Cr
            Cu
            Cu_Palik
            Fe
            Hg
            In
            Mg
            Mn
            Mo
            Nb
            Ni
            Pd
            Pt
            Rh
            Ta
            Ti
            TiN
            TiN800_Guler
            TiN_Guler
            TiO2
            V
            W
            ZnO
            ZrN
            graphene