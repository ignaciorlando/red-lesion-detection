
function plot_froc(per_lesion_sensitivity, fpi, x_axis)
    
    if (exist('x_axis', 'var')==0)
        x_axis = 10.^[-1.5 1.3];
    end
    semilogx(fpi, per_lesion_sensitivity, 'LineWidth', 2);
    xlim(x_axis);
    ylim([0 1]);
    grid on
    xlabel('FPI');
    ylabel('Per lesion sensitivity');
    
end