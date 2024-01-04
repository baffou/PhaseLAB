.. dropdown:: **figure** |subTitle| Display the dipoles. |/subTitle|
    
    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        objList.figure()

    .. raw:: html
      
        <p class="title">Description</p>

    Display the geometry of a system of nanoparticles, defined by a *Dipole* vector ``objList``. For instance:
    
    .. code:: matlab

        % creation of a ring of nanoparticles
        radius = 550e-9;  % Nanoparticle radius
        DI0 = Dipole('Au',radius);

        DI = repmat(DI0,12,1);

        R=3e-6;           % radius of the ring

        % creation of a ring of dipoles
        for ii=1:12
            DI(ii)=DI(ii).moveTo('x',R*cos(2*pi*ii/12),'y',R*sin(2*pi*ii/12));
        end

        DI.figure


    .. image:: /images/NPring.png
        :width: 600
        :align: center