c program that computes the Efield of a piece of graphene with 12
c illumination at various angle along a circle. Meant to be used to
c simulate phase contrast of SLIM images.



#ifdef USE_HDF5
      use HDF5
#endif
      implicit none
c     integer

      character(LEN=100) :: h5file
      character(64) h5loop

      integer ii,jj,kk,i,j,k,nstop
      integer  nlocal,nmacro,nsection,nforce ,nforced
     $     ,ntorque,ntorqued,nsens,nproche,nlecture,nquickdiffracte
     $     ,nrig,ncote,ndiffracte,ninterp,ir,nenergie,nmatf,ntypemic

c     variables for the object
      integer nbsphere3,nbsphere,ndipole,IP(3),test,numberobjetmax
     $     ,numberobjet,ng
      parameter (numberobjetmax=20)
      integer nx,ny,nz,nx2,ny2,nxy2,nz2,nxm,nym,nzm,ntotal,nxmp,nymp
     $     ,nzmp,nxym1,nzm1,nzms1
      integer subunit,nphi,ntheta
c     definition of the size for the code
      INTEGER nmax, ntotalm, nmaxpp
      character(2) polarizability
c     variables for the positions
      double precision rayon,side,sidex,sidey ,sidez,hauteur
     $     ,xgmulti(numberobjetmax) ,ygmulti(numberobjetmax)
     $     ,zgmulti(numberobjetmax) ,rayonmulti(numberobjetmax),demiaxea
     $     ,demiaxeb,demiaxec ,thetaobj,phiobj,psiobj,lc,hc,density,psi
      double precision aretecube,pxSize
      double precision pi,lambda,lambda0,lambda10n,k0,k03,epi,epr,c

c     variables for the material
      integer ierror,error
      double precision eps0
      double complex epsmulti(numberobjetmax)
     $     ,epsanimulti(numberobjetmax,3,3),chi2(27,numberobjetmax)
      character (64), DIMENSION(numberobjetmax) :: materiaumulti
      character(64) materiau,object,beam,namefileobj,namefileinc
     $     ,filereread
      character(3) trope

c     variables for the incident field and local field
      double precision forcexmulti(numberobjetmax)
     $     ,forceymulti(numberobjetmax),forcezmulti(numberobjetmax)
     $     ,torquexmulti(numberobjetmax),torqueymulti(numberobjetmax)
     $     ,torquezmulti(numberobjetmax)
      integer nbinc
      double precision ss,pp,theta,phi,phi0,I0,phim(10)
     $     ,thetam(10),ssm(10),ppm(10)
      double complex Eloc(3),Em(3),E0,uncomp,icomp,zzero,E0m(10)
      double complex propaesplibre(3,3)
      
      double complex , dimension (:,:,:),  allocatable :: sdetnn
      double complex , dimension (:),  allocatable :: FFprecon
      integer, dimension (:,:),  allocatable ::  ipvtnn

      integer nxyz8
      double complex , dimension (:),  allocatable :: FFTTENSORxx,
     $     FFTTENSORxy,FFTTENSORxz,FFTTENSORyy,FFTTENSORyz, FFTTENSORzz
     $     ,vectx,vecty,vectz

      
c     Green function
      integer indice,nmat,nbs,n1m,nmatim,nplanm,npoints

      integer neps,nepsmax
      parameter (nepsmax=8)
      double precision zcouche(0:nepsmax)
      double complex epscouche(0:nepsmax+1)
      double precision ncouche(0:nepsmax+1)
      character (64), DIMENSION(0:nepsmax+1) :: materiaucouche

      double precision forcet(3),forcem,forcemie
      double precision couplet(3),couplem
      double complex Eder(3,3)
      
c     computation of the cross section
      integer iphi,itheta
      double precision MIECEXT,MIECABS,MIECSCA ,GSCA,Cext,normal(3)
     $     ,deltatheta,deltaphi,Csca,Cscai,Cabs,gasym,thetas,phis
      double complex ctmp
      
c     variables for the iterative method
      INTEGER ldabi, nlar
      integer nnnr,ncompte
      integer NLIM,ndim,nou,maxit,nstat,nloop,STEPERR,nprecon,ninitest
      DOUBLE PRECISION  NORM,TOL,DZNRM2,norm1,norm2,tolinit,tol1
     $     ,tempsreelmvp,tempsreeltotal
      double complex ALPHA,BETA,GPETA,DZETA,R0RN

      
c     double complex wrk(*), xi(*), xr(*), b(*)
c     POINTER ( xr_p, xr ), ( b_p, b )
c     POINTER ( wrk_p, wrk ), ( xi_p, xi)

c     Poynting vector
      integer nr,nrmax,nw,nwmax
      double precision Poyntinginc

c     Info string
      character(64) infostr

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     nouvelle variable a passer en argument d'entree
c     power et diametre
      double precision P0,w0,xgaus,ygaus,zgaus,quatpieps0
      character(12) methodeit

c     nouvelle variable de sortie Irra     
      double precision irra,efficacite,efficaciteref,efficacitetrans
      

c     nouvelle variable
      integer nloin

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     Creation des nouvelles variables
      integer na

c     variable pour avoir l'image a travers la lentille
      integer nquicklens,nlentille,nobjet,nfft2d,nfft2d2,nonlinear
      integer npoynting

      double precision kx,ky,kz,deltakx,deltaky,numaperref,numapertra
     $     ,deltax,gross,numaperinc,numaperinc2,kcnax ,kcnay,zlensr
     $     ,zlenst

      integer :: ios
      integer, parameter :: read_unit = 99
      
      integer iloop,nmaxloop,imaxk0
      double precision epsObj_r, epsObj_i
      double complex epsObj
      
