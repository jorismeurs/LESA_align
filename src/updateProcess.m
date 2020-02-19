function updateProcess(val,handles)

axes(handles.axes1);
cla
if val ~= 0
    patch([0 val/length(handles.processNames) val/length(handles.processNames) 0],...
        [0 0 1 1],[0 1 0]);
    text(0.1,0.5,handles.processNames{val},'FontSize',10,...
        'FontName','Calibri');
    xlim([0 1]);
    ylim([0 1]);
    box on
end