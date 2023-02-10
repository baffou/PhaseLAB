%clear 
Rrod=250e-9;
Hrod=1500e-9;

Lrod=(Hrod -2*Rrod)/2; % half length of the cylinder

eps0 = 1.33^2;
%epsRod= (1.38+0.1*1i)^2;
epsRod= (1.38)^2;

%da=65e-9; % for a 100x
da=97.5e-9/3;

nx=ceil(Hrod/(2*da));
ny=ceil(Rrod/da);
nz=floor(Rrod/da);
fprintf('Ncells=%d\n',(2*nx+1)*(2*ny+1)*(2*nz+1))
folder=pwd;
fileName=[folder '/bacteria1.5x0.5um_n1.38.txt'];
delete fileName
hf=fopen(fileName,'w');
fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,2*nz+1);
fprintf(hf,'%d\n',da*1e9);

zshift = -Rrod-da/2;
%figure
%hold on
for z=-nz:nz
    for y=-ny:ny
        for x=-nx:nx
            fprintf(hf,'%f %f %f\n',x*da*1e9,y*da*1e9,z*da*1e9+zshift*1e9);

            if y*y + z*z <= Rrod*Rrod/(da*da) % plot
                if abs(x) <= Lrod/da ...
                        || (x-Lrod/da)*(x-Lrod/da) + y*y + z*z <= Rrod*Rrod/(da*da) ...
                        || (x+Lrod/da)*(x+Lrod/da) + y*y + z*z <= Rrod*Rrod/(da*da) 
                    %scatter3(x*da*1e9,y*da*1e9,(z*da+zshift)*1e9)
                    %plotcube([1 1 1]*da,([x y z]-0.5)*da+[0 0 zshift],.5,[0.8 0.2 0.2]);
                end
            end

        end
    end
end
%view(40,35)
%set(gca,'DataAspectRatio',[1 1 1])
count=0;
for z=-nz:nz
    for y=-ny:ny
        for x=-nx:nx
            if y*y + z*z <= Rrod*Rrod/(da*da)
                if abs(x) <= Lrod/da ...
                        || (x-Lrod/da)*(x-Lrod/da) + y*y + z*z <= Rrod*Rrod/(da*da) ...
                        || (x+Lrod/da)*(x+Lrod/da) + y*y + z*z <= Rrod*Rrod/(da*da) 
                    fprintf(hf,'(%f, %f) \n',real(epsRod),imag(epsRod));
                    count=count+1;
                else
                    fprintf(hf,'(%f, %f) \n',real(eps0),imag(eps0));
                end
            else
                fprintf(hf,'(%f, 0) \n',eps0);
            end
        end
    end
end

fprintf('cell count: %d\n',count)

fprintf('cell optical volume: %d\n',count*da^3*(sqrt(epsRod)-sqrt(eps0)))
