clc
h5
h5create(fileh5,'/Option/lambda',[1 1])
h5write(fileh5,'/Option/lambda',632.8);         % wave vector

h5create(fileh5,'/Option/Mobj',[1 1])
h5write(fileh5,'/Option/Mobj',100);         % wave vector

h5create(fileh5,'/Option/NA',[1 1])
h5write(fileh5,'/Option/NA',1.3);         % wave vector

h5create(fileh5,'/Option/dxSize',[1 1])
h5write(fileh5,'/Option/dxSize',6.5e-6);         % wave vector

