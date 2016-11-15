
function xml_code = get_xml_code_from_roc_scores(roc_data_path, scores_files)
    
    % initialize xml code
    xml_code = '<?xml version="1.0" encoding="utf-8"?>\n<set>\n';
    
    % for each score map
    for i = 1 : length(scores_files)
        
        % retrieve scores names
        [~, filename, ~] = fileparts(scores_files{i});
        % if filename contains a dot, refilter to get only the filename
        [~, filename, ~] = fileparts(filename);

        fprintf(strcat(filename, '\n'));
        
        % add tag of current image
        xml_code = strcat(xml_code, ...
            '\t<annotations-per-image imagename="', filename, '.jpg">\n');
        
        % load current annotation
        load(fullfile(roc_data_path, scores_files{i}));
        % retrieve xml annotations from current score map
        annotation_codes = get_xml_annotation_from_given_image(score_map);
        
        % now, add every single annotation
        for id_annotation = 1 : length(annotation_codes)
            % add an extra tab
            current_annotation = strrep(annotation_codes{id_annotation}, '\t', '\t\t');
            % concatenate current annotation to the xml code
            xml_code = strcat(xml_code, ...
                current_annotation);
        end
        
        % now, close the annotations from current image
        xml_code = strcat(xml_code, ...
            '\t</annotations-per-image>\n');
        
    end
    
    % and finally close the set
        xml_code = strcat(xml_code, ...
            '\t</set>');
    
end


function xml_codes = get_xml_annotation_from_given_image(annotation)
    
    % threshold the probability map to identify connected components
    BW = annotation > 0;
    CC = bwconncomp(BW);
    stats = regionprops(BW,{'Centroid', 'EquivDiameter', 'PixelIdxList'});
    
    % initialize the XML code as an empty array of annotations
    xml_codes = cell(length(stats), 1);
    
    for i = 1 : length(stats)
        
        current_annotation_string = '<annotation>\n';
        current_annotation_string = strcat(current_annotation_string, ...
            '\t<mark x="', num2str(round(stats(i).Centroid(1))), '" y="', num2str(round(stats(i).Centroid(2))), '">\n');
        current_annotation_string = strcat(current_annotation_string, ...
            '\t\t<radius> ', num2str(round(stats(i).EquivDiameter / 2)), '</radius>\n');
        current_annotation_string = strcat(current_annotation_string, ...
            '\t</mark>\n');        
        current_annotation_string = strcat(current_annotation_string, ...
            '\t<lesion> microaneurysm </lesion>\n');
        current_annotation_string = strcat(current_annotation_string, ...
            '\t<probability>', num2str(unique(annotation(stats(1).PixelIdxList))), '</probability>\n');
        current_annotation_string = strcat(current_annotation_string, ...
            '</annotation>\n');
        
        xml_codes{i} = current_annotation_string;
        
    end
    
end