#ifndef USE_HDF5
      integer,parameter:: hid_t=4
#endif    
      integer(hid_t) :: file_id_loop
      integer(hid_t) :: group_idopt_loop,group_idim_loop
      integer :: dim(4)
      character(40) :: name
      character(LEN=100) :: datasetname
      character( 2 )  fil2
      character( 3 )  fil3
      character( 4 )  fil4
      
      double precision dimObj(10),xObj,yObj,zObj,zLens

c allocatable variables
      DOUBLE PRECISION, DIMENSION(:), allocatable :: 
     $     xs,ys,zs,xswf,yswf,zswf
      double complex, dimension(:,:,:),allocatable ::
     $ polarisa,epsilon
      DOUBLE PRECISION, DIMENSION(:),allocatable ::
     $ incidentfield,localfield,macroscopicfield,forcex,forcey,forcez, 
     $ torquex,torquey,torquez
      double complex, dimension(:),  allocatable ::
     $ macroscopicfieldx
      double complex, dimension(:),  allocatable ::
     $ macroscopicfieldy
      double complex, dimension(:),  allocatable ::
     $ macroscopicfieldz
      double complex, dimension(:),  allocatable ::
     $  localfieldx
      double complex, dimension(:),  allocatable :: 
     $ localfieldy
      double complex, dimension(:),  allocatable ::
     $  localfieldz
      double complex, dimension(:),  allocatable ::
     $  incidentfieldx
      double complex, dimension(:),  allocatable ::
     $  incidentfieldy
      double complex, dimension(:),  allocatable ::
     $  incidentfieldz
      double complex, dimension(:),allocatable ::
     $  FF,FF0,FFloc,FFnl
      double complex, dimension(:),  allocatable :: FFscal
      integer, dimension(:),         allocatable :: 
     $ Tabdip,Tabmulti,Tabzn
      double complex,dimension(:,:),         allocatable :: matrange
      integer, dimension(:,:),       allocatable :: matindice
      integer, dimension(:),         allocatable :: matind
      integer, dimension(:,:),             allocatable :: matindplan
      double complex, dimension(:,:,:),allocatable ::
     $ a11,a12,a13,a22,a23,a31,a32, a33
      double complex, dimension(:),    allocatable ::
     $ b11,b12,b13,b22,b23,b31,b32,b33
      double complex, dimension(:),allocatable :: b,xr,xi
      double complex, dimension(:,:),allocatable :: wrk




      DOUBLE PRECISION,DIMENSION(:),
     $ allocatable ::
     $     thetafield,phifield ,poyntingfield
     $     ,poyntingfieldpos ,poyntingfieldneg
      
      integer,dimension(:),allocatable :: tabfft2
      double precision,dimension(:),allocatable ::
     $ kxy,kxypoynting,xy
      double complex,dimension(:),allocatable ::
     $     Eimagexpos,Eimageypos
     $     ,Eimagezpos,Eimageincxpos
     $     ,Eimageincypos,Eimageinczpos
     $     ,Efourierxpos,Efourierypos
     $     ,Efourierzpos,Efourierincxpos
     $     ,Efourierincypos,Efourierinczpos,Eimagexneg,Eimageyneg
     $     ,Eimagezneg,Eimageincxneg
     $     ,Eimageincyneg,Eimageinczneg
     $     ,Efourierxneg,Efourieryneg
     $     ,Efourierzneg,Efourierincxneg
     $     ,Efourierincyneg,Efourierinczneg
      double complex,dimension(:,:),allocatable ::
     $ masque
      double complex,dimension(:,:,:),allocatable ::
     $ Ediffkzpos,Ediffkzneg

      
c     nxm=3
c     nym=3
c     nzm=3
c     nphi=72
c     ntheta=35
        
c     constant
      c=299792458.d0
      quatpieps0=1.d0/(c*c*1.d-7)
      pi=dacos(-1.d0)
      icomp=(0.d0,1.d0)




c  Importation de tous les paramètres
      open(unit=read_unit, file='paramList.txt', iostat=ios)
      if ( ios /= 0 ) stop "Error opening file data.dat"

