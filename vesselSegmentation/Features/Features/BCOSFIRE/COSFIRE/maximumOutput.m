function [ output ] = maximumOutput( input )
    for i = 1:length(input)
        in(:,:,i) = input{i};
    end

    output = max(in, [], 3);
end

