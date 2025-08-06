function Segment = SplitSegment(Segment)
% Select a segment and split it in two

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Select a segment to be split', 'FontSize',12);

    %% Loop until button is pushed and redraw lines
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    hMarkedLine = plot(0,0,'-r', 'LineWidth',2);
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));

        %% Find the closest line (midpoint)
        lonMid = (Segment.lon1 + Segment.lon2) / 2;
        latMid = (Segment.lat1 + Segment.lat2) / 2;
        d = (lonMid - x).^2 + (latMid - y).^2;
        [minDVal, minDIdx] = min(d); %#ok<ASGLU>

        %% Change marked line segment
        set(hMarkedLine, 'xdata',[Segment.lon1(minDIdx) Segment.lon2(minDIdx)], 'ydata',[Segment.lat1(minDIdx) Segment.lat2(minDIdx)]);
        set(Seg.modSegList, 'Value', minDIdx + 2);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonDownFcn', '');
    title(Seg.axHandle, '');

    %% Get the midpoint coordinates
    lonMid = lonMid(minDIdx);
    latMid = latMid(minDIdx);

    %% Copy the segment with a new name
    Segment = CopySegmentProp(Segment, minDIdx, strcat(Segment.name(minDIdx, :), 'b'), lonMid, latMid, Segment.lon2(minDIdx), Segment.lat2(minDIdx));
    Segment = CopySegmentProp(Segment, minDIdx, strcat(Segment.name(minDIdx, :), 'a'), Segment.lon1(minDIdx), Segment.lat1(minDIdx), lonMid, latMid);
    Segment = DeleteSegment(Segment, minDIdx);

    %% Let RedrawSegments Handle the deletion
    delete(hMarkedLine);
    drawnow;
