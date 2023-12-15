.. meta::
   :description: The PhaseLAB Matlab toolbox documentation
   :keywords: QLSI, Matlab, toolbox



Some Sphinx coding examples
---------------------------

**Lumache** (/lu'make/) is a Python library for cooks and food lovers that
creates recipes mixing random ingredients.  It pulls data from the `Open Food
Facts database <https://world.openfoodfacts.org/>`_ and offers a *simple* and
*intuitive* API.

Check out the :doc:`example` section for further information, including how to
:ref:`install <installation>` the project.

The ``kind`` parameter should be either ``"meat"``, ``"fish"``,
or ``"veggies"``. Otherwise, :py:func:`lumache.get_random_ingredients`
will raise an exception.

term (up to a line of text)
   Definition of the term, which must be indented

   and can even consist of multiple paragraphs

next term
   Description.


| These lines are
| broken exactly like in
| the source file.

These lines are
broken exactly like in
the source file.



This is a normal text paragraph. The next paragraph is a code sample ::

   IM = QLSIprocess(Itf, MI);

This is a normal text paragraph again.

+------------------------+------------+----------+----------+
| Header row, column 1   | Header 2   | Header 3 | Header 4 |
| (header rows optional) |            |          |          |
+========================+============+==========+==========+
| body row 1, column 1   | column 2   | column 3 | column 4 |
+------------------------+------------+----------+----------+
| body row 2             | ...        | ...      |          |
+------------------------+------------+----------+----------+


=====  =====  =======
A      B      A and B
=====  =====  =======
False  False  False
True   False  False
False  True   False
True   True   True
=====  =====  =======


`Link text <https://domain.invalid/>`_

This is a paragraph that contains `a link`_.

.. _a link: https://domain.invalid/



By default, inline code such as :code:`1 + 2` just displays without
highlighting.

Since Pythagoras, we know that :math:`a^2 + b^2 = c^2`.


.. math:: e^{i\pi} + 1 = 0
   :label: euler

Euler's identity, equation :math:numref:`euler`, was elected one of the
most beautiful mathematical formulas.


For example: :abbr:`LIFO (last-in, first-out)` displays LIFO.


... is installed in :file:`/usr/lib/python3.{x}/site-packages` ...

:program:`program file`

:samp:`print(1+{variable})`


.. function:: foo(x)
              foo(y, z)
   :module: some.module.name

   Return a line of text input from the user.




.. code-block::

       The output of this line has no spaces at the beginning.


.. image:: images/sample.png
   :width: 200


Lorem ipsum [#f1]_ dolor sit amet ... [#f2]_



Lorem ipsum [Ref]_ dolor sit amet.

.. [Ref] Book or article reference, URL or whatever.




.. |name| replace:: replacement *text*


|name|

.. This is a comment.



.. code-block:: python
   :emphasize-lines: 3,5

   def some_function():
       interesting = False
       print('This line is highlighted.')
       print('This one is not...')
       print('...but this one is.')


..
   This whole indented block
   is a comment.

   Still in the comment.

.. note::

   This project is under active development.




.. rubric:: Footnotes

.. [#f1] Text of the first footnote.
.. [#f2] Text of the second footnote.


