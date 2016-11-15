
function [labels, filenames] = get_ROC_labels(xml_filename, input_images_folder, output_images_folder, probability)

    % parse the file
    s = xml2struct(xml_filename);
    
    % move within the tree until reaching the images list
    images = s.set.annotations_dash_per_dash_image;
    % assign the labels
    labels = cell(length(images), 1);
    % create a filenames array
    filenames = cell(length(images), 1);
    % for each of the images
    for i = 1 : length(images)
        
        % get image name and open it
        I = imread(fullfile(input_images_folder, images{i}.Attributes.imagename));
        % get filename
        [~, filenames{i}, ~] = fileparts(images{i}.Attributes.imagename);
        
        % create a binary mask with the labels
        label = zeros(size(I,1), size(I,2)); 
        % retrieve the annotations
        if (isfield(images{i}, 'annotation'))
            annotations = images{i}.annotation;
            % for each lesion, draw a circle in the label
            for j = 1 : length(annotations)
                if (iscell(annotations))
                    if num2str(annotations{j}.probability.Text) > probability
                        [label] = drawCircle(label, str2double(annotations{j}.mark.Attributes.x), str2double(annotations{j}.mark.Attributes.y), str2double(annotations{j}.mark.radius.Text));
                    else
                        disp('A');
                    end
                else
                    if num2str(annotations.probability.Text) > probability
                        [label] = drawCircle(label, str2double(annotations(j).mark.Attributes.x), str2double(annotations(j).mark.Attributes.y), str2double(annotations(j).mark.radius.Text));
                    else
                        disp('A');
                    end
                end
            end
        end
        
        % save the labels
        imwrite(label > 0, fullfile(output_images_folder, strcat(filenames{i}, '.png')));
        
    end

end


function [mask] = drawCircle(mask, centerX, centerY, radius)

    [columnsInImage, rowsInImage] = meshgrid(1:size(mask,2), 1:size(mask,1));
    circlePixels = (rowsInImage - centerY).^2 ...
        + (columnsInImage - centerX).^2 <= radius.^2;
    mask(circlePixels) = 1;

end