c     nxm=63,nym=63,nzm=3,nphi=144,ntheta=72)
c     


      read(read_unit, *) nfft2d  !=512
      read(read_unit, *) nxm  !=63
      read(read_unit, *) nym  !=63
      read(read_unit, *) nzm  !=63
      read(read_unit, *) nmaxloop ! nombre de sources sur l'anneau
      read(read_unit, *) nphi  !=144
      read(read_unit, *) ntheta  !=72
      read(read_unit, *) lambda0  !=632.8d0       !wavelength
      read(read_unit, *) beam    !='pwavecircular'    !Circular plane wave
      read(read_unit, *) theta
      read(read_unit, *) phi0
      read(read_unit, *) pp
      read(read_unit, *) ss
      read(read_unit, *) object !='arbitrary' !Arbitrary object
      read(read_unit, *) namefileobj  ! ='graphene_Disc4.dat'
      read(read_unit, *) epsObj_r  ! real part of the permittivity of the material
      read(read_unit, *) epsObj_i  ! imag part of the permittivity of the material
      read(read_unit, *) pxSize  ! =65e-9
      read(read_unit, *) ncouche(0)  !=1.33d0
      read(read_unit, *) ncouche(1)  !=1.5d0
      read(read_unit, *) zlenst  !position of the objective in z (focus)
      read(read_unit, *) nlecture  !=0
      read(read_unit, *) numapertra   != 1.3d0
      read(read_unit, *) gross        !=100.d0      
      read(read_unit, *) h5loop       !='SLIM_graphene.h5'
      read(read_unit, *) xObj       !dimension of the object
      read(read_unit, *) yObj       !dimension of the object
      read(read_unit, *) zObj       !dimension of the object
      read(read_unit, *) dimObj(1)       !dimension of the object
      read(read_unit, *) dimObj(2)       !dimension of the object
      read(read_unit, *) dimObj(3)       !dimension of the object
      read(read_unit, *) nrig       !IFDDA algorithm for near-field calculation, 0 or 7 (rigourous or approx.)
      close(read_unit)

      n1m=max(nxm,nym)
      nmatim = min(nxm,nym) *(2*max(nxm,nym)-min(nxm,nym)+1)/2
      nplanm=nzm*(nzm+1)/2
      ntotalm=4*nxm*nym
      nbs=nzm*(nzm+1)*nmatim/2
      npoints=max((ntheta+1)*nphi,nfft2d*nfft2d)
      epsObj = epsObj_r*(1.d0,0.d0)+epsObj_i*(0.d0,1.d0)
      nlar=12

c ***************************************
c Allocation
c ***************************************
c allocate(sdetnn(nzms1,nzms1,nxym1))
      
      allocate(xs(nxm*nym*nzm),ys(nxm*nym*nzm),zs(nxm*nym*nzm),
     $ xswf(nxm*nym*nzm),yswf(nxm*nym*nzm),zswf(nxm*nym*nzm))
      allocate(polarisa(nxm*nym*nzm,3,3),epsilon(nxm*nym*nzm,3,3))
      allocate(incidentfield(nxm*nym*nzm),localfield(nxm*nym*nzm),
     $ macroscopicfield(nxm*nym*nzm),forcex(nxm*nym*nzm),
     $ forcey(nxm*nym*nzm),forcez(nxm*nym*nzm),torquex(nxm*nym*nzm),
     $ torquey(nxm*nym*nzm),torquez(nxm*nym*nzm))
      allocate(macroscopicfieldx(nxm*nym*nzm),
     $ macroscopicfieldy(nxm*nym*nzm),
     $ macroscopicfieldz(nxm*nym*nzm),
     $ localfieldx(nxm*nym*nzm),
     $ localfieldy(nxm*nym*nzm),
     $ localfieldz(nxm*nym*nzm),
     $ incidentfieldx(nxm*nym*nzm),
     $ incidentfieldy(nxm*nym*nzm),
     $ incidentfieldz(nxm*nym*nzm))
      allocate(FF(3*nxm*nym*nzm),FF0(3*nxm*nym*nzm),
     $ FFloc(3*nxm*nym*nzm),FFnl(3*nxm*nym*nzm))
      allocate( FFscal(nxm*nym*nzm),
     $ Tabdip(nxm*nym*nzm),Tabmulti(nxm*nym*nzm),Tabzn(nxm*nym*nzm))
      allocate(matrange(nbs,5))
      allocate(matindice(nplanm,nmatim),matind(0:2*n1m*n1m),
     $ matindplan(nzm,nzm),
     $ a11(2*nxm,2*nym,nplanm),a12(2*nxm,2*nym,nplanm),
     $ a13(2*nxm,2*nym,nplanm),a22(2*nxm,2*nym,nplanm),
     $ a23(2*nxm,2*nym,nplanm),a31(2*nxm,2*nym,nplanm),
     $ a32(2*nxm,2*nym,nplanm), a33(2*nxm,2*nym,nplanm),
     $ b11(4*nxm*nym),b12(4*nxm*nym),b13(4*nxm*nym),b22(4*nxm*nym),
     $ b23(4*nxm*nym),b31(4 *nxm*nym),b32(4*nxm*nym),b33(4*nxm*nym))
      allocate(b(3*nxm*nym*nzm),xr(3*nxm*nym*nzm),xi(3*nxm*nym*nzm))
      allocate(wrk(3*nxm*nym*nzm,nlar))



      allocate(thetafield(npoints),phifield(npoints),
     $ poyntingfield(npoints),
     $ poyntingfieldpos(npoints) ,poyntingfieldneg(npoints))
      
      allocate(tabfft2(nfft2d))
      allocate(kxy(nfft2d),kxypoynting(nfft2d),xy(nfft2d))
      allocate(Eimagexpos(nfft2d*nfft2d),Eimageypos(nfft2d*nfft2d)
     $     ,Eimagezpos(nfft2d*nfft2d),Eimageincxpos(nfft2d*nfft2d)
     $     ,Eimageincypos(nfft2d*nfft2d),Eimageinczpos(nfft2d*nfft2d)
     $     ,Efourierxpos(nfft2d*nfft2d),Efourierypos(nfft2d*nfft2d)
     $     ,Efourierzpos(nfft2d*nfft2d),Efourierincxpos(nfft2d*nfft2d)
     $     ,Efourierincypos(nfft2d*nfft2d),Efourierinczpos(nfft2d
     $     *nfft2d),Eimagexneg(nfft2d*nfft2d),Eimageyneg(nfft2d*nfft2d)
     $     ,Eimagezneg(nfft2d*nfft2d),Eimageincxneg(nfft2d*nfft2d)
     $     ,Eimageincyneg(nfft2d*nfft2d),Eimageinczneg(nfft2d*nfft2d)
     $     ,Efourierxneg(nfft2d*nfft2d),Efourieryneg(nfft2d*nfft2d)
     $     ,Efourierzneg(nfft2d*nfft2d),Efourierincxneg(nfft2d*nfft2d),
     $     Efourierincyneg(nfft2d*nfft2d),
     $     Efourierinczneg(nfft2d*nfft2d),masque(nfft2d,nfft2d),
     $     Ediffkzpos(nfft2d,nfft2d,3),Ediffkzneg(nfft2d,nfft2d,3))



   






