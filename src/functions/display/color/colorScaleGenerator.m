function output = colorScaleGenerator(valTable,posTable,Ncolors)
arguments
    valTable % a vertical array of hex ("a34c88")  or 3-vectors ( [102, 87, 213] ).
    posTable (1,:) {mustBeNumeric(posTable),mustBeGreaterThanOrEqual(posTable,0)} % values between 0 and any max number, ideally 1 or 100.
    Ncolors = 1024 % number of colors in the output colorscale, 1024 by default
end

% output = colorScaleGenerator(valTable,posTable,Ncolors)
% valTable is the table of values, can be hex string array format (#A45b59), or Nx3 integer RVB format.
% postTable : values between 0 and 1 or 0 and 100
% Ncolors = 1024 by default

if isstring(valTable)
    Nval = numel(valTable);
    colorList=zeros(Nval,3);
    for ii = 1:Nval
        colorList(ii,:) = hex2rgb(valTable(ii));
    end
elseif isnumeric(valTable)
    Nval = size(valTable,1);
    colorList = valTable/255;
end

if nargin == 1
    posTable = round(linspace(0,1,Nval)*(Ncolors-1));
else
    if posTable(1)~=0
        warning("posTable(1) set to zero")
        posTable(1)=0;
    end
    posTable = round(posTable/max(posTable)*(Ncolors-1));
end

posTableInterp = 0:(Ncolors-1);


Rlist = interp1(posTable,colorList(:,1),posTableInterp);
Glist = interp1(posTable,colorList(:,2),posTableInterp);
Blist = interp1(posTable,colorList(:,3),posTableInterp);


output = [Rlist', Glist', Blist'];







