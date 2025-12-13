function colorM = rainbow(Ncol)
arguments
    Ncol = 1024
end

colorM = colorScaleGenerator(["ffffff"; "000000"; "3c6b2d";"ffe700";"ff8000";"d21536";"ffffff";"3e49d3";"9a00c4";"e73a5f";"b4914e";"b3b44e";"000000"],[0 5 10:10:90 95 100],Ncol);