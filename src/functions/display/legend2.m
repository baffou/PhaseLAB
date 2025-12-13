function legend2(numbers)
if isnumeric(numbers)
    cellArray = arrayfun(@(x) {num2str(x)}, numbers);
    legend(cellArray{:});
else
    legend(numbers)
end