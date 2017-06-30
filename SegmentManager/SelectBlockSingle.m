function idx = SelectBlockSingle(Block)
% Test the line drawing functions

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Select a segment', 'FontSize',12);

    %% Loop until button is pushed and redraw lines
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    hMarkedBlock = findobj(Seg.axHandle, 'Tag','SelectedBlock');
    if isempty(hMarkedBlock)
        hMarkedBlock = plot(Seg.axHandle, 0,0,'og', 'Tag','SelectedBlock');
    end
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', npi2pi(x), x, y));

        % Find the closest point
        d2 = (Block.interiorLon - x).^2 + (Block.interiorLat - y).^2;
        [minDVal, minDIdx] = min(d2); %#ok<ASGLU>

        % Change marked block
        set(hMarkedBlock, 'xdata',Block.interiorLon(minDIdx), 'ydata',Block.interiorLat(minDIdx));

        % Update the selected block in the blocks drop-down (combo-box)
        set(Seg.modSegListBlock, 'Value', minDIdx + 2);

        % Update the selected property's value
        propIdx = get(Seg.modPropListBlock, 'Value');
        if propIdx > 1
            SegmentManagerFunctions('Seg.modPropListBlock', false)
        end

        drawnow; pause(0.02);
    end
    set(gcf, 'WindowButtonDownFcn', '');
    title(Seg.axHandle, '');
    idx = minDIdx;
    drawnow;
