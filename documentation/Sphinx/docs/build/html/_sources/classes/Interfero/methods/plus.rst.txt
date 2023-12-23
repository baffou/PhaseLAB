.. dropdown:: **plus** |subTitle| Defines the addition between two *Interfero* objects: ``Itf1 + Itf2``. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: ruby

        obj = plus(obj1, obj2);
        obj = obj1 + obj2;
        obj = obj1 + obj2 + ... + objN;

    .. raw:: html
      
        <p class="title">Description</p>

    The method overload the operator ``+`` by defining the method ``plus``. It actually adds the two interferograms ``obj1.Itf`` and ``obj2.Itf`` and stores the result in attribue ``Itf`` of the output ``obj``. It does the same for the references  ``obj1.Ref.Itf`` and ``obj2.Ref.Itf``.

    .. include:: ../hr.txt

    The method also work with several additions at a time: ``obj = obj1 + obj2 + ... + objN;``