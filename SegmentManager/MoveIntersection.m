function Segment = MoveIntersection(Segment)
% Graphically move an intersection

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

    %% Find all of the segments that touch this point
    matchLon1 = find(Segment.lon1 == lonClose);
    matchLon2 = find(Segment.lon2 == lonClose);
    matchLat1 = find(Segment.lat1 == latClose);
    matchLat2 = find(Segment.lat2 == latClose);
    matchIdx = intersect([matchLon1 ; matchLon2], [matchLat1 ; matchLat2]);

    %% Find the other endpoint coordinates
    nMatch = numel(matchIdx);
    xOther = zeros(size(matchIdx));
    yOther = zeros(size(matchIdx));
    for iMatch = 1 : nMatch
        idx = matchIdx(iMatch);
        if (Segment.lon1(idx) == lonClose) && (Segment.lat1(idx) == latClose)
            xOther(iMatch) = Segment.lon2(idx);
            yOther(iMatch) = Segment.lat2(idx);
        else
            xOther(iMatch) = Segment.lon1(idx);
            yOther(iMatch) = Segment.lat1(idx);
        end
    end

    %% Draw the initial dynamic lines and delete the intersection marker
    for iMatch = nMatch : -1 : 1
        hLine(iMatch) = plot([xOther(iMatch) lonClose], [yOther(iMatch) latClose], 'r-', 'Tag',strcat('lineMove', num2str(iMatch)), 'LineWidth',1, 'erasemode','xor');
    end
    delete(hMarker);

    %% Move the lines till the next click
    set(gcf, 'WindowButtonUpFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', npi2pi(x), x, y));
        for iMatch = 1 : nMatch
            set(hLine(iMatch), 'xData',[xOther(iMatch) x], 'yData',[yOther(iMatch) y]);
        end
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonUpFcn', '');
    title(Seg.axHandle, '');

    %% Update and move positions of old segment lines
    hSegments = findobj(Seg.axHandle, 'Tag','Segment.1');
    xdata = get(hSegments, 'XData');
    ydata = get(hSegments, 'YData');
    for iMatch = 1 : nMatch
        idx = matchIdx(iMatch);
        if (Segment.lon1(idx) == lonClose) && (Segment.lat1(idx) == latClose)
            Segment.lon1(idx) = x;
            Segment.lat1(idx) = y;
            xdata(idx*3-2) = x;
            ydata(idx*3-2) = y;
        else
            Segment.lon2(idx) = x;
            Segment.lat2(idx) = y;
            xdata(idx*3-1) = x;
            ydata(idx*3-1) = y;
        end
        %set(findobj('Tag', strcat('Segment.', num2str(idx))), 'xData', [Segment.lon1(idx) Segment.lon2(idx)], 'yData', [Segment.lat1(idx) Segment.lat2(idx)]);
    end
    set(hSegments, 'XData',xdata, 'YData',ydata);

    %% Delete dynamic lines
    delete(hLine);
    drawnow;
