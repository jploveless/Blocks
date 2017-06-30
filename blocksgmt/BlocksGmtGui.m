function BlocksGmtGui

% Color variables
white                            = [1 1 1];
lightGrey                        = 0.85 * [1 1 1];
fn                               = 'Lucida';
fs                               = 9;

% I/O options
global GLOBAL ul cul st;
GLOBAL.filestream                = 1;

% Open figure and 
h                                = figure('Position', [100 100 200 300], 'Color', lightGrey, 'menubar', 'none', 'toolbar', 'none');

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
