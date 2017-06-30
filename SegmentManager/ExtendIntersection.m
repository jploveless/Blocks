function [Segment, newSegmentName] = ExtendIntersection(Segment)
% Graphically extend an intersection

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
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', npi2pi(x), x, y));

        %% Find the closest intersection
        d2 = (lonEnd - x).^2 + (latEnd - y).^2;
        [minDVal, minDIdx] = min(d2); %#ok<ASGLU>
        [lonClose, latClose] = deal(lonEnd(minDIdx), latEnd(minDIdx));

        %% Update circle marker position
        set(hMarker, 'XData',lonClose, 'Ydata',latClose);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonDownFcn', '');

    %% Draw the initial dynamic line and delete the intersection marker
    hLine = plot([lonClose lonClose], [latClose latClose], 'r-', 'Tag','lineMove', 'LineWidth',1);
    delete(findobj('Tag', 'HighlightIntersection'));

    %% Move the lines till the next click
    set(gcf, 'WindowButtonUpFcn', 'ButtonDown');
    done = 0;
    setappdata(gcf, 'doneClick', done);
    while ~done
        done = getappdata(gcf, 'doneClick');
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', npi2pi(x), x, y));
        set(hLine, 'xData',[lonClose x], 'yData',[latClose y]);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonUpFcn', '');
    title(Seg.axHandle, '');

    %% Add new segment to structure Segment
    newSegmentName = char(inputdlg('New segment name:'));
    Segment = AddGenericSegment(Segment, newSegmentName, lonClose, latClose, x, y);

    %% Delete dynamic line
    delete(hLine);

    %% Update the blue Segment lines
    %nSegment = numel(Segment.lon1);
    %plot([Segment.lon1(nSegment) Segment.lon2(nSegment)], [Segment.lat1(nSegment) Segment.lat2(nSegment)], '-b', 'Tag',strcat('Segment.', num2str(nSegment)), 'LineWidth',2);
    drawnow;
