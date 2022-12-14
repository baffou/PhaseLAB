close all
clear all

namefileh5=input('Please give the name of an H5 file : ','s')
nexisth5 = exist(namefileh5,'file');

if (nexisth5 == 0);
disp('Data files do not exist!')
return;
end;

nim=input('donner le numero de l image : ');


icomp=complex(0,1);
ximage=h5read(namefileh5,'/Image/x Image');
kx=h5read(namefileh5,'/Image/kx Fourier');
nfft=h5read(namefileh5,'/Option/nfft2d');
k0=h5read(namefileh5,'/Option/k0');


imageneginc=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field modulus'));
imagenegincx(:,1)=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field x component real part'));
imagenegincx(:,2)=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field x component imaginary part'));
imagenegincy(:,1)=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field y component real part'));
imagenegincy(:,2)=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field y component imaginary part'));
imagenegincz(:,1)=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field z component real part'));
imagenegincz(:,2)=h5read(namefileh5,strcat('/Image/Image+incident',compose3(nim),'kz<0 field z component imaginary part'));


imageincm=reshape(imageneginc,nfft,nfft);
imageincx=reshape(imagenegincx(:,1)+icomp*imagenegincx(:,2),nfft,nfft);
imageincy=reshape(imagenegincy(:,1)+icomp*imagenegincy(:,2),nfft,nfft);
imageincz=reshape(imagenegincz(:,1)+icomp*imagenegincz(:,2),nfft,nfft);


figure(1)

subplot(2,2,1)

imagesc(ximage,ximage,imageincm)
colorbar
subplot(2,2,2)
imagesc(ximage,ximage,abs(imageincx))
colorbar
subplot(2,2,3)
imagesc(ximage,ximage,abs(imageincy))
colorbar
subplot(2,2,4)
imagesc(ximage,ximage,abs(imageincz))
colorbar

figure(2)

fourierincx=fftshift(fft2(imageincx));
fourierincy=fftshift(fft2(imageincy));

fourincm=(abs(fourierincx).^2+abs(fourierincy).^2);

imagesc(kx,kx,fourincm)
  colorbar
  axis square
  axis image




imageneg=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field modulus'));
imagenegx(:,1)=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field x component real part'));
imagenegx(:,2)=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field x component imaginary part'));
imagenegy(:,1)=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field y component real part'));
imagenegy(:,2)=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field y component imaginary part'));
imagenegz(:,1)=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field z component real part'));
imagenegz(:,2)=h5read(namefileh5,strcat('/Image/Image',compose3(nim),'kz<0 field z component imaginary part'));


imagem=reshape(imageneg,nfft,nfft);
imagex=reshape(imagenegx(:,1)+icomp*imagenegx(:,2),nfft,nfft);
imagey=reshape(imagenegy(:,1)+icomp*imagenegy(:,2),nfft,nfft);
imagez=reshape(imagenegz(:,1)+icomp*imagenegz(:,2),nfft,nfft);


figure(3)

subplot(2,2,1)

imagesc(ximage,ximage,imagem)
colorbar
subplot(2,2,2)
imagesc(ximage,ximage,abs(imagex))
colorbar
subplot(2,2,3)
imagesc(ximage,ximage,abs(imagey))
colorbar
subplot(2,2,4)
imagesc(ximage,ximage,abs(imagez))
colorbar

figure(4)

fourierx=fftshift(fft2(imagex));
fouriery=fftshift(fft2(imagey));

fourierm=(abs(fourierx).^2+abs(fouriery).^2);

imagesc(kx,kx,fourierm)
  colorbar
  axis image
axis([-1.5 1.5 -1.5 1.5])

xlabel('$k_x/k_0$','Interpreter','latex','Fontsize',18)
ylabel('$k_y/k_0$','Interpreter','latex','Fontsize',18)


