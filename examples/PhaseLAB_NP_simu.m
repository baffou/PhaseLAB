%% Comparison Mie theory and GDT simulation for a gold nanosphere

clear
NPradius = 25e-9;
lambdaList = 500:25:800;
Nl = numel(lambdaList);

ME = Medium(1);
NP = Nanoparticle('Au', 'sphere',NPradius,'meshParam',5e-9);
DI = Dipole('Au',NPradius);

NP.figure
drawnow
NPs = Nanoparticle(Nl);
DIs = Dipole(Nl);
for il = 1:Nl
    printLoop(il,Nl)
    IL = Illumination(lambdaList(il));
    NPs(il) = NP.shine(IL);
    
    DIs(il) = DI.shine(IL);
    
end
%%

for il = 1:Nl
    alphaMie(il) = DIs(il).alphaMie(1);
    alphaNP(il) = NPs(il).alpha;
    CextMie(il) = DIs(il).CextMie;
    CscaMie(il) = DIs(il).CscaMie;
    CabsMie(il) = DIs(il).CabsMie;
    CextNP(il) = NPs(il).Cext;
    CscaNP(il) = NPs(il).Csca;
    CabsNP(il) = NPs(il).Cabs;
end


figure
subplot(1,4,1)
hold on
plot(alphaNP*1e21,'o-')
plot(alphaMie*1e21,'o-')
legend({"NP","Mie"})
subplot(1,4,2)
hold on
plot(lambdaList,CextMie*1e15,'o-')
plot(lambdaList,CextNP*1e15,'o-')
subplot(1,4,3)
hold on
plot(lambdaList,CscaMie*1e15,'o-')
plot(lambdaList,CscaNP*1e15,'o-')
subplot(1,4,4)
hold on
plot(lambdaList,CabsMie*1e15,'o-')
plot(lambdaList,CabsNP*1e15,'o-')
fullwidth


