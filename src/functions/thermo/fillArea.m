function A=areaFilling2(A0)


[Nr,Nc]=size(A0);
A=A0;

for ir=1:Nr-2
    for ic=1:Nc-2
        P1.r=1+max(0,ir-Nc+ic+1);
        P1.c=1+min(ic+ir,Nc-1);
        P2.r=1+min(ic+ir,Nr-1);
        P2.c=1+max(0,ic-Nr+ir+1);
        d1=1/abs(1+ir-P1.r);
        d2=1/abs(1+ir-P2.r);
        A(1+ir,1+ic)=(d1*A0(P1.r,P1.c)+d2*A0(P2.r,P2.c))/(d1+d2);
    end
end
