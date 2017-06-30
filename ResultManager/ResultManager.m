function ResultManager(dir1, dir2)

    % Color variables
    white     = [1 1 1];
    lightGrey = 0.85 * [1 1 1];
    fn        = 'Lucida';
    fs        = 9;

    % I/O options
    global GLOBAL ul cul st;
    GLOBAL.filestream = 1;
    ul  = 10; % number of navigation undo levels
    cul = ul - 1; % current undo level
    st  = 2; % where to start counting the undo levels

    % Open figure
    screensize = get(0, 'screensize');
    figloc = screensize(3:4)./2 - [600 425];
    hFig = figure('Position', [figloc 1200 850], 'Color', lightGrey, 'menubar', 'figure', 'toolbar', 'figure');
    set(hFig, 'MenuBar', 'none', 'ToolBar', 'none');

    % (Result Manager) File I/O controls

    % Main file I/O
    fileYOffset = 775;
    compareXOffset = 170;
    dx = compareXOffset - 10;
    Rst.loadCommandFrame = uicontrol('style', 'frame',      'position', [5 fileYOffset     290 64], 'visible', 'on', 'tag', 'Rst.navFrame', 'BackgroundColor', lightGrey);
    Rst.loadText         = uicontrol('style', 'text',       'position', [10 fileYOffset+41 120 15], 'visible', 'on', 'tag', 'Rst.loadText', 'string', 'Result directory', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.loadEdit         = uicontrol('style', 'edit',       'position', [10 fileYOffset+20 120 20], 'visible', 'on', 'tag', 'Rst.loadEdit', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8);
    Rst.loadPush         = uicontrol('style', 'pushbutton', 'position', [10 fileYOffset+5  60 20],  'visible', 'on', 'tag', 'Rst.loadPush',  'callback', 'ResultManagerFunctions(''Rst.loadPush'')',  'string', 'Load',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.clearPush        = uicontrol('style', 'pushbutton', 'position', [70 fileYOffset+5  60 20],  'visible', 'on', 'tag', 'Rst.clearPush', 'callback', 'ResultManagerFunctions(''Rst.clearPush'')', 'string', 'Clear', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

    % Secondary file I/O
    Rst.cloadText        = uicontrol('style', 'text',       'position', [ 0+compareXOffset fileYOffset+41 120 15], 'visible', 'on', 'tag', 'Rst.cloadText', 'string', 'Compare directory', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.cloadEdit        = uicontrol('style', 'edit',       'position', [ 0+compareXOffset fileYOffset+20 120 20], 'visible', 'on', 'tag', 'Rst.cloadEdit', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8);
    Rst.cloadPush        = uicontrol('style', 'pushbutton', 'position', [ 0+compareXOffset fileYOffset+5  60 20],  'visible', 'on', 'tag', 'Rst.cloadPush',  'callback', 'ResultManagerFunctions(''Rst.cloadPush'')',  'string', 'Load',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.cclearPush       = uicontrol('style', 'pushbutton', 'position', [60+compareXOffset fileYOffset+5  60 20],  'visible', 'on', 'tag', 'Rst.cclearPush', 'callback', 'ResultManagerFunctions(''Rst.cclearPush'')', 'string', 'Clear', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

    % Main results:
    % Check marks for toggling stations/velocities on and off
    stYOffset = 540;
    Rst.StavText         = uicontrol('style', 'text',       'position', [10 185+stYOffset  78 15], 'visible', 'on', 'tag', 'Rst.StavText', 'string', 'Station controls', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.StatCheck        = uicontrol('style', 'checkbox',   'position', [10 165+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.StatCheck', 'callback', 'ResultManagerFunctions(''Rst.StatCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Stations');
    Rst.StanCheck        = uicontrol('style', 'checkbox',   'position', [10 145+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.StanCheck', 'callback', 'ResultManagerFunctions(''Rst.StanCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Station names');
    Rst.ObsvCheck        = uicontrol('style', 'checkbox',   'position', [10 125+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.ObsvCheck', 'callback', 'ResultManagerFunctions(''Rst.ObsvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Observed vels.');
    Rst.ModvCheck        = uicontrol('style', 'checkbox',   'position', [10 105+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.ModvCheck', 'callback', 'ResultManagerFunctions(''Rst.ModvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Modeled vels.');
    Rst.ResvCheck        = uicontrol('style', 'checkbox',   'position', [10  85+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.ResvCheck', 'callback', 'ResultManagerFunctions(''Rst.ResvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Residual vels.');
    Rst.RotvCheck        = uicontrol('style', 'checkbox',   'position', [10  65+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.RotvCheck', 'callback', 'ResultManagerFunctions(''Rst.RotvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Rotation vels.');
    Rst.DefvCheck        = uicontrol('style', 'checkbox',   'position', [10  45+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.DefvCheck', 'callback', 'ResultManagerFunctions(''Rst.DefvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Elastic vels.');
    Rst.StrvCheck        = uicontrol('style', 'checkbox',   'position', [10  25+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.StrvCheck', 'callback', 'ResultManagerFunctions(''Rst.StrvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strain vels.');
    Rst.TrivCheck        = uicontrol('style', 'checkbox',   'position', [10   5+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.TrivCheck', 'callback', 'ResultManagerFunctions(''Rst.TrivCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Triangle vels.');
    Rst.ResmCheck        = uicontrol('style', 'checkbox',   'position', [10 -15+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.ResmCheck', 'callback', 'ResultManagerFunctions(''Rst.ResmCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Residual mags.');

    % labels
    %{
    Rst.StatText         = uicontrol('style', 'text',       'position', [35 160+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.StatText', 'string', 'Stations',       'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.StanText         = uicontrol('style', 'text',       'position', [35 140+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.StanText', 'string', 'Station names',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.ObsvText         = uicontrol('style', 'text',       'position', [35 120+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.ObsvText', 'string', 'Observed vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.ModvText         = uicontrol('style', 'text',       'position', [35 100+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.ModvText', 'string', 'Modeled vels.',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.ResvText         = uicontrol('style', 'text',       'position', [35  80+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.ResvText', 'string', 'Residual vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.RotvText         = uicontrol('style', 'text',       'position', [35  60+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.RotvText', 'string', 'Rotation vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.DefvText         = uicontrol('style', 'text',       'position', [35  40+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.DefvText', 'string', 'Elastic vels.',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.StrvText         = uicontrol('style', 'text',       'position', [35  20+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.StrvText', 'string', 'Strain vels.',   'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.TrivText         = uicontrol('style', 'text',       'position', [35   0+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.TrivText', 'string', 'Triangle vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.ResmText         = uicontrol('style', 'text',       'position', [35 -20+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.ResmText', 'string', 'Residual mags.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %}

    % Comparison results:
    % Check marks for toggling stations/velocities on and off
    %Rst.cStavText       = uicontrol('parent', sst, 'style', 'text', 'position', [0 181 78 15],    'visible', 'on', 'tag', 'Rst.cStavText' , 'string', 'Station controls', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cStatCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset 165+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cStatCheck', 'callback', 'ResultManagerFunctions(''Rst.cStatCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Stations');
    Rst.cStanCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset 145+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cStanCheck', 'callback', 'ResultManagerFunctions(''Rst.cStanCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Station names');
    Rst.cObsvCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset 125+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cObsvCheck', 'callback', 'ResultManagerFunctions(''Rst.cObsvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Observed vels.');
    Rst.cModvCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset 105+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cModvCheck', 'callback', 'ResultManagerFunctions(''Rst.cModvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Modeled vels.');
    Rst.cResvCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset  85+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cResvCheck', 'callback', 'ResultManagerFunctions(''Rst.cResvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Residual vels.');
    Rst.cRotvCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset  65+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cRotvCheck', 'callback', 'ResultManagerFunctions(''Rst.cRotvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Rotation vels.');
    Rst.cDefvCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset  45+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cDefvCheck', 'callback', 'ResultManagerFunctions(''Rst.cDefvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Elastic vels.');
    Rst.cStrvCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset  25+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cStrvCheck', 'callback', 'ResultManagerFunctions(''Rst.cStrvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strain vels.');
    Rst.cTrivCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset   5+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cTrivCheck', 'callback', 'ResultManagerFunctions(''Rst.cTrivCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Triangle vels.');
    Rst.cResmCheck       = uicontrol('style', 'checkbox',   'position', [ 0+compareXOffset -15+stYOffset dx 20], 'visible', 'on', 'tag', 'Rst.cResmCheck', 'callback', 'ResultManagerFunctions(''Rst.cResmCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Residual mags.');

    % labels
    %{
    Rst.cStatText        = uicontrol('style', 'text', 'position', [25+compareXOffset 160+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cStatText', 'string', 'Stations',       'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.StanText         = uicontrol('style', 'text', 'position', [25+compareXOffset 140+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cStanText', 'string', 'Station names',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cObsvText        = uicontrol('style', 'text', 'position', [25+compareXOffset 120+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cObsvText', 'string', 'Observed vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cModvText        = uicontrol('style', 'text', 'position', [25+compareXOffset 100+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cModvText', 'string', 'Modeled vels.',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cResvText        = uicontrol('style', 'text', 'position', [25+compareXOffset  80+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cResvText', 'string', 'Residual vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cRotvText        = uicontrol('style', 'text', 'position', [25+compareXOffset  60+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cRotvText', 'string', 'Rotation vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cDefsvText       = uicontrol('style', 'text', 'position', [25+compareXOffset  40+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cDefvText', 'string', 'Elastic vels.',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cStrvText        = uicontrol('style', 'text', 'position', [25+compareXOffset  20+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cStrvText', 'string', 'Strain vels.',   'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cTrivText        = uicontrol('style', 'text', 'position', [25+compareXOffset   0+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cTrivText', 'string', 'Triangle vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cResmText        = uicontrol('style', 'text', 'position', [25+compareXOffset -20+stYOffset 85 20],    'visible', 'on', 'tag', 'Rst.cResmText', 'string', 'Residual mags.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %}

    % +/- Buttons to control velocity scaling (operates on ALL plotted vectors identically)
    vecscaleYOffset = 470;
    Rst.velScaleText     = uicontrol('style', 'text', 'position', [10 25+vecscaleYOffset 78 15], 'visible', 'on', 'tag', 'Rst.velScaleText', 'string', 'Vector scaling', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.velPushUp        = uicontrol('style', 'push', 'position', [10 0+vecscaleYOffset 20 20], 'String', '+', 'visible', 'on', 'tag', 'Rst.velPushUp',   'callback', 'ResultManagerFunctions(''Rst.velPushUp'')',   'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 12, 'enable', 'on', 'tooltipstring', 'Increase velocity vector scaling');
    Rst.velPushDown      = uicontrol('style', 'push', 'position', [30 0+vecscaleYOffset 20 20], 'String', '-', 'visible', 'on', 'tag', 'Rst.velPushDown', 'callback', 'ResultManagerFunctions(''Rst.velPushDown'')', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 12, 'enable', 'on', 'tooltipstring', 'Decrease velocity vector scaling');

    % Residual improvement
    resimpYOffset = 400;
    Rst.ResidImpCheck     = uicontrol    ('style', 'checkbox', 'position', [10 20+resimpYOffset 290 20],  'visible', 'on', 'tag', 'Rst.ResidImpCheck', 'callback', 'ResultManagerFunctions(''Rst.ResidImpCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show residual improvement');
    %Rst.ResidImpCheckText = uicontrol   ('style', 'text',     'position', [35 15+resimpYOffset 265 20], 'visible', 'on', 'tag', 'Rst.ResidImpCheckText', 'string', 'Show residual improvement', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.pickResid         = uibuttongroup('units', 'pixels',   'position', [20 0+resimpYOffset 290 20], 'tag', 'Rst.pickResid', 'SelectionChangeFcn', @pickResid, 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.ResidRadioW       = uicontrol    ('style', 'radio',    'position', [0 0 150 20],    'parent', Rst.pickResid, 'visible', 'on', 'tag', 'Rst.ResidRadioW',  'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Weighted by uncertainty');
    Rst.ResidRadioNW      = uicontrol    ('style', 'radio',    'position', [150 0 150 20],  'parent', Rst.pickResid, 'visible', 'on', 'tag', 'Rst.ResidRadioNW', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Unweighted');
    %Rst.ResidRadioTextW  = uicontrol    ('style', 'text',     'position', [25 -5 120 20], 'parent', Rst.pickResid, 'visible', 'on', 'tag', 'Rst.ResidRadioTextW',  'string', 'Weighted by uncertainty', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.ResidRadioTextNW = uicontrol    ('style', 'text',     'position', [165 -5 80 20], 'parent', Rst.pickResid, 'visible', 'on', 'tag', 'Rst.ResidRadioTextNW', 'string', 'Unweighted',              'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');

    % Main results:
    % Toggle slip rate views
    srYOffset = 220;
    Rst.SlipText          = uicontrol('style', 'text',       'position', [10 srYOffset+131 85 20],  'visible', 'on', 'tag', 'Rst.SlipText', 'string', 'Slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.SlipNumCheck      = uicontrol('style', 'checkbox',   'position', [10 srYOffset+115 145 20], 'visible', 'on', 'tag', 'Rst.SlipNumCheck', 'callback', 'ResultManagerFunctions(''Rst.SlipNumCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show numerical rates');
    %Rst.SlipNumCheckText = uicontrol('style', 'text',       'position', [35 srYOffset+110 120 20], 'visible', 'on', 'tag', 'Rst.SlipNumCheckText', 'string', 'Show numerical rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.SlipNumComp       = uibuttongroup('units', 'pixels', 'position', [20 srYOffset+75 150 40], 'tag', 'Rst.SlipNumComp', 'SelectionChangeFcn', @SlipNumComp, 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.srateNumRadio     = uicontrol('style', 'radio',      'position', [0 20 150 20], 'parent', Rst.SlipNumComp, 'visible', 'on', 'tag', 'Rst.srateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strike-slip');
    Rst.drateNumRadio     = uicontrol('style', 'radio',      'position', [0  0 150 20], 'parent', Rst.SlipNumComp, 'visible', 'on', 'tag', 'Rst.drateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Dip-slip/tensile');
    %Rst.srateNumText     = uicontrol('style', 'text',       'position', [55 srYOffset+90 85 20],   'visible', 'on', 'tag', 'Rst.srateNumText', 'string', 'Strike-slip',      'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.drateNumText     = uicontrol('style', 'text',       'position', [55 srYOffset+70 85 20],   'visible', 'on', 'tag', 'Rst.drateNumText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.SlipColCheck      = uicontrol('style', 'checkbox',   'position', [10 srYOffset+45 160 20],   'visible', 'on', 'tag', 'Rst.SlipColCheck', 'callback', 'ResultManagerFunctions(''Rst.SlipColCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show colored line rates');
    %Rst.SlipColCheckText = uicontrol('style', 'text',       'position', [35 srYOffset+40 120 20],  'visible', 'on', 'tag', 'Rst.SlipColCheckText', 'string', 'Show colored line rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.SlipColComp       = uibuttongroup('units', 'pixels', 'position', [20 srYOffset+5 150 40], 'tag', 'Rst.SlipColComp', 'SelectionChangeFcn', @SlipColComp,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.srateColRadio     = uicontrol('style', 'radio',      'position', [0 20 150 20], 'parent', Rst.SlipColComp, 'visible', 'on', 'tag', 'Rst.srateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strike-slip');
    Rst.drateColRadio     = uicontrol('style', 'radio',      'position', [0  0 150 20], 'parent', Rst.SlipColComp, 'visible', 'on', 'tag', 'Rst.drateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Dip-slip/tensile');
    %Rst.srateColText     = uicontrol('style', 'text',       'position', [55 srYOffset+20 85 20],   'visible', 'on', 'tag', 'Rst.srateColText', 'string', 'Strike-slip',      'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.drateColText     = uicontrol('style', 'text',       'position', [55 srYOffset+0 85 20],    'visible', 'on', 'tag', 'Rst.drateColText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');

    % Comparison results:
    % Toggle slip rate views
    %Rst.cSlipText        = uicontrol('style', 'text', 'position',       [compareXOffset+0  srYOffset+131 85 20],  'visible', 'on', 'tag', 'Rst.cSlipText', 'string', 'Slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cSlipNumCheck     = uicontrol('style', 'checkbox',   'position', [compareXOffset+0  srYOffset+115 160 20],  'visible', 'on', 'tag', 'Rst.cSlipNumCheck', 'callback', 'ResultManagerFunctions(''Rst.cSlipNumCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show numerical rates');
    %Rst.cSlipNumCheckText= uicontrol('style', 'text',       'position', [compareXOffset+25 srYOffset+110 120 20], 'visible', 'on', 'tag', 'Rst.cSlipNumCheckText', 'string', 'Show numerical rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cSlipNumComp      = uibuttongroup('units', 'pixels', 'position', [compareXOffset+20 srYOffset+75 150 40], 'tag', 'Rst.cSlipNumComp', 'SelectionChangeFcn', @cSlipNumComp, 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.csrateNumRadio    = uicontrol('style', 'radio',      'position', [0 20 150 20], 'parent', Rst.cSlipNumComp, 'visible', 'on', 'tag', 'Rst.csrateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strike-slip');
    Rst.cdrateNumRadio    = uicontrol('style', 'radio',      'position', [0  0 150 20], 'parent', Rst.cSlipNumComp, 'visible', 'on', 'tag', 'Rst.cdrateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Dip-slip/tensile');
    %Rst.csrateNumText    = uicontrol('style', 'text',       'position', [compareXOffset+45 srYOffset+90 85 20],   'visible', 'on', 'tag', 'Rst.csrateNumText', 'string', 'Strike-slip',      'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.cdrateNumText    = uicontrol('style', 'text',       'position', [compareXOffset+45 srYOffset+70 85 20],   'visible', 'on', 'tag', 'Rst.cdrateNumText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cSlipColCheck     = uicontrol('style', 'checkbox',   'position', [compareXOffset+0  srYOffset+45 160 20],   'visible', 'on', 'tag', 'Rst.cSlipColCheck', 'callback', 'ResultManagerFunctions(''Rst.cSlipColCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show colored line rates');
    %Rst.cSlipColCheckText= uicontrol('style', 'text',       'position', [compareXOffset+25 srYOffset+40 120 20],  'visible', 'on', 'tag', 'Rst.cSlipColCheckText', 'string', 'Show colored line rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cSlipColComp      = uibuttongroup('units', 'pixels', 'position', [compareXOffset+20 srYOffset+5 150 40], 'tag', 'Rst.cSlipColComp', 'SelectionChangeFcn', @cSlipColComp,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.csrateColRadio    = uicontrol('style', 'radio',      'position', [0 20 150 20], 'parent', Rst.cSlipColComp, 'visible', 'on', 'tag', 'Rst.csrateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strike-slip');
    Rst.cdrateColRadio    = uicontrol('style', 'radio',      'position', [0  0 150 20], 'parent', Rst.cSlipColComp, 'visible', 'on', 'tag', 'Rst.cdrateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Dip-slip/tensile');
    %Rst.csrateColText    = uicontrol('style', 'text',       'position', [compareXOffset+45 srYOffset+20 85 20],   'visible', 'on', 'tag', 'Rst.csrateColText', 'string', 'Strike-slip',      'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.cdrateColText    = uicontrol('style', 'text',       'position', [compareXOffset+45 srYOffset+0 85 20],    'visible', 'on', 'tag', 'Rst.cdrateColText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');

    % Main results:
    % Strain axis and triangular slip plotting options
    opYOffset = 100;
    Rst.opText            = uicontrol('style', 'text',     'position', [10 opYOffset+81 85 20],  'visible', 'on', 'tag', 'Rst.opText', 'string', 'Optional results', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.StrainCheck       = uicontrol('style', 'checkbox', 'position', [10 opYOffset+65 160 20], 'visible', 'on', 'tag', 'Rst.StrainCheck', 'callback', 'ResultManagerFunctions(''Rst.StrainCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show princ. strain axes');
    %Rst.StrainCheckText  = uicontrol('style', 'text',     'position', [35 opYOffset+60 120 20], 'visible', 'on', 'tag', 'Rst.StrainCheckText', 'string', 'Show princ. strain axes', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.TriCheck          = uicontrol('style', 'checkbox', 'position', [10 opYOffset+45 160 20], 'visible', 'on', 'tag', 'Rst.TriCheck',    'callback', 'ResultManagerFunctions(''Rst.TriCheck'')',    'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show triangular slip rates');
    %Rst.TriCheckText     = uicontrol('style', 'text',     'position', [35 opYOffset+40 120 20], 'visible', 'on', 'tag', 'Rst.TriCheckText', 'string', 'Show triangular slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.CompTri       = uibuttongroup('units', 'pixels',   'position', [30 opYOffset+5 150 40], 'tag', 'Rst.CompTri', 'SelectionChangeFcn', @CompTri,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.TriSRadio         = uicontrol('style', 'radio',    'position', [0 20 150 20], 'parent', Rst.CompTri, 'visible', 'on', 'tag', 'Rst.TriSRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strike-slip');
    Rst.TriDRadio         = uicontrol('style', 'radio',    'position', [0  0 150 20], 'parent', Rst.CompTri, 'visible', 'on', 'tag', 'Rst.TriDRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Dip-slip/tensile');
    %Rst.TriSText         = uicontrol('style', 'text',     'position', [55 opYOffset+20 85 20],  'visible', 'on', 'tag', 'Rst.TriSText', 'string', 'Strike-slip',      'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.TriDText         = uicontrol('style', 'text',     'position', [55 opYOffset+0 85 20],   'visible', 'on', 'tag', 'Rst.TriDText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');

    % Comparison results:
    % Strain axis and triangular slip plotting options

    %Rst.copText          = uicontrol('parent', sop, 'style', 'text', 'position', [0 81 85 20],    'visible', 'on', 'tag', 'Rst.copText', 'string', 'Optional results', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cStrainCheck      = uicontrol('style', 'checkbox', 'position', [compareXOffset+0 opYOffset+65 160 20],  'visible', 'on', 'tag', 'Rst.cStrainCheck', 'callback', 'ResultManagerFunctions(''Rst.cStrainCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show princ. strain axes');
    %Rst.cStrainCheckText = uicontrol('style', 'text',     'position', [compareXOffset+25 opYOffset+60 120 20], 'visible', 'on', 'tag', 'Rst.cStrainCheckText', 'string', 'Show princ. strain axes', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cTriCheck         = uicontrol('style', 'checkbox', 'position', [compareXOffset+0 opYOffset+45 160 20],  'visible', 'on', 'tag', 'Rst.cTriCheck',    'callback', 'ResultManagerFunctions(''Rst.cTriCheck'')',    'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Show triangular slip rates');
    %Rst.cTriCheckText    = uicontrol('style', 'text',     'position', [compareXOffset+25 opYOffset+40 120 20], 'visible', 'on', 'tag', 'Rst.cTriCheckText', 'string', 'Show triangular slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    Rst.cCompTri      = uibuttongroup('units', 'pixels',   'position', [compareXOffset+20 opYOffset+5 150 40], 'tag', 'Rst.cCompTri', 'SelectionChangeFcn', @cCompTri,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none');
    Rst.cTriSRadio        = uicontrol('style', 'radio',    'position', [0 20 150 20], 'parent', Rst.cCompTri, 'visible', 'on', 'tag', 'Rst.cTriSRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Strike-slip');
    Rst.cTriDRadio        = uicontrol('style', 'radio',    'position', [0  0 150 20], 'parent', Rst.cCompTri, 'visible', 'on', 'tag', 'Rst.cTriDRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off', 'string', 'Dip-slip/tensile');
    %Rst.cTriSText        = uicontrol('style', 'text',     'position', [compareXOffset+45 opYOffset+20 85 20],  'visible', 'on', 'tag', 'Rst.cTriSText', 'string', 'Strike-slip',      'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
    %Rst.cTriDText        = uicontrol('style', 'text',     'position', [compareXOffset+45 opYOffset+0 85 20],   'visible', 'on', 'tag', 'Rst.cTriDText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');

    % (Result Manager) Additional features frame
    %{
    %% Rst.dispFrame      = uicontrol('style', 'frame',      'position', [5 90 290 75],    'visible', 'on', 'tag', 'Rst.dispFrame', 'BackgroundColor', lightGrey);
    %Rst.dispText         = uicontrol('style', 'text',       'position', [10 156 36 15],   'visible', 'on', 'tag', 'Rst.dispText', 'string', 'Display', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    %
    %% (Result Manager) Load line file
    %Rst.dispEditLine     = uicontrol('style', 'edit',       'position', [10 135 100 20],  'visible', 'on', 'tag', 'Rst.dispEditLine', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8, 'FontName', fn, 'FontSize', fs);
    %Rst.dispPushLine     = uicontrol('style', 'pushbutton', 'position', [115 135 30 20],  'visible', 'on', 'tag', 'Rst.dispPushLine', 'string', 'Load', 'callback', 'ResultManagerFunctions(''Rst.dispPushLine'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    %Rst.dispTextLine     = uicontrol('style', 'text',       'position', [150 135 100 18], 'visible', 'on', 'tag', 'Rst.dispTextLine', 'string', 'line file', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    %Rst.dispCheckLine    = uicontrol('style', 'checkbox',   'position', [200 135 20 20],  'visible', 'on', 'tag', 'Rst.dispCheckLine', 'callback', 'ResultManagerFunctions(''Rst.dispCheckLine'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
    %
    %% (Result Manager) Load xy file
    %Rst.dispEditXy       = uicontrol('style', 'edit',       'position', [10 115 100 20],  'visible', 'on', 'tag', 'Rst.dispEditXy', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8, 'FontName', fn, 'FontSize', fs);
    %Rst.dispPushXy       = uicontrol('style', 'pushbutton', 'position', [115 115 30 20],  'visible', 'on', 'tag', 'Rst.dispPushXy', 'string', 'Load', 'callback', 'ResultManagerFunctions(''Rst.dispPushXy'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    %Rst.dispTextXy       = uicontrol('style', 'text',       'position', [150 115 100 18], 'visible', 'on', 'tag', 'Rst.dispTextXy', 'string', 'xy file', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    %Rst.dispCheckXy      = uicontrol('style', 'checkbox',   'position', [200 115 20 20],  'visible', 'on', 'tag', 'Rst.dispCheckXy', 'callback', 'ResultManagerFunctions(''Rst.dispCheckXy'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
    %
    %% (Result Manager) Topo, Grid lines, and meridian popups
    %Rst.dispTopo         = uicontrol('style', 'popupmenu',  'position', [220 135 70 20],  'visible', 'on', 'tag', 'Rst.dispTopo',     'callback', 'ResultManagerFunctions(''Rst.dispTopo'')',     'string', {'No topo', 'SoCal'},      'BackgroundColor', white, 'FontName', fn, 'FontSize', fs);
    %Rst.dispGrid         = uicontrol('style', 'popupmenu',  'position', [220 115 70 20],  'visible', 'on', 'tag', 'Rst.dispGrid',     'callback', 'ResultManagerFunctions(''Rst.dispGrid'')',     'string', {'Grid off', 'Grid on'},   'BackgroundColor', white, 'FontName', fn, 'FontSize', fs);
    %Rst.dispMeridian     = uicontrol('style', 'popupmenu',  'position', [220 95 70 20],   'visible', 'on', 'tag', 'Rst.dispMeridian', 'callback', 'ResultManagerFunctions(''Rst.dispMeridian'')', 'string', {'[0 360]', '[-180 180]'}, 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs);
    %}

    % (Result Manager) Navigate frame and navigation rose buttons
    nav = uipanel('units', 'pixels', 'position', [10 10 290 80], 'bordertype', 'none', 'backgroundcolor', lightGrey);
    Rst.navText          = uicontrol('parent', nav, 'style', 'text',       'position', [0 56 44 20],   'visible', 'on', 'tag', 'Rst.navText', 'string', 'Navigate', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.navSW            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [220 0 20 20],  'visible', 'on', 'tag', 'Rst.navSW',   'string', 'SW', 'callback', 'ResultManagerFunctions(''Rst.navSW'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navS             = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [240 0 20 20],  'visible', 'on', 'tag', 'Rst.navS',    'string', 'S',  'callback', 'ResultManagerFunctions(''Rst.navS'')',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navSE            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [260 0 20 20],  'visible', 'on', 'tag', 'Rst.navSE',   'string', 'SE', 'callback', 'ResultManagerFunctions(''Rst.navSE'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navW             = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [220 20 20 20], 'visible', 'on', 'tag', 'Rst.navW',    'string', 'W',  'callback', 'ResultManagerFunctions(''Rst.navW'')',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navC             = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [240 20 20 20], 'visible', 'on', 'tag', 'Rst.navC',    'string', 'C',  'callback', 'ResultManagerFunctions(''Rst.navC'')',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navE             = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [260 20 20 20], 'visible', 'on', 'tag', 'Rst.navE',    'string', 'E',  'callback', 'ResultManagerFunctions(''Rst.navE'')',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navNW            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [220 40 20 20], 'visible', 'on', 'tag', 'Rst.navNW',   'string', 'NW', 'callback', 'ResultManagerFunctions(''Rst.navNW'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navN             = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [240 40 20 20], 'visible', 'on', 'tag', 'Rst.navN',    'string', 'N',  'callback', 'ResultManagerFunctions(''Rst.navN'')',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navNE            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [260 40 20 20], 'visible', 'on', 'tag', 'Rst.navNE',   'string', 'NE', 'callback', 'ResultManagerFunctions(''Rst.navNE'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

    % (Result Manager) longitude and latitude ranges
    Rst.navEditLonMax    = uicontrol('parent', nav, 'style', 'edit',       'position', [ 0 40 50 20],  'visible', 'on', 'tag', 'Rst.navEditLonMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
    Rst.navTextLonMax    = uicontrol('parent', nav, 'style', 'text',       'position', [50 40 50 18],  'visible', 'on', 'tag', 'Rst.navTextLonMax', 'string', 'Lon+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.navEditLonMin    = uicontrol('parent', nav, 'style', 'edit',       'position', [ 0 20 50 20],  'visible', 'on', 'tag', 'Rst.navEditLonMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
    Rst.navTextLonMin    = uicontrol('parent', nav, 'style', 'text',       'position', [50 20 50 18],  'visible', 'on', 'tag', 'Rst.navTextLonMin', 'string', 'Lon-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.navEditLatMax    = uicontrol('parent', nav, 'style', 'edit',       'position', [75 40 50 20],  'visible', 'on', 'tag', 'Rst.navEditLatMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
    Rst.navTextLatMax    = uicontrol('parent', nav, 'style', 'text',       'position', [125 40 50 18], 'visible', 'on', 'tag', 'Rst.navTextLatMax', 'string', 'Lat+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.navEditLatMin    = uicontrol('parent', nav, 'style', 'edit',       'position', [75 20 50 20],  'visible', 'on', 'tag', 'Rst.navEditLatMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
    Rst.navTextLatMin    = uicontrol('parent', nav, 'style', 'text',       'position', [125 20 50 18], 'visible', 'on', 'tag', 'Rst.navTextLatMin', 'string', 'Lat-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
    Rst.navUpdate        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [150 40 60 20], 'visible', 'on', 'tag', 'Rst.navUpdate', 'string', 'Update', 'callback', 'ResultManagerFunctions(''Rst.navUpdate'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navBack          = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [150 20 60 20], 'visible', 'on', 'tag', 'Rst.navBack',   'string', 'Back',   'callback', 'ResultManagerFunctions(''Rst.navBack'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

    % (Result Manager) Zoom options
    Rst.navZoomIn        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [0 0 70 20],    'visible', 'on', 'tag', 'Rst.navZoomIn',    'callback', 'ResultManagerFunctions(''Rst.navZoomIn'')', 'string', 'Zoom In', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navZoomOut       = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [70 0 70 20],   'visible', 'on', 'tag', 'Rst.navZoomOut',   'callback', 'ResultManagerFunctions(''Rst.navZoomOut'')', 'string', 'Zoom Out', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.navZoomRange     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [140 0 70 20],  'visible', 'on', 'tag', 'Rst.navZoomRange', 'callback', 'ResultManagerFunctions(''Rst.navZoomRange'')', 'string', 'Zoom Range', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

    % (Result Manager) Print, Save, Zumax
    %Rst.pszFrame        = uicontrol('style', 'frame',      'position', [300 5 695 30],  'visible', 'on', 'tag', 'Rst.pszFrame', 'BackgroundColor', lightGrey);
    Rst.pszPrint         = uicontrol('style', 'pushbutton', 'position', [305 10 90 20],  'visible', 'on', 'tag', 'Rst.pszPrint', 'callback', 'ResultManagerFunctions(''Rst.pszPrint'')', 'string', 'Print', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.pszSave          = uicontrol('style', 'pushbutton', 'position', [400 10 90 20],  'visible', 'on', 'tag', 'Rst.pszSave',  'callback', 'ResultManagerFunctions(''Rst.pszSave'')', 'string', 'Save', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.pszZumax         = uicontrol('style', 'pushbutton', 'position', [495 10 90 20],  'visible', 'on', 'tag', 'Rst.pszZumax', 'callback', 'ResultManagerFunctions(''Rst.pszZumax'')', 'string', 'Zumax', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
    Rst.pszCoords        = uicontrol('style', 'edit',       'position', [800 10 190 20], 'visible', 'on', 'tag', 'Rst.pszCoords', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'string', ' ', 'FontName', fn, 'FontSize', fs);

    % (Result Manager) Result file figure axes
    Rst.axHandle = axes('parent', hFig, 'units', 'pixels', 'position', [360 100 1000 700], 'visible', 'on', 'Tag', 'Rst.axHandle', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'FontName', fn);

    % Create handles structure for easy use in the callback later
    Handles.Rst = Rst;
    set(hFig, 'userdata', Handles);

    ResultManagerFunctions('DrawClean');
    set(gca, 'Fontname', fn, 'FontSize', fs)

    % Make all figure components normalized so that they auto-resize on figure resize
    set(findall(hFig,'-property','Units'),'Units','norm');

    % Maximize the GUI in its current screen
    drawnow;  % this is required for jFrame to be accessible
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    jFrame = get(handle(hFig),'JavaFrame');
    jFrame.setMaximized(true);

    % Making the GUI visible and give it a name
    set(hFig, 'visible', 'on', 'name', 'Result Manager');
    set(hFig, 'DoubleBuffer', 'on');

    % Load directory or directories upon figure opening
    if exist('dir1', 'var')
        slashes = strfind(dir1, filesep);
        if length(slashes) == 0 || (length(slashes == 1) && slashes == length(dir1))
            dir1 = [pwd filesep dir1];
            if strmatch(dir1(end), filesep)
                dir1 = dir1(1:end-1);
            end
        end
        set(findobj(hFig, 'Tag', 'Rst.loadEdit'), 'string', dir1);
        ResultManagerFunctions('Rst.loadPush')
    end

    if exist('dir2', 'var')
        slashes = strfind(dir2, filesep);
        if length(slashes) == 0 || (length(slashes == 1) && slashes == length(dir2))
            dir2 = [pwd filesep dir2];
            if strmatch(dir2(end), filesep)
                dir2 = dir2(1:end-1);
            end
        end
        set(findobj(hFig, 'Tag', 'Rst.cloadEdit'), 'string', dir2);
        ResultManagerFunctions('Rst.cloadPush');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radio button functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%

function pickResid(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.ResidRadioNW')
        ResultManagerFunctions('Rst.ResidRadioNW')
    else
        ResultManagerFunctions('Rst.ResidRadioW')
    end

function SlipNumComp(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.srateNumRadio')
        ResultManagerFunctions('Rst.srateNumRadio')
    else
        ResultManagerFunctions('Rst.drateNumRadio')
    end

function SlipColComp(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.srateColRadio')
        ResultManagerFunctions('Rst.srateColRadio')
    else
        ResultManagerFunctions('Rst.drateColRadio')
    end

function cSlipNumComp(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.csrateNumRadio')
        ResultManagerFunctions('Rst.csrateNumRadio')
    else
        ResultManagerFunctions('Rst.cdrateNumRadio')
    end

function cSlipColComp(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.csrateColRadio')
        ResultManagerFunctions('Rst.csrateColRadio')
    else
        ResultManagerFunctions('Rst.cdrateColRadio')
    end

function CompTri(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.TriSRadio')
        ResultManagerFunctions('Rst.TriSRadio')
    else
        ResultManagerFunctions('Rst.TriDRadio')
    end

function cCompTri(source, eventdata)
    if strcmpi(get(get(source,'SelectedObject'),'Tag'), 'Rst.cTriSRadio')
        ResultManagerFunctions('Rst.cTriSRadio')
    else
        ResultManagerFunctions('Rst.cTriDRadio')
    end
