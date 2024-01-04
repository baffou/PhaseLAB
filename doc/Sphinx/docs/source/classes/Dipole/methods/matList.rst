.. dropdown:: **matList** |subTitle| Return the list of available materials. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.matList()
        val = obj.matList();

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.matList()`` displays the list of available materials in the command window.

    ``val = obj.matList();`` returns a cell vector of available materials.

    This list represents the possible input arguments for the ``mat`` value of the constructor:
    
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

    Each item represents a material. Each line corresponds to file, containing the data, and stored in the **spec/materials** folder.

    If other materials are being used, new custom files can be made, following a specific format: the file must be an ASCII file, containing 3 columns, the first for the energies in eV, the second for the real part of the refractive index, and the third for the imaginary part of the refractive index. Any new file can be saved in the **spec/materials** folder, or in any other folder known by Matlab. However, in order to simply keep track of the updated versions of PhaseLAB via Github, I suggest to store any custom-made file to a separate folder, out of the |PhaseLAB| package, and include this directory in the Matlab paths. Also, feel free to contact me to ask for any file addition/modification in the public Github version of |PhaseLAB| that would suit your studies.