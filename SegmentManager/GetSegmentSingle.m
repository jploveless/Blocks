function segIdx = GetSegmentSingle(Segment)
% Test the line drawing functions

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Select a segment', 'FontSize',12);

    %% Loop until button is pushed and redraw lines
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    hMarkedLine = findobj(Seg.axHandle, 'Tag','SelectedLine');
    if isempty(hMarkedLine)
        hMarkedLine = plot(Seg.axHandle, 0,0,'-r', 'LineWidth',2, 'Tag','SelectedLine');
    end
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));

        % Find the closest line (midpoint)
        lonMid = (Segment.lon1 + Segment.lon2) / 2;
        latMid = (Segment.lat1 + Segment.lat2) / 2;
        d2 = (lonMid - x).^2 + (latMid - y).^2;
        [minDVal, minDIdx] = min(d2); %#ok<ASGLU>

        % Change marked line segment
        set(hMarkedLine, 'xdata',[Segment.lon1(minDIdx) Segment.lon2(minDIdx)], 'ydata',[Segment.lat1(minDIdx) Segment.lat2(minDIdx)]);

        % Update the selected segment in the segments drop-down (combo-box)
        set(Seg.modSegList, 'Value', minDIdx + 2);

        % Update the selected property's value
        propIdx = get(Seg.modPropList, 'Value');
        if propIdx > 1
            SegmentManagerFunctions('Seg.modPropList', false)
        end

        drawnow; pause(0.02);
    end
    set(gcf, 'WindowButtonDownFcn', '');
    title(Seg.axHandle, '');
    segIdx = minDIdx;
    %delete(hMarkedLine);  % keep the marker line active!
    drawnow;
