
function [benefit] = get_benefit(cm, path)
    benefit = sum(sum(cm(path)));
end