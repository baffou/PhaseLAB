.. dropdown:: QLSIprocess |subTitle| Process and return the intensity and wavefront images. |/subTitle|
    
    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        Im = QLSIprocess(Itf, IL);
        ImList = QLSIprocess(ItfList, IL);
        ImList = QLSIprocess(___, Name, Value);


    .. raw:: html
      
        <p class="title">Description</p>

    Method of the class *Interfero* that transforms the interferograms into intensity and wavefront images. As aa second input, the illumination must be specified.

    |hr|

    The method also work with a *Interfero* array, and returns an *ImageQLSI* array: :matlab:`ImList = QLSIprocess(ItfList, IL);`




