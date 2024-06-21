function legend(numbers)
arguments
    numbers double
end

cellArray = arrayfun(@(x) {num2str(x)}, numbers);

legend(cellArray);