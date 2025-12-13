function colMap = Sepia(Nval)
arguments
    Nval = 1024
end

colorList = ["ffffff";"d9d1a7";"b4913e";"805b28";"492d15";"000000"];
posList = [0, 12, 33, 50, 70, 100];

colMap = colorScaleGenerator(colorList,posList,Nval);




