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

templates_path = ['_templates']


exclude_patterns = ['**/methods/*.rst','classes/CGcamera/methods/*']

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

#html_theme = 'alabaster'
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_favicon = 'images/favicon2.png'

html_css_files = ['custom.css']




rst_prolog = """
.. |PhaseLAB| replace:: **PhaseLAB**

.. role:: matlab(code)
    :language: matlab
    :class: highlight
  

.. |sub1| replace:: mine1
.. |sub2| replace:: mine2

.. |br| raw:: html

   <br />

.. |gr| raw:: html

    <span style="color:#888">


.. |subTitle| replace:: |br| |gr|

.. |/subTitle| raw:: html

    </span>

.. |hr| raw:: html
    
    <hr style="height: 2px; width: 99%; background-color: #777; margin-top: 0;" />



"""



