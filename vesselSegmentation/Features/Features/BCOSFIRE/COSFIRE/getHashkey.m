function key = getHashkey(tuple)

primelist = [2 3 5];
key = prod(primelist(1:length(tuple)).^tuple);