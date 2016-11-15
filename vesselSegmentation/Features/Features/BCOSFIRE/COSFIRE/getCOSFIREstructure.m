function getCOSFIREstructure(operator)

if isfield(operator,'children')
    figure;
    ax = axes;
    radius = 150;
    dim = (2 * radius) + 1;
    
    for i = 0:1
        for c = 1:length(operator.children)            
            [x y] = pol2cart(operator.tuples(2,c),operator.tuples(1,c));        
            showCOSFIREstructure(ax,operator.children(c),1-i,0+i,[radius-y radius+x],dim);        
        end        
    end
    hold on;
    for c = 1:length(operator.children)            
        circle([radius radius],operator.tuples(1,c),1000,'-',2,[1 0 0],0,2*pi); 
    end    
end