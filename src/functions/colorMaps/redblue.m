function phasemap=redblue(npx)
if nargin==0
    npx=1024;
end

phasemap=[...
1 0 0
1 1 1
0 0 1
];

len=size(phasemap,1);

a=interp1(1:len,phasemap(:,1),1:len/npx:len).';
b=interp1(1:len,phasemap(:,2),1:len/npx:len).';
c=interp1(1:len,phasemap(:,3),1:len/npx:len).';
phasemap=[a b c];




























