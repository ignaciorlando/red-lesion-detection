function A = imshift(im, shiftRows, shiftCols)

A = zeros(size(im));

if shiftRows >= 0 && shiftCols >= 0
    A(1+shiftRows:end,1+shiftCols:end) = im(1:end-shiftRows,1:end-shiftCols);
elseif shiftRows >= 0 && shiftCols < 0
    A(1+shiftRows:end,1:end+shiftCols) = im(1:end-shiftRows,1-shiftCols:end);
elseif shiftRows < 0 && shiftCols >= 0
    A(1:end+shiftRows,1+shiftCols:end) = im(1-shiftRows:end,1:end-shiftCols);
else
    A(1:end+shiftRows,1:end+shiftCols) = im(1-shiftRows:end,1-shiftCols:end);
end