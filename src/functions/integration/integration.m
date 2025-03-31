function W = integration (DWx, DWy,pxSize)
arguments
    DWx
    DWy
    pxSize = 1
end

N = 13;
Tikh = 1e-5;

x = (1:size(DWx,2))';
y = (1:size(DWy,1))';
S = g2sTikhonovRTalpha(x,y,N);
W = g2sTikhonovRT(DWx,DWy,S,Tikh)*pxSize;
