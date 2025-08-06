function [Segment, newSegmentName] = ConnectIntersection(Segment)
% Graphically connect two intersections

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Select and drag a segment intersection', 'FontSize',12);

    %% Dynamically highlight fault endpoints
    lonEnd = [Segment.lon1; Segment.lon2];
    latEnd = [Segment.lat1; Segment.lat2];
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    hMarker = plot(0, 0, 'ro', 'Tag', 'HighlightIntersection');  % draw initial circle marker
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));

        %% Find the closest intersection
        d2 = (lonEnd - x).^2 + (latEnd - y).^2;
        [minDVal, minDIdx] = min(d2); %#ok<ASGLU>
        [lonClose, latClose] = deal(lonEnd(minDIdx), latEnd(minDIdx));

        %% Update circle marker position
        set(hMarker, 'XData',lonClose, 'Ydata',latClose);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonDownFcn', '');

    %% Draw initial dynamic line and second intersection
    hLine = plot([lonClose lonClose], [latClose latClose], '-r', 'lineWidth',1, 'Tag','lineMove');
    hMarker2 = plot(lonClose, latClose, 'ro', 'Tag','HighlightIntersection02');

    %% Dynamically highlight possible connections
    set(gcf, 'WindowButtonUpFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));

        %% Find the closest intersection
        d2 = (lonEnd - x).^2 + (latEnd - y).^2;
        [minDVal, minDIdx] = min(d2); %#ok<ASGLU>
        [lonCon, latCon] = deal(lonEnd(minDIdx), latEnd(minDIdx));

        set(hLine, 'xData',[lonClose lonCon], 'yData',[latClose latCon]);
        set(hMarker2, 'xData',lonCon, 'yData',latCon);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonUpFcn', '');
    title(Seg.axHandle, '');

    %% Add new segment to structure Segment
    newSegmentName = char(inputdlg('New segment name:'));
    Segment = AddGenericSegment(Segment, newSegmentName, lonClose, latClose, lonCon, latCon);

    %% Update the blue Segment lines
    nSegment = numel(Segment.lon1);
    plot([Segment.lon1(nSegment) Segment.lon2(nSegment)], [Segment.lat1(nSegment) Segment.lat2(nSegment)], '-b', 'Tag', strcat('Segment.', num2str(nSegment)), 'LineWidth',2);

    %% Delete dynamic line and intersection markers
    delete(hLine);
    delete(hMarker);
    delete(hMarker2);
    drawnow;
