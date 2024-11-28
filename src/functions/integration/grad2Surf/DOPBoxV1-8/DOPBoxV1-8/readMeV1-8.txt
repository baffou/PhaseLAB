Diecrete Orthogonal Polynomials: Dopbox Version V1.8

July 2013

Introduction
------------
This a toolbox for Diecrete Orthogonal Polynomials called the DOPbox. 
Discrete orthogonal polynomials have many applications, such as: in discrete 
approximations; in the solution of ordinaty differential equations, in 
particular boundary value problems and initial value problems. For the 
generation of admissible functions etc.

Organization
------------
You will need to install all directories on you computer and set the matlab 
path to include the directories and their sub-directories.

The library is organized in three main directories:

1) DOPbox: This directory contains the files central to the library.
2) SupportFns: These are supporting fnctions which make the generation of 
   documentation simpler. They are used extensively in the examples and 
   documentation provied.
3) Documentation: this directory contains matlab and -pdf files which 
   document the use of the library functions.

Documentation
-------------
We recommend you start by looking at the GettingStarted.pdf documentation. This contains an example of the use of each and every function in the library.

None of the theory behind the library is explained in the documentation, the 
reader is referred to the following publications, should they wish to study 
the theoritical material:

This paper provied an introduction to the Gram polynomials

@inproceedings{
oleary2008b,
   Author = {O'Leary, P. and Harker, M.},
   Title = {An Algebraic Framework for Discrete Basis Functions in Computer Vision},
   BookTitle = {2008 $6^{\textrm{th}}$ ICVGIP},
   Address= {Bhubaneswar, India},
   Publisher = {IEEE},
   Pages = {150-157},
   Year = {2008} }

DOI: 10.1109/ICVGIP.2008.107

This paper introduced the concept of local and global polynomial approximations

@inproceedings{oleary2010C,
   Author = {O'Leary, P. and Harker, M.},
   Title = {Discrete Polynomial Moments and Savitzky-Golay Smoothing},
   BookTitle = {Waset Special Journal},
   Volume = {72},
   DOI = {},
   Pages = {439--443},
   Year = {2010}}

The PDF is available at 

www.waset.org/journals/waset/v48/v48-85.pdf

This paper provies extenside theory and deviations for the application of discrete 
orthogonal polynomials to the solution of inverse boundary value problems. 
The work is done the the bounds of an application in the monitoring of structures.
We highly recommend reading this paper if more advanced applications of the ideas are to be made.

@article{Oleary2012,
  author    = {Paul O'Leary and Matthew Harker},
  title     = {A Framework for the Evaluation of Inclinometer Data in the
               Measurement of Structures},
  journal   = {IEEE T. Instrumentation and Measurement},
  volume    = {61},
  number    = {5},
  year      = {2012},
  pages     = {1237-1251},
  ee        = {http://dx.doi.org/10.1109/TIM.2011.2180969}

http://dx.doi.org/10.1109/TIM.2011.2180969

Matthew harker and Paul O'Leary     July 2013

Changes
-------
Version V1.8

1) A code error in the function dopVal.m has been corrected


Version V1.7

1) A code error in dopDiffLocal was corrected. The function now works correctly with sparse matrices.

Version V1.6

1) A demonstration for constrained polynomials where the constraints are not at a node has been added.

2) A demonstration of a constraint located outside the range of the support has been added.

3) An example of using constrained basis functions as admissible functions in a discrete Rayligh-Ritz solution to a Sturm-Liouville equation has been added. This is an example where the constraints are located outside the range of the support.

4) The dopDiffLocal function has been modified to return a full differentiating matrix when the support length is equal to the number of points.

5) The rank of the differentiating matrix is tested and a warning is issued if the matrix is more than rank-1 deficient.

