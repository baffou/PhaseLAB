.. include:: substitutions.rst


The ImageQLSI class
-------------------

Properties
^^^^^^^^^^

.. list-table:: Public properties inherited from the superclass *ImageMethods*:
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - default
     - description
   * - ``Microscope``
     - *Microscope*
     - 
     - Microscope object
   * - ``Illumination``
     - *Illumination*
     - 
     - Illumination object
   * - ``comment``
     - char
     - 
     - Any comment on the image




.. list-table:: Public properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - default
     - description
   * - ``T``
     - double array
     - 
     - Intensity image
   * - ``OPD``
     - double array
     - 
     - OPD image
 
.. list-table:: Read-only properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - default
     - description
   * - ``DWx``
     - double array
     - 
     - OPD gradient along *x*
   * - ``DWy``
     - double array
     - 
     - OPD gradient along *y*
 


.. list-table:: Dependent properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - dependence
     - description
   * - ``OPDnm``
     - double array
     - ``= this.OPD*1e9``;
     - OPD in nm
   * - ``DWn``
     - double array
     - ``= sqrt(this.DWx.^2 + this.DWy.^2);``
     - norm of the OPD gradient
   * - ``Ph``
     - double array
     - ``= 2*pi/this.lambda*obj.OPD;``
     - Phase image
   * - ``Nx``
     - double
     - ``= size(this.OPD,2);``
     - Number of columns
   * - ``Ny``
     - double
     - ``= size(this.OPD,1);``
     - Number of rows
 

Constructor
^^^^^^^^^^^
.. code-block:: python
    :caption: Prototype

    obj = ImageQLSI(INT,OPD,MI,IL)
    obj = ImageQLSI(INT,OPD,MI,IL,"remotePath",logical)
    obj = ImageQLSI(INT,OPD,MI,IL,"fileName",char)
    obj = ImageQLSI(INT,OPD,MI,IL,"imageNumber",int)


.. list-table:: function inputs
   :widths: 30 160
   :header-rows: 1
   :align: center


   * - ``INT``
     - Intensity image. Can be either a char (name of the file) or a matrix
   * - ``OPD``
     - OPD image. Can be either a char (name of the file) or a matrix
   * - ``MI``
     - *Microscope* object
   * - ``IL``
     - *Illumination* object
   * - ``"remotePath"``
     - Tells whether the T and OPD matrices should be actually saved in the RAM (``= false``), or rather on the hard disk (``=true``).
   * - ``"fileName"``
     - Prefix of the T and OPD fileNames to be saved on the hard disk in case the option ``"remotePath"`` is set to ``true``.
   * - ``"imageNumber"``
     - Number of the image
     

Methods
^^^^^^^

camList()
"""""""""

Displays the list of predefined camera names.

.. code-block:: python

    >> MI.camList

    ans =

        5x1 cell array

        {'Sid4Element-Sona'}
        {'Sid4Element'     }
        {'Silios_mono'     }
        {'sC8-830'         }
        {'sC8-944'         }


This list gives the possible values of the ``CGcam`` input in the Microscope constructor.

highPassFilter(nCrop)
"""""""""""""""""""""

.. code-block:: python

    IM.highPassFilter(nCrop)

``nCrop`` is an integer.

Remove the low frequencies of the OPD image simply by ``IM.OPD - imgaussfilt(IM.OPD,nCrop);``.

lowPassFilter(nCrop)
""""""""""""""""""""

.. code-block:: python

    IM.lowPassFilter(nCrop)


``nCrop`` is an integer.

Applies a Gaussian filter to the OPD image simply by ``imgaussfilt(IM.OPD,nCrop);``.


.. include:: classes/ImageQLSI/ZernikeRemove.rst


untilt(objList,opt) 
""""""""""""""""""""

.. code-block:: python

    IM.untilt(options)
    IM2 = IM.untilt(options)
    IM.untilt('xy1',[1 10], 'xy2', [100 210])
    IM.untilt(Center = 'Manual')
    


        arguments
            objList
            % parameters for boxSelection()
            opt.xy1 = []
            opt.xy2 = []
            opt.Center = 'Auto' % 'Auto', 'Manual' or [x, y]
            opt.Size = 'Auto' % 'Auto', 'Manual', d or [dx, dy]
            opt.twoPoints logical = false
            opt.params double = double.empty() % = [x1, x2, y1, y2]
            opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
            opt.app PhaseLABgui = PhaseLABgui.empty()
        end


| ``n``, ``m`` are the orders of the Zernike moment.
| ``r0`` is the radius of the area over which the Zerninke moment is calculated.



        function [objList2,params] = untilt(objList,opt) 
        function IMout = mean(IM,opt)
        function IM2 = smooth(IM,nn,hfigInit)
        function objList2 = square(objList)
        function objList2 = phase0(objList,option)
        function obj = setFcrops(obj,crops)
        function obj2 = binning(obj,n)
        function obj = setProcessingSoftware(obj,name)
        function [obj, params] = level0(obj0,opt)
        function obj2 = gauss(obj,nn)
        function obj = rot90(obj0,k)
        function obj = mirrorH(obj0)
        function obj = mirrorV(obj0)
        function val = get.DWn(obj)
        function val = DWnorm(obj)
        function val = D2Wnorm(obj)
        function val = PDCM(obj)
        function val = DM(obj)
        function PDCMdisplay(obj,hfig)
        function obj2List = download(objList)
        function save(objList,folder,varargin)
        function write(obj,obj_in)
        function IMout = propagation(IM, z, opt)
