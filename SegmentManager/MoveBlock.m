function Block = MoveBlock(Block)
% Graphically move a block

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Select and drag a block location', 'FontSize',12);

    %% Dynamically highlight fault endpoints
    lon = Block.interiorLon;
    lat = Block.interiorLat;
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    hMarker = plot(0, 0, 'og', 'Tag', 'HighlightIntersection');  % draw initial circle marker
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));

        % Find the closest intersection
        d = (lon - x).^2 + (lat - y).^2;
        [minDVal, minDIdx] = min(d); %#ok<ASGLU>
        [lonClose, latClose] = deal(lon(minDIdx), lat(minDIdx));

        %% Update circle marker position
        set(hMarker, 'XData',lonClose, 'Ydata',latClose);
        drawnow; pause(0.05);
    end
    set(gcf, 'WindowButtonDownFcn', '');

    %% Move the lines till mouse is released
    set(gcf, 'WindowButtonUpFcn', 'ButtonDown');
    done = 0;
    setappdata(gcf, 'doneClick', done);
    while ~done
        done = getappdata(gcf, 'doneClick');
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', wrapTo180(x), x, y));
        set(hMarker, 'xData',x, 'yData',y);
        drawnow;
    end
    set(gcf, 'WindowButtonUpFcn', '');
    title(Seg.axHandle, '');

    %% Update and move positions of old interior point
    Block.interiorLon(minDIdx) = x;
    Block.interiorLat(minDIdx) = y;
    %set(findobj('Tag', strcat('Block.', num2str(minDIdx))), 'xData',Block.interiorLon(minDIdx), 'yData',Block.interiorLat(minDIdx));
    delete(hMarker);
    drawnow;