c     parametre de la boucle
c     nmaxloop=12  ! nombre de sources sur l'anneau
      call hdf5create(trim(h5loop), file_id_loop)
      call h5gcreate_f(file_id_loop,"Option", group_idopt_loop, error)
      call h5gcreate_f(file_id_loop,"Image", group_idim_loop, error)
      
      
      
  
c********************************************************
c     Define the polarizability
c********************************************************

c     polarizability='CM'  !Clausius Mossotti
      polarizability='RR'  !Clausius Mossotti with radiative reaction
c     polarizability='LA'  !Polarizability defines by Lakthakia
c     polarizability='LR'  !Polarizability defines by Draine
c     polarizability='GB'  !Polarizability with first Mie coefficient
c     polarizability='PS'  !Polarizability for a sphere with local correction
c********************************************************
c     End polarizability
c********************************************************
      

c     effectue la boucle ici
      do iloop=1,nmaxloop


c  Importation de tous les paramètres
      open(unit=read_unit, file='paramList.txt', iostat=ios)
      if ( ios /= 0 ) stop "Error opening file data.dat"

c     nxm=63,nym=63,nzm=3,nphi=144,ntheta=72)
c     


      read(read_unit, *) nfft2d  !=512
      read(read_unit, *) nxm  !=63
      read(read_unit, *) nym  !=63
      read(read_unit, *) nzm  !=63
      read(read_unit, *) nmaxloop ! nombre de sources sur l'anneau
      read(read_unit, *) nphi  !=144
      read(read_unit, *) ntheta  !=72
      read(read_unit, *) lambda0  !=632.8d0       !wavelength
      read(read_unit, *) beam    !='pwavecircular'    !Circular plane wave
      read(read_unit, *) theta
      read(read_unit, *) phi0
      read(read_unit, *) pp
      read(read_unit, *) ss
      read(read_unit, *) object !='arbitrary' !Arbitrary object
      read(read_unit, *) namefileobj  ! ='graphene_Disc4.dat'
      read(read_unit, *) epsObj_r  ! real part of the permittivity of the material
      read(read_unit, *) epsObj_i  ! imap part of the permittivity of the material
      read(read_unit, *) pxSize  ! =65e-9
      read(read_unit, *) ncouche(0)  !=1.33d0
      read(read_unit, *) ncouche(1)  !=1.5d0
      read(read_unit, *) zlenst  !position of the objective in z (focus)
      read(read_unit, *) nlecture  !=0
      read(read_unit, *) numapertra   != 1.3d0
      read(read_unit, *) gross        !=100.d0      
      read(read_unit, *) h5loop       !='SLIM_graphene.h5'
      read(read_unit, *) xObj       !dimension of the object
      read(read_unit, *) yObj       !dimension of the object
      read(read_unit, *) zObj       !dimension of the object
      read(read_unit, *) dimObj(1)       !dimension of the object
      read(read_unit, *) dimObj(2)       !dimension of the object
      read(read_unit, *) dimObj(3)       !dimension of the object
      close(read_unit)

      epscouche(0)=ncouche(0)**2.d0
      epscouche(1)=ncouche(1)**2.d0



      lambda=lambda0   ! re-establish the proper value of lambda after
                       ! cdmlibsurf( modifies it
c     DATA INPUT
c     lambda=632.8d0       !wavelength
      P0=1.d0              !power    
      w0=lambda*10.d0      !waist

c*******************************************************
c     Define the incident wave
c*******************************************************
c     beam='gwavelinear'      !Linear Gaussian wave
c     beam='gwavecircular'    !Circular Gaussian wave
c     beam='pwavelinear'      !Linear plane wave
c     beam='pwavecircular'    !Circular plane wave
c     beam='wavelinearmulti'  !Multiple linear plane wave
c     beam='gwaveiso'         !Iso focus wave
c     beam='speckle'          !Specke wave
c     beam='arbitrary'        !Arbitrary wave defines by the user
      
      if (beam(1:11).eq.'pwavelinear') then
c        theta=30.d0
         phi=phi0+180.d0*dble(iloop-1)/dble(nmaxloop)*2.d0
c        pp=0.d0
c        ss=1.d0
      elseif (beam(1:13).eq.'pwavecircular') then
c        theta=30.d0
         phi=phi0+180.d0*dble(iloop-1)/dble(nmaxloop)*2.d0
c        ss=1.d0 
      elseif (beam(1:11).eq.'gwavelinear') then
c        theta=0.d0
         phi=phi0+180.d0*dble(iloop-1)/dble(nmaxloop)*2.d0
         psi=0.d0      
         xgaus=0.d0
         ygaus=0.d0
         zgaus=0.d0
         pp=psi
      elseif (beam(1:11).eq.'gwavecircular') then
c        theta=0.d0
         phi=phi0+180.d0*dble(iloop-1)/dble(nmaxloop)*2.d0   
c        ss=0.d0
         xgaus=0.d0
         ygaus=0.d0
         zgaus=0.d0
      elseif (beam(1:7).eq.'speckle') then        
c        pp=1.d0
c        ss=0.d0
         xgaus=0.d0
         ygaus=0.d0
         zgaus=0.d0
         ir=0
      elseif (beam(1:16).eq.'wavelinearmulti') then        
         nbinc=2
         ppm(1)=0.5d0
         ppm(2)=0.5d0
         ssm(1)=1.d0
         ssm(2)=1.d0
         thetam(1)=65.287098590488455d0
         thetam(2)=-65.287098590488455d0
         phim(1)=0.d0
         phim(2)=0.d0
         E0m(1)=(1.d0,0.d0)*cdexp(-icomp*4.d0*pi/3.d0)
         E0m(2)=(1.d0,0.d0)*cdexp(icomp*4.d0*pi/3.d0)
      elseif (beam(1:9).eq.'arbitrary') then
         namefileinc='incarbitrary.in'
         open(15,file=namefileinc,status='old',iostat=ierror)
         if (ierror.ne.0) then
            write(*,*) 'bad namefile for arbitrary'
            stop
         endif
         read(15,*) nx,ny,nz
         read(15,*) aretecube
         rewind(15)
         close(15)

         if (nx.gt.nxm.or.ny.gt.nym.or.nz.gt.nzm) then
            write(*,*) 'Size of the table too small'
            stop
         endif
         
      endif
c*******************************************************
c     End incident wave
c*******************************************************

      
c*******************************************************
c     Define the object
c*******************************************************
c     object='sphere'               !Sphere
c     object='inhomosphere'         !Inhomogeneous sphere
c     object='cube'                 !Cube
c     object='cuboid1'              !Cuboid with side given
c     object='cuboid2'              !Cuboid with nx,ny,nz,aretecube given
c     object='inhomocuboid1'        !Inhomogeneous cuboid with side given
c     object='inhomocuboid2'        !Inhomogeneous cuboid with nx,ny,nz,aretecube given
c     object='ellipsoid'            !Ellipsoid
c     object='nspheres'             !Multiple spheres with same radius
c     object='cylinder'             !Cylinder
c     object='concentricsphere'     !Concentric sphere    
c     object='arbitrary'            !Arbitrary object

      thetaobj=0.d0
      phiobj=0.d0
      psiobj=0.d0


      if (object(1:6).eq.'sphere') then
         numberobjet=1
c        pxSize=20.d0
         rayonmulti(1)=dimObj(1)/2       
         xgmulti(1)=xObj
         ygmulti(1)=yObj
         zgmulti(1)=zObj
         materiaumulti(1)='xx'
         nnnr=aint(2.d0*rayonmulti(1)/pxSize)
         rayonmulti(1) = nnnr*pxSize/2.d0 !readjustement of the size of the object to make sure the atual pxSize is not changed by the aint
         epsmulti(1)=epsObj
      elseif (object(1:4).eq.'cube') then
         numberobjet=1
         side=dimObj(1)
         xgmulti(1)=xObj
         ygmulti(1)=yObj
         zgmulti(1)=zObj
         materiaumulti(1)='xx'
         nnnr=aint(side/pxSize)
         epsmulti(1)=epsObj
      elseif (object(1:6).eq.'cuboid') then
         object='cuboid1'
         numberobjet=1
         sidex=dimObj(1)
         sidey=dimObj(2)
         sidez=dimObj(3)
         xgmulti(1)=xObj
         ygmulti(1)=yObj
         zgmulti(1)=zObj
         materiaumulti(1)='xx'
         nnnr=aint(maxval(dimObj)/pxSize)
         epsmulti(1)=epsObj
      elseif (object(1:8).eq.'nspheres') then
         numberobjet=3
         xgmulti(1)=0.d0
         ygmulti(1)=0.d0
         zgmulti(1)=300.d0
         rayonmulti(1)=1500.d0
         epsmulti(1)=(1.3d0,0.d0)
         materiaumulti(1)='xx'
         xgmulti(2)=2500.d0
         ygmulti(2)=2500.d0
         zgmulti(2)=300.d0
         rayonmulti(2)=400.d0
         epsmulti(2)=(1.1d0,0.d0)
         materiaumulti(2)='xx'
         xgmulti(3)=-2500.d0
         ygmulti(3)=-2500.d0
         zgmulti(3)=300.d0
         rayonmulti(3)=400.d0
         epsmulti(3)=(1.1d0,0.d0)
         materiaumulti(3)='xx'
         nnnr=50
      elseif (object(1:9).eq.'ellipsoid') then
         demiaxea=dimObj(1)/2
         demiaxeb=dimObj(2)/2
         demiaxec=dimObj(3)/2
         xgmulti(1)=xObj
         ygmulti(1)=yObj
         zgmulti(1)=zObj
         nnnr=aint(dimObj(1)/pxSize)
         epsmulti(1)=epsObj
      elseif (object(1:8).eq.'cylinder') then
         rayonmulti(1)=dimObj(1)
         hauteur=dimObj(3)
         xgmulti(1)=xObj
         ygmulti(1)=yObj
         zgmulti(1)=zObj
         nnnr=aint(dimObj(1)/pxSize)
         epsmulti(1)=epsObj
      elseif (object(1:16).eq.'concentricsphere') then
         numberobjet=2      
         rayonmulti(1)=10.d0
         epsmulti(1)=(2.25d0,0.d0)
         xgmulti(1)=0.d0
         ygmulti(1)=0.d0
         zgmulti(1)=0.d0
         rayonmulti(2)=20.d0
         epsmulti(2)=(1.25d0,0.d0)        
         nnnr=10
         materiaumulti(1)='xx'
         materiaumulti(2)='xx'
      elseif (object(1:9).eq.'arbitrary') then
c        namefileobj='graphene_Disc4.dat'
         numberobjet=1
         materiaumulti(1)='xx'
         epsmulti(1)=epsObj
         materiaumulti(1)='xx'
      endif
c*******************************************************
c     End object
c*******************************************************
      
c*******************************************************
c     Define if object is isotropic or not
c*******************************************************
      trope='iso'
c     trope='ani'


c*******************************************************
c     Define the iterative method used
c*******************************************************
      methodeit='GPBICG1'      
c     methodeit='GPBICG2'
c     methodeit='GPBICGplus'
c     methodeit='GPBICGsafe'          
c     methodeit='GPBICGAR'    
c     methodeit='GPBICGAR2'
c     methodeit='BICGSTARPLUS'
c     methodeit='GPBICOR'
c     methodeit='CORS'
c     methodeit='QMRCLA'          
c     methodeit='TFQMR'       
c     methodeit='CG'           
c     methodeit='BICGSTAB'    
c     methodeit='QMRBICGSTAB1' 
c     methodeit='QMRBICGSTAB2' 


c     Define the tolerance of the iterative method
      tolinit=1.d-3
      nlim=1000
      nprecon=0
      ninitest=1
      if (nprecon.eq.0) then
         nxym1=1
         nzm1=1
         nzms1=1
      else
         if (nrig.eq.0.or.nrig.eq.5.or.nrig.eq.6) then
            nxym1=nxm*nym
            nzm1=nzm
            nzms1=3*nzm
         else
            nxym1=nxm*nym
            nzm1=nzm
            nzms1=nzm
         endif
      endif
      allocate(sdetnn(nzms1,nzms1,nxym1))
      allocate(FFprecon(3*nxym1*nzm1))
      allocate(ipvtnn(nzms1,nxym1))

      if (nrig.eq.5.or.nrig.eq.6) then
         nxyz8=8*nxm*nym*nzm
      else
         nxyz8=1
      endif
      allocate(FFTTENSORxx(nxyz8))
      allocate(FFTTENSORxy(nxyz8))
      allocate(FFTTENSORxz(nxyz8))
      allocate(FFTTENSORyy(nxyz8))
      allocate(FFTTENSORyz(nxyz8))
      allocate(FFTTENSORzz(nxyz8))
      allocate(vectx(nxyz8))
      allocate(vecty(nxyz8))
      allocate(vectz(nxyz8))
      
c*******************************************************
c     End iterative method used
c*******************************************************

c*******************************************************
c     Define the multilayer
c*******************************************************
c     example for neps=1
c     epscouche(2)
c     ---------------------------- ZCOUCHE(1)
c     epscouche(1)
c     -----------------------------ZCOUCHE(0)
c     epscouche(0)
c*******************************************************
      neps=0
c     epscouche(0)=1.d0
c     epscouche(1)=2.25d0
      zcouche(0)=0.d0
      materiaucouche(0)='xx'
      materiaucouche(1)='xx'
c*******************************************************
c     End multilayer
c*******************************************************
      
c*******************************************************
c     define all the options
c*******************************************************
      nobjet=0                  ! 1 compute only the position of the dipole, all the other options are disabled.
      
c     nproche adjust the size of near field domain. Near field (0)
c     inside the object, (1) inside a cuboid which contains the object,
c     (2) inside the boxnx+2*nxmp,ny+2*nymp,nz+2*nzmp
      nproche=0
      
      nxmp=0                    ! if nproche=2 used then the addsize along x : nx+2*nxmp
      nymp=0                    ! if nproche=2 used then the addsize along y : ny+2*nymp
      nzmp=0                    ! if nproche=2 used then the addsize along z : nz+2*nzmp
      nlocal=0                  ! 0 do not compute the local field, 1 compute the local field
      nmacro=0                  ! 0 do not compute the macroscopic field, 1 compute the macroscopic field

c     1 reread or create a file which contains the local field at each
c     position. Avoid to compute again the local field if the
c     configuration is the same, i.e. keep the same local field.
c     nlecture=0               
      filereread='toto'         ! name fo the file if reread the local field.

c     nrig adjust the ways used to compute the near field. (0) compute
c     rigorously the near field in solving the near field equation, (1)
c     use renormalized Born approximation, (2) use Born approximation,
c     (3) use Born series at order 1.
c     nrig=0

c     ninterp =0 compute rigourosly the Green tensor, ninterp=n compute
c     the Green tensor at the position d/n and interpolate for get the
c     Green tensor at any position.
      ninterp=2      

c     nforce=1 ! calcul la force exercee par la lumiere sur l'objet.
c     nforced=1 ! calcul la densite de force dans l'objet.
c     ntorque=1 ! calcul le couple exerce par la lumiere sur l'objet.
c     ntorqued=1 ! calcul la desnite de couple dans l'objet l'objet.
      
      nsection=0                ! 0 do not compute the cross section, 1 compute the cross section. Possible only in homogeneous space.
      ncote=1                   ! 1 compute both side for the diffracted field and lens, 0 only below (z<0), 2 only above (z>0).
      ndiffracte=1              ! 0 do not compute the diffracted far field, 1 compute the diffracted far field.
      nquickdiffracte=1         ! 0 compute far field classically, 1 compute far field with FFT.      
      nlentille=1               ! Compute microscopy.
      nquicklens=1              ! Compute microscopy with FFT (1) or wihtout FFT (0).      
      numaperref= 0.9d0         ! Numerical aperture for the microscope in reflexion.
c     numapertra= 1.3d0         ! Numerical aperture for the microscope in transmission.      
      zlensr=0.d0               ! Position of lens in reflexion.
c     zlenst=0               ! Position of lens in transmission.
      ntypemic=0                ! Type of microscope: O Holographic, 1 Bright field, 2, dark field, 3 schieren, 4 Dark field cone, 5 experimental
c     gross=100.d0              ! Manyfing factor for the microscope
      numaperinc=0.d0          ! Numerical aperture for the condenser lens.
      numaperinc2=0.d0          ! Central aperture for the condenser lens.
      kcnax=0.d0                ! Position of the aperture x.
      kcnay=0.d0                ! Position of the aperture y.
      nenergie=0                ! 0 Do not compute energy, 1 compute energy conservation.

      nmatf=1                   ! 1 Do not save the data, 0 save the data in mat file, 2 save the data in one hdf5 file.
c     h5file='ifdda.h5'         ! name of the hdf5 file
     

c*******************************************************
c     End options
c*******************************************************
      

c     compute size when meshsize is given
      if (object(1:13).eq.'inhomocuboid2'.or.object(1:7).eq.'cuboid2')
     $     then
         nx=nxm-2*nxmp
         ny=nym-2*nymp
         nz=nzm-2*nzmp
      else
         if (nx+2*nxmp.gt.nxm) then
            write(*,*) 'pb with size: increase nxm'
            stop
         endif
         if (ny+2*nymp.gt.nym) then
            write(*,*) 'pb with size: increase nym'
            stop
         endif
         if (nz+2*nzmp.gt.nzm) then
            write(*,*) 'pb with size: increase nzm'
            stop
         endif
      endif
      
c*******************************************************
c     Call the routine cdmlibsurf
c*******************************************************

      call cdmlibsurf(
c     input file cdm.in
     $     lambda,beam,object,trope,
     $     materiaumulti,nnnr,tolinit,nlim,methodeit,polarizability,
     $     nprecon,ninitest,nlecture,filereread,nmatf,h5file,
C     Definition du multicouche
     $     neps,zcouche,epscouche,materiaucouche,
c     output file cdm.out
     $     nlocal,nmacro,ncote,nsection,ndiffracte,nquickdiffracte,nrig,
     $     ninterp,nforce,nforced,ntorque,ntorqued,nproche,
     $     nlentille,nquicklens,nenergie,nobjet,nonlinear,
c     cube, sphere (includes multiple)
     $     density,side, sidex, sidey, sidez, hauteur,
     $     numberobjet, rayonmulti, xgmulti, ygmulti, zgmulti,
     $     epsmulti, epsanimulti,chi2,lc,hc,ng,
c     ellipsoid+arbitrary
     $     demiaxea,demiaxeb,demiaxec,thetaobj,phiobj,psiobj,
     $     namefileobj,
c     planewavecircular.in / planewavelinear.in files
     $     theta, phi,pp,ss,ir,P0,w0,xgaus,ygaus,zgaus,namefileinc,
     $     thetam,phim,ppm,ssm,E0m,nbinc,
c     return info stringf
     $     infostr, nstop,
c     return scalar results
     $     nbsphere, ndipole, aretecube,
     $     lambda10n,k0,tol1,tempsreelmvp,tempsreeltotal,ncompte,nloop,
     $     efficacite,efficaciteref,efficacitetrans,
     $     Cext,Cabs,Csca,Cscai,gasym,irra, E0,
     $     forcet, forcem,
     $     couplet, couplem,
     $     nxm, nym, nzm, nxmp, nymp, nzmp, nmaxpp, nxym1, nzm1, nzms1,
     $     nxyz8,
     $     incidentfield, localfield, macroscopicfield,
     $     xs, ys, zs, xswf, yswf, zswf,
     $     ntheta, nphi, thetafield,phifield,poyntingfield,
     $     kxypoynting,poyntingfieldpos, poyntingfieldneg, 
     $     forcex,forcey,forcez,forcexmulti,forceymulti,forcezmulti,
     $     torquex,torquey,torquez,torquexmulti,torqueymulti,
     $     torquezmulti,
     $     incidentfieldx, incidentfieldy,incidentfieldz,
     $     localfieldx, localfieldy, localfieldz,
     $     macroscopicfieldx, macroscopicfieldy, macroscopicfieldz,
     $     polarisa,epsilon,
     $     nfft2d,npoynting,Eimagexpos,Eimageypos,Eimagezpos,
     $     Eimageincxpos,Eimageincypos,Eimageinczpos,
     $     Efourierxpos, Efourierypos,Efourierzpos,
     $     Efourierincxpos,Efourierincypos, Efourierinczpos,
     $     Eimagexneg,Eimageyneg,Eimagezneg,
     $     Eimageincxneg,Eimageincyneg,Eimageinczneg,
     $     Efourierxneg,Efourieryneg,Efourierzneg,
     $     Efourierincxneg,Efourierincyneg,Efourierinczneg,masque,
     $     kxy,xy,numaperref,numapertra,numaperinc,numaperinc2,kcnax
     $     ,kcnay,gross,zlensr,zlenst,ntypemic,
c     passe certains arguments pour le dimensionnement
     $     n1m,nmatim,nplanm,nbs,
c     fonction de green de la surface
c     matrange(nbs,5),matindice(nplanm,nmatim),matind(0:2*n1m*n1m)
c     ,matindplan(nzm,nzm)
     $     matrange,matindice,matindplan,matind,
c     a11,a12,a13,a22,a23,a31,a32,a33(2*nxm,2*nym,nplanm)nplanm=nzm*(nzm+1)/2
     $     a11,a12,a13,a22,a23,a31,a32,a33,
     $     b11,b12,b13,b22,b23,b31,b32,b33,
c     taille double complex (3*nxm*nym*nzm)
     $     FF,FF0,FFloc,xr,xi,FFprecon,FFnl,
c     tableau pour preconditionnem
     $     Sdetnn, ipvtnn,
c     taille double complex (3*nxm*nym*nzm,12)
     $     wrk,nlar,
c     taille double complex (8*nxm*nym*nzm)
     $     FFTTENSORxx, FFTTENSORxy,FFTTENSORxz,FFTTENSORyy,FFTTENSORyz,
     $     FFTTENSORzz,vectx,vecty,vectz,  
c     taille double complex (nfft2d,nfft2d,3)
     $     Ediffkzpos,Ediffkzneg, FFscal,     
c     taille entier (nxm*nym*nzm)
     $     Tabdip,Tabmulti,Tabzn,Tabfft2)

      deallocate(sdetnn)
      deallocate(FFprecon)
      deallocate(ipvtnn)

      deallocate(FFTTENSORxx)
      deallocate(FFTTENSORxy)
      deallocate(FFTTENSORxz)
      deallocate(FFTTENSORyy)
      deallocate(FFTTENSORyz)
      deallocate(FFTTENSORzz)
      deallocate(vectx)
      deallocate(vecty)
      deallocate(vectz)

      
      if (nstop.eq.0) then
         write(*,*) '***********************************************'
         write(*,*) 'Computation finished without problem:'
         write(*,*) '***********************************************'
      else
         write(*,*) '***********************************************'
         write(*,*) '! ! ! ! PROBLEM ! ! ! !'
         write(*,*) infostr
         write(*,*) '***********************************************'
      endif

c     save the file
      call integer_string3(iloop,fil3)
      k=0
      imaxk0=0
      name='Image'//fil3//'kz>0'
      call writehdf5mic(Eimagexpos,Eimageypos,Eimagezpos,nfft2d ,imaxk0
     $     ,Ediffkzpos,k,name,group_idim_loop)
      name='Image+incident'//fil3//'kz>0'
      call writehdf5mic(Eimageincxpos,Eimageincypos ,Eimageinczpos
     $     ,nfft2d,imaxk0,Ediffkzpos,k,name ,group_idim_loop)


      if (iloop.eq.1) then
         dim(1)=1
         dim(2)=1
         datasetname='Npx'
         call hdf5write1d_int(group_idopt_loop,datasetname,nfft2d,dim)  

         datasetname='lambda'
         call hdf5write(group_idopt_loop,datasetname,lambda,dim)
         
         datasetname='P0'
         call hdf5write(group_idopt_loop,datasetname,P0,dim)
         
         datasetname='w0'
         call hdf5write(group_idopt_loop,datasetname,w0,dim)
         
         datasetname='ndipole'
         call hdf5write1d_int(group_idopt_loop,datasetname,ndipole,dim)
         
         datasetname='aretecube'
         call hdf5write(group_idopt_loop,datasetname,aretecube,dim)
         datasetname='epsmax'

         call hdf5write(group_idopt_loop,datasetname,
     $   maxval(dreal(epsilon)),dim)

         datasetname='epsmin'
         call hdf5write(group_idopt_loop,datasetname,
     $   dreal(epscouche(0)),dim)

         datasetname='NA'
         call hdf5write(group_idopt_loop,datasetname,numapertra,dim)

         datasetname='M'
         call hdf5write(group_idopt_loop,datasetname,gross,dim)


         dim(1)=nfft2d
         dim(2)=nfft2d
         datasetname='x Image'
         call hdf5write1d(group_idim_loop,datasetname,xy,dim)
         datasetname='y Image'
         call hdf5write1d(group_idim_loop,datasetname,xy,dim)
         datasetname='kx Fourier'
         call hdf5write1d(group_idim_loop,datasetname,kxy,dim)
      endif

      
c     fin de la boucle
      enddo
      write(*,*) error
      write(*,*) group_idopt_loop


      CALL h5gclose_f(group_idopt_loop,error) 
      CALL h5gclose_f(group_idim_loop,error) 

      call hdf5close(file_id_loop)
      end
c**********************************************************
c**********************************************************
c**********************************************************
      subroutine integer_string4(i,fil)
      implicit none
      integer i,j
      character*4 fil
C     
      write(fil,100) i
      do j=1,4
         if (fil(j:j).eq.' ') then
            fil(j:j)='0'
         endif
      enddo
 100  format(i4)
      return
      end
c**********************************************************
c**********************************************************
c**********************************************************
      subroutine integer_string2(i,fil)
      implicit none
      integer i,j
      character*2 fil
C     
      write(fil,100) i
      do j=1,2
         if (fil(j:j).eq.' ') then
            fil(j:j)='0'
         endif
      enddo
 100  format(i2)
      return
      end
c**********************************************************
c**********************************************************
c**********************************************************
      subroutine integer_string3(i,fil)
      implicit none
      integer i,j
      character*3 fil
C     
      write(fil,100) i
      do j=1,3
         if (fil(j:j).eq.' ') then
            fil(j:j)='0'
         endif
      enddo
 100  format(i3)
      return
      end
