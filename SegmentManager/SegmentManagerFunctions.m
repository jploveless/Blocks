function SegmentManagerFunctions(option, displayTimingInfo)
    % SegmentManagerFunctions
    %
    % Functions called by Segment Manager GUI

    % **** Big change: Switched from unlimited storage of the window bounds
    % to only retaining the 10 most recent views.  Changed by JPL, 8 Jan 08.

    % Declare variables
    global GLOBAL ul cul st;
    translateScale = 0.2;
    if ~exist('vecScale', 'var') || isempty(vecScale) %#ok<NODEF>
        vecScale = 0.5;
    end

    % Get the struct holding the uicontrols' direct handles (avoiding runtime findobj() calls)
    %drawnow;
    ud = get(gcf,'UserData');
    Seg = ud.Seg;

    % Parse callbacks
    %fprintf(GLOBAL.filestream, '%s => %s\n', datestr(now,'HH:MM:SS.FFF'), option);
    t=tic;
    switch (option)

        % Start File I/O commands
        case 'Seg.loadPushCommand'  % Load .command file
            % Get the name of the segment file
            filenameFull = GetFilename(Seg.loadEditCommand, 'Command', '*.command');
            if isempty(filenameFull),  return;  end

            % Read in the command file
            Command = ReadCommand(filenameFull);

            % Process .segment file
            ha = Seg.loadEdit;
            set(ha, 'string', Command.segFileName);
            Segment = ReadSegmentTri(Command.segFileName);
            Segment.midLon = 0.5*(Segment.lon1 + Segment.lon2);
            Segment.midLat = 0.5*(Segment.lat1 + Segment.lat2);
            Segment = AlphaSortSegment(Segment);
            setappdata(gcf, 'Segment', Segment);
            SegmentManagerFunctions('DrawSegments');
            set(Seg.modSegList, 'string', cellstr(strvcat('< none >', 'Multiple', Segment.name)));
            set(Seg.dispCheck, 'enable', 'on', 'value', 1);

            % Process .block file
            ha = Seg.loadEditBlock;
            set(ha, 'string', 'Command.blockFileName');
            Block = ReadBlocksStruct(Command.blockFileName);
            Block = AlphaSortBlock(Block);
            setappdata(gcf, 'Block', Block);
            set(Seg.modSegListBlock, 'string', cellstr(strvcat(' ', 'Multiple', Block.name)));
            nBlocks = numel(Block.interiorLon);
            blnames = cellstr([repmat('Block.', nBlocks, 1) strjust(num2str((1:nBlocks)'), 'left')]);
            plotbls = line([Block.interiorLon'; Block.interiorLon'], [Block.interiorLat'; Block.interiorLat'], 'MarkerFaceColor', 'm', 'MarkerSize', 5, 'marker', 'o', 'linestyle', 'none', 'MarkerEdgeColor', 'k');
            set(plotbls, {'tag'}, blnames);
            set(Seg.dispCheckBlock, 'enable', 'on', 'value', 1);

            % Process the .sta.data file
            ha = Seg.dispEditSta;
            set(ha, 'String', Command.staFileName);
            Station = PlotSta(Command.staFileName);
            PlotStaVec(Station, vecScale);
            setappdata(gcf, 'Station', Station);
            set(Seg.dispCheckSta, 'Value', 1, 'Enable', 'on');
            set(Seg.dispCheckStaNames, 'Enable', 'on');
            hb = Seg.dispCheckSta;
            set(hb, 'Value', 1);

            % Process the .msh files... only works for one right now
            P = ReadPatches(Command.patchFileNames);
            h = patch('Vertices', P.c, 'faces', P.v, 'facecolor', 'g', 'edgecolor', 'black', 'Tag', 'Patch');
            if ~isempty(Command.patchFileNames)
                set(Seg.dispCheckMesh, 'enable', 'on', 'value', 1);
            end

        case 'Seg.loadPush'   % Load segment file
            % Get the name of the segments file
            filenameFull = GetFilename(Seg.loadEdit, 'Segments', '*.segment; *.segment.xml', '*.segment*');
            if isempty(filenameFull),  return;  end

            % Clear before reloading
            SegmentManagerFunctions('Seg.clearPush');

            % Read in the segment file
            Segment = ReadSegmentTri(filenameFull);
            Segment.midLon = 0.5*(Segment.lon1 + Segment.lon2);
            Segment.midLat = 0.5*(Segment.lat1 + Segment.lat2);

            Segment = AlphaSortSegment(Segment);
            setappdata(gcf, 'Segment', Segment);

            % Plot segments file
            SegmentManagerFunctions('DrawSegments');

            % Add the segment names to the segment pulldown list
            set(Seg.modSegList, 'string', cellstr(strvcat('< none >', 'Multiple', Segment.name)));

            % Enable the display check box
            set(Seg.dispCheck, 'enable', 'on', 'value', 1);
        case 'Seg.dispCheck'  % Segment display toggle
            ha = findobj(gcf, '-regexp', 'Tag', '^Segment.');
            hs = findobj(Seg.axHandle, 'Tag','SelectedLine');
            hb = Seg.dispCheck;
            if get(hb, 'Value') == 0;
                set(ha, 'Visible', 'off');
                set(hs, 'Visible', 'off');
            else
                set(ha, 'Visible', 'on');
                set(hs, 'Visible', 'on');
            end
        case 'Seg.clearPush'  % Clear segment file
            %set(Seg.loadEdit, 'string', '');
            setappdata(gcf, 'Segment', []);
            delete(findobj(Seg.axHandle, '-regexp', 'tag', '^Segment.'));
            delete(findobj(Seg.axHandle, 'Tag','SelectedLine'));
            % Disable the display check box
            set(Seg.dispCheck, 'enable', 'off', 'value', 0);
        case 'Seg.savePush'   % Save segment file
            Segment = getappdata(gcf, 'Segment');
            if size(Segment, 1) == 0
                return;
            else
                [filename, pathname] = uiputfile({'*.segment; *.segment.xml'}, 'Save segment file');
                if filename == 0
                    return;
                else
                    filenameFull = strcat(pathname, filename);
                    WriteSegmentStruct(filenameFull, Segment);
                end
                set(Seg.loadEdit, 'string', ['  ' filename]);
            end
        case 'Seg.modSegList'
            ha = Seg.modSegList;
            value = get(ha, 'Value');
            idxSeg = value - 2;
            %Segment = getappdata(gcf, 'Segment');
            %nSegments = length(Segment.lon1);
            %set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');
            hMarkedBlock = findobj(Seg.axHandle, 'Tag','SelectedLine');
            if value > 2
                setappdata(gcf, 'segIdx', idxSeg);

                % Indicate the selected segment with a red line
                %set(findobj(gcf, 'Tag', strcat('Segment.', num2str(idxSeg))), 'Color', 'r');
                if isempty(hMarkedBlock)
                    hMarkedBlock = plot(Seg.axHandle, 0,0,'-r', 'LineWidth',2, 'Tag','SelectedLine');
                end
                Segment = getappdata(gcf,'Segment');
                set(hMarkedBlock, 'xdata',[Segment.lon1(idxSeg) Segment.lon2(idxSeg)], 'ydata',[Segment.lat1(idxSeg) Segment.lat2(idxSeg)]);

                % Update the selected property's value
                propIdx = get(Seg.modPropList, 'Value');
                if propIdx > 1
                    SegmentManagerFunctions('Seg.modPropList')
                end
            else
                delete(hMarkedBlock);
            end
        case 'Seg.modSegPush'  % Start Modify Commands
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                valueStr = get(Seg.modPropEdit, 'String');
                try % Convert string to numerical value
                    value = str2double(valueStr);
                catch
                    fprintf(GLOBAL.filestream, 'Could not convert to a numerical value\n');
                end

                % Figure out which field has and which segments have been selected...then update
                segIdx = getappdata(gcf, 'segIdx');
                propIdx = get(Seg.modPropList, 'Value');
                %segNames = get(Seg.modSegList, 'String'); segName = segNames{segIdx}  % for debugging
                if propIdx < 2
                    fprintf(GLOBAL.filestream, 'Select a property with a numerical value\n');
                    return;
                end

                % Set and save properties
                switch propIdx
                    case 2;  Segment.lon1(segIdx)      = value;
                    case 3;  Segment.lat1(segIdx)      = value;
                    case 4;  Segment.lon2(segIdx)      = value;
                    case 5;  Segment.lat2(segIdx)      = value;
                    case 6;  Segment.dip(segIdx)       = value;
                    case 7;  Segment.dipSig(segIdx)    = value;
                    case 8;  Segment.dipTog(segIdx)    = value;
                    case 9;  Segment.lDep(segIdx)      = value;
                    case 10; Segment.lDepSig(segIdx)   = value;
                    case 11; Segment.lDepTog(segIdx)   = value;
                    case 12; Segment.ssRate(segIdx)    = value;
                    case 13; Segment.ssRateSig(segIdx) = value;
                    case 14; Segment.ssRateTog(segIdx) = value;
                    case 15; Segment.dsRate(segIdx)    = value;
                    case 16; Segment.dsRateSig(segIdx) = value;
                    case 17; Segment.dsRateTog(segIdx) = value;
                    case 18; Segment.tsRate(segIdx)    = value;
                    case 19; Segment.tsRateSig(segIdx) = value;
                    case 20; Segment.tsRateTog(segIdx) = value;
                    case 21; Segment.res(segIdx)       = value;
                    case 22; Segment.resOver(segIdx)   = value;
                    case 23; Segment.resOther(segIdx)  = value;
                    case 24; Segment.patchFile(segIdx) = value;
                    case 25; Segment.patchTog(segIdx)  = value;
                    case 26; Segment.other3(segIdx)    = value;
                    case 27; Segment.patchSlipFile(segIdx) = value;
                    case 28; Segment.patchSlipTog(segIdx)  = value;
                    case 29; Segment.other6(segIdx)    = value;
                    case 30; Segment.other7(segIdx)    = value;
                    case 31; Segment.other8(segIdx)    = value;
                    case 32; Segment.other9(segIdx)    = value;
                    case 33; Segment.other10(segIdx)   = value;
                    case 34; Segment.other11(segIdx)   = value;
                    case 35; Segment.other12(segIdx)   = value;
                end
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('Seg.modSegList')
                SegmentManagerFunctions('RedrawSegments');
            end
        case 'Seg.modPropList'
            %disp('show segment properties')
            Segment = getappdata(gcf, 'Segment');
            ha = Seg.modSegList;
            value = get(ha, 'Value');
            segIdx = value - 2;
            propIdx = get(Seg.modPropList, 'Value');
            if (value > 1)
                % Show selected property in edit box
                switch propIdx
                    case 2;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lon1(segIdx))]);
                    case 3;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lat1(segIdx))]);
                    case 4;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lon2(segIdx))]);
                    case 5;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lat2(segIdx))]);
                    case 6;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.dip(segIdx))]);
                    case 7;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.dipSig(segIdx))]);
                    case 8;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.dipTog(segIdx))]);
                    case 9;  set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lDep(segIdx))]);
                    case 10; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lDepSig(segIdx))]);
                    case 11; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.lDepTog(segIdx))]);
                    case 12; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.ssRate(segIdx))]);
                    case 13; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.ssRateSig(segIdx))]);
                    case 14; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.ssRateTog(segIdx))]);
                    case 15; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.dsRate(segIdx))]);
                    case 16; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.dsRateSig(segIdx))]);
                    case 17; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.dsRateTog(segIdx))]);
                    case 18; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.tsRate(segIdx))]);
                    case 19; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.tsRateSig(segIdx))]);
                    case 20; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.tsRateTog(segIdx))]);
                    case 21; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.res(segIdx))]);
                    case 22; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.resOver(segIdx))]);
                    case 23; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.resOther(segIdx))]);
                    case 24; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.patchFile(segIdx))]);
                    case 25; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.patchTog(segIdx))]);
                    case 26; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other3(segIdx))]);
                    case 27; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.patchSlipFile(segIdx))]);
                    case 28; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.patchSlipTog(segIdx))]);
                    case 29; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other6(segIdx))]);
                    case 30; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other7(segIdx))]);
                    case 31; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other8(segIdx))]);
                    case 32; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other9(segIdx))]);
                    case 33; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other10(segIdx))]);
                    case 34; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other11(segIdx))]);
                    case 35; set(Seg.modPropEdit, 'string', ['   ' num2str(Segment.other12(segIdx))]);
                end
            else
                set(Seg.modPropEdit, 'string', ' ');
            end
        case 'Seg.modGSelect'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');

                % Select a segment graphically
                segIdx = GetSegmentSingle(Segment);

                % Set the listbox and save the segment index segment
                set(Seg.modSegList, 'Value', segIdx + 2);
                setappdata(gcf, 'segIdx', segIdx);
                %set(Seg.modPropList, 'Value', 1);
                %set(Seg.modPropEdit, 'String', ' ');
            end
        case 'Seg.modGSelectBox'
            Segment = getappdata(gcf, 'Segment');
 
            % Calculate segment midpoints here, assuming they'll be needed in the future
            Segment.midLon = (Segment.lon1 + Segment.lon2)/2;
            Segment.midLat = (Segment.lat1 + Segment.lat2)/2;
            setappdata(gcf, 'Segment', Segment);
            set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');
            hMarkedLine = findobj(Seg.axHandle, 'Tag','SelectedLine');
            if isempty(hMarkedLine)
               hMarkedLine = plot(Seg.axHandle, 0,0,'-r', 'LineWidth',2, 'Tag','SelectedLine');
            end
            % Find the segments that are inside a clickable box
            fprintf(GLOBAL.filestream, 'Starting Box Select\n');
            title(Seg.axHandle, 'Select and drag a bounding box for the requested segments', 'FontSize',12);
            segRange = GetRangeRbbox(getappdata(gcf, 'Range'));
            title(Seg.axHandle, '');
            segPolyX = [min(segRange.lon) max(segRange.lon) max(segRange.lon) min(segRange.lon)];
            segPolyY = [min(segRange.lat) min(segRange.lat) max(segRange.lat) max(segRange.lat)];
            segIdx = inpolygon(Segment.midLon, Segment.midLat, segPolyX, segPolyY);
            lons = [Segment.lon1(segIdx)'; Segment.lon2(segIdx)'; NaN(1, sum(segIdx))];
            lats = [Segment.lat1(segIdx)'; Segment.lat2(segIdx)'; NaN(1, sum(segIdx))];
            set(hMarkedLine, 'xdata', lons(:), 'ydata', lats(:));
            setappdata(gcf, 'segIdx', segIdx);
        case 'Seg.modGSelectLasso'
            Segment = getappdata(gcf, 'Segment');
            Range = getappdata(gcf, 'Range');
            hMarkedLine = findobj(Seg.axHandle, 'Tag','SelectedLine');
            if isempty(hMarkedLine)
               hMarkedLine = plot(Seg.axHandle, 0,0,'-r', 'LineWidth',2, 'Tag','SelectedLine');
            end
            % Calculate segment midpoints here, assuming they'll be needed in the future
            Segment.midLon = (Segment.lon1 + Segment.lon2)/2;
            Segment.midLat = (Segment.lat1 + Segment.lat2)/2;
            setappdata(gcf, 'Segment', Segment);
            set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');
            mp = plot(Segment.midLon, Segment.midLat, '.', 'visible', 'off');
            %ignore = setdiff(get(gca, 'children'), mp);
            title(Seg.axHandle, 'Select and drag a bounding area for the requested segments', 'FontSize',12);
            segIdx = myselectdata('sel', 'lasso', 'ignore', mp);
            title(Seg.axHandle, '');
            lons = [Segment.lon1(segIdx)'; Segment.lon2(segIdx)'; NaN(1, length(segIdx))];
            lats = [Segment.lat1(segIdx)'; Segment.lat2(segIdx)'; NaN(1, length(segIdx))];
            set(hMarkedLine, 'xdata', lons(:), 'ydata', lats(:));
            delete(mp); clear mp
            SetAxes(Range);
            setappdata(gcf, 'segIdx', segIdx);
        case 'Seg.modDeletePush'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                Segment = DeleteSegmentSingle(Segment);
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('RedrawSegments');
            end
        case 'Seg.modDeletePushBox'
            Segment = getappdata(gcf, 'Segment');
            % Calculate segment midpoints here, assuming they'll be needed in the future
            Segment.midLon = (Segment.lon1 + Segment.lon2)/2;
            Segment.midLat = (Segment.lat1 + Segment.lat2)/2;
            setappdata(gcf, 'Segment', Segment);
            set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');

            if ~isempty(Segment)
                fprintf(GLOBAL.filestream, 'Starting Box Select\n');
                segRange = GetRangeRbbox(getappdata(gcf, 'Range'));
                segPolyX = [min(segRange.lon) max(segRange.lon) max(segRange.lon) min(segRange.lon)];
                segPolyY = [min(segRange.lat) min(segRange.lat) max(segRange.lat) max(segRange.lat)];
                segIdx = find(inpolygon(Segment.midLon, Segment.midLat, segPolyX, segPolyY) == 1);
                for i = 1:numel(segIdx)
                    fprintf(GLOBAL.filestream, 'Deleting %s\n', Segment.name(segIdx(i), :));
                    set(findobj('Tag', strcat('Segment.', num2str(segIdx(i)))), 'Color', 'r');
                end
                Segment = DeleteSegment(Segment, segIdx);
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('RedrawSegments');
            end
        case 'Seg.modGDeleteLasso'
            Segment = getappdata(gcf, 'Segment');
            Range = getappdata(gcf, 'Range');
            % Calculate segment midpoints here, assuming they'll be needed in the future
            Segment.midLon = (Segment.lon1 + Segment.lon2)/2;
            Segment.midLat = (Segment.lat1 + Segment.lat2)/2;
            setappdata(gcf, 'Segment', Segment);
            set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');
            mp = plot(Segment.midLon, Segment.midLat, '.', 'visible', 'off');
            %ignore = setdiff(get(gca, 'children'), mp);
            segIdx = myselectdata('sel', 'lasso', 'ignore', mp);
            for i = 1:numel(segIdx)
                fprintf(GLOBAL.filestream, '%s\n', Segment.name(segIdx(i), :));
                set(findobj(gcf, 'Tag', strcat('Segment.', num2str(segIdx(i)))), 'Color', 'r');
            end
            delete(mp); clear mp
            Segment = DeleteSegment(Segment, segIdx);
            setappdata(gcf, 'Segment', Segment);
            SetAxes(Range);
            setappdata(gcf, 'segIdx', segIdx);
            SegmentManagerFunctions('RedrawSegments');
        case 'Seg.modNewPush'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                [Segment, newSegmentName] = NewSegment(Segment);
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('RedrawSegments');
                SelectSegment('modSegList', newSegmentName);
            end
        case 'Seg.modExtendPush'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                [Segment, newSegmentName] = ExtendIntersection(Segment);
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('RedrawSegments');
                SelectSegment('modSegList', newSegmentName);
            end
        case 'Seg.modConnectPush'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                [Segment, newSegmentName] = ConnectIntersection(Segment);
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('RedrawSegments');
                SelectSegment('modSegList', newSegmentName);
            end
        case 'Seg.modClear'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                %nSegments = length(Segment.lon1);
                set(findobj(gcf, '-regexp', 'Tag', 'Segment.\d'), 'color', 'k');
                set(Seg.modSegList, 'Value', 1);
                setappdata(gcf, 'segIdx', []);
                set(Seg.modPropList, 'Value', 1);
                set(Seg.modPropEdit, 'String', ' ');
                delete(findobj(Seg.axHandle, 'Tag','SelectedLine'));
            end
        case 'Seg.modMovePush'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                delete(findobj(Seg.axHandle, 'Tag','SelectedLine'));
                Segment = MoveIntersection(Segment);
                setappdata(gcf, 'Segment', Segment);
            end
        case 'Seg.modSplitPush'
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                Segment = SplitSegment(Segment);
                setappdata(gcf, 'Segment', Segment);
                SegmentManagerFunctions('RedrawSegments');
            end
        case 'Seg.modShowList'  % Show segment properties
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                switch get(Seg.modShowList, 'Value')
                    case 1
                        DeletePropertyLabels;
                    case 2
                        ShowPropertyLabels(strjust(Segment.name, 'center')); BigTitle('Segment names');
                    case 3
                        ShowPropertyLabels(num2str(Segment.lon1)); BigTitle('Longitude 1');
                    case 4
                        ShowPropertyLabels(num2str(Segment.lat1)); BigTitle('Latitude 1');
                    case 5
                        ShowPropertyLabels(num2str(Segment.lon2)); BigTitle('Longitude 2');
                    case 6
                        ShowPropertyLabels(num2str(Segment.lat2)); BigTitle('Latitude 2');
                    case 7
                        ShowPropertyLabels(num2str(Segment.dip)); BigTitle('Dip');
                    case 8
                        ShowPropertyLabels(num2str(Segment.dipSig)); BigTitle('Dip sigma');
                    case 9
                        ShowPropertyLabels(num2str(Segment.dipTog)); BigTitle('Dip flag');
                    case 10
                        ShowPropertyLabels(num2str(Segment.lDep)); BigTitle('Locking depth');
                    case 11
                        ShowPropertyLabels(num2str(Segment.lDepSig)); BigTitle('Locking depth sigma');
                    case 12
                        ShowPropertyLabels(num2str(Segment.lDepTog)); BigTitle('Locking depth flag');
                    case 13
                        labels = [num2str(Segment.ssRate) repmat('+/-', numel(Segment.ssRate), 1) strjust(num2str(Segment.ssRateSig), 'left')];
                        ShowPropertyLabels(labels); BigTitle('Strike slip rate \pm sigma');
                    case 14
                        ShowPropertyLabels(num2str(Segment.ssRate)); BigTitle('Strike slip rate');
                    case 15
                        ShowPropertyLabels(num2str(Segment.ssRateSig)); BigTitle('Strike slip sigma');
                    case 16
                        ShowPropertyLabels(num2str(Segment.ssRateTog)); BigTitle('Strike slip flag');
                    case 17
                        labels = [num2str(Segment.dsRate) repmat('+/-', numel(Segment.dsRate), 1) strjust(num2str(Segment.dsRateSig), 'left')];
                        ShowPropertyLabels(labels); BigTitle('Dip slip rate \pm sigma');
                    case 18
                        ShowPropertyLabels(num2str(Segment.dsRate)); BigTitle('Dip slip rate');
                    case 19
                        ShowPropertyLabels(num2str(Segment.dsRateSig)); BigTitle('Dip slip sigma');
                    case 20
                        ShowPropertyLabels(num2str(Segment.dsRateTog)); BigTitle('Dip slip flag');
                    case 21
                        labels = [num2str(Segment.tsRate) repmat('+/-', numel(Segment.tsRate), 1) strjust(num2str(Segment.tsRateSig), 'left')];
                        ShowPropertyLabels(labels); BigTitle('Tensile slip rate \pm sigma');
                    case 22
                        ShowPropertyLabels(num2str(Segment.tsRate)); BigTitle('Tensile slip rate');
                    case 23
                        ShowPropertyLabels(num2str(Segment.tsRateSig)); BigTitle('Tensile slip sigma');
                    case 24
                        ShowPropertyLabels(num2str(Segment.tsRateTog)); BigTitle('Tensile slip flag');
                    case 25
                        ShowPropertyLabels(num2str(Segment.res)); BigTitle('Resolution');
                    case 26
                        ShowPropertyLabels(num2str(Segment.resOv)); BigTitle('Resolution override');
                    case 27
                        ShowPropertyLabels(num2str(Segment.resOther)); BigTitle('Resolution other');
                    case 28
                        ShowPropertyLabels(num2str(Segment.patchFile)); BigTitle('Patch name');
                    case 29
                        ShowPropertyLabels(num2str(Segment.patchTog)); BigTitle('Patch toggle');
                    case 30
                        ShowPropertyLabels(num2str(Segment.other3)); BigTitle('Patch Flag 2');
                    case 31
                        ShowPropertyLabels(num2str(Segment.patchSlipFile)); BigTitle('Other 1');
                    case 32
                        ShowPropertyLabels(num2str(Segment.patchSlipTog)); BigTitle('Other 2');
                    case 33
                        ShowPropertyLabels(num2str(Segment.other6)); BigTitle('Other 3');
                    case 34
                        ShowPropertyLabels(num2str(Segment.other7)); BigTitle('Other 4');
                    case 35
                        ShowPropertyLabels(num2str(Segment.other8)); BigTitle('Other 5');
                    case 36
                        ShowPropertyLabels(num2str(Segment.other9)); BigTitle('Other 6');
                    case 37
                        ShowPropertyLabels(num2str(Segment.other10)); BigTitle('Other 7');
                    case 38
                        ShowPropertyLabels(num2str(Segment.other11)); BigTitle('Other 8');
                    case 39
                        ShowPropertyLabels(num2str(Segment.other12)); BigTitle('Other 9');
                end
            end

        %% Start File I/O commands (block-file)

        case 'Seg.loadPushBlock'   % Load block file
            % Get the name of the block file
            filenameFull = GetFilename(Seg.loadEditBlock, 'Block', '*.block; *.block.xml', '*.block*');
            if isempty(filenameFull),  return;  end

            % Read in the block file
            Block = ReadBlocksStruct(filenameFull);
            Block = AlphaSortBlock(Block);
            setappdata(gcf, 'Block', Block);

            % Plot blocks file
            SegmentManagerFunctions('RedrawBlocks')
            set(Seg.dispCheckBlock, 'enable', 'on', 'value', 1);
        case 'Seg.dispCheckBlock'  % Block display toggle
            ha = findobj(gcf, '-regexp', 'Tag', '^Block.');
            hb = Seg.dispCheckBlock;
            if get(hb, 'Value') == 0;
                set(ha, 'Visible', 'off');
            else
                set(ha, 'Visible', 'on');
            end
        case 'Seg.clearPushBlock'  % Clear block file
            %set(Seg.loadEditBlock, 'string', '');
            setappdata(gcf, 'Block', []);
            delete(findobj(Seg.axHandle, '-regexp', 'tag', '^Block.'));
            delete(findobj(Seg.axHandle, 'Tag','SelectedBlock'));
            % Disable the display check box
            set(Seg.dispCheckBlock, 'enable', 'off', 'value', 0);
        case 'Seg.savePushBlock'   % Save block file
            Block = getappdata(gcf, 'Block');
            if size(Block, 1) == 0
                return;
            else
                [filename, pathname] = uiputfile({'*.block; *.block.xml'}, 'Save block file');
                if filename == 0
                    return;
                else
                    filenameFull = strcat(pathname, filename);
                    WriteBlocksStruct(filenameFull, Block);
                end
                set(Seg.loadEditBlock, 'string', ['  ' filename]);
            end
        case 'Seg.modSegPushBlock'  % Start Modify Commands
            Block = getappdata(gcf, 'Block');
            if ~isempty(Block)
                valueStr = get(Seg.modPropEditBlock, 'String');
                try % Convert string to numerical value
                    value = str2double(valueStr);
                catch
                    fprintf(GLOBAL.filestream, 'Could not convert to a numerical value\n');
                end

                % Figure out which field has and which blocks have been selected...then update
                blockIdx = getappdata(gcf, 'blockIdx');
                propIdx = get(Seg.modPropListBlock, 'Value');
                if propIdx <= 2
                    fprintf(GLOBAL.filestream, 'Select a property with a numerical value\n');
                    return;
                end

                % Set and save properties
                switch propIdx
                    case 3;  Block.eulerLon(blockIdx)     = value;
                    case 4;  Block.eulerLat(blockIdx)     = value;
                    case 5;  Block.rotationRate(blockIdx) = value;
                    case 6;  Block.eulerLonSig(blockIdx)  = value;
                    case 7;  Block.eulerLatSig(blockIdx)  = value;
                    case 8;  Block.rotationRateSig(blockIdx) = value;
                    case 9;  Block.rotationInfo(blockIdx) = value;
                    case 10; Block.interiorLon(blockIdx)  = value;
                    case 11; Block.interiorLat(blockIdx)  = value;
                    case 12; Block.aprioriTog(blockIdx)   = value;
                    case 13; Block.other1(blockIdx) = value;
                    case 14; Block.other2(blockIdx) = value;
                    case 15; Block.other3(blockIdx) = value;
                    case 16; Block.other4(blockIdx) = value;
                    case 17; Block.other5(blockIdx) = value;
                    case 18; Block.other6(blockIdx) = value;
                end
                setappdata(gcf, 'Block', Block);
                SegmentManagerFunctions('RedrawBlocks');
            end
        case 'Seg.modPropListBlock'
            %disp('show block properties')
            Block = getappdata(gcf, 'Block');
            ha = Seg.modSegListBlock;
            value = get(ha, 'Value');
            blockIdx = value - 2;
            propIdx = get(Seg.modPropListBlock, 'Value');

            if value > 1
                % Show selected property in edit box
                switch propIdx
                    case 2;  set(Seg.modPropEditBlock, 'string', ['   ' Block.name(blockIdx, :)]);
                    case 3;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.eulerLon(blockIdx))]);
                    case 4;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.eulerLat(blockIdx))]);
                    case 5;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.rotationRate(blockIdx))]);
                    case 6;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.eulerLonSig(blockIdx))]);
                    case 7;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.eulerLatSig(blockIdx))]);
                    case 8;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.rotationRateSig(blockIdx))]);
                    case 9;  set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.rotationInfo(blockIdx))]);
                    case 10; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.interiorLon(blockIdx))]);
                    case 11; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.interiorLat(blockIdx))]);
                    case 12; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.aprioriTog(blockIdx))]);
                    case 13; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.other1(blockIdx))]);
                    case 14; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.other2(blockIdx))]);
                    case 15; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.other3(blockIdx))]);
                    case 16; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.other4(blockIdx))]);
                    case 17; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.other5(blockIdx))]);
                    case 18; set(Seg.modPropEditBlock, 'string', ['   ' num2str(Block.other6(blockIdx))]);
                end
            else
                set(Seg.modPropEditBlock, 'string', ' ');
            end
        case 'Seg.modShowListBlock'  % Show block properties
            Block = getappdata(gcf, 'Block');
            if ~isempty(Block)
                switch get(Seg.modShowListBlock, 'Value');
                    case 1
                        DeletePropertyLabelsBlock;
                    case 2
                        ShowPropertyLabelsBlock(strjust(Block.name, 'center')); BigTitle('Block names');
                    case 3
                        ShowPropertyLabelsBlock(num2str(Block.eulerLon)); BigTitle('Euler longitude');
                    case 4
                        ShowPropertyLabelsBlock(num2str(Block.eulerLat)); BigTitle('Euler latitude');
                    case 5
                        ShowPropertyLabelsBlock(num2str(Block.rotationRate)); BigTitle('Rotation rate');
                    case 6
                        ShowPropertyLabelsBlock(num2str(Block.eulerLonSig)); BigTitle('Euler longitude sigma');
                    case 7
                        ShowPropertyLabelsBlock(num2str(Block.eulerLatSig)); BigTitle('Euler latitude sigma');
                    case 8
                        ShowPropertyLabelsBlock(num2str(Block.rotationRateSig)); BigTitle('Rotation rate sigma');
                    case 9
                        ShowPropertyLabelsBlock(num2str(Block.rotationInfo)); BigTitle('Internal strain flag');
                    case 10
                        ShowPropertyLabelsBlock(num2str(Block.interiorLon)); BigTitle('Interior longitude');
                    case 11
                        ShowPropertyLabelsBlock(num2str(Block.interiorLat)); BigTitle('Interior latitude');
                    case 12
                        ShowPropertyLabelsBlock(num2str(Block.aprioriTog)); BigTitle('a priori pole flag');
                    case 13
                        ShowPropertyLabelsBlock(num2str(Block.other1)); BigTitle('Other 1');
                    case 14
                        ShowPropertyLabelsBlock(num2str(Block.other2)); BigTitle('Other 2');
                    case 15
                        ShowPropertyLabelsBlock(num2str(Block.other3)); BigTitle('Other 3');
                    case 16
                        ShowPropertyLabelsBlock(num2str(Block.other4)); BigTitle('Other 4');
                    case 17
                        ShowPropertyLabelsBlock(num2str(Block.other5)); BigTitle('Other 5');
                    case 18
                        ShowPropertyLabelsBlock(num2str(Block.other6)); BigTitle('Other 6');
                end
            end
        case 'Seg.modSegListBlock'
            ha = Seg.modSegListBlock;
            value = get(ha, 'Value');
            blockIdx = value - 2;
            %Block = getappdata(gcf, 'Block');
            %nBlocks = numel(Block.interiorLon);
            hMarkedBlock = findobj(Seg.axHandle, 'Tag','SelectedBlock');
            if value > 2
                setappdata(gcf, 'blockIdx', blockIdx);

                % Indicate the selected block
                if isempty(hMarkedBlock)
                    hMarkedBlock = plot(Seg.axHandle, 0,0,'og', 'Tag','SelectedBlock');
                end
                Block = getappdata(gcf,'Block');
                set(hMarkedBlock, 'xdata',Block.interiorLon(blockIdx), 'ydata',Block.interiorLat(blockIdx));

                % Update the selected property's value
                propIdx = get(Seg.modPropListBlock, 'Value');
                if propIdx > 1
                    SegmentManagerFunctions('Seg.modPropListBlock')
                end
            else
                delete(hMarkedBlock);
            end
        case 'Seg.modGSelectBlock'
            Block = getappdata(gcf, 'Block');
            set(findobj(gcf, '-regexp', 'Tag', '^Block.'), 'color', 'g');
            blockIdx = SelectBlockSingle(Block);
            setappdata(gcf, 'blockIdx', blockIdx);

            % Set the listbox and save the segment index segment
            set(Seg.modPropListBlock, 'Value', 1);
            set(Seg.modPropEditBlock, 'String', ' ');
        case 'Seg.modGSelectBlockBox'
            Block = getappdata(gcf, 'Block');
            set(findobj(gcf, '-regexp', 'Tag', '^Block.'), 'color', 'g');

            if ~isempty(Block)
                fprintf(GLOBAL.filestream, 'Starting Box Select\n');
                segRange = GetRangeRbbox(getappdata(gcf, 'Range'));
                segPolyX = [min(segRange.lon) max(segRange.lon) max(segRange.lon) min(segRange.lon)];
                segPolyY = [min(segRange.lat) min(segRange.lat) max(segRange.lat) max(segRange.lat)];
                blockIdx = find(inpolygon(Block.interiorLon, Block.interiorLat, segPolyX, segPolyY) == 1);
                for i = 1:numel(blockIdx)
                    fprintf(GLOBAL.filestream, 'Selected %s\n', Block.name(blockIdx(i), :));
                    set(findobj('Tag', strcat('Block.', num2str(blockIdx(i)))), 'Color', 'r');
                end
                setappdata(gcf, 'blockIdx', blockIdx);
            end
            set(Seg.modPropListBlock, 'Value', 1);
            set(Seg.modPropEditBlock, 'String', ' ');
        case 'Seg.modDeleteBlock'
            Block = getappdata(gcf, 'Block');
            if ~isempty(Block)
                Block = DeleteBlockSingle(Block);
                setappdata(gcf, 'Block', Block);
            end
            SegmentManagerFunctions('RedrawBlocks');
        case 'Seg.modDeleteBlockBox'
            Block = getappdata(gcf, 'Block');
            set(findobj(gcf, '-regexp', 'Tag', '^Block.'), 'color', 'g');

            if ~isempty(Block)
                fprintf(GLOBAL.filestream, 'Starting Box Select\n');
                segRange = GetRangeRbbox(getappdata(gcf, 'Range'));
                segPolyX = [min(segRange.lon) max(segRange.lon) max(segRange.lon) min(segRange.lon)];
                segPolyY = [min(segRange.lat) min(segRange.lat) max(segRange.lat) max(segRange.lat)];
                blockIdx = find(inpolygon(Block.interiorLon, Block.interiorLat, segPolyX, segPolyY) == 1);
                for i = 1:numel(blockIdx)
                    fprintf(GLOBAL.filestream, 'Deleting %s\n', Block.name(blockIdx(i), :));
                    set(findobj('Tag', strcat('Block.', num2str(blockIdx(i)))), 'Color', 'r');
                end
                Block = DeleteBlock(Block, blockIdx);
                setappdata(gcf, 'Block', Block);
                SegmentManagerFunctions('RedrawBlocks');
            end
        case 'Seg.modAddBlock'
            Block = getappdata(gcf, 'Block');
            if ~isempty(Block)
                [Block, newBlockName] = NewBlock(Block);
                setappdata(gcf, 'Block', Block);
                SegmentManagerFunctions('RedrawBlocks');
                SelectSegment('modSegListBlock', newBlockName);
            end
        case 'Seg.modClearBlock'
            SegmentManagerFunctions('RedrawBlocks');
            setappdata(gcf, 'blockIdx', []);
            delete(findobj(Seg.axHandle, 'Tag','SelectedBlock'));
        case 'Seg.modMoveBlock'
            Block = getappdata(gcf, 'Block');
            if ~isempty(Block)
                Block = MoveBlock(Block);
                setappdata(gcf, 'Block', Block);
                SegmentManagerFunctions('RedrawBlocks');
            end
    
        case 'Seg.loadPushMesh'   % Load mesh file
            % Get the name of the mesh file
            filenameFull = GetFilename(Seg.loadEditMesh, 'Mesh', '*.msh; *.mat; *.mshp', '*.m*');
            if isempty(filenameFull),  return;  end

            % Read in the mesh file and plot
            if strmatch(filenameFull(end-4:end), '.mshp')
                P = ReadMshp(filenameFull); % Optional .mshp file containing multiple meshes
            else
                P = ReadPatches(filenameFull, true);  % ignore spaces
            end
            h = patch('Vertices', P.c, 'faces', P.v, 'facecolor','g', 'edgecolor','black', 'tag','Patch');
            setappdata(gcf, 'Patch', P);
            % Enable the display check box
            set(Seg.dispCheckMesh, 'enable', 'on', 'value', 1);
        case 'Seg.dispCheckMesh'  % Mesh display toggle
            ha = findobj(gcf, 'Tag', 'Patch');
            hb = Seg.dispCheckMesh;
            if get(hb, 'Value') == 0
                set(ha, 'Visible','off');
            else
                set(ha, 'Visible','on');
            end
        case 'Seg.clearPushMesh'  % Clear mesh file
            ha = Seg.loadEditMesh;
            set(ha, 'string','');
            delete(findobj(gcf, 'tag','Patch'));
            set(Seg.dispCheckMesh, 'enable','off', 'value',0);
        case 'Seg.snapPushMesh'   % Clear mesh file
            Segment = getappdata(gcf, 'Segment');
            segIdx  = getappdata(gcf, 'segIdx');
            Patch   = getappdata(gcf, 'Patch');
            S = snapsegments(Segment, Patch, segIdx);
            setappdata(gcf, 'Segment', S);
            SegmentManagerFunctions('RedrawSegments');

        %% File integrity functions

        case 'Seg.modCheckSegsBlock'  % Check segment boundaries
            Segment = getappdata(gcf, 'Segment');
            if ~isempty(Segment)
                % Find unique points
                lonVec = [Segment.lon1(:); Segment.lon2(:)];
                latVec = [Segment.lat1(:); Segment.lat2(:)];
                [uCoord1, uIdx1] = unique([lonVec latVec], 'rows', 'first');
                [uCoord2, uIdx2] = unique([lonVec latVec], 'rows', 'last');
                nOccur = uIdx2-uIdx1 + 1;

                if ~isempty(find(nOccur == 1, 1))
                    htemp = msgbox('Segments do not form closed blocks!');
                else
                    htemp = msgbox('All segments form closed blocks');
                end
            end
        case 'Seg.modCheckIpsBlock'  % Check interior points
            Segment = getappdata(gcf, 'Segment');
            Block = getappdata(gcf, 'Block');
            Station = getappdata(gcf, 'Station');
            % Check to see if the station structure really exists
            if ~isempty(Station)
                % If so, just extract the toggled on stations
                Station = structsubset(Station, logical(Station.tog));
            else
                % If not, make a fake station file
                [Station.lon, Station.lat] = deal(0); % fake station file for passing to BlockLabel
            end

            if ~isempty(Segment) && ~isempty(Block)
                try
                    Segment = OrderEndpoints(Segment); % Reorder segment endpoints in a consistent fashion
                    [Segment.midLon, Segment.midLat] = deal((Segment.lon1+Segment.lon2)/2, (Segment.lat1+Segment.lat2)/2);
                    [Segment, Block, Station] = BlockLabel(Segment, Block, Station); % passing true station file or fake station file, if no real station file is loaded
                    % If BlockLabel was successful, check for any blocks lacking stations
                    ub = unique(Station.blockLabel);
                    emptyBlocks = setdiff(1:length(Block.interiorLon), ub);

                    if ~isempty(emptyBlocks) && sum(abs(Station.lon)) ~= 0 % Need this second condition for the case when we haven't loaded a segment file but still want to check IPs
                        for i = 1:length(emptyBlocks)
                            eb(i) = plot(Block.orderLon{emptyBlocks(i)}, Block.orderLat{emptyBlocks(i)}, 'color', 'r', 'linewidth', 3);
                        end
                        legend(eb(1), 'Blocks containing no stations', 'location', 'southeast')
                        setappdata(gcf, 'emptyBlocks', eb);
                    end
                    if numel(Block.orderLon) == numel(Block.interiorLon)
                        htemp = msgbox(sprintf('Interior points uniquely identify %d blocks.', numel(Block.associateLabel)));
                    else

                        noIntPt = setdiff(1:numel(Block.orderLon), unique(Block.associateLabel))
                        for i = 1:length(noip)
                            ni(i) = plot(Block.orderLon{noIntPt(i)}, Block.orderLat{noIntPt(i)}, 'color', 'c', 'linewidth', 3, 'linestyle', '--');
                            setappdata(gcf, 'noIntPt', ni);
                        end
                        if exist('eb', 'var')
                            legend([eb(1); ni(1)], 'Blocks containing no stations', 'Blocks lacking an interior point', 'location', 'southeast')
                        else
                            legend(ni(1), 'Blocks lacking an interior point', 'location', 'southeast')
                        end
                        htemp = msgbox('Interior points do not uniquely identify blocks!');
                    end
                catch
                    htemp = msgbox('Interior points do not uniquely identify blocks!');
                end
            end
        case 'Seg.modSegmentChecker'  % Check for problematic segments
            SegmentManagerFunctions('Seg.modClearSegmentChecks');
            Segment = getappdata(gcf, 'Segment');
            %h = findobj(gcf, '-regexp', 'tag', 'Segment.\d');
            if ~isempty(Segment)
                SegmentCheckerForGui(Segment); %,h)
            end
        case 'Seg.modClearSegmentChecks'  % Clear segment checks
            SegmentManagerFunctions('RedrawSegments');
            legend('deletelegend')
            delete(findobj(Seg.axHandle, 'tag','CheckedSegment')); 
            delete(findobj(Seg.axHandle, 'tag','hang'));
            eb = getappdata(gcf, 'emptyBlocks');
            if ~isempty(eb)
                delete(eb)
                setappdata(gcf, 'emptyBlocks', []);
            end
            ni = getappdata(gcf, 'noIntPt');
            if ~isempty(ni)
                delete(ni)
                setappdata(gcf, 'noIntPt', []);
            end

        %% Start Display Commands

        case 'Seg.dispPushLine'   % Load a line file
            filenameFull = GetFilename(Seg.dispEditLine, 'Line', '*');
            if isempty(filenameFull),  return;  end
            PlotLine(filenameFull);
            set(Seg.dispCheckLine, 'Value',1, 'Enable','on');
        case 'Seg.dispPushXy'     % Load a xy file
            filenameFull = GetFilename(Seg.dispEditXy, 'XY', '*');
            if isempty(filenameFull),  return;  end
            PlotXy(filenameFull);
            set(Seg.dispCheckXy, 'Value',1, 'Enable','on');
        case 'Seg.dispPushSta'    % Load a stations file
            filenameFull = GetFilename(Seg.dispEditSta, 'Stations', '*.sta; *.sta.data', '*.sta*');
            if isempty(filenameFull),  return;  end
            Station = PlotSta(filenameFull);
            PlotStaVec(Station, vecScale)
            setappdata(gcf, 'Station', Station);
            set(Seg.dispCheckSta, 'Value',1, 'Enable','on');
            set(Seg.dispCheckStaNames, 'Enable','on');
        case 'Seg.dispCheckLine'     % Toggle line file visibility
            ha = findobj(gcf, 'Tag', 'lineAll');
            hb = Seg.dispCheckLine;
            if isempty(ha)
                return;
            else
                if get(hb, 'Value') == 0
                    set(ha, 'Visible', 'off');
                elseif get(hb, 'Value') == 1
                    set(ha, 'Visible', 'on');
                end
            end
        case 'Seg.dispCheckXy'       % Toggle xy file visibility
            ha = findobj(gcf, 'Tag', 'xyAll');
            hb = Seg.dispCheckXy;
            if isempty(ha)
                return;
            else
                if get(hb, 'Value') == 0
                    set(ha, 'Visible', 'off');
                elseif get(hb, 'Value') == 1
                    set(ha, 'Visible', 'on');
                end
            end
        case 'Seg.dispCheckSta'      % Toggle station location visibility
            ha = findobj(gcf, 'Tag', 'staAll');
            hb = Seg.dispCheckSta;
            if isempty(ha)
                return;
            else
                if get(hb, 'Value') == 0
                    set(ha, 'Visible', 'off');
                elseif get(hb, 'Value') == 1
                    set(ha, 'Visible', 'on');
                end
            end
        case 'Seg.dispCheckStaNames' % Toggle station name visibility
            ha = findobj(gcf, 'Tag','staNames');
            hb = Seg.dispCheckStaNames;
            delete(ha);
            if get(hb, 'Value')  %isempty(ha) % plot if it doesn't exit
                fprintf(GLOBAL.filestream, 'No station names\n');
                % text command goes here
                Station = getappdata(gcf, 'Station');
                if isempty(Station),  return;  end
                %text(Station.lon, Station.lat, Station.name, 'Interpreter','none', 'FontName','Lucida', 'Tag','staNames', 'FontSize',8);

                % Much faster to limit the labels only to the visible axes area
                hAxes = handle(Seg.axHandle);
                lonLimits = hAxes.XLim;
                latLimits = hAxes.YLim;
                valid = within(Station.lon,lonLimits) & within(Station.lat,latLimits);
                labels = Station.name;
                labels = strcat(char([128,128]), strtrim(labels(valid,:))); labels(labels==128)=' ';
                text(Station.lon(valid), Station.lat(valid), labels, 'Interpreter','none', 'FontName','Lucida', 'Tag','staNames', 'FontSize',8);
            end
        case 'Seg.dispCheckStaVec'   % Toggle vector visibility
            ha = findobj(gcf, 'Tag', 'staAllVec');
            hb = Seg.dispCheckStaVec;
            if isempty(ha)
                fprintf(GLOBAL.filestream, 'No vectors\n');
                return;
            else
                if get(hb, 'Value') == 0
                    set(ha, 'Visible', 'off');
                elseif get(hb, 'Value') == 1
                    set(ha, 'Visible', 'on');
                end
            end
        case 'Seg.dispTopo'       % Toggle topo map visibility
            delete(findobj(gcf, 'Tag','topo'));
            value = get(Seg.dispTopo, 'Value');
            if value == 1
                % plot_google_map('MapType','terrain', 'ShowLabels',0, 'AutoAxis',0)
                xlim = get(gca, 'xlim');
                ylim = get(gca, 'ylim');
                if xlim(1) > 180
                    xlimtemp = xlim - 360;
                else
                    xlimtemp = xlim;
                end

                %set(gca, 'xlim', xlim);
                %set(gca, 'ylim', ylim);
                [lonvec, latvec, map] = my_plot_google_map(xlimtemp, ylim);

                if xlim(1) > 180
                    lonvec = lonvec + 360;
                end
                h = image(lonvec, latvec, map);
                set(gca,'YDir','Normal');
                set(h, 'tag', 'topo');
                uistack(h, 'bottom');
                set(gca, 'xlim', xlim);
                set(gca, 'ylim', ylim);
                set(h, 'visible','on');
            end
        case 'Seg.dispGrid'       % Toggle grid visibility
            value = get(Seg.dispGrid, 'Value');
            if value == 0
                set(gca, 'XGrid', 'off', 'YGrid', 'off');
            elseif value == 1
                set(gca, 'XGrid', 'on', 'YGrid', 'on');
            else
                return;
            end
        case 'Seg.dispDips'       % Toggle Dips visibility
            value = get(Seg.dispDips, 'Value');
            Segment = getappdata(gcf, 'Segment');
            if value == 0
                % Remove surface projection of dipping structures
                h = (findobj(gcf, 'Tag', 'Dips'));
                if ~isempty(h)
                    delete(h);
                end
            elseif value == 1
                % Plot surface projection of dipping structures
                if isempty(Segment),  return;  end
                PlotDips(Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2, Segment.dip, Segment.lDep, Segment.bDep);
            else
                return;
            end
        case 'Seg.dispMeridian'   % Change longitude labeling
            try value = get(Seg.dispMeridian, 'Value'); catch, return; end
            if value == 1
                set(gca, 'XTickLabel', deblank(strjust(num2str(zero22pi(transpose(get(gca, 'XTick')))), 'center')));
            elseif value == 2
                set(gca, 'XTickLabel', deblank(strjust(num2str(npi2pi(transpose(get(gca, 'XTick')))), 'center')));
            else
                return;
            end

        case 'Seg.velPushUp'
            vecScale = 1.1*vecScale;
            ScaleAllVectors(1.1);
        case 'Seg.velPushDown'
            vecScale = 0.9*vecScale;
            ScaleAllVectors(0.9);

        case 'Seg.navZoomRange'   % Start Navigation Commands
            title(Seg.axHandle, 'Select and drag a zoom box', 'FontSize',12);
            setptr(gcf,'glassplus');
            Range = GetRangeRbbox(getappdata(gcf, 'Range'));
            setptr(gcf,'arrow');
            title(Seg.axHandle, '');
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            Range = getappdata(gcf, 'Range');
            Range.lonOld = [Range.lonOld(st:cul+1, :); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, :); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
        case 'Seg.navZoomIn'
            zoomFactor = 0.5;
            Range = getappdata(gcf, 'Range');
            deltaLon = (max(Range.lon) - min(Range.lon)) / 2;
            deltaLat = (max(Range.lat) - min(Range.lat)) / 2;
            centerLon = mean(Range.lon);
            centerLat = mean(Range.lat);
            Range.lon = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
            Range.lat = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, :); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, :); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navZoomOut'
            zoomFactor = 2.0;
            Range = getappdata(gcf, 'Range');
            deltaLon = (max(Range.lon) - min(Range.lon)) / 2;
            deltaLat = (max(Range.lat) - min(Range.lat)) / 2;
            centerLon = mean(Range.lon);
            centerLat = mean(Range.lat);
            Range.lon = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
            Range.lat = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, :); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, :); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navUpdate'
            lonMax = str2num(get(Seg.navEditLonMax, 'string'));
            lonMin = str2num(get(Seg.navEditLonMin, 'string'));
            latMax = str2num(get(Seg.navEditLatMax, 'string'));
            latMin = str2num(get(Seg.navEditLatMin, 'string'));
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navBack'
            Range = getappdata(gcf, 'Range');
            RangeLev = max([1 cul]);
            Range.lon = Range.lonOld(RangeLev, :);
            Range.lat = Range.latOld(RangeLev, :);
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            cul = max([1 RangeLev - 1]);
        case 'Seg.navSW'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navS'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navSE'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon + translateScale * deltaLon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navW'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navC'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lonOld = [Range.lonOld(2:end,:); Range.lon];
            Range.latOld = [Range.latOld(2:end,:); Range.lat];
            k = waitforbuttonpress;
            point = get(gca, 'CurrentPoint');
            point = point(1, 1:2);
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navE'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon + translateScale * deltaLon;
            Range.lat = Range.lat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navNW'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat + translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navN'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon;
            Range.lat = Range.lat + translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
        case 'Seg.navNE'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon + translateScale * deltaLon;
            Range.lat = Range.lat + translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1,:); Range.lon];
            Range.latOld = [Range.latOld(st:cul+1,:); Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);

            % Draw the clean map

        case 'DrawClean'
            %delete(gca);
            %Seg.axHandle = axes('parent',gcf, 'units','pixels', 'position',[360 80 800 700], 'visible','on', 'Tag','Seg.axHandle', 'Layer','top', 'xlim',[0 360], 'ylim',[-90 90], 'nextplot','add');
            delete(allchild(Seg.axHandle));
            WorldHiVectors = load('WorldHiVectors');
            plot(WorldHiVectors.lon, WorldHiVectors.lat, '-k', 'LineWidth', 0.25, 'visible', 'on', 'tag', 'Seg.coastLow', 'Color', 0.7 * [1 1 1]);
            box on;
            Range.lon = [0 360];
            Range.lat = [-90 90];
            Range.lonOld = repmat(Range.lon, ul, 1);
            Range.latOld = repmat(Range.lat, ul, 1);
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);

        case 'DrawSegments'  % Redraw the segments
            Segment = getappdata(gcf, 'Segment');
            % This is slower:
            %{
            nSegments = length(Segment.lon1);
            segnames = cellstr([repmat('Segment.', nSegments, 1) strjust(num2str([1:nSegments]'), 'left')]);
            plotsegs = line([Segment.lon1'; Segment.lon2'], [Segment.lat1'; Segment.lat2'], 'color', 'k');
            set(plotsegs, {'tag'}, segnames);
            return
            %}

            % This is faster:
            lons = [Segment.lon1'; Segment.lon2'; nan(1,numel(Segment.lon2))];
            lats = [Segment.lat1'; Segment.lat2'; nan(1,numel(Segment.lat2))];
            plotsegs = line(lons(:), lats(:), 'color', 'k', 'tag','Segment.1');
            drawnow;
        case 'RedrawSegments'  % Redraw the segments, including update of the name list
            % Delete all old segments
            delete(findobj(gcf, '-regexp', 'tag', '^Segment.\d+'));

            % Sort new Segment structure and update fault name pulldown
            Segment = getappdata(gcf, 'Segment');
            Segment = AlphaSortSegment(Segment);
            setappdata(gcf, 'Segment', Segment);
            set(Seg.modSegList, 'string', cellstr(strvcat(' ', 'Multiple', Segment.name)));

            % Plot segments again
            SegmentManagerFunctions('DrawSegments');
        case 'RedrawBlocks'  % Redraw the blocks, including update of the name list
            % Delete all old block IPs
            delete(findobj(gcf, '-regexp', 'tag', 'Block.\d'));

            % Sort new block structure and update block name pulldown
            Block = getappdata(gcf, 'Block');
            Block = AlphaSortBlock(Block);
            setappdata(gcf, 'Block', Block);
            %ha = Seg.modSegListBlock;
            set(Seg.modSegListBlock, 'string', cellstr(strvcat(' ', 'Multiple', Block.name)));

            % Plot blocks again
            % This is slower:
            %{
            nBlocks = length(Block.interiorLon);
            blnames = cellstr([repmat('Block.', nBlocks, 1) strjust(num2str([1:nBlocks]'), 'left')]);
           %plotbls = line([Block.interiorLon'; Block.interiorLon'], [Block.interiorLat'; Block.interiorLat'], 'color', 'g', 'marker', '.', 'linestyle', 'none');
            plotbls = line([Block.interiorLon'; Block.interiorLon'], [Block.interiorLat'; Block.interiorLat'], 'MarkerFaceColor', 'm', 'MarkerSize', 5, 'marker', 'o', 'linestyle', 'none', 'MarkerEdgeColor', 'k');
            set(plotbls, {'tag'}, blnames);
            %}

            % This is faster:
            lons = [Block.interiorLon'; Block.interiorLon'; nan(1,numel(Block.interiorLon))];
            lats = [Block.interiorLat'; Block.interiorLat'; nan(1,numel(Block.interiorLat))];
            plotbls = line(lons(:), lats(:), 'tag','Block.1', 'MarkerFaceColor','m', 'MarkerSize',5, 'marker','o', 'linestyle','none', 'MarkerEdgeColor','k');
            drawnow;

            % Reset the selected block name to blank
            set(Seg.modSegListBlock, 'Value',1);

        case 'Seg.pszPrint'  % Print the figure
            printdlg(gcf);
        case 'Seg.pszSave'   % Save the figure
            % Get filename
            filename = char(inputdlg('Please enter a base filename', 'Base filename', 1));
            if ~isempty(filename)
                Zumax(gca);
                SaveCurrentFigure(filename);
                delete(gcf);
            else
                return;
            end
        case 'Seg.pszZumax'  % Zumax the figure
            Zumax(gca);
    end

    if nargin < 2 || displayTimingInfo
        fprintf('%s  %-25s %6.2f secs\n', datestr(now,'HH:MM:SS.FFF'), option, toc(t));
    end


function Range = GetRangeRbbox(Range)
    % GetRangeRbbox
    k = waitforbuttonpress;
    point1 = get(gca, 'CurrentPoint');
    finalRect = rbbox;
    point2 = get(gca, 'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    Range.lon = sort([point1(1) point2(1)]);
    Range.lat = sort([point1(2) point2(2)]);

function SelectSegment(listName, entryName)
    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    hList = Seg.(listName);
    allNames = get(hList,'String');
    idx = find(strcmpi(entryName, allNames),1);
    if ~isempty(idx)
        set(hList,'value',idx);
        SegmentManagerFunctions(['Seg.' listName]);
    end
        
function SetAxes(Range)
    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    axis([min(Range.lon) max(Range.lon) min(Range.lat) max(Range.lat)]);
    set(Seg.navEditLonMin, 'string', sprintf('%7.3f', min(Range.lon)));
    set(Seg.navEditLonMax, 'string', sprintf('%7.3f', max(Range.lon)));
    set(Seg.navEditLatMin, 'string', sprintf('%7.3f', min(Range.lat)));
    set(Seg.navEditLatMax, 'string', sprintf('%7.3f', max(Range.lat)));
    yAspect = cos(deg2rad(mean(Range.lat)));
    daspect([1 yAspect 1]);

    if max(Range.lon) == 360
        set(gca, 'XTick', [0 60 120 180 240 300 360]);
        set(gca, 'YTick', [-90 -45 0 45 90]);
    else
        set(gca, 'XTickMode', 'auto');
        set(gca, 'YTickMode', 'auto');
    end
    SegmentManagerFunctions('Seg.dispMeridian');
    SegmentManagerFunctions('Seg.dispTopo');
    SegmentManagerFunctions('Seg.dispCheckStaNames');

function Range = CheckRange(Range)
    % CheckRange
    Range.lon = sort(Range.lon);
    Range.lat = sort(Range.lat);
    Range.lon(Range.lon > 360) = 360;
    Range.lon(Range.lon < 0) = 0;
    Range.lat(Range.lat > 90) = 90;
    Range.lat(Range.lat < -90) = -90;

function PlotLine(filename)
    % *** CHANGED: JPL 7 January 2008 ****
    % open the file
    fid1 = fopen(filename); frewind(fid1);

    in = textscan(fid1, '%s', 'delimiter', '\n', 'whitespace', '');
    in = in{1};
    in = char(in);
    szin = size(in);

    fclose(fid1);

    % find line separators
    in = strjust(in, 'left'); % shift all left
    str = in(:, 1)';
    pat = '[^-\d]';
    blank = regexp(str, pat, 'start');
    in(blank, 1:7) = repmat('NaN NaN', length(blank), 1);
    in = str2num(in);
    plot(zero22pi(in(:, 1)), in(:, 2), '-', 'LineWidth', 0.5, 'Color', 'm', 'Tag', 'lineAll');

function PlotXy(filename)
    % PlotXy
    fileStream = fopen(filename, 'r');
    data = fgetl(fileStream);
    while (ischar(data))
        % Try a conversion to numeric
        vals = str2num(data);
        if ~isempty(vals)
            plot(zero22pi(vals(1)), vals(2), '.k', 'Tag', 'xyAll');
        end

        % Get the next line
        data = fgetl(fileStream);
    end
    fclose(fileStream);

function Station = PlotSta(filename)
    % PlotSta
    Station = ReadStation(filename);
    on = find(Station.tog);
    plot(Station.lon(on), Station.lat(on), 'bo', 'color', [0 0 1], 'MarkerSize', 2, 'MarkerFaceColor', 'b', 'Tag', 'staAll');

function PlotStaVec(Station, vecScale)
    on = find(Station.tog);
    quiver(Station.lon(on), Station.lat(on), vecScale*Station.eastVel(on), vecScale*Station.northVel(on), 0, 'userdata', vecScale, 'color', [0 0 1], 'tag', 'staAllVec', 'visible', 'off');

% Scale station vectors
function ScaleAllVectors(vecScale)
    verstruct = ver;
    if datenum(verstruct(1).Date) >= datenum('08-Sep-2014')
        groups = findobj(gcf, 'type', 'quiver');
    else
        groups = findobj(gcf, 'type', 'hggroup');
    end
    set(groups, 'Udata', vecScale*get(groups, 'UData'));
    set(groups, 'Vdata', vecScale*get(groups, 'VData'));

function DeletePropertyLabels
    ha = findobj('Tag', 'propertyLabel');
    try %if isstruct(get(ha))
        delete(ha);
    catch
        % never mind
    end
    title('');

function DeletePropertyLabelsBlock
    ha = findobj('Tag', 'propertyLabelBlock');
    try %if isstruct(get(ha))
        delete(ha);
    catch
        % never mind
    end
    title('');

function ShowPropertyLabels(labels)
    DeletePropertyLabels;
    Segment = getappdata(gcf, 'Segment');
    lonMid = (Segment.lon1 + Segment.lon2) / 2;
    latMid = (Segment.lat1 + Segment.lat2) / 2;
    extraProps = {'clipping','on', 'FontSize',8, 'HorizontalAlignment','left', 'Tag','propertyLabel', 'FontName','Lucida', 'Interpreter','none'}; %, 'BackgroundColor','none', 'EdgeColor','none'};
    %text(lonMid, latMid, labels, extraProps{:});

    % Much faster to limit the labels only to the visible axes area
    hAxes = handle(gca);
    lonLimits = hAxes.XLim;
    latLimits = hAxes.YLim;
    valid = within(lonMid,lonLimits) & within(latMid,latLimits);
    newLabels = strcat(char([128,128]), strtrim(labels(valid,:))); newLabels(newLabels==128)=' ';
    text(lonMid(valid), latMid(valid), newLabels, extraProps{:});

function idx = within(data,limits)
    idx = data >= limits(1) & data <= limits(2);

function ShowPropertyLabelsBlock(labels)
    DeletePropertyLabelsBlock;
    Block = getappdata(gcf, 'Block');
    extraProps = {'clipping','on', 'FontSize',8, 'HorizontalAlignment','left', 'Tag','propertyLabelBlock', 'FontName','Lucida', 'Interpreter','none'}; %, 'BackgroundColor','none', 'EdgeColor','none'};
    %text(Block.interiorLon, Block.interiorLat, labels, extraProps{:});

    % Much faster to limit the labels only to the visible axes area
    hAxes = handle(gca);
    lonLimits = hAxes.XLim;
    latLimits = hAxes.YLim;
    valid = within(Block.interiorLon,lonLimits) & within(Block.interiorLat,latLimits);
    newLabels = strcat(char([128,128]), strtrim(labels(valid,:))); newLabels(newLabels==128)=' ';
    text(Block.interiorLon(valid), Block.interiorLat(valid), newLabels, extraProps{:});

function BigTitle(label)
    title(label, 'FontSize',16);
