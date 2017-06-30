function ResultManagerFunctions(option, displayTimingInfo)
% ResultManagerFunctions - functions called by ResultManagerGUI

    %tic

    % Declare variables
    global GLOBAL ul cul st Segment plotsegs Obs Mod Res Rot Def Str Tri cSegment cplotsegs cObs cMod cRes cRot cDef cStr cTri vecScale
    translateScale = 0.2;
    if ~exist('vecScale', 'var') || isempty(vecScale)
        vecScale = 0.5;
    end

    % Get the struct holding the uicontrols' direct handles (avoiding runtime findobj() calls)
    %drawnow;
    ud = get(gcf,'UserData');
    Rst = ud.Rst;

    % Parse callbacks
    %fprintf(GLOBAL.filestream, '%s => %s\n', datestr(now,'HH:MM:SS.FFF'), option);
    t=tic;
    switch(option)

        %%%   Start File I/O commands   %%%
        case 'Rst.loadPush'   % Load segment file
            % Delete all the children of the current axes

            % Get the name of the segment file
            ha = Rst.loadEdit; %=findobj(gcf, 'Tag', 'Rst.loadEdit');
            dirname = get(ha, 'string');
            if ~exist(dirname, 'dir')
                try
                    dirname = getpref('Blocks','ResultsDir');
                catch
                    try
                        dirname = getpref('Blocks','CompareDir');
                    catch
                        dirname = pwd;
                    end
                end
                dirname = uigetdir(dirname, 'Choose results directory');
                if dirname == 0
                    return;
                    set(ha, 'string', '');
                else
                    set(ha, 'string', dirname);
                end
                setpref('Blocks','ResultsDir',dirname);
            else
                ResultManagerFunctions('Rst.clearPush');  % clear before reloading
            end

            % Read in the results files
            if exist([dirname filesep 'Mod.segment'],'file')
                Segment = ReadSegmentTri([dirname filesep 'Mod.segment']);
                Rst.SlipText.Enable     = 'on';
                Rst.SlipNumCheck.Enable = 'on';
                Rst.SlipColCheck.Enable = 'on';
                setappdata(gcf, 'Segment', Segment);
                % Plot segments
                plotsegs = DrawSegment(Segment, 'color', 'b', 'tag', 'Segs');
            end

            % Check the extension of station files
            osn = dir([dirname filesep 'Obs.sta*']);
            [~, ~, ext] = fileparts(osn.name);
            if strmatch(ext, '.data')
                ext = '.sta.data';
            end

            if exist([dirname filesep 'Obs' ext],'file')
                Obs = ReadStation([dirname filesep 'Obs' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                Rst.velScaleText.Enable = 'on';
                Rst.ObsvCheck.Enable    = 'on';
            end

            if exist([dirname filesep 'Mod' ext],'file')
                Mod = ReadStation([dirname filesep 'Mod' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                Rst.velScaleText.Enable = 'on';
                Rst.ModvCheck.Enable    = 'on';
            end

            if exist([dirname filesep 'Res' ext],'file')
                Res = ReadStation([dirname filesep 'Res' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.ResvCheck, 'enable', 'on');
                set(Rst.ResmCheck, 'enable', 'on');
                if ~isempty(strmatch(get(Rst.cResvCheck, 'enable'), 'on', 'exact'))
                    set(Rst.ResidImpCheck, 'enable', 'on');
                end
            end

            if exist([dirname filesep 'Rot' ext],'file')
                Rot = ReadStation([dirname filesep 'Rot' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.RotvCheck, 'enable', 'on');
            end

            if exist([dirname filesep 'Def' ext],'file')
                Def = ReadStation([dirname filesep 'Def' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.DefvCheck, 'enable', 'on');
            end

            if exist([dirname filesep 'Strain' ext],'file')
                Str = ReadStation([dirname filesep 'Strain' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.StrvCheck, 'enable', 'on');
            end

            if exist([dirname filesep 'Tri' ext],'file')
                Tri = ReadStation([dirname filesep 'Tri' ext]);
                set([Rst.StanCheck Rst.StatCheck Rst.StavText], 'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.TrivCheck, 'enable', 'on');
            end
            %s = whos('Obs', 'Mod', 'Res', 'Rot', 'Def', 'Str', 'Tri'); % at least one of these exists, or else the button would be inactive
            %varName = eval(s(round(find([s.size], 1)/2)).name);
            %PlotSta (varName, '.k', 'tag', 'Sta', 'visible', 'off')
            %LabelSta(varName, 'color', 'k', 'tag', 'Stan', 'visible', 'off');
            quiver(0, 0, vecScale*10, 0, 0, 'k', 'tag', 'scav', 'visible', 'off', 'userdata', vecScale)
            text(0, 0, '10 mm/yr', 'tag', 'tscav', 'visible', 'off')
            MoveLegend

            % check for optional files
            if exist([dirname filesep 'Strain.block'],'file')
                StrBlock = ReadBlock([dirname filesep 'Strain.block']);
                set(Rst.opText, 'enable', 'on');
            else
                StrBlock = [];
            end
            setappdata(gcf, 'StrBlock', StrBlock)
            set(Rst.StrainCheck,  'enable', 'on');
            set(Rst.velScaleText, 'enable', 'on');

            if exist([dirname filesep 'Mod.patch'],'file')
                [C, V, tSlip] = PatchData([dirname filesep 'Mod.patch']);
                if ~isempty(C)
                    C(:, 1) = wrapTo360(C(:, 1));
                end
                setappdata(gcf, 'C', C); 
                setappdata(gcf, 'V', V); 
                setappdata(gcf, 'tSlip', tSlip);
                set(Rst.TriCheck, 'enable', 'on');
                set(Rst.opText,   'enable', 'on');
            end
        case 'Rst.clearPush'  % Clear directory
            setappdata(gcf, 'Segment', []);
            %set(Rst.loadEdit, 'string', '');
            set(Rst.SlipNumCheck,  'enable', 'off', 'value', 0);
            set(Rst.SlipColCheck,  'enable', 'off', 'value', 0);
            set(Rst.SlipText,      'enable', 'off', 'value', 0);
            set(Rst.StavText,      'enable', 'off', 'value', 0);
            set(Rst.StatCheck,     'enable', 'off', 'value', 0);
            set(Rst.StanCheck,     'enable', 'off', 'value', 0);
            set(Rst.ObsvCheck,     'enable', 'off', 'value', 0);
            set(Rst.ModvCheck,     'enable', 'off', 'value', 0);
            set(Rst.ResvCheck,     'enable', 'off', 'value', 0);
            set(Rst.ResmCheck,     'enable', 'off', 'value', 0);
            set(Rst.RotvCheck,     'enable', 'off', 'value', 0);
            set(Rst.DefvCheck,     'enable', 'off', 'value', 0);
            set(Rst.StrainCheck,   'enable', 'off', 'value', 0);
            set(Rst.StrvCheck,     'enable', 'off', 'value', 0);
            set(Rst.TriCheck,      'enable', 'off', 'value', 0);
            set(Rst.TriDRadio,     'enable', 'off', 'value', 0);
            set(Rst.TriSRadio,     'enable', 'off', 'value', 1);
            set(Rst.TrivCheck,     'enable', 'off', 'value', 0);
            set(Rst.srateColRadio, 'enable', 'off', 'value', 1);
            set(Rst.srateNumRadio, 'enable', 'off', 'value', 1);
            set(Rst.drateColRadio, 'enable', 'off', 'value', 0);
            set(Rst.drateNumRadio, 'enable', 'off', 'value', 0);
            set(Rst.ResidImpCheck, 'enable', 'off', 'value', 0);
            set(Rst.ResidRadioNW,  'enable', 'off', 'value', 0);
            set(Rst.ResidRadioW,   'enable', 'off', 'value', 1);

            delete(findobj(gcf, '-regexp', 'tag', '^Sta')); % delete stations and names
            delete(findobj(gcf, 'tag', 'Segs')); % delete segments
            delete(findobj(gcf, '-regexp', 'tag', '^\w{3,3}[v]')); % delete main vectors
            delete(findobj(gcf, 'tag', 'Resm')); % delete residual magnitudes
            delete(findobj(gcf, '-regexp', 'tag', '^Slip\w{4,4}')); % delete main slip rate object
            delete(findobj(gcf, '-regexp', 'tag', '^diffres')); % delete residual comparisons
            delete(findobj(gcf, '-regexp', 'tag', '^TriSlips\d')); % delete triangular slips
            delete(findobj(gcf, '-regexp', 'tag', '^StrainAxes')); % delete strain axes
            delete(findobj(gcf, 'tag', 'tscav'));
            clear -regexp '[A-Z]\w+'
            try
                rmappdata(gcf, 'StrBlock');
                rmappdata(gcf, 'C');
                rmappdata(gcf, 'V');
                rmappdata(gcf, 'tSlip');
            catch
                % ignore
            end
            colorbar off
        case 'Rst.StatCheck'  % Plot stations
            %ha = findobj(gcf, 'Tag', 'Sta');
            hb = Rst.StatCheck;
            if get(hb, 'Value') == 0
                %set(ha, 'Visible', 'off');
                delete(getappdata(hb,'handles'));
            else
                %set(ha, 'Visible', 'on');
                s = whos('Obs', 'Mod', 'Res', 'Rot', 'Def', 'Str', 'Tri'); % at least one of these exists, or else the button would be inactive
                varName = eval(s(round(find([s.size], 1)/2)).name);
                ha = PlotSta(varName, '.k', 'tag','Sta');
                setappdata(hb,'handles',ha);
            end
        case 'Rst.StanCheck'  % Label stations
            %ha = findobj(gcf, 'Tag', 'Stan');
            hb = Rst.StanCheck;
            delete(findobj(gcf,'Tag','Stan'));
            if get(hb, 'Value') == 0
                %set(ha, 'Visible', 'off');
                delete(getappdata(hb,'handles'));
            else
                %set(ha, 'Visible', 'on');
                s = whos('Obs', 'Mod', 'Res', 'Rot', 'Def', 'Str', 'Tri'); % at least one of these exists, or else the button would be inactive
                varName = eval(s(round(find([s.size], 1)/2)).name);
                ha = LabelSta(varName, 'color','k', 'tag','Stan');
                setappdata(hb,'handles',ha);
            end
        case 'Rst.ObsvCheck'
            ha = findobj(gcf, 'Tag', 'Obsv');
            hb = Rst.ObsvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Obs, vecScale, 'color', 'b', 'tag', 'Obsv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.ModvCheck'
            ha = findobj(gcf, 'Tag', 'Modv');
            hb = Rst.ModvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Mod, vecScale, 'color', 'r', 'tag', 'Modv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.ResvCheck'
            ha = findobj(gcf, 'Tag', 'Resv');
            hb = Rst.ResvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Res, vecScale, 'color', 'm', 'tag', 'Resv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.RotvCheck'
            ha = findobj(gcf, 'Tag', 'Rotv');
            hb = Rst.RotvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Rot, vecScale, 'color', 'g', 'tag', 'Rotv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.DefvCheck'
            ha = findobj(gcf, 'Tag', 'Defv');
            hb = Rst.DefvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Def, vecScale, 'color', 'c', 'tag', 'Defv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.StrvCheck'
            ha = findobj(gcf, 'Tag', 'Strv');
            hb = Rst.StrvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Str, vecScale, 'color', [0 0.5 0.5], 'tag', 'Strv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.TrivCheck'
            ha = findobj(gcf, 'Tag', 'Triv');
            hb = Rst.TrivCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(Tri, vecScale, 'color', [1 .65 0], 'tag', 'Triv', 'visible', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.ResmCheck'
            ha  = findobj(gcf, 'Tag', 'Resm');
            hac = findobj(gcf, 'Tag', 'cResm');
            hb  = Rst.ResmCheck;
            hbc = Rst.cResmCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
                if ~isempty(cRes)
                    set(hbc, 'value', 0, 'enable', 'on');
                end
            else
                if isempty(ha)
                    PlotResMag(Res, vecScale, 'tag', 'Resm', 'visible', 'on', 'clipping', 'on');
                else
                    set(ha, 'Visible', 'on');
                end
                set(hbc, 'value', 0, 'enable', 'off');
                if ~isempty(hac)
                    delete(hac);  %set(hac, 'visible', 'off');
                end
            end
    
        case 'Rst.cloadPush'   % Load the comparison directory results
            % Delete all the childrean of the current axes

            % Get the name of the segment file
            ha = Rst.cloadEdit;
            dirname = get(ha, 'string');
            if ~exist(dirname, 'dir')
                try
                    dirname = getpref('Blocks','CompareDir');
                catch
                    try
                        dirname = getpref('Blocks','ResultsDir');
                    catch
                        dirname = pwd;
                    end
                end
                dirname = uigetdir(dirname, 'Choose compare directory');
                if dirname == 0
                    return;
                    set(ha, 'string', '');
                else
                    set(ha, 'string', dirname);
                end
                setpref('Blocks','CompareDir',dirname);
            else
                ResultManagerFunctions('Rst.cclearPush');  % clear before reloading
            end

            % Read in the results files
            if exist([dirname filesep 'Mod.segment'],'file');
                cSegment = ReadSegmentTri([dirname filesep 'Mod.segment']);
                set(Rst.cSlipNumCheck, 'enable', 'on');
                set(Rst.cSlipColCheck, 'enable', 'on');
                %set(Rst.csrate'), 'enable', 'on');
                %set(Rst.cdrate'), 'enable', 'on');
                setappdata(gcf, 'cSegment', cSegment);
                % Plot segments
                plotsegsc = DrawSegment(cSegment, 'color', 'b', 'linestyle', '--', 'tag', 'cSegs');
            end

            % Check the extension of station files
            osn = dir([dirname filesep 'Obs.sta*']);
            [~, ~, ext] = fileparts(osn.name);
            if strmatch(ext, '.data')
                ext = '.sta.data';
            end

            if exist([dirname filesep 'Obs' ext],'file')
                cObs = ReadStation([dirname filesep 'Obs' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cObsvCheck,   'enable', 'on');
            end

            if exist([dirname filesep 'Mod' ext],'file')
                cMod = ReadStation([dirname filesep 'Mod' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cModvCheck, 'enable', 'on');
            end

            if exist([dirname filesep 'Res' ext],'file')
                cRes = ReadStation([dirname filesep 'Res' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cResvCheck,   'enable', 'on');
                set(Rst.cResmCheck,   'enable', 'on');
                if ~isempty(strmatch(get(Rst.ResvCheck, 'enable'), 'on', 'exact'))
                    set(Rst.ResidImpCheck, 'enable', 'on');
                    % make a bubble legend
                    scatter(0, 0, vecScale*10001, 'k', 'tag', 'diffressca', 'userdata', 1, 'visible', 'off');
                    text(0, 0, '1 mm/yr', 'tag', 'tdiffressca', 'visible', 'off');
                    MoveLegend
                end
            end

            if exist([dirname filesep 'Rot' ext],'file')
                cRot = ReadStation([dirname filesep 'Rot' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cRotvCheck,   'enable', 'on');
            end

            if exist([dirname filesep 'Def' ext],'file')
                cDef = ReadStation([dirname filesep 'Def' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cDefvCheck,   'enable', 'on');
            end

            if exist([dirname filesep 'Strain' ext],'file')
                cStr = ReadStation([dirname filesep 'Strain' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cStrvCheck,   'enable', 'on');
            end

            if exist([dirname filesep 'Tri' ext],'file')
                cTri = ReadStation([dirname filesep 'Tri' ext]);
                set(Rst.cStanCheck,   'enable', 'on');
                set(Rst.cStatCheck,   'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.cTrivCheck,   'enable', 'on');
            end
            %s = who('cObs', 'cMod', 'cRes', 'cRot', 'cDef', 'cStr', 'cTri'); % at least one of these exists, or else the button would be inactive
            %varName = eval(s{1});
            %PlotSta (varName, '.b', 'tag', 'cSta', 'visible', 'off')
            %LabelSta(varName, 'color', 'b', 'tag', 'cStan', 'visible', 'off');

            % check for optional files
            if exist([dirname filesep 'Strain.block'],'file')
                cStrBlock = ReadBlock([dirname filesep 'Strain.block']);
                setappdata(gcf, 'cStrBlock', cStrBlock);
                set(Rst.cStrainCheck, 'enable', 'on');
                set(Rst.velScaleText, 'enable', 'on');
                set(Rst.opText,       'enable', 'on');
            end

            if exist([dirname filesep 'Mod.patch'],'file')
                [cC, cV, ctSlip] = PatchData([dirname filesep 'Mod.patch']);
                setappdata(gcf, 'cC', cC); setappdata(gcf, 'cV', cV); setappdata(gcf, 'ctSlip', ctSlip);
                set(Rst.cTriCheck, 'enable', 'on');
                set(Rst.opText,    'enable', 'on');
            end
        case 'Rst.cclearPush'  % Clear directory
            setappdata(gcf, 'cSegment', []);
            %set(Rst.cloadEdit, 'string', '');
            set(Rst.cSlipNumCheck,  'enable', 'off', 'value', 0);
            set(Rst.cSlipColCheck,  'enable', 'off', 'value', 0);
            set(Rst.cStatCheck,     'enable', 'off', 'value', 0);
            set(Rst.cStanCheck,     'enable', 'off', 'value', 0);
            set(Rst.cObsvCheck,     'enable', 'off', 'value', 0);
            set(Rst.cModvCheck,     'enable', 'off', 'value', 0);
            set(Rst.cResvCheck,     'enable', 'off', 'value', 0);
            set(Rst.cResmCheck,     'enable', 'off', 'value', 0);
            set(Rst.cRotvCheck,     'enable', 'off', 'value', 0);
            set(Rst.cDefvCheck,     'enable', 'off', 'value', 0);
            set(Rst.cStrainCheck,   'enable', 'off', 'value', 0);
            set(Rst.cStrvCheck,     'enable', 'off', 'value', 0);
            set(Rst.cTriCheck,      'enable', 'off', 'value', 0);
            set(Rst.cTriDRadio,     'enable', 'off', 'value', 0);
            set(Rst.cTriSRadio,     'enable', 'off', 'value', 1);
            set(Rst.cTrivCheck,     'enable', 'off', 'value', 0);
            set(Rst.csrateColRadio, 'enable', 'off', 'value', 1);
            set(Rst.csrateNumRadio, 'enable', 'off', 'value', 1);
            set(Rst.cdrateColRadio, 'enable', 'off', 'value', 0);
            set(Rst.cdrateNumRadio, 'enable', 'off', 'value', 0);
            set(Rst.ResidImpCheck,  'enable', 'off', 'value', 0);
            set(Rst.ResidRadioNW,   'enable', 'off', 'value', 0);
            set(Rst.ResidRadioW,    'enable', 'off', 'value', 1);

            delete(findobj(gcf, '-regexp', 'tag', '^cSta')); % delete compare stations and names
            delete(findobj(gcf, 'tag', 'cSegs')); % delete compare segments
            delete(findobj(gcf, '-regexp', 'tag', '^c\w{3,3}[v]')); % delete compare vectors
            delete(findobj(gcf, 'tag', 'cResm')); % delete residual magnitudes
            delete(findobj(gcf, '-regexp', 'tag', '^cSlip\w{4,4}')); % delete compare slip rate object
            delete(findobj(gcf, '-regexp', 'tag', '^diffres')); % delete residual comparisons
            delete(findobj(gcf, '-regexp', 'tag', 'cTriSlips\d')); % delete triangular slips
            delete(findobj(gcf, '-regexp', 'tag', 'cStrainAxes')); % delete strain axes
            delete(findobj(gcf, 'tag', 'tdiffressca'));
            clear -regexp 'c[A-Z]\w+'
            try
                rmappdata(gcf, 'cStrBlock'); 
                rmappdata(gcf, 'cC'); 
                rmappdata(gcf, 'cV'); 
                rmappdata(gcf, 'ctSlip'); 
            catch
                % ignore
            end
            colorbar off
        case 'Rst.cStatCheck'  % Plot stations
            %ha = findobj(gcf, 'Tag', 'cSta');
            hb = Rst.cStatCheck;
            if get(hb, 'Value') == 0
                %set(ha, 'Visible', 'off');
                delete(getappdata(hb,'handles'));
            else
                %set(ha, 'Visible', 'on');
                s = who('cObs', 'cMod', 'cRes', 'cRot', 'cDef', 'cStr', 'cTri'); % at least one of these exists, or else the button would be inactive
                varName = eval(s{1});
                ha = PlotSta (varName, '.b', 'tag','cSta');
                setappdata(hb,'handles',ha);
            end
        case 'Rst.cStanCheck'  % Label stations
            %ha = findobj(gcf, 'Tag', 'cStan');
            hb = Rst.cStanCheck;
            delete(findobj(gcf,'Tag','cStan'));
            if get(hb, 'Value') == 0
                %set(ha, 'Visible', 'off');
                delete(getappdata(hb,'handles'));
            else
                %set(ha, 'Visible', 'on');
                s = who('cObs', 'cMod', 'cRes', 'cRot', 'cDef', 'cStr', 'cTri'); % at least one of these exists, or else the button would be inactive
                varName = eval(s{1});
                ha = LabelSta(varName, 'color','b', 'tag','cStan');
                setappdata(hb,'handles',ha);
            end
        case 'Rst.cObsvCheck'
            ha = findobj(gcf, 'Tag', 'cObsv');
            hb = Rst.cObsvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cObs, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cObsv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cObs, vecScale, 'color', 0.8*[0 0 1], 'tag', 'cObsv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Obsv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cModvCheck'
            ha = findobj(gcf, 'Tag', 'cModv');
            hb = Rst.cModvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cMod, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cModv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cMod, vecScale, 'color', 0.8*[1 0 0], 'tag', 'cModv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Modv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cResvCheck'
            ha = findobj(gcf, 'Tag', 'cResv');
            hb = Rst.cResvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cRes, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cResv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cRes, vecScale, 'color', 0.8*[1 0 1], 'tag', 'cResv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Resv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cRotvCheck'
            ha = findobj(gcf, 'Tag', 'cRotv');
            hb = Rst.cRotvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cRot, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cRotv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cRot, vecScale, 'color', 0.8*[0 1 0], 'tag', 'cRotv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Rotv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cDefvCheck'
            ha = findobj(gcf, 'Tag', 'cDefv');
            hb = Rst.cDefvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cDef, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cDefv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cDef, vecScale, 'color', 0.8*[0 1 1], 'tag', 'cDefv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Defv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cStrvCheck'
            ha = findobj(gcf, 'Tag', 'cStrv');
            hb = Rst.cStrvCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cStr, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cStrv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cStr, vecScale, 'color', 0.8*[0 0.5 0.5], 'tag', 'cStrv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Strv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cTrivCheck'
            ha = findobj(gcf, 'Tag', 'cTriv');
            hb = Rst.cTrivCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    PlotStaVec(cTri, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cTriv', 'visible', 'on', 'linewidth', 2);
                    PlotStaVec(cTri, vecScale, 'color', 0.8*[1 .65 0], 'tag', 'cTriv', 'visible', 'on', 'linewidth', 1);
                    % make sure the main vectors are on top
                    m = findobj(gcf, 'tag', 'Triv');
                    if ~isempty(m)
                        a = get(gca, 'children');
                        i = find(a == m);
                        set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
                    end
                else
                    set(ha, 'Visible', 'on');
                end
            end
            CheckVecScale
        case 'Rst.cResmCheck'
            ha  = findobj(gcf, 'Tag', 'Resm');
            hac = findobj(gcf, 'Tag', 'cResm');
            hb  = Rst.ResmCheck;
            hbc = Rst.cResmCheck;
            if get(hbc, 'Value') == 0
                if isempty(hac)
                    return
                else
                    delete(hac);  %set(hac, 'Visible', 'off');
                end
                if ~isempty(Res)
                    set(hb, 'value', 0, 'enable', 'on');
                end
            else
                if isempty(hac)
                    PlotResMag(cRes, vecScale, 'tag', 'cResm', 'visible', 'on', 'clipping', 'on');
                else
                    set(hac, 'Visible', 'on');
                end
                set(hb, 'value', 0, 'enable', 'off');
                if ~isempty(ha)
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            end
            
        case 'Rst.ResidImpCheck'  % Show residual improvement
            ha = findobj(gcf, '-regexp', 'Tag', '^diffres');
            hb = Rst.ResidImpCheck;
            rads = [Rst.ResidRadioNW Rst.ResidRadioW];
            if get(hb, 'Value') == 0 % unchecked
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                    set(findobj(gcf, '-regexp', 'tag', 'diffressca'), 'visible', 'off');
                end
            else
                set(rads, 'enable', 'on');
                weighted = cell2mat(get(rads, 'value'));
                weighted = find(weighted==max(weighted)) - 1;
                if numel(ha) < 2 % if the bubbles have not yet been plotted...
                    % ...plot them
                    ResidImprove(Res, cRes, vecScale, weighted)
                else
                    set(findobj(gcf, 'tag', ['diffres' num2str(weighted)]), 'Visible', 'on');
                    set(findobj(gcf, 'tag', ['diffres' num2str(setdiff([0 1], weighted))]), 'Visible', 'off');
                end
                set(findobj(gcf, '-regexp', 'tag', 'diffressca'), 'visible', 'on');
            end
        case 'Rst.ResidRadioNW'
            han = findobj('tag', 'diffres0');
            haw = findobj('tag', 'diffres1');
            if ~isempty(haw)
                set(haw, 'visible', 'off')
            end
            if isempty(han)
                ResidImprove(Res, cRes, vecScale, 0)
            else
                set(han, 'visible', 'on')
            end
        case 'Rst.ResidRadioW'
            han = findobj('tag', 'diffres0');
            haw = findobj('tag', 'diffres1');
            if ~isempty(han)
                set(han, 'visible', 'off')
            end
            if isempty(haw)
                ResidImprove(Res, cRes, vecScale, 1)
            else
                set(haw, 'visible', 'on')
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Slip rate plotting, main results %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case 'Rst.SlipNumCheck'  % Numerical slip rates
            ha = findobj(gcf, '-regexp', 'Tag', '^SlipNum');
            hb = Rst.SlipNumCheck;
            rads = [Rst.srateNumRadio Rst.drateNumRadio];
            if get(hb, 'Value') == 0
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                set(rads, 'enable', 'on');
                comp = cell2mat(get(rads, 'value'));
                comp = find(comp==max(comp));
                delete(ha); ha=[];
                if isempty(ha)
                    symb = ['cx'; 'bx'];
                    tgs = ['SlipNums'; 'SlipNumd'];
                    % SlipNumLabel(Segment, comp, symb(comp, :), 'tag', tgs(comp, :));
                    SlipNumLabel(Segment, comp, 0, 0, 'color', 'k', 'tag', tgs(comp, :), 'horizontalalignment', 'right');
                else
                    tgs = get(rads, 'tag');
                    set(findobj(gcf, 'tag', ['SlipNum' tgs{comp}(5)]), 'Visible', 'on');
                    set(findobj(gcf, 'tag', ['SlipNum' tgs{setdiff([1 2], comp)}(5)]), 'Visible', 'off');
                end
            end
        case 'Rst.srateNumRadio'
            has = findobj('tag', 'SlipNums');
            had = findobj('tag', 'SlipNumd');
            if ~isempty(had)
                set(had, 'visible', 'off')
            end
            if isempty(has)
                %   SlipNumLabel(Segment, 1, 'cx', 'tag', 'SlipNums');
                SlipNumLabel(Segment, 1, 0, 0, 'color', 'k', 'tag', 'SlipNums', 'horizontalalignment', 'right');
            else
                set(has, 'visible', 'on')
            end
        case 'Rst.drateNumRadio'
            has = findobj('tag', 'SlipNums');
            had = findobj('tag', 'SlipNumd');
            if ~isempty(has)
                set(has, 'visible', 'off')
            end
            if isempty(had)
                %   SlipNumLabel(Segment, 2, 'bx', 'tag', 'SlipNumd');
                SlipNumLabel(Segment, 2, 0, 0, 'color', 'k', 'tag', 'SlipNumd', 'horizontalalignment', 'right');
            else
                set(had, 'visible', 'on')
            end

        case 'Rst.SlipColCheck'  % Colored slip rates
            ha = findobj(gcf, '-regexp', 'Tag', '^SlipCol');
            hb = Rst.SlipColCheck;
            rads = [Rst.srateColRadio Rst.drateColRadio];
            if get(hb, 'Value') == 0
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                    colorbar off
                end
            else
                %colorbar off
                set(rads, 'enable', 'on');
                comp = cell2mat(get(rads, 'value'));
                comp = find(comp==max(comp));
                cmaps = ['redwhiteblue(256)'; 'bluewhitered(256)'];
                if isempty(ha)
                    symb = ['ro'; 'mo'];
                    tgs = ['SlipCols'; 'SlipCold'];
                    lims = SlipColored(Segment, comp, 'tag', tgs(comp, :), [tgs(comp, :) 'Scale']);
                    caxis(lims)
                    ch = colorbar('east'); %, 'tag', [tgs(comp, :) 'Scale']);
                else
                    tgs = get(rads, 'tag');
                    on  = findobj(gcf, '-regexp', 'tag', ['^SlipCol' tgs{comp}(5)]);
                    off = findobj(gcf, '-regexp', 'tag', ['^SlipCol' tgs{setdiff([1 2], comp)}(5)]);
                    set(on,  'Visible', 'on');
                    set(off, 'Visible', 'off');
                    caxis(get(on(end), 'userdata'))
                    ch = colorbar('east'); %, 'tag', ['SlipCol' tgs{comp}(5) 'Scale']);
                end
                colormap(cmaps(comp, :));
            end
        case 'Rst.srateColRadio'
            has = findobj(gcf, '-regexp', 'tag', '^SlipCols');
            had = findobj(gcf, '-regexp', 'tag', '^SlipCold');
            if ~isempty(had)
                set(had, 'visible', 'off')
            end
            %colorbar off
            if isempty(has)
                slims = SlipColored(Segment, 1, 'tag', 'SlipCols', 'SlipColsScale');
            else
                set(has, 'visible', 'on')
                slims = get(has(end), 'userdata');
            end
            caxis(slims)
            %chs = colorbar('east', 'tag', 'SlipColsScale');
            colormap(redwhiteblue(256));
        case 'Rst.drateColRadio'
            has = findobj(gcf, '-regexp', 'tag', '^SlipCols');
            had = findobj(gcf, '-regexp', 'tag', '^SlipCold');
            if ~isempty(has)
                set(has, 'visible', 'off')
            end
            %colorbar off
            if isempty(had)
                dlims = SlipColored(Segment, 2, 'tag', 'SlipCold', 'SlipColdScale');
            else
                set(had, 'visible', 'on')
                dlims = get(had(end), 'userdata');
            end
            caxis(dlims)
            %chd = colorbar('east', 'tag', 'SlipColdScale');
            colormap(bluewhitered(256));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Slip rate plotting, compare results %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case 'Rst.cSlipNumCheck'  % Numerical slip rates
            ha = findobj(gcf, '-regexp', 'Tag', '^cSlipNum');
            hb = Rst.cSlipNumCheck;
            rads = [Rst.csrateNumRadio Rst.cdrateNumRadio];
            if get(hb, 'Value') == 0
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                set(rads, 'enable', 'on');
                comp = cell2mat(get(rads, 'value'));
                comp = find(comp==max(comp));
                delete(ha); ha=[];
                if isempty(ha)
                    symb = ['rx'; 'mx'];
                    tgs = ['cSlipNums'; 'cSlipNumd'];
                    SlipNumLabel(cSegment, comp, 0, 0, 'tag', tgs(comp, :), 'horizontalalignment', 'left', 'color', 'b');
                else
                    tgs = get(rads, 'tag');
                    set(findobj(gcf, 'tag', ['cSlipNum' tgs{comp}(5)]), 'Visible', 'on');
                    set(findobj(gcf, 'tag', ['cSlipNum' tgs{setdiff([1 2], comp)}(5)]), 'Visible', 'off');
                end
            end
        case 'Rst.csrateNumRadio'
            has = findobj(gcf, 'tag', 'cSlipNums');
            had = findobj(gcf, 'tag', 'cSlipNumd');
            if ~isempty(had)
                set(had, 'visible', 'off')
            end
            if isempty(has)
                SlipNumLabel(cSegment, 1, 0, 0, 'tag', 'cSlipNums', 'horizontalalignment', 'left', 'color', 'b');
            else
                set(has, 'visible', 'on')
            end
        case 'Rst.cdrateNumRadio'
            has = findobj(gcf, 'tag', 'cSlipNums');
            had = findobj(gcf, 'tag', 'cSlipNumd');
            if ~isempty(has)
                set(has, 'visible', 'off')
            end
            if isempty(had)
                SlipNumLabel(cSegment, 2, 0, 0, 'tag', 'cSlipNumd', 'horizontalalignment', 'left', 'color', 'b');
            else
                set(had, 'visible', 'on')
            end
            
        case 'Rst.cSlipColCheck'  % Colored slip rates
            ha = findobj(gcf, '-regexp', 'Tag', '^cSlipCol');
            hb = Rst.cSlipColCheck;
            rads = [Rst.csrateColRadio Rst.cdrateColRadio];
            if get(hb, 'Value') == 0
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                    colorbar off
                end
            else
                %colorbar off
                set(rads, 'enable', 'on');
                comp = cell2mat(get(rads, 'value'));
                comp = find(comp==max(comp));
                cmaps = ['redwhiteblue(256)'; 'bluewhitered(256)'];
                if isempty(ha)
                    tgs = ['cSlipCols'; 'cSlipCold'];
                    lims = SlipColored(cSegment, comp, 'tag', tgs(comp, :), [tgs(comp, :) 'Scale']);
                    caxis(lims)
                    ch = colorbar('east'); %, 'tag', [tgs(comp, :) 'Scale']);
                else
                    tgs = get(rads, 'tag');
                    on  = findobj(gcf, '-regexp', 'tag', ['^cSlipCol' tgs{comp}(6)]);
                    off = findobj(gcf, '-regexp', 'tag', ['^cSlipCol' tgs{setdiff([1 2], comp)}(6)]);
                    set(on,  'Visible', 'on');
                    set(off, 'Visible', 'off');
                    caxis(get(on(end), 'userdata'))
                    ch = colorbar('east'); %, 'tag', ['SlipCol' tgs{comp}(6) 'Scale']);
                end
                colormap(cmaps(comp, :));
            end
        case 'Rst.csrateColRadio'
            has = findobj(gcf, '-regexp', 'tag', '^cSlipCols');
            had = findobj(gcf, '-regexp', 'tag', '^cSlipCold');
            if ~isempty(had)
                set(had, 'visible', 'off')
            end
            %colorbar off
            if isempty(has)
                slims = SlipColored(cSegment, 1, 'tag', 'cSlipCols', 'cSlipColsScale');
            else
                set(has, 'visible', 'on')
                slims = get(has(end), 'userdata');
            end
            caxis(slims)
            %chs = colorbar('east', 'tag', 'cSlipColsScale');
            colormap(redwhiteblue(256));
        case 'Rst.cdrateColRadio'
            has = findobj(gcf, '-regexp', 'tag', '^cSlipCols');
            had = findobj(gcf, '-regexp', 'tag', '^cSlipCold');
            if ~isempty(has)
                set(has, 'visible', 'off')
            end
            %colorbar off
            if isempty(had)
                dlims = SlipColored(cSegment, 2, 'tag', 'cSlipCold', 'cSlipColdScale');
            else
                set(had, 'visible', 'on')
                dlims = get(had(end), 'userdata');
            end
            caxis(dlims)
            %chd = colorbar('east', 'tag', 'cSlipColdScale');
            colormap(bluewhitered(256));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Optional result plotting , main results %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case 'Rst.StrainCheck'
            ha = findobj(gcf, 'Tag', 'StrainAxes');
            hb = Rst.StrainCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    StrBlock = getappdata(gcf, 'StrBlock');
                    PlotStrainAxes(StrBlock, vecScale, 'r', 'b', 'linewidth', 2, 'tag', 'StrainAxes', 'userdata', vecScale)
                else
                    set(ha, 'visible', 'on')
                end
            end
            
        case 'Rst.TriCheck'
            ha = findobj(gcf, '-regexp', 'Tag', '^TriSlips');
            hb = Rst.TriCheck;
            rads = [Rst.TriSRadio Rst.TriDRadio];  %=findobj(gcf,'-regexp','tag','Rst.Tri[A-Z]{2}')
            if get(hb, 'Value') == 0
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                set(rads, 'enable', 'on');
                comp = cell2mat(get(rads, 'value'));
                comp = find(comp==max(comp));
                if isempty(ha)
                    C = getappdata(gcf, 'C');
                    V = getappdata(gcf, 'V');
                    tSlip = getappdata(gcf, 'tSlip');
                    PlotTriSlips(C, V, tSlip(:, comp), 'tag', ['TriSlips' num2str(comp)]);
                else
                    on = findobj(gcf, '-regexp', 'tag', ['^TriSlips' num2str(comp)]);
                    off = findobj(gcf, '-regexp', 'tag', ['^TriSlips' num2str(setdiff([1 2], comp))]);
                    set(on, 'Visible', 'on');
                    set(off, 'Visible', 'off');
                end
            end
        case 'Rst.TriSRadio'
            has = findobj(gcf, 'tag', 'TriSlips1');
            had = findobj(gcf, 'tag', 'TriSlips2');
            if ~isempty(had)
                set(had, 'visible', 'off')
            end
            if isempty(has)
                C = getappdata(gcf, 'C');
                V = getappdata(gcf, 'V');
                tSlip = getappdata(gcf, 'tSlip');
                PlotTriSlips(C, V, tSlip(:, 1), 'tag', 'TriSlips1');
            else
                set(has, 'visible', 'on')
            end
        case 'Rst.TriDRadio'
            has = findobj(gcf, 'tag', 'TriSlips1');
            had = findobj(gcf, 'tag', 'TriSlips2');
            if ~isempty(has)
                set(has, 'visible', 'off')
            end
            if isempty(had)
                C = getappdata(gcf, 'C');
                V = getappdata(gcf, 'V');
                tSlip = getappdata(gcf, 'tSlip');
                PlotTriSlips(C, V, tSlip(:, 2), 'tag', 'TriSlips2');
            else
                set(had, 'visible', 'on')
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Optional result plotting , compare results %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case 'Rst.cStrainCheck'
            ha = findobj(gcf, 'Tag', 'cStrainAxes');
            hb = Rst.cStrainCheck;
            if get(hb, 'Value') == 0
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                if isempty(ha)
                    cStrBlock = getappdata(gcf, 'cStrBlock');
                    PlotStrainAxes(cStrBlock, vecScale, 'r', 'b', 'linewidth', 2, 'tag', 'cStrainAxes', 'userdata', vecScale)
                else
                    set(ha, 'visible', 'on')
                end
            end
        case 'Rst.cTriCheck'
            ha = findobj(gcf, '-regexp', 'Tag', '^cTriSlips');
            hb = Rst.cTriCheck;
            rads = [Rst.cTriSRadio Rst.cTriDRadio];  %=findobj(gcf,'-regexp','tag','Rst.cTri[A-Z]{2}')
            if get(hb, 'Value') == 0
                set(rads, 'enable', 'off');
                if isempty(ha)
                    return
                else
                    delete(ha);  %set(ha, 'Visible', 'off');
                end
            else
                set(rads, 'enable', 'on');
                comp = cell2mat(get(rads, 'value'));
                comp = find(comp==max(comp));
                if isempty(ha)
                    cC = getappdata(gcf, 'cC');
                    cV = getappdata(gcf, 'cV');
                    ctSlip = getappdata(gcf, 'ctSlip');
                    PlotTriSlips(cC, cV, ctSlip(:, comp), 'tag', ['cTriSlips' num2str(comp)]);
                else
                    on = findobj(gcf, '-regexp', 'tag', ['^cTriSlips' num2str(comp)]);
                    off = findobj(gcf, '-regexp', 'tag', ['^cTriSlips' num2str(setdiff([1 2], comp))]);
                    set(on, 'Visible', 'on');
                    set(off, 'Visible', 'off');
                end
            end
        case 'Rst.cTriSRadio'
            has = findobj(gcf, 'tag', 'cTriSlips1');
            had = findobj(gcf, 'tag', 'cTriSlips2');
            if ~isempty(had)
                set(had, 'visible', 'off')
            end
            if isempty(has)
                cC = getappdata(gcf, 'cC');
                cV = getappdata(gcf, 'cV');
                ctSlip = getappdata(gcf, 'ctSlip');
                PlotTriSlips(cC, cV, ctSlip(:, 1), 'tag', 'cTriSlips1');
            else
                set(has, 'visible', 'on')
            end
        case 'Rst.cTriDRadio'
            has = findobj(gcf, 'tag', 'cTriSlips1');
            had = findobj(gcf, 'tag', 'cTriSlips2');
            if ~isempty(has)
                set(has, 'visible', 'off')
            end
            if isempty(had)
                cC = getappdata(gcf, 'cC');
                cV = getappdata(gcf, 'cV');
                ctSlip = getappdata(gcf, 'ctSlip');
                PlotTriSlips(cC, cV, ctSlip(:, 2), 'tag', 'cTriSlips2');
            else
                set(had, 'visible', 'on')
            end


        %%%   Start Display Commands   %%%

        case 'Rst.dispTopo'  % Change topo settings
            value = get(Rst.dispTopo, 'Value');
            if value == 1
                set(findobj(gcf, 'Tag', 'topo'), 'visible', 'off');
                delete(findobj(gcf, 'Tag', 'topo'));
            elseif value == 2
                SocalTopo = load('SocalTopo.mat');
                surf(SocalTopo.lon_mat, SocalTopo.lat_mat, zeros(size(SocalTopo.map)), real(log10(SocalTopo.map)), 'EdgeColor', 'none', 'Tag', 'topo'); colormap(gray);
                set(findobj(gcf, 'Tag', 'topo'), 'visible', 'on');
            else
                return;
            end

        % Change grid settings
        case 'Rst.dispGrid'
            value = get(Rst.dispGrid, 'Value');
            if value == 1
                set(gca, 'XGrid', 'off', 'YGrid', 'off');
            elseif value == 2
                set(gca, 'XGrid', 'on', 'YGrid', 'on');
            else
                return;
            end

        %  Change longitude labeling
        case 'Rst.dispMeridian'
            value = []; %get(Rst.dispMeridian, 'Value');  % dispMeridian is not displayed!!!
            if value == 1
                set(gca, 'XTickLabel', deblank(strjust(num2str(zero22pi(transpose(get(gca, 'XTick')))), 'center')));
            elseif value == 2
                set(gca, 'XTickLabel', deblank(strjust(num2str(npi2pi(transpose(get(gca, 'XTick')))), 'center')));
            else
                return;
            end

        %  Load a line file
        case 'Rst.dispPushLine'
            ha = Rst.dispEditLine;
            filename = get(ha, 'String');
            if exist(filename, 'file')
                filenameFull = strcat(pwd, '\', filename);
            else
                [filename, pathname] = uigetfile({'*'}, 'Load line file');
                if filename == 0
                    return;
                    set(ha, 'string', '');
                else
                    set(ha, 'string', filename);
                    filenameFull = strcat(pathname, filename);
                end
            end
            PlotLine(filenameFull);
            hb = Rst.dispCheckLine;
            set(hb, 'Value', 1);

        %  Toggle the line file visibility
        case 'Rst.dispCheckLine'
            ha = findobj(gcf, 'Tag', 'lineAll');
            hb = Rst.dispCheckLine;
            if isempty(ha)
                return;
            else
                if get(hb, 'Value') == 0
                    delete(ha);  %set(ha, 'Visible', 'off');
                elseif get(hb, 'Value') == 1
                    set(ha, 'Visible', 'on');
                end
            end

        %  Load a xy file
        case 'Rst.dispPushXy'
            ha = Rst.dispEditXy;
            filename = get(ha, 'String');
            if exist(filename, 'file')
                filenameFull = strcat(pwd, '\', filename);
            else
                [filename, pathname] = uigetfile({'*'}, 'Load xy file');
                if filename == 0
                    return;
                    set(ha, 'string', '');
                else
                    set(ha, 'string', filename);
                    filenameFull = strcat(pathname, filename);
                end
            end
            PlotXy(filenameFull);
            hb = Rst.dispCheckXy;
            set(hb, 'Value', 1);

        %  Toggle the xy file visibility
        case 'Rst.dispCheckXy'
            ha = findobj(gcf, 'Tag', 'xyAll');
            hb = Rst.dispCheckXy;
            if isempty(ha)
                return;
            else
                if get(hb, 'Value') == 0
                    delete(ha);  %set(ha, 'Visible', 'off');
                elseif get(hb, 'Value') == 1
                    set(ha, 'Visible', 'on');
                end
            end

        % Vector scale buttons

        case 'Rst.velPushUp'
            vecScale = 1.1*vecScale;
            ScaleAllVectors(1.1);
        case 'Rst.velPushDown'
            vecScale = 0.9*vecScale;
            ScaleAllVectors(0.9);


        %%%   Start Navigation Commands   %%%

        case 'Rst.navZoomRange'
            Range = GetRangeRbbox(getappdata(gcf, 'Range'));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            Range = getappdata(gcf, 'Range');
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            MoveLegend
        case 'Rst.navZoomIn'
            zoomFactor = 0.5;
            Range = getappdata(gcf, 'Range');
            deltaLon = (max(Range.lon) - min(Range.lon)) / 2;
            deltaLat = (max(Range.lat) - min(Range.lat)) / 2;
            centerLon = mean(Range.lon);
            centerLat = mean(Range.lat);
            Range.lon = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
            Range.lat = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navZoomOut'
            zoomFactor = 2.0;
            Range = getappdata(gcf, 'Range');
            deltaLon = (max(Range.lon) - min(Range.lon)) / 2;
            deltaLat = (max(Range.lat) - min(Range.lat)) / 2;
            centerLon = mean(Range.lon);
            centerLat = mean(Range.lat);
            Range.lon = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
            Range.lat = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navUpdate'
            lonMax = str2num(get(Rst.navEditLonMax, 'string'));
            lonMin = str2num(get(Rst.navEditLonMin, 'string'));
            latMax = str2num(get(Rst.navEditLatMax, 'string'));
            latMin = str2num(get(Rst.navEditLatMin, 'string'));
            Range = getappdata(gcf, 'Range');
            Range.lon = [lonMin lonMax];
            Range.lat = [latMin latMax];
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navBack'
            Range = getappdata(gcf, 'Range');
            RangeLev = max([1 cul]);
            Range.lon = Range.lonOld(RangeLev, :);
            Range.lat = Range.latOld(RangeLev, :);
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            cul = max([1 RangeLev - 1]);
            MoveLegend
        case 'Rst.navSW'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navS'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navSE'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon + translateScale * deltaLon;
            Range.lat = Range.lat - translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navW'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navC'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lonOld = [Range.lonOld(2:end, :) ; Range.lon];
            Range.latOld = [Range.latOld(2:end, :) ; Range.lat];
            k = waitforbuttonpress;
            point = get(gca, 'CurrentPoint');
            point = point(1, 1:2);
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navE'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon + translateScale * deltaLon;
            Range.lat = Range.lat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navNW'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon - translateScale * deltaLon;
            Range.lat = Range.lat + translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navN'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon;
            Range.lat = Range.lat + translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend
        case 'Rst.navNE'
            Range = getappdata(gcf, 'Range');
            deltaLon = max(Range.lon) - min(Range.lon);
            deltaLat = max(Range.lat) - min(Range.lat);
            Range.lon = Range.lon + translateScale * deltaLon;
            Range.lat = Range.lat + translateScale * deltaLat;
            Range = CheckRange(Range);
            Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
            Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
            cul = min([size(Range.lonOld, 1)-1 cul+1]);
            st = 1 + (cul==(ul-1));
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);
            MoveLegend

        %  Draw the clean map

        case 'DrawClean'
            delete(gca);
            Rst.axHandle = axes('parent', gcf, 'units', 'pixels', 'position', [360 80 800 700],     'visible', 'on', 'Tag', 'Rst.axHandle', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'nextplot', 'add');
            WorldHiVectors = load('WorldHiVectors');
            coast = plot(WorldHiVectors.lon, WorldHiVectors.lat, '-k', 'LineWidth', 0.25, 'visible', 'on', 'tag', 'Rst.coast', 'Color', 0.7 * [1 1 1]);
            box on;
            Range.lon = [0 360];
            Range.lat = [-90 90];
            Range.lonOld = repmat(Range.lon, ul, 1);
            Range.latOld = repmat(Range.lat, ul, 1);
            setappdata(gcf, 'Range', Range);
            SetAxes(Range);

        case 'Rst.pszPrint'  % Print the figure
            printdlg(gcf);

        %  Save the figure
        case 'Rst.pszSave'
            %%  Get filename
            filename = char(inputdlg('Please enter a base filename', 'Base filename', 1));
            if length(filename) > 0
                Zumax(gca);
                SaveCurrentFigure(filename);
                delete(gcf);
            else
                return;
            end

        %  Zumax the figure
        case 'Rst.pszZumax'
            Zumax(gca);
    end

    if nargin < 2 || displayTimingInfo
        fprintf('%s  %-25s %6.2f secs\n', datestr(now,'HH:MM:SS.FFF'), option, toc(t));
    end
    %toc

%%%%%%%%%%%%%%%%%%%%%%%
%                     %
%      FUNCTIONS      %
%                     %
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get range from drawn rubberband box %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Range = GetRangeRbbox(Range)
    %%  GetRangeRbbox
    k = waitforbuttonpress;
    point1 = get(gca, 'CurrentPoint');
    finalRect = rbbox;
    point2 = get(gca, 'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    Range.lon = sort([point1(1) point2(1)]);
    Range.lat = sort([point1(2) point2(2)]);
end

%%%%%%%%%%%%%%%%%%%
% Set axis limits %
%%%%%%%%%%%%%%%%%%%
function SetAxes(Range)
    %%  SetAxes
    axis equal
    axis([min(Range.lon) max(Range.lon) min(Range.lat) max(Range.lat)]);
    set(Rst.navEditLonMin, 'string', sprintf('%7.3f', min(Range.lon)));
    set(Rst.navEditLonMax, 'string', sprintf('%7.3f', max(Range.lon)));
    set(Rst.navEditLatMin, 'string', sprintf('%7.3f', min(Range.lat)));
    set(Rst.navEditLatMax, 'string', sprintf('%7.3f', max(Range.lat)));
    %yAspect = cos(deg2rad(mean(Range.lat)));
    %daspect([1 yAspect 1]);

    if max(Range.lon) == 360
        set(gca, 'XTick', [0 60 120 180 240 300 360]);
        set(gca, 'YTick', [-90 -45 0 45 90]);
    else
        set(gca, 'XTickMode', 'auto');
        set(gca, 'YTickMode', 'auto');
    end
    ResultManagerFunctions('Rst.dispMeridian');

    ResultManagerFunctions('Rst.SlipNumCheck');
    ResultManagerFunctions('Rst.cSlipNumCheck');

    ResultManagerFunctions('Rst.StanCheck');
    ResultManagerFunctions('Rst.cStanCheck');
end

%%%%%%%%%%%%%%%%%%%%%%
% Check window range %
%%%%%%%%%%%%%%%%%%%%%%
function Range = CheckRange(Range)
    % CheckRange
    Range.lon = sort(Range.lon);
    Range.lat = sort(Range.lat);
    Range.lon(Range.lon > 360) = 360;
    Range.lon(Range.lon < 0) = 0;
    Range.lat(Range.lat > 90) = 90;
    Range.lat(Range.lat < -90) = -90;
end

%%%%%%%%%%%%%%%%%%%%%
% Plot the segments %
%%%%%%%%%%%%%%%%%%%%%
function plotsegs = DrawSegment(Segment, varargin)
    % Note: limiting the display to the axes limits makes the display faster, but this
    % would require special processing upon zoom/pan
    % Now that we unified all plot segments into a single line, it's fast enough that
    % this extra processing is no longer necessary.
    %{
    hAxes = handle(gca);
    lonLimits = hAxes.XLim;
    latLimits = hAxes.YLim;
    valid = (within(Segment.lon1,lonLimits) | within(Segment.lon2,lonLimits)) & ...
            (within(Segment.lat1,latLimits) | within(Segment.lat2,latLimits));
    %plotsegs = line([Segment.lon1(valid)', Segment.lon2(valid)'], ...
    %                [Segment.lat1(valid)', Segment.lat2(valid)'], ...
    %                varargin{:});
    lats = [Segment.lon1(valid)'; Segment.lon2(valid)'; Segment.lon2(valid)'];
    lons = [Segment.lat1(valid)'; Segment.lat2(valid)'; nan(1,sum(valid))];
    %}
    lats = [Segment.lon1'; Segment.lon2'; Segment.lon2'];
    lons = [Segment.lat1'; Segment.lat2'; nan(1,numel(Segment.lat2))];
    plotsegs = line(lats(:), lons(:), varargin{:});
end
function idx = within(data,limits)
    idx = data >= limits(1) & data <= limits(2);
end

%%%%%%%%%%%%%%%%%%%%
% Plot a line file %
%%%%%%%%%%%%%%%%%%%%
function PlotLine(filename)
    % PlotLine
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
    plot(zero22pi(in(:, 1)), in(:, 2), '-', 'LineWidth', 0.5, 'Color', 0.6 * [1 1 1], 'Tag', 'lineAll');
end

%%%%%%%%%%%%%%%%%%%%
% Plot an X-Y file %
%%%%%%%%%%%%%%%%%%%%
function PlotXy(filename)
    % PlotXy
    fileStream = fopen(filename, 'r');
    data = fgetl(fileStream);
    while (isstr(data));
        % Try a conversion to numeric
        vals = str2num(data);
        if ~isempty(vals)
            plot(zero22pi(vals(1)), vals(2), '.k', 'Tag', 'xyAll');
        end

        % Get the next line
        data = fgetl(fileStream);
    end
    fclose(fileStream);
end

%%%%%%%%%%%%%%%%%%%%%
% Plot the stations %
%%%%%%%%%%%%%%%%%%%%%
function h = PlotSta(Station, varargin)
    % PlotSta
    h = plot(Station.lon, Station.lat, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%
% Label the stations %
%%%%%%%%%%%%%%%%%%%%%
function h = LabelSta(Station, varargin)
    % LabelSta
    names = [repmat(' ', numel(Station.lon), 1) Station.name];
    extraProps = {'interpreter', 'none', 'clipping', 'on', 'fontname', 'fixedwidth', varargin{:}};
    %h = text(Station.lon, Station.lat, names, extraProps{:});

    % Much faster to limit the labels only to the visible axes area
    hAxes = handle(gca);
    lonLimits = hAxes.XLim;
    latLimits = hAxes.YLim;
    valid = within(Station.lon,lonLimits) & within(Station.lat,latLimits);
    h = text(Station.lon(valid), Station.lat(valid), names(valid,:), extraProps{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%
% Plot station vectors %
%%%%%%%%%%%%%%%%%%%%%%%%
function PlotStaVec(Station, vecScale, varargin)
    % PlotStaVec
    quiver(Station.lon, Station.lat, vecScale*Station.eastVel, vecScale*Station.northVel, 0, 'userdata', vecScale, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot residual magnitudes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotResMag(Res, vecScale, varargin)
    % Determine residual magnitudes
    rmag = sqrt(Res.eastVel.^2 + Res.northVel.^2);

    % create scale of marker size
    sc = 50;
    cmap = jet(256);
    cidx = ceil(255*((rmag - min(rmag))./(max(rmag) - min(rmag)))) + 1;
    cidx = ceil(255*((rmag - min(rmag))./(5 - min(rmag)))) + 1;
    cidx(cidx>256) = 256;

    cvec = cmap(cidx, :);

    % plotting commands
    rmgc = scatter(Res.lon, Res.lat, sc, cvec, 'filled', varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% Scale station vectors %
%%%%%%%%%%%%%%%%%%%%%%%%%
function ScaleAllVectors(scaleFactor)
    % ScaleAllVectors
    verstruct = ver;
    if datenum(verstruct(1).Date) >= datenum('08-Sep-2014')
        groups = findobj(gcf, 'type', 'quiver');
        vecs = findobj(groups, '-regexp', 'tag', '\w+v');
        bubs = findobj('type', 'scatter');
        saxs = findobj(groups, '-regexp', 'tag', 'StrainAxes$');
    else
        groups = findobj(gcf, 'type', 'hggroup');
        vecs = findobj(groups, '-regexp', 'tag', '\w+v');
        bubs = findobj(groups, '-regexp', 'tag', '^diffres');
        saxs = findobj(groups, '-regexp', 'tag', 'StrainAxes$');
    end
    % scale the vectors
    if ~isempty(vecs)
        if length(vecs) == 1
            ovs = get(vecs, 'userdata');
            ud = (get(vecs, 'udata')*scaleFactor);
            vd = (get(vecs, 'vdata')*scaleFactor);
            set(vecs, 'udata', ud);
            set(vecs, 'vdata', vd);
        else
            ovs = get(vecs(1), 'userdata');
            ud = cellfun(@(x) x*scaleFactor, get(vecs, 'udata'), 'uniformoutput', false);
            vd = cellfun(@(x) x*scaleFactor, get(vecs, 'vdata'), 'uniformoutput', false);
            set(vecs, {'udata'}, ud);
            set(vecs, {'vdata'}, vd);
        end
    end

    % scale the bubbles
    if ~isempty(bubs)
        bv = get(bubs, 'visible');
        if length(bubs) > 1 % actual bubbles exist
            ms = cellfun(@(x) ceil(scaleFactor*abs(x)), get(bubs, 'sizedata'), 'uniformoutput', false);
            set(bubs, {'sizedata'}, ms);
        end
        % Turn bubbles back off if they were off; having some issues in 2009b where, if they're turned on,
        % then turned off, then the vector scale is reset, they'll turn back on
        if length(bubs) == 1
            set(bubs, 'visible', bv);
        else
            set(bubs, {'visible'}, bv);
        end
    end
    %
    % % scale the strain axes
    % if ~isempty(saxs)
    %  ovs = get(saxs(1), 'userdata');
    %  ud = cellfun(@(x) x/ovs*vecScale, get(saxs, 'udata'), 'uniformoutput', false);
    %  vd = cellfun(@(x) x/ovs*vecScale, get(saxs, 'vdata'), 'uniformoutput', false);
    %  set(saxs, {'udata'}, ud);
    %  set(saxs, {'vdata'}, vd);
    %  set(saxs, 'userdata', vecScale)
    % end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show residual improvement %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResidImprove(one, two, vecScale, weighted)
    % ResidImprove

    % compare residual velocities
    if weighted == 0
        oneVel = sqrt(one.eastVel.^2 + one.northVel.^2);
        twoVel = sqrt(two.eastVel.^2 + two.northVel.^2);
    else
        oneVel = sqrt(one.eastVel.^2 + one.northVel.^2)./(sqrt(one.eastSig.^2 + one.northSig.^2));
        twoVel = sqrt(two.eastVel.^2 + two.northVel.^2)./(sqrt(two.eastSig.^2 + two.northSig.^2));
    end

    % Match coordinates
    [tf, ui1, ui2] = intersect([one.lon one.lat], [two.lon two.lat], 'rows');
    noMatch1 = setdiff(1:length(one.lon), ui1);
    noMatch2 = setdiff(1:length(two.lon), ui2);

    %if numel(oneVel) ~= numel(twoVel) % different numbers of stations, need to find common stations based on coordinates
    % coords = [one.lon one.lat; two.lon two.lat];
    % [uv, ui1] = unique(coords, 'rows', 'first');
    % [uv, ui2] = unique(coords, 'rows', 'last');
    % ui = [ui1 ui2];
    % noMatchInd = find(diff(ui, 1, 2) == 0);
    % noMatch = ui1(noMatchInd);
    % noMatch1 = noMatch(find(noMatch <= numel(oneVel)));
    % noMatch2 = noMatch(find(noMatch > numel(oneVel))) - numel(oneVel);
    % matchInd = setdiff(1:size(ui, 1), noMatchInd);
    % ui1 = ui(matchInd, 1);
    % ui2 = ui(matchInd, 2) - numel(oneVel);
    % corObj = 4;
    %else
    % corObj = 3;
    %end

    % take the difference
    dVel = twoVel(ui2) - oneVel(ui1);

    % create scale of marker size
    sc = vecScale*10000;
    ms = ceil(sc*abs(dVel))+1;

    cmap = bluewhitered(256, [min(dVel) max(dVel)]);
    if max(abs(dVel)) ~= 0
        cidx = ceil(255*((dVel - min(dVel))./(max(dVel) - min(dVel)))) + 1;
        cvec = cmap(cidx, :);
    else
        cvec = [1 1 1];
    end

    % plotting commands
    diffc = scatter(two.lon(ui2), two.lat(ui2), ms, cvec, 'filled', 'tag', ['diffres' num2str(weighted)], 'userdata', dVel, 'clipping', 'on');
    ovrly = scatter(two.lon(ui2), two.lat(ui2), ms, 'k', 'tag', ['diffres' num2str(weighted)], 'userdata', dVel, 'clipping', 'on');
    nmtch1 = plot(one.lon(noMatch1), one.lat(noMatch1), 'xk', 'tag', ['diffres' num2str(weighted)]);
    nmtch2 = plot(two.lon(noMatch2), two.lat(noMatch2), 'xk', 'tag', ['diffres' num2str(weighted)]);

    % make sure that bubbles lie beneath any vectors that are plotted
    warning off all
    allobj = get(gca, 'children');
    allvec = findobj(gcf, '-regexp', 'tag', '\w{3,4}v$');
    [otherObj, otherInd] = setdiff(allobj, allvec);
    allobj = [allvec; allobj(sort(otherInd))];
    set(gca, 'children', allobj);
    warning on all
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Label numerical slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SlipNumLabel(Sm, comp, xshift, yshift, varargin)
    if comp == 1
        shift = xshift;
        strs = [strjust(num2str(Sm.ssRate, '%4.1f'), 'right') ...
                repmat('\pm', numel(Sm.lon1), 1) ...
                strjust(num2str(Sm.ssRateSig, '%4.1f'), 'left')];
    else
        shift = yshift;
        strs = [strjust(num2str(Sm.dsRate-Sm.tsRate, '%4.1f'), 'right') ...
                repmat('\pm', numel(Sm.lon1), 1) ...
                strjust(num2str(Sm.dsRateSig+Sm.tsRateSig, '%4.1f'), 'left')];
    end
    % plot(180, 0, varargin{:})
    lons = xshift + (Sm.lon1+Sm.lon2)/2;
    lats = shift  + (Sm.lat1+Sm.lat2)/2;
    extraProps = {'clipping','on', 'FontSize',8, 'HorizontalAlignment','center', varargin{:}};
    %ht = text(lons, lats, strs, extraProps{:});

    % Much faster to limit the labels only to the visible axes area
    hAxes = handle(gca);
    lonLimits = hAxes.XLim;
    latLimits = hAxes.YLim;
    valid = within(lons,lonLimits) & within(lats,latLimits);
    ht = text(lons(valid), lats(valid), strs(valid,:), extraProps{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot colored slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lims = SlipColored(Sm, comp, varargin)
    % plot(170, 0, varargin{:})
    if comp == 1  % Strike-slip
        trate = Sm.ssRate;
        maxRate = max(trate(:));
        minRate = min(trate(:));
        sw = abs(Sm.ssRateSig/2) + eps;
        lims = [minRate maxRate];
        cmap = redwhiteblue(256, lims);
        userData = -[maxRate minRate];
    else  % Dip-slip/tensile
        trate = Sm.dsRate - Sm.tsRate;
        maxRate = max(trate(:));
        minRate = min(trate(:));
        consigs = Sm.dsRateSig + Sm.tsRateSig;
        sw = abs(consigs/2) + eps;
        lims = [minRate maxRate];
        cmap = bluewhitered(256, lims);
        userData = [minRate maxRate];
    end
    lw = abs(trate)/2 + eps;

    % Color code the slip rate
    diffRate = maxRate - minRate;
    trate(trate > maxRate) = maxRate;
    trate(trate < minRate) = minRate;
    cidx = ceil(255*(trate + abs(minRate))./diffRate + 1);
    cvec = cmap(cidx,:);
    colslips = line([Sm.lon1'; Sm.lon2'], [Sm.lat1'; Sm.lat2'], varargin{1:end-1});
    set(colslips, {'color'}, mat2cell(cvec, ones(length(cvec), 1), 3), {'linewidth'}, num2cell(lw), 'userdata', userData);
    sigslips = line([Sm.lon1'; Sm.lon2'], [Sm.lat1'; Sm.lat2'], 'color', 'k', 'tag', [varargin{end-1} 'Wid']);
    set(sigslips, {'LineWidth'}, num2cell(sw));

    % make sure that the colored lines lie beneath all other objects
    allobj = get(gca, 'children');
    first = find(allobj == colslips(end));
    last = find(allobj == colslips(1));
    allobj = [allobj(1:first-1); allobj(last+1:end); colslips(:)];
    set(gca, 'children', allobj);
    drawnow;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot principal strain rate axes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotStrainAxes(Block, vecScale, varargin)
    a = gca;
    BlockStrainAxes(Block, a, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot triangular slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotTriSlips(c, v, bc, varargin)
    h = patch('Vertices', c, 'faces', v, 'facevertexcdata', bc, 'facecolor', 'flat', 'edgecolor', 'black', 'parent', gca, varargin{:});
    colormap(bluewhitered)
end

%%%%%%%%%%%%%%%%%%%
% Move the legend %
%%%%%%%%%%%%%%%%%%%
function MoveLegend
    r = getappdata(gcf, 'Range');
    legLon = r.lon(1) + 0.1*diff(r.lon);
    legLat = r.lat(2) - 0.05*diff(r.lat);

    scav = findobj(gcf, 'tag', 'scav');
    diffressca = findobj(gcf, 'tag', 'diffressca');
    set(scav, 'xdata', legLon, 'ydata', legLat);
    set(diffressca, 'xdata', legLon + 0.03*diff(r.lon), 'ydata', (legLat - 0.05*diff(r.lat)));

    tscav = findobj(gcf, 'tag', 'tscav');
    tdiffressca = findobj(gcf, 'tag', 'tdiffressca');
    set(tscav, 'position', [(legLon - 0.09*diff(r.lon)), legLat, 0]);
    set(tdiffressca, 'position', [(legLon - 0.09*diff(r.lon)), (legLat - 0.05*diff(r.lat)), 0]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check to see whether or not the vector legend should be visible %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckVecScale
    legTags = findobj(gcf, '-regexp', 'tag', 'scav$');
    vecChecks = findobj(gcf, '-regexp', 'tag', 'vCheck');
    on = sum(cell2mat(get(vecChecks, 'value')));
    if on > 0
        set(legTags, 'visible', 'on');
    else
        set(legTags, 'visible', 'off');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call to plot colored line segments %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = mycline(x, y, varargin)
    % MYCLINE  Modification of CLINE, using more line-line conventions.
    %   MYCLINE(X, Y) draws one line segment per column of X and Y.
    %
    %   MYCLINE(X, Y, Z) draws one three-dimensional line segment per
    %   columns of X, Y, and Z.
    %
    %   MYCLINE(X, Y, C) draws one line segment per column of X and Y,
    %   with segment color specified by vector C.
    %
    %   MYCLINE(X, Y, Z, C) draws one three-dimensional line segment
    %   per column of X, Y, and Z, colored by vector C.
    if nargin == 3
        if isequal(size(varargin{1}), size(x)) % Z has been specified
            z = varargin{1};
            c = zeros([size(z) 3]);
            c(:, :, 3) = 1;
        else
            c = varargin{1};
            c = repmat(c(:)', 2, 1);
            z = zeros(size(x));
        end
    elseif nargin == 4
        z = varargin{1};
        c = repmat(varargin{2}(:)', 2, 1);
    elseif nargin == 2
        c = [0 0 1];
        z = zeros(size(x));
    end

    % Do the plotting, using the convention of CLINE but with more line-like notation
    h = patch(x, y, z, c);
    set(h, 'edgecolor', 'flat')
end

%%%%%%%%%%%%%%%%%%%
function BigTitle(label)
    title(label, 'FontSize', 16);
end

end