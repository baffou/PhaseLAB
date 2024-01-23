.. dropdown:: **sum** |subTitle| Coherent sum of the fields. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj = sum(objList);

    .. raw:: html
      
        <p class="title">Description</p>

    The method uses the overloaded operator ``+`` to sum all the E fields of list of *ImageEM* E fields in ``objList``. It simply sums the electromagnetic fields associated to all 2 *ImageEM* objects. Note that it also sums the incident fields. 

    .. warning::

        This method is relevant if the different images correspond to the same sample, for instance an object illuminated with various plane waves with different incidence angles at the same time.

        When the list of images does not correspond to the same sample, for instance when it consists of different nanoparticles at different locations, one should not use this method to get the image of all the nanoparticles at the same time. There will be no self-consistent optical coupling between these objects, and the incident E fields should be be sumed in this case. Prefer summing dipoles (``DIlist=DI1+DI2``) and then imaging the dipole array(``DIlist.imaging()``), which will run a DDA self consistent calculation of the dipolar moments.

    