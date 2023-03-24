function phasemap=Pradeep(npx)
if nargin==0
    npx=1024;
end

jethsv=rgb2hsv(jet(npx));

jethsv(1:npx/2,2)=linspace(1,0,npx/2);
jethsv(npx/2+1:npx,2)=linspace(0,1,npx/2);

phasemap=hsv2rgb(jethsv);







