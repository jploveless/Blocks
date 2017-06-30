function ResultManagerGui

% Color variables
white                            = [1 1 1];
lightGrey                        = 0.85 * [1 1 1];
fn                               = 'Lucida';
fs                               = 9;

% I/O options
global GLOBAL ul cul st;
GLOBAL.filestream                = 1;
ul										   = 10; % number of navigation undo levels
cul									   = ul - 1; % current undo level
st											= 2; % where to start counting the undo levels

% Open figure and 
h                                = figure('Position', [100 100 1000 750], 'Color', lightGrey, 'menubar', 'none', 'toolbar', 'none');

% (Result Manager) File I/O controls

% Main file I/O
mf = uipanel('units', 'pixels', 'position', [10 695 120 60], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.loadText                     = uicontrol('parent', mf, 'style', 'text',           'position', [0 36 120 15],    'visible', 'on', 'tag', 'Rst.loadText', 'string', 'Result directory', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.loadEdit                     = uicontrol('parent', mf, 'style', 'edit',           'position', [0 15 120 20],   'visible', 'on', 'tag', 'Rst.loadEdit', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8);
Rst.loadPush                     = uicontrol('parent', mf, 'style', 'pushbutton',     'position', [0 -5 60 20],    'visible', 'on', 'tag', 'Rst.loadPush', 'callback', 'ResultManagerFunctions(''Rst.loadPush'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.clearPush                    = uicontrol('parent', mf, 'style', 'pushbutton',     'position', [60 -5 60 20],    'visible', 'on', 'tag', 'Rst.clearPush', 'callback', 'ResultManagerFunctions(''Rst.clearPush'')', 'string', 'Clear', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% Secondary file I/O
sf = uipanel('units', 'pixels', 'position', [170 695 120 60], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.cloadText                     = uicontrol('parent', sf, 'style', 'text',           'position', [0 36 120 15],    'visible', 'on', 'tag', 'Rst.cloadText', 'string', 'Compare directory', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.cloadEdit                     = uicontrol('parent', sf, 'style', 'edit',           'position', [0 15 120 20],   'visible', 'on', 'tag', 'Rst.cloadEdit', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8);
Rst.cloadPush                     = uicontrol('parent', sf, 'style', 'pushbutton',     'position', [0 -5 60 20],     'visible', 'on', 'tag', 'Rst.cloadPush', 'callback', 'ResultManagerFunctions(''Rst.cloadPush'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.cclearPush                    = uicontrol('parent', sf, 'style', 'pushbutton',     'position', [60 -5 60 20],    'visible', 'on', 'tag', 'Rst.cclearPush', 'callback', 'ResultManagerFunctions(''Rst.cclearPush'')', 'string', 'Clear', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% Main results:
% Check marks for toggling stations/velocities on and off
mst = uipanel('units', 'pixels', 'position', [10 490 120 60], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.StavText                     = uicontrol('parent', mst, 'style', 'text',           'position', [0 181 78 15],    'visible', 'on', 'tag', 'Rst.StavText', 'string', 'Station controls', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StatCheck          	         = uicontrol('parent', mst, 'style', 'checkbox',       'position', [0 165 20 20],    'visible', 'on', 'tag', 'Rst.StatCheck', 'callback', 'ResultManagerFunctions(''Rst.StatCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StanCheck          	         = uicontrol('parent', mst, 'style', 'checkbox',       'position', [0 145 20 20],    'visible', 'on', 'tag', 'Rst.StanCheck', 'callback', 'ResultManagerFunctions(''Rst.StanCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ObsvCheck           	      = uicontrol('parent', mst, 'style', 'checkbox',       'position', [0 125 20 20],    'visible', 'on', 'tag', 'Rst.ObsvCheck', 'callback', 'ResultManagerFunctions(''Rst.ObsvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ModvCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0 105 20 20],    'visible', 'on', 'tag', 'Rst.ModvCheck', 'callback', 'ResultManagerFunctions(''Rst.ModvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ResvCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0  85 20 20],    'visible', 'on', 'tag', 'Rst.ResvCheck', 'callback', 'ResultManagerFunctions(''Rst.ResvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.RotvCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0  65 20 20],    'visible', 'on', 'tag', 'Rst.RotvCheck', 'callback', 'ResultManagerFunctions(''Rst.RotvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.DefvCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0  45 20 20],    'visible', 'on', 'tag', 'Rst.DefvCheck', 'callback', 'ResultManagerFunctions(''Rst.DefvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StrvCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0  25 20 20],    'visible', 'on', 'tag', 'Rst.StrvCheck', 'callback', 'ResultManagerFunctions(''Rst.StrvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.TrivCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0   5 20 20],    'visible', 'on', 'tag', 'Rst.TrivCheck', 'callback', 'ResultManagerFunctions(''Rst.TrivCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ResmCheck                  	= uicontrol('parent', mst, 'style', 'checkbox',       'position', [0 -15 20 20],    'visible', 'on', 'tag', 'Rst.ResmCheck', 'callback', 'ResultManagerFunctions(''Rst.ResmCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');

% labels
Rst.StatText          	         = uicontrol('parent', mst, 'style', 'text',       'position', [25 160 85 20],    'visible', 'on', 'tag', 'Rst.StatText', 'string', 'Stations', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StanText          	         = uicontrol('parent', mst, 'style', 'text',       'position', [25 140 85 20],    'visible', 'on', 'tag', 'Rst.StanText', 'string', 'Station names', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ObsvText	           	      = uicontrol('parent', mst, 'style', 'text',       'position', [25 120 85 20],    'visible', 'on', 'tag', 'Rst.ObsvText', 'string', 'Observed vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ModvText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25 100 85 20],    'visible', 'on', 'tag', 'Rst.ModvText', 'string', 'Modeled vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ResvText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25  80 85 20],    'visible', 'on', 'tag', 'Rst.ResvText', 'string', 'Residual vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.RotvText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25  60 85 20],    'visible', 'on', 'tag', 'Rst.RotvText', 'string', 'Rotation vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.DefvText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25  40 85 20],    'visible', 'on', 'tag', 'Rst.DefvText', 'string', 'Elastic vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StrvText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25  20 85 20],    'visible', 'on', 'tag', 'Rst.StrvText', 'string', 'Strain vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.TrivText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25   0 85 20],    'visible', 'on', 'tag', 'Rst.TrivText', 'string', 'Triangle vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.ResmText                  	= uicontrol('parent', mst, 'style', 'text',       'position', [25 -20 85 20],    'visible', 'on', 'tag', 'Rst.ResmText', 'string', 'Residual mags.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');

% Comparison results:
% Check marks for toggling stations/velocities on and off
sst = uipanel('units', 'pixels', 'position', [170 490 120 60], 'bordertype', 'none', 'backgroundcolor', lightGrey);
%Rst.cStavText                    = uicontrol('parent', sst, 'style', 'text',           'position', [0 181 78 15],    'visible', 'on', 'tag', 'Rst.cStavText' , 'string', 'Station controls', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cStatCheck          	      = uicontrol('parent', sst, 'style', 'checkbox',       'position', [0 165 20 20],    'visible', 'on', 'tag', 'Rst.cStatCheck', 'callback', 'ResultManagerFunctions(''Rst.cStatCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cStanCheck         	         = uicontrol('parent', sst, 'style', 'checkbox',       'position', [0 145 20 20],    'visible', 'on', 'tag', 'Rst.cStanCheck', 'callback', 'ResultManagerFunctions(''Rst.cStanCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cObsvCheck           	      = uicontrol('parent', sst, 'style', 'checkbox',       'position', [0 125 20 20],    'visible', 'on', 'tag', 'Rst.cObsvCheck', 'callback', 'ResultManagerFunctions(''Rst.cObsvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cModvCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0 105 20 20],    'visible', 'on', 'tag', 'Rst.cModvCheck', 'callback', 'ResultManagerFunctions(''Rst.cModvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cResvCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0  85 20 20],    'visible', 'on', 'tag', 'Rst.cResvCheck', 'callback', 'ResultManagerFunctions(''Rst.cResvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cRotvCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0  65 20 20],    'visible', 'on', 'tag', 'Rst.cRotvCheck', 'callback', 'ResultManagerFunctions(''Rst.cRotvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cDefvCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0  45 20 20],    'visible', 'on', 'tag', 'Rst.cDefvCheck', 'callback', 'ResultManagerFunctions(''Rst.cDefvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cStrvCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0  25 20 20],    'visible', 'on', 'tag', 'Rst.cStrvCheck', 'callback', 'ResultManagerFunctions(''Rst.cStrvCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cTrivCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0   5 20 20],    'visible', 'on', 'tag', 'Rst.cTrivCheck', 'callback', 'ResultManagerFunctions(''Rst.cTrivCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cResmCheck                  	= uicontrol('parent', sst, 'style', 'checkbox',       'position', [0 -15 20 20],    'visible', 'on', 'tag', 'Rst.cResmCheck', 'callback', 'ResultManagerFunctions(''Rst.cResmCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off');

% labels
Rst.cStatText          	         = uicontrol('parent', sst, 'style', 'text', 'position', [25 160 85 20],    'visible', 'on', 'tag', 'Rst.cStatText', 'string', 'Stations', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StanText          	         = uicontrol('parent', sst, 'style', 'text', 'position', [25 140 85 20],    'visible', 'on', 'tag', 'Rst.cStanText', 'string', 'Station names', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cObsvText	           	      = uicontrol('parent', sst, 'style', 'text', 'position', [25 120 85 20],    'visible', 'on', 'tag', 'Rst.cObsvText', 'string', 'Observed vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cModvText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25 100 85 20],    'visible', 'on', 'tag', 'Rst.cModvText', 'string', 'Modeled vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cResvText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25  80 85 20],    'visible', 'on', 'tag', 'Rst.cResvText', 'string', 'Residual vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cRotvText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25  60 85 20],    'visible', 'on', 'tag', 'Rst.cRotvText', 'string', 'Rotation vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cDefsvText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25  40 85 20],    'visible', 'on', 'tag', 'Rst.cDefvText', 'string', 'Elastic vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cStrvText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25  20 85 20],    'visible', 'on', 'tag', 'Rst.cStrvText', 'string', 'Strain vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cTrivText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25   0 85 20],    'visible', 'on', 'tag', 'Rst.cTrivText', 'string', 'Triangle vels.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cResmText                  	= uicontrol('parent', sst, 'style', 'text', 'position', [25 -20 85 20],    'visible', 'on', 'tag', 'Rst.cResmText', 'string', 'Residual mags.', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');


% Slider to control velocity scaling (operates on ALL plotted vectors identically)
vsc = uipanel('units', 'pixels', 'position', [10 418 280 70], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.velScaleText    	  		      = uicontrol('parent', vsc, 'style', 'text', 'position', [0 28 85 20],    'visible', 'on', 'tag', 'Rst.velScaleText', 'string', 'Vector scaling', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.velScale							= uicontrol('parent', vsc, 'style', 'edit', 'position', [0 12 50 20], 'string', '0.5', 'visible', 'on', 'tag', 'Rst.velScale', 'callback', 'ResultManagerFunctions(''Rst.velScale'')', 'BackgroundColor', white, 'FontName', fn, 'Fontsize', 8, 'enable', 'off');
Rst.velSlider							= uicontrol('parent', vsc, 'style', 'slider', 'position', [50 0 230 30], 'min', 1e-6, 'max', 1, 'value', 0.5, 'visible', 'on', 'tag', 'Rst.velSlider', 'callback', 'ResultManagerFunctions(''Rst.velSlider'')', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8, 'enable', 'off');

% Residual improvement
res = uipanel('units', 'pixels', 'position', [10 380 290 40], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.ResidImpCheck						= uicontrol('parent', res, 'style', 'checkbox', 'position', [0 20 20 20],    'visible', 'on', 'tag', 'Rst.ResidImpCheck', 'callback', 'ResultManagerFunctions(''Rst.ResidImpCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.ResidImpCheckText				= uicontrol('parent', res, 'style', 'text', 'position', [25 15 265 20],    'visible', 'on', 'tag', 'Rst.ResidImpCheckText', 'string', 'Show residual improvement', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.pickResid							= uibuttongroup('parent', res, 'units', 'pixels', 'position', [20 0 290 20], 'tag', 'Rst.pickResid', 'SelectionChangeFcn', @pickResid, 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.ResidRadioW						= uicontrol('style', 'radio', 'pos', [0 0 20 20], 'parent', Rst.pickResid, 'visible', 'on', 'tag', 'Rst.ResidRadioW', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.ResidRadioTextW					= uicontrol('style', 'text', 'position', [25 -5 120 20], 'parent', Rst.pickResid,   'visible', 'on', 'tag', 'Rst.ResidRadioTextW', 'string', 'Weighted by uncertainty', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.ResidRadioNW						= uicontrol('style', 'radio', 'pos', [140 0 20 20], 'parent', Rst.pickResid, 'visible', 'on', 'tag', 'Rst.ResidRadioNW', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.ResidRadioTextNW					= uicontrol('style', 'text', 'position', [165 -5 80 20], 'parent', Rst.pickResid,   'visible', 'on', 'tag', 'Rst.ResidRadioTextNW', 'string', 'Unweighted', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 

% Main results:
% Toggle slip rate views
msr = uipanel('units', 'pixels', 'position', [10 220 130 40], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.SlipText        	  		      = uicontrol('parent', msr, 'style', 'text', 'position', [0 131 85 20],    'visible', 'on', 'tag', 'Rst.SlipText', 'string', 'Slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.SlipNumCheck						= uicontrol('parent', msr, 'style', 'checkbox', 'position', [0 115 20 20],    'visible', 'on', 'tag', 'Rst.SlipNumCheck', 'callback', 'ResultManagerFunctions(''Rst.SlipNumCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.SlipNumCheckText					= uicontrol('parent', msr, 'style', 'text', 'position', [25 110 120 20],    'visible', 'on', 'tag', 'Rst.SlipNumCheckText', 'string', 'Show numerical rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.SlipNumComp						= uibuttongroup('parent', msr, 'units', 'pixels', 'position', [20 75 20 40], 'tag', 'Rst.SlipNumComp', 'SelectionChangeFcn', @SlipNumComp, 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.srateNumRadio						= uicontrol('style', 'radio', 'pos', [0 20 20 20], 'parent', Rst.SlipNumComp, 'visible', 'on', 'tag', 'Rst.srateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.drateNumRadio						= uicontrol('style', 'radio', 'pos', [0  0 20 20], 'parent', Rst.SlipNumComp, 'visible', 'on', 'tag', 'Rst.drateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.srateNumText						= uicontrol('parent', msr, 'style', 'text', 'position', [45 90 85 20],    'visible', 'on', 'tag', 'Rst.srateNumText', 'string', 'Strike-slip', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.drateNumText						= uicontrol('parent', msr, 'style', 'text', 'position', [45 70 85 20],    'visible', 'on', 'tag', 'Rst.drateNumText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.SlipColCheck						= uicontrol('parent', msr, 'style', 'checkbox', 'position', [0 45 20 20],    'visible', 'on', 'tag', 'Rst.SlipColCheck', 'callback', 'ResultManagerFunctions(''Rst.SlipColCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.SlipColCheckText					= uicontrol('parent', msr, 'style', 'text', 'position', [25 40 120 20],    'visible', 'on', 'tag', 'Rst.SlipColCheckText', 'string', 'Show colored line rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.SlipColComp						= uibuttongroup('parent', msr, 'units', 'pixels', 'position', [20 5 20 40], 'tag', 'Rst.SlipColComp', 'SelectionChangeFcn', @SlipColComp,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.srateColRadio						= uicontrol('style', 'radio', 'pos', [0 20 20 20], 'parent', Rst.SlipColComp, 'visible', 'on', 'tag', 'Rst.srateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.drateColRadio						= uicontrol('style', 'radio', 'pos', [0  0 20 20], 'parent', Rst.SlipColComp, 'visible', 'on', 'tag', 'Rst.drateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.srateColText						= uicontrol('parent', msr, 'style', 'text', 'position', [45 20 85 20],    'visible', 'on', 'tag', 'Rst.srateColText', 'string', 'Strike-slip', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.drateColText						= uicontrol('parent', msr, 'style', 'text', 'position', [45 0 85 20],    'visible', 'on', 'tag', 'Rst.drateColText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 

% Comparison results:
% Toggle slip rate views
ssr = uipanel('units', 'pixels', 'position', [170 220 130 40], 'bordertype', 'none', 'backgroundcolor', lightGrey);
%Rst.cSlipText        	  		   = uicontrol('parent', ssr, 'style', 'text', 'position', [0 131 85 20],    'visible', 'on', 'tag', 'Rst.cSlipText', 'string', 'Slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cSlipNumCheck						= uicontrol('parent', ssr, 'style', 'checkbox', 'position', [0 115 20 20],    'visible', 'on', 'tag', 'Rst.cSlipNumCheck', 'callback', 'ResultManagerFunctions(''Rst.cSlipNumCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cSlipNumCheckText				= uicontrol('parent', ssr, 'style', 'text', 'position', [25 110 120 20],    'visible', 'on', 'tag', 'Rst.cSlipNumCheckText', 'string', 'Show numerical rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cSlipNumComp						= uibuttongroup('parent', ssr, 'units', 'pixels', 'position', [20 75 20 40], 'tag', 'Rst.cSlipNumComp', 'SelectionChangeFcn', @cSlipNumComp, 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.csrateNumRadio					= uicontrol('style', 'radio', 'pos', [0 20 20 20], 'parent', Rst.cSlipNumComp, 'visible', 'on', 'tag', 'Rst.csrateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cdrateNumRadio					= uicontrol('style', 'radio', 'pos', [0  0 20 20], 'parent', Rst.cSlipNumComp, 'visible', 'on', 'tag', 'Rst.cdrateNumRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.csrateNumText						= uicontrol('parent', ssr, 'style', 'text', 'position', [45 90 85 20],    'visible', 'on', 'tag', 'Rst.csrateNumText', 'string', 'Strike-slip', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cdrateNumText						= uicontrol('parent', ssr, 'style', 'text', 'position', [45 70 85 20],    'visible', 'on', 'tag', 'Rst.cdrateNumText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cSlipColCheck						= uicontrol('parent', ssr, 'style', 'checkbox', 'position', [0 45 20 20],    'visible', 'on', 'tag', 'Rst.cSlipColCheck', 'callback', 'ResultManagerFunctions(''Rst.cSlipColCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cSlipColCheckText				= uicontrol('parent', ssr, 'style', 'text', 'position', [25 40 120 20],    'visible', 'on', 'tag', 'Rst.cSlipColCheckText', 'string', 'Show colored line rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cSlipColComp						= uibuttongroup('parent', ssr, 'units', 'pixels', 'position', [20 5 20 40], 'tag', 'Rst.cSlipColComp', 'SelectionChangeFcn', @cSlipColComp,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.csrateColRadio					= uicontrol('style', 'radio', 'pos', [0 20 20 20], 'parent', Rst.cSlipColComp, 'visible', 'on', 'tag', 'Rst.csrateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cdrateColRadio					= uicontrol('style', 'radio', 'pos', [0  0 20 20], 'parent', Rst.cSlipColComp, 'visible', 'on', 'tag', 'Rst.cdrateColRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.csrateColText						= uicontrol('parent', ssr, 'style', 'text', 'position', [45 20 85 20],    'visible', 'on', 'tag', 'Rst.csrateColText', 'string', 'Strike-slip', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cdrateColText						= uicontrol('parent', ssr, 'style', 'text', 'position', [45 0 85 20],     'visible', 'on', 'tag', 'Rst.cdrateColText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 

% Main results:
% Strain axis and triangular slip plotting options
mop = uipanel('units', 'pixels', 'position', [10 110 290 40], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.opText        	  		  		= uicontrol('parent', mop, 'style', 'text', 'position', [0 81 85 20],    'visible', 'on', 'tag', 'Rst.opText', 'string', 'Optional results', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.StrainCheck						= uicontrol('parent', mop, 'style', 'checkbox', 'position', [0 65 20 20],    'visible', 'on', 'tag', 'Rst.StrainCheck', 'callback', 'ResultManagerFunctions(''Rst.StrainCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.StrainCheckText					= uicontrol('parent', mop, 'style', 'text', 'position', [25 60 120 20],    'visible', 'on', 'tag', 'Rst.StrainCheckText', 'string', 'Show princ. strain axes', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.TriCheck							= uicontrol('parent', mop, 'style', 'checkbox', 'position', [0 45 20 20],    'visible', 'on', 'tag', 'Rst.TriCheck', 'callback', 'ResultManagerFunctions(''Rst.TriCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.TriCheckText						= uicontrol('parent', mop, 'style', 'text', 'position', [25 40 120 20],    'visible', 'on', 'tag', 'Rst.TriCheckText', 'string', 'Show triangular slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.CompTri								= uibuttongroup('parent', mop, 'units', 'pixels', 'position', [20 5 20 40], 'tag', 'Rst.CompTri', 'SelectionChangeFcn', @CompTri,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.TriSRadio							= uicontrol('style', 'radio', 'pos', [0 20 20 20], 'parent', Rst.CompTri, 'visible', 'on', 'tag', 'Rst.TriSRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.TriDRadio							= uicontrol('style', 'radio', 'pos', [0  0 20 20], 'parent', Rst.CompTri, 'visible', 'on', 'tag', 'Rst.TriDRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.TriSText							= uicontrol('parent', mop, 'style', 'text', 'position', [45 20 85 20],    'visible', 'on', 'tag', 'Rst.TriSText', 'string', 'Strike-slip', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.TriDText							= uicontrol('parent', mop, 'style', 'text', 'position', [45 0 85 20],     'visible', 'on', 'tag', 'Rst.TriDText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 

% Comparison results:
% Strain axis and triangular slip plotting options
sop = uipanel('units', 'pixels', 'position', [170 110 290 40], 'bordertype', 'none', 'backgroundcolor', lightGrey);
%Rst.copText        	  		  		= uicontrol('parent', sop, 'style', 'text', 'position', [0 81 85 20],    'visible', 'on', 'tag', 'Rst.copText', 'string', 'Optional results', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off');
Rst.cStrainCheck						= uicontrol('parent', sop, 'style', 'checkbox', 'position', [0 65 20 20],    'visible', 'on', 'tag', 'Rst.cStrainCheck', 'callback', 'ResultManagerFunctions(''Rst.cStrainCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cStrainCheckText					= uicontrol('parent', sop, 'style', 'text', 'position', [25 60 120 20],    'visible', 'on', 'tag', 'Rst.cStrainCheckText', 'string', 'Show princ. strain axes', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cTriCheck							= uicontrol('parent', sop, 'style', 'checkbox', 'position', [0 45 20 20],    'visible', 'on', 'tag', 'Rst.cTriCheck', 'callback', 'ResultManagerFunctions(''Rst.cTriCheck'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cTriCheckText						= uicontrol('parent', sop, 'style', 'text', 'position', [25 40 120 20],    'visible', 'on', 'tag', 'Rst.cTriCheckText', 'string', 'Show triangular slip rates', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cCompTri							= uibuttongroup('parent', sop, 'units', 'pixels', 'position', [20 5 20 40], 'tag', 'Rst.cCompTri', 'SelectionChangeFcn', @cCompTri,'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'bordertype', 'none'); 
Rst.cTriSRadio							= uicontrol('style', 'radio', 'pos', [0 20 20 20], 'parent', Rst.cCompTri, 'visible', 'on', 'tag', 'Rst.cTriSRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cTriDRadio							= uicontrol('style', 'radio', 'pos', [0  0 20 20], 'parent', Rst.cCompTri, 'visible', 'on', 'tag', 'Rst.cTriDRadio', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cTriSText							= uicontrol('parent', sop, 'style', 'text', 'position', [45 20 85 20],    'visible', 'on', 'tag', 'Rst.cTriSText', 'string', 'Strike-slip', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 
Rst.cTriDText							= uicontrol('parent', sop, 'style', 'text', 'position', [45 0 85 20],     'visible', 'on', 'tag', 'Rst.cTriDText', 'string', 'Dip-slip/tensile', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs, 'enable', 'off'); 








%
%% (Result Manager) Additional features frame
%% Rst.dispFrame                    = uicontrol('style', 'frame',          'position', [5 90 290 75],     'visible', 'on', 'tag', 'Rst.dispFrame', 'BackgroundColor', lightGrey);
%Rst.dispText                     = uicontrol('style', 'text', 'position', [10 156 36 15],     'visible', 'on', 'tag', 'Rst.dispText', 'string', 'Display', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
%
%% (Result Manager) Load line file
%Rst.dispEditLine                 = uicontrol('style', 'edit', 'position', [10 135 100 20],    'visible', 'on', 'tag', 'Rst.dispEditLine', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8, 'FontName', fn, 'FontSize', fs);
%Rst.dispPushLine                 = uicontrol('style', 'pushbutton', 'position', [115 135 30 20],    'visible', 'on', 'tag', 'Rst.dispPushLine', 'string', 'Load', 'callback', 'ResultManagerFunctions(''Rst.dispPushLine'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
%Rst.dispTextLine                 = uicontrol('style', 'text', 'position', [150 135 100 18],   'visible', 'on', 'tag', 'Rst.dispTextLine', 'string', 'line file', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
%Rst.dispCheckLine                = uicontrol('style', 'checkbox', 'position', [200 135 20 20],    'visible', 'on', 'tag', 'Rst.dispCheckLine', 'callback', 'ResultManagerFunctions(''Rst.dispCheckLine'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
%
%% (Result Manager) Load xy file
%Rst.dispEditXy                   = uicontrol('style', 'edit', 'position', [10 115 100 20],    'visible', 'on', 'tag', 'Rst.dispEditXy', 'BackgroundColor', white, 'HorizontalAlignment', 'left', 'Fontsize', 8, 'FontName', fn, 'FontSize', fs);
%Rst.dispPushXy                   = uicontrol('style', 'pushbutton', 'position', [115 115 30 20],    'visible', 'on', 'tag', 'Rst.dispPushXy', 'string', 'Load', 'callback', 'ResultManagerFunctions(''Rst.dispPushXy'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
%Rst.dispTextXy                   = uicontrol('style', 'text', 'position', [150 115 100 18],   'visible', 'on', 'tag', 'Rst.dispTextXy', 'string', 'xy file', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
%Rst.dispCheckXy                  = uicontrol('style', 'checkbox', 'position', [200 115 20 20],    'visible', 'on', 'tag', 'Rst.dispCheckXy', 'callback', 'ResultManagerFunctions(''Rst.dispCheckXy'')', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
%
%% (Result Manager) Topo, Grid lines, and meridian popups
%Rst.dispTopo                     = uicontrol('style', 'popupmenu', 'position', [220 135 70 20],    'visible', 'on', 'tag', 'Rst.dispTopo', 'callback', 'ResultManagerFunctions(''Rst.dispTopo'')', 'string', {'No topo', 'SoCal'}, 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs);
%Rst.dispGrid                     = uicontrol('style', 'popupmenu', 'position', [220 115 70 20],    'visible', 'on', 'tag', 'Rst.dispGrid', 'callback', 'ResultManagerFunctions(''Rst.dispGrid'')', 'string', {'Grid off', 'Grid on'}, 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs);
%Rst.dispMeridian                 = uicontrol('style', 'popupmenu', 'position', [220 95 70 20],     'visible', 'on', 'tag', 'Rst.dispMeridian', 'callback', 'ResultManagerFunctions(''Rst.dispMeridian'')', 'string', {'[0 360]', '[-180 180]'}, 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs);

% (Result Manager) Navigate frame and navigation rose buttons
nav = uipanel('units', 'pixels', 'position', [10 10 290 80], 'bordertype', 'none', 'backgroundcolor', lightGrey);
Rst.navText                      = uicontrol('parent', nav, 'style', 'text',       'position', [0 56 44 20],       'visible', 'on', 'tag', 'Rst.navText', 'string', 'Navigate', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.navSW                        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [220 0 20 20],      'visible', 'on', 'tag', 'Rst.navSW', 'string', 'SW', 'callback', 'ResultManagerFunctions(''Rst.navSW'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navS                         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [240 0 20 20],      'visible', 'on', 'tag', 'Rst.navS', 'string', 'S', 'callback', 'ResultManagerFunctions(''Rst.navS'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navSE                        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [260 0 20 20],      'visible', 'on', 'tag', 'Rst.navSE', 'string', 'SE', 'callback', 'ResultManagerFunctions(''Rst.navSE'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navW                         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [220 20 20 20],      'visible', 'on', 'tag', 'Rst.navW', 'string', 'W', 'callback', 'ResultManagerFunctions(''Rst.navW'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navC                         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [240 20 20 20],      'visible', 'on', 'tag', 'Rst.navC', 'string', 'C', 'callback', 'ResultManagerFunctions(''Rst.navC'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navE                         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [260 20 20 20],      'visible', 'on', 'tag', 'Rst.navE', 'string', 'E', 'callback', 'ResultManagerFunctions(''Rst.navE'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navNW                        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [220 40 20 20],      'visible', 'on', 'tag', 'Rst.navNW', 'string', 'NW', 'callback', 'ResultManagerFunctions(''Rst.navNW'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navN                         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [240 40 20 20],      'visible', 'on', 'tag', 'Rst.navN', 'string', 'N', 'callback', 'ResultManagerFunctions(''Rst.navN'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navNE                        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [260 40 20 20],      'visible', 'on', 'tag', 'Rst.navNE', 'string', 'NE', 'callback', 'ResultManagerFunctions(''Rst.navNE'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% (Result Manager) longitude and latitude ranges
Rst.navEditLonMax                = uicontrol('parent', nav, 'style', 'edit',           'position', [ 0 40 50 20],       'visible', 'on', 'tag', 'Rst.navEditLonMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Rst.navTextLonMax                = uicontrol('parent', nav, 'style', 'text',           'position', [50 40 50 18],       'visible', 'on', 'tag', 'Rst.navTextLonMax', 'string', 'Lon+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.navEditLonMin                = uicontrol('parent', nav, 'style', 'edit',           'position', [ 0 20 50 20],       'visible', 'on', 'tag', 'Rst.navEditLonMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Rst.navTextLonMin                = uicontrol('parent', nav, 'style', 'text',           'position', [50 20 50 18],       'visible', 'on', 'tag', 'Rst.navTextLonMin', 'string', 'Lon-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.navEditLatMax                = uicontrol('parent', nav, 'style', 'edit',           'position', [75 40 50 20],       'visible', 'on', 'tag', 'Rst.navEditLatMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Rst.navTextLatMax                = uicontrol('parent', nav, 'style', 'text',           'position', [125 40 50 18],      'visible', 'on', 'tag', 'Rst.navTextLatMax', 'string', 'Lat+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.navEditLatMin                = uicontrol('parent', nav, 'style', 'edit',           'position', [75 20 50 20],       'visible', 'on', 'tag', 'Rst.navEditLatMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Rst.navTextLatMin                = uicontrol('parent', nav, 'style', 'text',           'position', [125 20 50 18],      'visible', 'on', 'tag', 'Rst.navTextLatMin', 'string', 'Lat-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Rst.navUpdate                    = uicontrol('parent', nav, 'style', 'pushbutton',     'position', [150 40 60 20],      'visible', 'on', 'tag', 'Rst.navUpdate', 'string', 'Update', 'callback', 'ResultManagerFunctions(''Rst.navUpdate'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navBack                      = uicontrol('parent', nav, 'style', 'pushbutton',     'position', [150 20 60 20],      'visible', 'on', 'tag', 'Rst.navBack', 'string', 'Back', 'callback', 'ResultManagerFunctions(''Rst.navBack'')', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% (Result Manager) Zoom options
Rst.navZoomIn                    = uicontrol('parent', nav, 'style', 'pushbutton',     'position', [0 0 70 20],       'visible', 'on', 'tag', 'Rst.navZoomIn', 'callback', 'ResultManagerFunctions(''Rst.navZoomIn'')', 'string', 'Zoom In', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navZoomOut                   = uicontrol('parent', nav, 'style', 'pushbutton',     'position', [70 0 70 20],       'visible', 'on', 'tag', 'Rst.navZoomOut',  'callback', 'ResultManagerFunctions(''Rst.navZoomOut'')', 'string', 'Zoom Out', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.navZoomRange                 = uicontrol('parent', nav, 'style', 'pushbutton',     'position', [140 0 70 20],      'visible', 'on', 'tag', 'Rst.navZoomRange', 'callback', 'ResultManagerFunctions(''Rst.navZoomRange'')', 'string', 'Zoom Range', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% (Result Manager) Result file figure axes
Rst.axHandle                     = axes('parent', gcf, 'units', 'pixels', 'position', [340 80 640 640],     'visible', 'on', 'Tag', 'Rst.axHandle', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90]);
ResultManagerFunctions('DrawClean');

% (Result Manager) Print, Save, Zumax
% Rst.pszFrame                     = uicontrol('style', 'frame',          'position', [300 5 695 30],      'visible', 'on', 'tag', 'Rst.pszFrame', 'BackgroundColor', lightGrey);
Rst.pszPrint                     = uicontrol('style', 'pushbutton',     'position', [305 10 90 20],      'visible', 'on', 'tag', 'Rst.pszPrint', 'callback', 'ResultManagerFunctions(''Rst.pszPrint'')', 'string', 'Print', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.pszSave                      = uicontrol('style', 'pushbutton',     'position', [400 10 90 20],      'visible', 'on', 'tag', 'Rst.pszSave', 'callback', 'ResultManagerFunctions(''Rst.pszSave'')', 'string', 'Save', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.pszZumax                     = uicontrol('style', 'pushbutton',     'position', [495 10 90 20],      'visible', 'on', 'tag', 'Rst.pszZumax', 'callback', 'ResultManagerFunctions(''Rst.pszZumax'')', 'string', 'Zumax', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Rst.pszCoords                    = uicontrol('style', 'edit',           'position', [800 10 190 20],     'visible', 'on', 'tag', 'Rst.pszCoords', 'BackgroundColor', white, 'HorizontalAlignment', 'center', 'string', ' ', 'FontName', fn, 'FontSize', fs);

% Create handles structure for easy use in the callback later
Handles.Rst                      = Rst;
set(h, 'userdata', Handles);

% Making the GUI visible and give it a name
set(h, 'visible', 'on', 'name', 'Result Manager');
set(gcf, 'DoubleBuffer', 'on');



%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radio button functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%

function pickResid(source, eventdata)
if ~isempty(strmatch(get(get(source,'SelectedObject'),'Tag'), 'Rst.ResidRadioNW', 'exact'))
	ResultManagerFunctions('Rst.ResidRadioNW')
else
	ResultManagerFunctions('Rst.ResidRadioW')
end

function SlipNumComp(source, eventdata)
if get(get(source,'SelectedObject'),'Tag') == 'Rst.srateNumRadio'
	ResultManagerFunctions('Rst.srateNumRadio')
else
	ResultManagerFunctions('Rst.drateNumRadio')
end

function SlipColComp(source, eventdata)
if get(get(source,'SelectedObject'),'Tag') == 'Rst.srateColRadio'
	ResultManagerFunctions('Rst.srateColRadio')
else
	ResultManagerFunctions('Rst.drateColRadio')
end

function cSlipNumComp(source, eventdata)
if get(get(source,'SelectedObject'),'Tag') == 'Rst.csrateNumRadio'
	ResultManagerFunctions('Rst.csrateNumRadio')
else
	ResultManagerFunctions('Rst.cdrateNumRadio')
end

function cSlipColComp(source, eventdata)
if get(get(source,'SelectedObject'),'Tag') == 'Rst.csrateColRadio'
	ResultManagerFunctions('Rst.csrateColRadio')
else
	ResultManagerFunctions('Rst.cdrateColRadio')
end

function CompTri(source, eventdata)
if get(get(source,'SelectedObject'),'Tag') == 'Rst.TriSRadio'
	ResultManagerFunctions('Rst.TriSRadio')
else
	ResultManagerFunctions('Rst.TriDRadio')
end

function cCompTri(source, eventdata)
if get(get(source,'SelectedObject'),'Tag') == 'Rst.cTriSRadio'
	ResultManagerFunctions('Rst.cTriSRadio')
else
	ResultManagerFunctions('Rst.cTriDRadio')
end


