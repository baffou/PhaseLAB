# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'PhaseLAB documentation'
copyright = '2023, Guillaume Baffou'
author = 'Guillaume Baffou'
release = '4.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration


import os
import sys

sys.path.insert(0, os.path.abspath('./_ext'))


sys.path.append(os.path.abspath("./_ext"))

extensions = ['sphinx_panels', 'sphinxcontrib.matlab', 'sphinx.ext.extlinks', 'sphinx_tabs.tabs']
# , "sphinx_design"
myst_enable_extensions = ["colon_fence"]




templates_path = ['_templates']

# exluce these patterns makes the compilation faster and avoid warnings, but excludes these pages from the search tool.
#exclude_patterns = ['**/methodsPages/*.rst','**/methods/*.rst']
exclude_patterns = ['**/methods/*.rst']

# In any case, always exclude these pages to avoid having many <no title> replies when using the seach tool.
#exclude_patterns = ['**/methodsPages/*.rst']

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

#html_theme = 'alabaster'
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_favicon = 'images/favicon2.png'

html_css_files = ['custom.css']


rst_prolog = """
.. |PhaseLAB| raw:: html

    <span style="font-family: 'Roboto';">PhaseLAB</span>

.. |PhaseLIVE| raw:: html

    <span style="font-family: 'Roboto';">PhaseLIVE</span>

.. role:: matlab(code)
    :language: matlab
    :class: highlight
  

.. |sub1| replace:: mine1
.. |sub2| replace:: mine2

.. |br| raw:: html

   <br />

.. |gr| raw:: html

    <span style="color:#888;font-size:0.85em;font-weight: normal;">

.. |st| replace:: :sup:`st`
    
.. |nd| replace:: :sup:`nd`
.. |rd| replace:: :sup:`rd`
    

.. |subTitle| replace:: |br| |gr| |em|

.. |/subTitle| raw:: html

    </em></span>

.. |hr| raw:: html
    
    <hr style="height: 2px; width: 99%; background-color: #777; margin-top: 0;" />

.. |em| raw:: html
    
    <em>

.. |/em| raw:: html
    
    </em>

.. |dots| replace:: |em| more details |/em|

.. |c| raw:: html

    <span style="font-family:SFMono-Regular,Menlo,Monaco,Consolas,Liberation Mono,Courier New,Courier,monospace;font-size:0.9em;">

.. |/c| raw:: html

    </span>
    
.. |Camera| replace:: :ref:`Camera <The_Camera_class>`

.. |CGcamera| replace:: :ref:`CGcamera <The_CGcamera_class>`

.. |CrossGrating| replace:: :ref:`CrossGrating <The_CrossGrating_class>`

.. |Dipole| replace:: :ref:`Dipole <The_Dipole_class>`

.. |Illumination| replace:: :ref:`Illumination <The_Illumination_class>`

.. |ImageEM| replace:: :ref:`ImageEM <The_ImageEM_class>`

.. |ImageQLSI| replace:: :ref:`ImageQLSI <The_ImageQLSI_class>`

.. |Interfero| replace:: :ref:`Interfero <The_Interfero_class>`

.. |Microscope| replace:: :ref:`Microscope <The_Microscope_class>`

.. |Objective| replace:: :ref:`Objective <The_Objective_class>`

.. |RelayLens| replace:: :ref:`Relaylens <The_RelayLens_class>`


.. |importItfRef| replace:: |c| :ref:`importItfRef <The_importItfRef_function>` |/c|



.. |MI| replace:: :matlab:`MI`

.. |IM| replace:: :matlab:`IM`

.. |Im| replace:: :matlab:`Im`

.. |IL| replace:: :matlab:`IL`

.. |obj| replace:: :matlab:`obj`

.. |objList| replace:: :matlab:`objList`

.. |Itf| replace:: :matlab:`Itf`

.. |Ref| replace:: :matlab:`Ref`

"""



