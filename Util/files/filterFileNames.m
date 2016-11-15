function [filteredNames] = filterFileNames(names, extension)
% filterFileNames Filter an array of image names, removing '..' and '.' from
% the list
% Input: names = cellarray of strings with the file names
%        extension = string with the desired extension
% Output: filteredNames = cellarray without '.' and '..'

    IndexC = strfind(names, strcat('.', extension));
    Index = find(not(cellfun('isempty', IndexC)));
    filteredNames = names(Index);
    
end