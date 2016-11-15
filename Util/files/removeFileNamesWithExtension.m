
function [fileNames] = removeFileNamesWithExtension(fileNames, extension)

%     newNames = {};
% 
%     % for each file name
%     for i = 1 : length(fileNames)
%         % if the filename contains the extension, it is saved in the list
%         filename = fileNames{i};
%         if ~strcmp(filename(end-3:end), strcat('.',extension))
%             newNames = cat(1, newNames, filename);
%         end
%         
%     end

    fileNames(~cellfun(@isempty,regexp(fileNames,strcat('.',extension), 'once'))) = [];
    

end