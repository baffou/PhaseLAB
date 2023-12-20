Constructor
-----------

.. dropdown:: **Constructor**

  .. raw:: html
      
    <p class="title">Synthax</p>

  .. code-block:: ruby
    :class: custom-code

    obj = ImageQLSI()
    obj = ImageQLSI(n)
    obj = ImageQLSI(IM)
    obj = ImageQLSI(INT,OPD, MI, IL, int)
    obj = ImageQLSI(___,Name,Value)


  .. raw:: html
      
    <div class="title">Description</div>

  ``obj = ImageQLSI()`` creates an empty *ImageQLSI* object.

  .. include:: ../hr.txt

  ``objList = ImageQLSI(n)`` create a *n*-vector ``objList`` of empty *ImageQLSI* objects.

  .. include:: ../hr.txt

  ``obj = ImageQLSI(obj0)`` creates a *ImageQLSI* object ``obj`` from an *ImageEM* object ``obj0``.

  .. include:: ../hr.txt

  ``obj = ImageQLSI(INT, OPD, MI, IL)`` creates an *ImageQLSI* object. ``INT`` defining the intensity image, ``OPD`` the optical path difference, ``MI`` the microscope and ``IL`` the illumination.
 
  ``INT`` an ``OPD`` can be either a matrix, or a file name containing the data. ``MI`` is a *Microscope* object. ``IL`` is an *Illumination* object.

  .. include:: ../hr.txt

  ``ImageQLSI`` accepts *Name-Value* options. 


  .. raw:: html
        
      <p class="title">Examples</p>
  
  .. dropdown:: **Build an ImageQLSI object by importing data**

    .. code-block:: matlab

      T = readMatrix('data/T.txt');
      W = readMatrix('data/W.txt');

      MI = Microscope(100);         % creates a microscope with 100x magnification
      IL = Illumintation (530e-9);  % creates an illumination at lambda = 530 nm

      IM = ImageQLSI(T, W, MI, IL); % creates the ImageQLSI object
    



  .. raw:: html
      
    <p class="title">Name-value arguments</p>
  
  .. note::
    
    Specify optional pairs of arguments as ``Name1 = Value1, ..., NameN = ValueN``, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.

    Example: :matlab:`ImageQLSI(___,'remotePath','images/data')`
  

  - :matlab:`remotePath`

    When working with a long vector of *ImageQLSI* objects, one can save RAM memory by storing the ``T`` and ``OPD`` matrices on the hard disk drive, when creating the objects. For this purpose, specify the folder to store these data.

  - :matlab:`FileName`

    The ``remotePath`` has to be used in conjonction with 


  - :matlab:`imageNumber`


