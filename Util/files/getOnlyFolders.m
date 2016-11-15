% Open multiple files from a given directory
function sub_folders = getOnlyFolders(main_folder)
    
    main_folder_dir = dir(main_folder);
    sub_folders = extractfield(main_folder_dir, 'name');
    is_folder = [main_folder_dir.isdir];
    sub_folders = sub_folders(is_folder);
    sub_folders(strcmp(sub_folders, '..')) = [];
    sub_folders(strcmp(sub_folders, '.')) = [];
    
end