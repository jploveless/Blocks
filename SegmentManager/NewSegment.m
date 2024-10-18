function [Segment, newSegmentName] = NewSegment(Segment)
% Draw a new segment

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Click on the new segment''s start point', 'FontSize',12);

    %% Select the first point
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonDownFcn', '');
    title(Seg.axHandle, 'Drag & release to the new segment''s endpoint');
    [lonClose, latClose] = deal(x, y);

    %% Draw the initial dynamic line and delete the intersection marker
    hLine = plot([lonClose lonClose], [latClose latClose], 'r-', 'Tag','lineMove', 'LineWidth',1);

    %% Move the lines till the next click
    set(gcf, 'WindowButtonUpFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));
        set(hLine, 'xData',[lonClose x], 'yData',[latClose y]);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonUpFcn', '');
    title(Seg.axHandle, '');

    %% Add new segment to structure Segment
    newSegmentName = char(inputdlg('New segment name:'));
    Segment = AddGenericSegment(Segment, newSegmentName, lonClose, latClose, x, y);

    %% Update the blue Segment lines
    nSegment = numel(Segment.lon1);
    plot([Segment.lon1(nSegment) Segment.lon2(nSegment)], [Segment.lat1(nSegment) Segment.lat2(nSegment)], '-b', 'Tag', strcat('Segment.', num2str(nSegment)), 'LineWidth', 2);

    %% Delete dynamic line
    delete(hLine);
    drawnow;
