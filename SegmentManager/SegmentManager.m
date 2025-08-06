function SegmentManager(nomaximize)
    warning off; % This seems to be neccesary for Matlab2014 to prevent massive CPU usage
                 % Warning: The EraseMode property is no longer supported and will error in a future release. Use the ANIMATEDLINE function for animating
                 % lines and points instead of EraseMode 'none'. Removing instances of EraseMode set to 'normal', 'xor', and 'background' has minimal impact. 
                 % > In MoveIntersection at 83
                 %   In SegmentManagerFunctions at 405 

    % Color variables
    white                  = [1 1 1];
    lightGrey              = 0.85 * [1 1 1];
    fn                     = 'Lucida';
    fs                     = 8;

    % I/O options
    global GLOBAL ul cul st;
    GLOBAL.filestream      = 1;
    ul                     = 10; % number of navigation undo levels
    cul                    = ul - 1; % current undo level
    st                     = 2; % where to start counting the undo levels

    % Open figure
    screensize             = get(0, 'screensize');
    figloc                 = screensize(3:4)./2 - [600 425];
    hFig                   = figure('Position', [figloc 1200 850], 'Color', lightGrey, 'menubar', 'none', 'toolbar', 'none');

    % Load command file and all listed files
    commandYOffset = 100;
    %Seg.loadCommandFrame  = uicontrol('style','frame',          'position', [5 785 290 54],                   'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey);
    %Seg.loadTextCommand   = uicontrol('style','text',           'position', [10 731+commandYOffset 80 15],    'visible','on', 'tag','Seg.loadTextCommand', 'String','Command File', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.loadCommandFrame   = uipanel  ('units','pixel',           'position', [5 785 290 63],                   'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey, 'title', 'Command file', 'foreground','b');
    Seg.loadEditCommand    = uicontrol('style','edit',           'position', [10 710+commandYOffset 280 20],   'visible','on', 'tag','Seg.loadEditCommand', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8);
    Seg.loadPushCommand    = uicontrol('style','pushbutton',     'position', [10 690+commandYOffset 70 20],    'visible','on', 'tag','Seg.loadPushCommand', 'callback','SegmentManagerFunctions(''Seg.loadPushCommand'')', 'String','Load', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Load inputs specified in command file');

    % (Segment Manager) File I/O controls
    segmentYOffset = 25;
    %Seg.loadSegFrame      = uicontrol('style','frame',          'position', [5 545+segmentYOffset 290 194],   'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey);
    %Seg.loadText          = uicontrol('style','text',           'position', [10 731+segmentYOffset 63 15],    'visible','on', 'tag','Seg.loadText', 'String','Segment File', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.loadSegFrame       = uipanel  ('units','pixel',           'position', [5 545+segmentYOffset 290 203],  'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey, 'title','Segment file', 'foreground','b');
    Seg.loadEdit           = uicontrol('style','edit',           'position', [10 710+segmentYOffset 260 20],   'visible','on', 'tag','Seg.loadEdit', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8);
    Seg.dispCheck          = uicontrol('style','checkbox',       'position', [275 710+segmentYOffset 15 20],   'visible','on', 'tag','Seg.dispCheck', 'callback','SegmentManagerFunctions(''Seg.dispCheck'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'enable','off', 'Tooltip','Toggle segments on/off');
    Seg.loadPush           = uicontrol('style','pushbutton',     'position', [10 690+segmentYOffset 70 20],    'visible','on', 'tag','Seg.loadPush',  'callback','SegmentManagerFunctions(''Seg.loadPush'')',  'String','Load',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Load a segment file');
    Seg.clearPush          = uicontrol('style','pushbutton',     'position', [80 690+segmentYOffset 70 20],    'visible','on', 'tag','Seg.clearPush', 'callback','SegmentManagerFunctions(''Seg.clearPush'')', 'String','Clear', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Clear current segment file');
    Seg.savePush           = uicontrol('style','pushbutton',     'position', [150 690+segmentYOffset 70 20],   'visible','on', 'tag','Seg.savePush',  'callback','SegmentManagerFunctions(''Seg.savePush'')',  'String','Save',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Save changes to segment file');

    % (Segment Manager) Modify segment controls
    %Seg.modText           = uicontrol('style','text',           'position', [ 10 666+segmentYOffset     78 15], 'visible','on', 'tag','Seg.modText', 'String','Modify Segment', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.modSegList         = uicontrol('style','popupmenu',      'position', [ 10 645+20+segmentYOffset 205 20], 'visible','on', 'tag','Seg.modSegList',    'callback','SegmentManagerFunctions(''Seg.modSegList'')', 'string', {''},    'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','List of segment names');
    Seg.modSegPush         = uicontrol('style','pushbutton',     'position', [220 645+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modSegPush',    'callback','SegmentManagerFunctions(''Seg.modSegPush'')', 'String','Update', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Confirm changes to selected segment(s)');
    segModPropList         = {'< none >', 'Longitude 1', 'Latitude 1', 'Longitude 2', 'Latitude 2', 'Dip', 'Dip sigma', 'Dip flag', 'Locking depth', 'Locking depth sigma', 'Locking depth flag', 'Strike slip rate', 'Strike slip rate sigma', 'Strike slip rate flag', 'Dip slip rate', 'Dip slip rate sigma', 'Dip slip rate flag', 'Tensile slip rate', 'Tensile slip rate sigma', 'Tensile slip rate flag', 'Resolution', 'Resolution flag', 'Resolution other', 'Patch file', 'Patch toggle', 'Other 3', 'Patch slip file', 'Patch slip toggle', 'Other 6', 'Rake', 'Rake Sigma', 'Rake Toggle', 'Other 7', 'Other 8', 'Other 9'};
    Seg.modPropList        = uicontrol('style','popupmenu',      'position', [ 10 620+20+segmentYOffset 205 20], 'visible','on', 'tag','Seg.modPropList',   'callback','SegmentManagerFunctions(''Seg.modPropList'')', 'string', segModPropList, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Choose a property to modify for currently selected segment(s)');
    Seg.modPropEdit        = uicontrol('style','edit',           'position', [220 620+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modPropEdit', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs, 'Callback',@(h,e)SegmentManagerFunctions('Seg.modSegPush'));
    Seg.modGSelect         = uicontrol('style','pushbutton',     'position', [ 10 595+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modGSelect',    'callback','SegmentManagerFunctions(''Seg.modGSelect'')',    'String','GSelect',    'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Select a single segment');
    Seg.modGSelectM        = uicontrol('style','pushbutton',     'position', [ 10 575+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modGSelectBox', 'callback','SegmentManagerFunctions(''Seg.modGSelectBox'')', 'String','GSelectBox', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Draw box and select segments within');
    Seg.modClear           = uicontrol('style','pushbutton',     'position', [220 595+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modClear',      'callback','SegmentManagerFunctions(''Seg.modClear'')',      'String','Clear',      'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Clear segment selection');

    % Graphical Modify Segment Controls
    Seg.modNewPush         = uicontrol('style','pushbutton',     'position', [150 595+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modNewPush',       'callback','SegmentManagerFunctions(''Seg.modNewPush'')',       'String','New',        'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Create a new segment');
    Seg.modDeletePush      = uicontrol('style','pushbutton',     'position', [ 80 595+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modDeletePush',    'callback','SegmentManagerFunctions(''Seg.modDeletePush'')',    'String','GDelete',    'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Delete a single segment');
    Seg.modDeletePushBox   = uicontrol('style','pushbutton',     'position', [ 80 575+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modDeletePushBox', 'callback','SegmentManagerFunctions(''Seg.modDeletePushBox'')', 'String','GDeleteBox', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Draw box and delete segments within');
    Seg.modExtendPush      = uicontrol('style','pushbutton',     'position', [150 575+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modExtendPush',    'callback','SegmentManagerFunctions(''Seg.modExtendPush'')',    'String','Extend',     'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Create new segment from existing endpoint');
    Seg.modMovePush        = uicontrol('style','pushbutton',     'position', [220 575+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modMovePush',      'callback','SegmentManagerFunctions(''Seg.modMovePush'')',      'String','Move',       'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Move a single endpoint');
    Seg.modConnectPush     = uicontrol('style','pushbutton',     'position', [150 555+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modConnectPush',   'callback','SegmentManagerFunctions(''Seg.modConnectPush'')',   'String','Connect',    'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Connect two existing endpoints');
    Seg.modSplitPush       = uicontrol('style','pushbutton',     'position', [220 555+20+segmentYOffset 70 20],  'visible','on', 'tag','Seg.modSplitPush',     'callback','SegmentManagerFunctions(''Seg.modSplitPush'')',     'String','Split',      'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Split a segment in half');

    % Pulldown to show values
    segModShowList         = {'< none >', 'Name', 'Longitude 1', 'Latitude 1', 'Longitude 2', 'Latitude 2', 'Dip', 'Dip sigma', 'Dip flag', 'Locking depth', 'Locking depth sigma', 'Locking depth flag', 'Strike slip rate and sigma', 'Strike slip rate', 'Strike slip rate sigma', 'Strike slip rate flag', 'Dip slip rate and sigma', 'Dip slip rate', 'Dip slip rate sigma', 'Dip slip rate flag', 'Tensile slip rate and sigma', 'Tensile slip rate', 'Tensile slip rate sigma', 'Tensile slip rate flag', 'Resolution', 'Resolution flag', 'Resolution other', 'Patch file', 'Patch toggle', 'Other 3', 'Patch slip file', 'Patch slip toggle', 'Other 6','Rake', 'Rake Sigma', 'Rake Toggle', 'Other 7', 'Other 8', 'Other 9'};
    Seg.modShowList        = uicontrol('style','popupmenu',      'position', [10 530+20+segmentYOffset 205 20], 'visible','on', 'tag','Seg.modShowList',     'callback','SegmentManagerFunctions(''Seg.modShowList'')',     'String', segModShowList, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Choose a property to display for all segments');
    Seg.modGSelectL        = uicontrol('style','pushbutton',     'position', [10 555+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modGSelectLasso', 'callback','SegmentManagerFunctions(''Seg.modGSelectLasso'')', 'String','GSelectLasso',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Draw lasso and select segments within');
    Seg.modGDeleteL		   = uicontrol('style','pushbutton',     'position', [80 555+20+segmentYOffset  70 20], 'visible','on', 'tag','Seg.modGDeleteLasso', 'callback','SegmentManagerFunctions(''Seg.modGDeleteLasso'')', 'String','GDeleteLasso',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Draw lasso and delete segments within');

    % (Block Manager) File I/O controls
    blockYOffset = 30;
    %Seg.loadBlockFrame    = uicontrol('style','frame',          'position', [  5 345+blockYOffset 290 174],    'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey);
    %Seg.loadTextBlock     = uicontrol('style','text',           'position', [ 10 511+blockYOffset  46  15],    'visible','on', 'tag','Seg.loadTextBlock', 'String','Block File', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.loadBlockFrame     = uipanel  ('units','pixel',           'position', [  5 345+blockYOffset 290 183],   'visible','on', 'tag','Seg.navFrame',      'BackgroundColor',lightGrey, 'title','Block file', 'foreground','b');
    Seg.loadEditBlock      = uicontrol('style','edit',           'position', [ 10 490+blockYOffset 260  20],    'visible','on', 'tag','Seg.loadEditBlock', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8, 'FontName',fn, 'FontSize',fs);
    Seg.dispCheckBlock     = uicontrol('style','checkbox',       'position', [275 490+blockYOffset  15  20],    'visible','on', 'tag','Seg.dispCheckBlock', 'callback','SegmentManagerFunctions(''Seg.dispCheckBlock'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'enable','off', 'Tooltip','Toggle block interior points on/off');
    Seg.loadPushBlock      = uicontrol('style','pushbutton',     'position', [ 10 470+blockYOffset  70  20],    'visible','on', 'tag','Seg.loadPushBlock',  'callback','SegmentManagerFunctions(''Seg.loadPushBlock'')',  'String','Load',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Load a block file');
    Seg.clearPushBlock     = uicontrol('style','pushbutton',     'position', [ 80 470+blockYOffset  70  20],    'visible','on', 'tag','Seg.clearPushBlock', 'callback','SegmentManagerFunctions(''Seg.clearPushBlock'')', 'String','Clear', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Clear current block file');
    Seg.savePushBlock      = uicontrol('style','pushbutton',     'position', [150 470+blockYOffset  70  20],    'visible','on', 'tag','Seg.savePushBlock',  'callback','SegmentManagerFunctions(''Seg.savePushBlock'')',  'String','Save',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Save changes to block file');

    % (Block Manager) Modify block controls
    % Seg.modTextBlock     = uicontrol('style','text',           'position', [ 10 666-220 61 15],               'visible','on', 'tag','Seg.modTextBlock', 'String','Modify Block', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.modSegListBlock    = uicontrol('style','popupmenu',      'position', [ 10 645-200+blockYOffset 205 20], 'visible','on', 'tag','Seg.modSegListBlock', 'callback','SegmentManagerFunctions(''Seg.modSegListBlock'')', 'string', {''},   'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','List of block names');
    Seg.modSegPushBlock    = uicontrol('style','pushbutton',     'position', [220 645-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modSegPushBlock', 'callback','SegmentManagerFunctions(''Seg.modSegPushBlock'')','String','Update', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Confirm changes to selected block(s)');
    segModPropListBlock    = {'< none >', 'Name', 'Euler longitude', 'Euler latitude', 'Rotation rate', 'Euler longitude sigma', 'Euler latitude sigma', 'Rotation rate sigma', 'Internal strain flag', 'Interior longitude', 'Interior latitude', 'a priori pole flag', 'Other 1', 'Other 2', 'Other 3', 'Other 4', 'Other 5', 'Other 6'};
    Seg.modPropListBlock   = uicontrol('style','popupmenu',      'position', [ 10 620-200+blockYOffset 205 20], 'visible','on', 'tag','Seg.modPropListBlock', 'callback','SegmentManagerFunctions(''Seg.modPropListBlock'')', 'string', segModPropListBlock, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Choose a property to modify for currently selected block(s)');
    Seg.modPropEditBlock   = uicontrol('style','edit',           'position', [220 620-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modPropEditBlock', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    % <--- Modified by JPL, 1/24/2008 
    Seg.modAddBlock        = uicontrol('style','pushbutton',     'position', [150 595-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modAddBlock',        'callback','SegmentManagerFunctions(''Seg.modAddBlock'')',        'String','Add',        'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Create a new block interior point');
    Seg.modDeleteBlock     = uicontrol('style','pushbutton',     'position', [ 80 595-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modDeleteBlock',     'callback','SegmentManagerFunctions(''Seg.modDeleteBlock'')',     'String','GDelete',    'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Delete a single block interior point');
    Seg.modDeleteBlockBox  = uicontrol('style','pushbutton',     'position', [ 80 575-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modDeleteBlockBox',  'callback','SegmentManagerFunctions(''Seg.modDeleteBlockBox'')',  'String','GDeleteBox', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Draw box and delete block interior points within');
    Seg.modMoveBlock       = uicontrol('style','pushbutton',     'position', [220 575-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modMoveBlock',       'callback','SegmentManagerFunctions(''Seg.modMoveBlock'')',       'String','Move',       'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Move a block interior point');
    Seg.modGSelectBlock    = uicontrol('style','pushbutton',     'position', [ 10 595-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modGSelectBlock',    'callback','SegmentManagerFunctions(''Seg.modGSelectBlock'')',    'String','GSelect',    'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Select a single block interior point');
    Seg.modGSelectBlockBox = uicontrol('style','pushbutton',     'position', [ 10 575-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modGSelectBlockBox', 'callback','SegmentManagerFunctions(''Seg.modGSelectBlockBox'')', 'String','GSelectBox', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Draw box and select block interior points within');
    Seg.modClearBlock      = uicontrol('style','pushbutton',     'position', [220 595-200+blockYOffset  70 20], 'visible','on', 'tag','Seg.modClearBlock',      'callback','SegmentManagerFunctions(''Seg.modClearBlock'')',      'String','Clear',      'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Clear block interior point selection');
    % Pulldown to show values
    segModShowListBlock    = {'< none >', 'Name', 'Euler longitude', 'Euler latitude', 'Rotation rate', 'Euler longitude sigma', 'Euler latitude sigma', 'Rotation rate sigma', 'Internal strain flag', 'Interior longitude', 'Interior latitude', 'a priori pole flag', 'Other 1', 'Other 2', 'Other 3', 'Other 4', 'Other 5', 'Other 6'};
    Seg.modShowListBlock   = uicontrol('style','popupmenu',      'position', [ 10 570-220+blockYOffset 205 20], 'visible','on', 'tag','Seg.modShowListBlock', 'callback','SegmentManagerFunctions(''Seg.modShowListBlock'')', 'string', segModShowListBlock, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Choose a property to display at block interior points');

    % Start interface for loading meshes
    meshYOffset = -390;
    %Seg.loadMeshFrame     = uicontrol('style','frame',          'position', [  5 685+meshYOffset 290 54],      'visible','on', 'tag','Seg.meshFrame', 'BackgroundColor',lightGrey);
    %Seg.loadTextMesh      = uicontrol('style','text',           'position', [ 10 731+meshYOffset  50 15],      'visible','on', 'tag','Seg.loadTextMesh', 'String','Mesh File', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.loadMeshFrame      = uipanel('units','pixel',            'position', [  5 685+meshYOffset 290 63],      'visible','on', 'tag','Seg.meshFrame', 'title','Mesh file', 'BackgroundColor',lightGrey, 'foreground','b');
    Seg.loadEditMesh       = uicontrol('style','edit',           'position', [ 10 712+meshYOffset 260 20],      'visible','on', 'tag','Seg.loadEditMesh', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8);
    Seg.dispCheckMesh      = uicontrol('style','checkbox',       'position', [275 712+meshYOffset  15 20],      'visible','on', 'tag','Seg.dispCheckMesh', 'callback','SegmentManagerFunctions(''Seg.dispCheckMesh'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'enable','off', 'Tooltip','Toggle mesh(es) on/off');
    Seg.loadPushMesh       = uicontrol('style','pushbutton',     'position', [ 10 688+meshYOffset  70 20],      'visible','on', 'tag','Seg.loadPushMesh',  'callback','SegmentManagerFunctions(''Seg.loadPushMesh'')', 'String','Load', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Load mesh or mesh property file');
    Seg.clearPushMesh      = uicontrol('style','pushbutton',     'position', [ 80 688+meshYOffset  70 20],      'visible','on', 'tag','Seg.clearPushMesh', 'callback','SegmentManagerFunctions(''Seg.clearPushMesh'')', 'String','Clear', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Clear current mesh file(s)');
    Seg.snapPushMesh       = uicontrol('style','pushbutton',     'position', [150 688+meshYOffset  70 20],      'visible','on', 'tag','Seg.snapPushMesh',  'callback','SegmentManagerFunctions(''Seg.snapPushMesh'')', 'String','Snap segments', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'tooltipstring', sprintf('Snap segments to mesh\n First, select a group of segments approximately along\n the updip edge of a mesh. Then, click ''''Snap segs.'''' to align\n those segments with the triangle edges.'));

    % Block checking options
    integrityYOffset = -45;
    %Seg.navFrame             = uicontrol('style','frame',       'position', [  5 274+integrityYOffset    290 40], 'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey);
    %Seg.modCheckText         = uicontrol('style','text',        'position', [ 10 541-240+integrityYOffset 60 20], 'visible','on', 'tag','Seg.modCheck', 'String','File integrity', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.navFrame              = uipanel('units','pixel',         'position', [  5 274+integrityYOffset    290 48], 'visible','on', 'tag','Seg.navFrame', 'title','File integrity', 'BackgroundColor',lightGrey, 'foreground','b');
    Seg.modCheckSegsBlock     = uicontrol('style','pushbutton',  'position', [ 10 520-240+integrityYOffset 70 20], 'visible','on', 'tag','Seg.modCheckSegsBlock',     'callback','SegmentManagerFunctions(''Seg.modCheckSegsBlock'')',    'String','Check closure', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Check to see if segments form closed blocks');
    Seg.modCheckIpsBlock      = uicontrol('style','pushbutton',  'position', [ 80 520-240+integrityYOffset 70 20], 'visible','on', 'tag','Seg.modCheckIpsBlock',      'callback','SegmentManagerFunctions(''Seg.modCheckIpsBlock'')',     'String','Block Checker', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Check to see that each closed block contains an interior point and/or at least one station');
    Seg.modSegmentChecker     = uicontrol('style','pushbutton',  'position', [150 520-240+integrityYOffset 70 20], 'visible','on', 'tag','Seg.modSegmentChecker',     'callback','SegmentManagerFunctions(''Seg.modSegmentChecker'')',    'String','Seg. Checker',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Highlight problematic segments');
    Seg.modClearSegmentChecks = uicontrol('style','pushbutton',  'position', [220 520-240+integrityYOffset 70 20], 'visible','on', 'tag','Seg.modClearSegmentChecks', 'callback','SegmentManagerFunctions(''Seg.modClearSegmentChecks'')','String','Clear checks',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Clear problematic segment highlighting');
    % --->

    % (Segment Manager) Additional features frame
    dispYOffset = 45;
    %Seg.navFrame         = uicontrol('style','frame',      'position',[ 5  74+dispYOffset-5 290  95], 'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey);
    %Seg.dispText         = uicontrol('style','text',       'position',[10 156+dispYOffset    36  15], 'visible','on', 'tag','Seg.dispText', 'String','Display', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.navFrame          = uipanel('units','pixel',        'position',[ 5  74+dispYOffset-5 290 103], 'visible','on', 'tag','Seg.navFrame', 'title','Display', 'BackgroundColor',lightGrey, 'foreground','b');

    % (Segment Manager) Load line file
    Seg.dispEditLine      = uicontrol('style','edit',       'position',[ 10 135+dispYOffset 120 20], 'visible','on', 'tag','Seg.dispEditLine', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8, 'FontName',fn, 'FontSize',fs);
    Seg.dispPushLine      = uicontrol('style','pushbutton', 'position',[135 135+dispYOffset  28 20], 'visible','on', 'tag','Seg.dispPushLine', 'String','Load', 'callback','SegmentManagerFunctions(''Seg.dispPushLine'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Load a line (fault map) file');
    Seg.dispCheckLine     = uicontrol('style','checkbox',   'position',[170 135+dispYOffset  90 20], 'visible','on', 'tag','Seg.dispCheckLine', 'Enable','off', 'String','line file', 'callback','SegmentManagerFunctions(''Seg.dispCheckLine'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle lines on/off');

    % (Segment Manager) Load xy file
    Seg.dispEditXy        = uicontrol('style','edit',       'position',[ 10 115+dispYOffset 120 20], 'visible','on', 'tag','Seg.dispEditXy', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8, 'FontName',fn, 'FontSize',fs);
    Seg.dispPushXy        = uicontrol('style','pushbutton', 'position',[135 115+dispYOffset  28 20], 'visible','on', 'tag','Seg.dispPushXy', 'String','Load', 'callback','SegmentManagerFunctions(''Seg.dispPushXy'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.dispCheckXy       = uicontrol('style','checkbox',   'position',[170 115+dispYOffset  90 20], 'visible','on', 'tag','Seg.dispCheckXy', 'Enable','off', 'String','xy file', 'callback','SegmentManagerFunctions(''Seg.dispCheckXy'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs);

    % (Segment Manager) Load station file
    Seg.dispEditSta       = uicontrol('style','edit',       'position',[ 10  95+dispYOffset 120 20], 'visible','on', 'tag','Seg.dispEditSta', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontSize',8, 'FontName',fn, 'FontSize',fs);
    Seg.dispPushSta       = uicontrol('style','pushbutton', 'position',[135  95+dispYOffset  28 20], 'visible','on', 'tag','Seg.dispPushSta', 'String','Load', 'callback','SegmentManagerFunctions(''Seg.dispPushSta'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs, 'Tooltip','Load GPS station file');
    Seg.dispCheckStaNames = uicontrol('style','checkbox',   'position',[170  95+dispYOffset  90 20], 'visible','on', 'tag','Seg.dispCheckStaNames', 'Enable','off', 'String','stat. names',     'callback','SegmentManagerFunctions(''Seg.dispCheckStaNames'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle station names on/off');
    Seg.dispCheckSta      = uicontrol('style','checkbox',   'position',[170  73+dispYOffset 120 20], 'visible','on', 'tag','Seg.dispCheckSta',      'Enable','off', 'String','stat. locations', 'callback','SegmentManagerFunctions(''Seg.dispCheckSta'')',      'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle station locations on/off');

    % *** new addition of station vector viewing ***
    Seg.dispCheckStaVec   = uicontrol('style','checkbox',   'position',[ 10  73+dispYOffset  60 20], 'visible','on', 'tag','Seg.dispCheckStaVec', 'String','vectors', 'callback','SegmentManagerFunctions(''Seg.dispCheckStaVec'')', 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle velocity vectors on/off');
    Seg.dipsScaleStaVec   = 0;

    % Slider to control velocity scaling (operates on ALL plotted vectors identically)
    %Seg.velSlider        = uicontrol('style','slider',     'position',[ 80  73+dispYOffset 90 20], 'min',1e-6, 'max',2, 'value',1.0, 'visible','on', 'tag','Seg.velSlider', 'callback','SegmentManagerFunctions(''Seg.velSlider'')', 'BackgroundColor',white, 'HorizontalAlignment','left', 'FontSize',8, 'enable', 'on');
    Seg.velPushUp         = uicontrol('style','push',       'position',[ 70  73+dispYOffset 30 20], 'String','+', 'visible','on', 'tag','Seg.velPushUp',   'callback','SegmentManagerFunctions(''Seg.velPushUp'')', 'BackgroundColor',white, 'HorizontalAlignment','left', 'FontSize',12, 'enable','on', 'Tooltip','Increase velocity vector scaling');
    Seg.velPushDown       = uicontrol('style','push',       'position',[100  73+dispYOffset 30 20], 'String','-', 'visible','on', 'tag','Seg.velPushDown', 'callback','SegmentManagerFunctions(''Seg.velPushDown'')', 'BackgroundColor',white, 'HorizontalAlignment','left', 'FontSize',12, 'enable','on', 'Tooltip','Decrease velocity vector scaling');

    % (Segment Manager) Topo, Grid lines, and meridian popups
    %Seg.dispTopo         = uicontrol('style','popupmenu',  'position',[210 135+dispYOffset 80 20], 'visible','on', 'tag','Seg.dispTopo', 'callback','SegmentManagerFunctions(''Seg.dispTopo'')', 'string', {'Topo off', 'Topo on'}, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs);
    %Seg.dispGrid         = uicontrol('style','popupmenu',  'position',[210 115+dispYOffset 80 20], 'visible','on', 'tag','Seg.dispGrid', 'callback','SegmentManagerFunctions(''Seg.dispGrid'')', 'string', {'Grid off', 'Grid on'}, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs);
    %Seg.dispDips         = uicontrol('style','popupmenu',  'position',[210  95+dispYOffset 80 20], 'visible','on', 'tag','Seg.dispDips', 'callback','SegmentManagerFunctions(''Seg.dispDips'')', 'string', {'Dips off', 'Dips on'}, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs);
    Seg.dispTopo          = uicontrol('style','checkbox',   'position',[245 135+dispYOffset 45 20], 'visible','on', 'tag','Seg.dispTopo', 'callback','SegmentManagerFunctions(''Seg.dispTopo'')', 'string', {'Topo'}, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle Google topography layer on/off');
    Seg.dispGrid          = uicontrol('style','checkbox',   'position',[245 115+dispYOffset 45 20], 'visible','on', 'tag','Seg.dispGrid', 'callback','SegmentManagerFunctions(''Seg.dispGrid'')', 'string', {'Grid'}, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle lat./lon. grid on/off');
    Seg.dispDips          = uicontrol('style','checkbox',   'position',[245  95+dispYOffset 45 20], 'visible','on', 'tag','Seg.dispDips', 'callback','SegmentManagerFunctions(''Seg.dispDips'')', 'string', {'Dips'}, 'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','Toggle fault dips on/off');

    % (Segment Manager) Navigate frame and navigation rose buttons
    %Seg.navFrame         = uicontrol('style','frame',      'position',[  5 5 290 90],    'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey);
    %Seg.navText          = uicontrol('style','text',       'position',[ 10 87 44 15],    'visible','on', 'tag','Seg.navText', 'String','Navigate', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.navFrame          = uipanel('units','pixel',        'position',[  5 5 290 98],    'visible','on', 'tag','Seg.navFrame', 'BackgroundColor',lightGrey, 'title','Navigate', 'foreground','b');
    Seg.navSW             = uicontrol('style','pushbutton', 'position',[230 10 20 20],    'visible','on', 'tag','Seg.navSW',   'String','SW', 'callback','SegmentManagerFunctions(''Seg.navSW'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navS              = uicontrol('style','pushbutton', 'position',[250 10 20 20],    'visible','on', 'tag','Seg.navS',    'String','S',  'callback','SegmentManagerFunctions(''Seg.navS'')',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navSE             = uicontrol('style','pushbutton', 'position',[270 10 20 20],    'visible','on', 'tag','Seg.navSE',   'String','SE', 'callback','SegmentManagerFunctions(''Seg.navSE'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navW              = uicontrol('style','pushbutton', 'position',[230 30 20 20],    'visible','on', 'tag','Seg.navW',    'String','W',  'callback','SegmentManagerFunctions(''Seg.navW'')',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navC              = uicontrol('style','pushbutton', 'position',[250 30 20 20],    'visible','on', 'tag','Seg.navC',    'String','C',  'callback','SegmentManagerFunctions(''Seg.navC'')',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navE              = uicontrol('style','pushbutton', 'position',[270 30 20 20],    'visible','on', 'tag','Seg.navE',    'String','E',  'callback','SegmentManagerFunctions(''Seg.navE'')',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navNW             = uicontrol('style','pushbutton', 'position',[230 50 20 20],    'visible','on', 'tag','Seg.navNW',   'String','NW', 'callback','SegmentManagerFunctions(''Seg.navNW'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navN              = uicontrol('style','pushbutton', 'position',[250 50 20 20],    'visible','on', 'tag','Seg.navN',    'String','N',  'callback','SegmentManagerFunctions(''Seg.navN'')',  'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navNE             = uicontrol('style','pushbutton', 'position',[270 50 20 20],    'visible','on', 'tag','Seg.navNE',   'String','NE', 'callback','SegmentManagerFunctions(''Seg.navNE'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);

    % (Segment Manager) longitude and latitude ranges
    Seg.navTextLonRange   = uicontrol('style','text',       'position',[ 10 82-10 70 15], 'visible','on', 'tag','Seg.navText', 'String','Lon Range', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.navTextLatRange   = uicontrol('style','text',       'position',[ 80 82-10 44 15], 'visible','on', 'tag','Seg.navText', 'String','Lat Range', 'BackgroundColor',lightGrey, 'HorizontalAlignment','left', 'FontName',fn, 'FontSize',fs);
    Seg.navEditLonMax     = uicontrol('style','edit',       'position',[ 10 50 70 20],    'visible','on', 'tag','Seg.navEditLonMax', 'BackgroundColor',lightGrey, 'HorizontalAlignment','right', 'FontName',fn, 'FontSize',fs);
    Seg.navEditLonMin     = uicontrol('style','edit',       'position',[ 10 30 70 20],    'visible','on', 'tag','Seg.navEditLonMin', 'BackgroundColor',lightGrey, 'HorizontalAlignment','right', 'FontName',fn, 'FontSize',fs);
    Seg.navEditLatMax     = uicontrol('style','edit',       'position',[ 80 50 70 20],    'visible','on', 'tag','Seg.navEditLatMax', 'BackgroundColor',lightGrey, 'HorizontalAlignment','right', 'FontName',fn, 'FontSize',fs);
    Seg.navEditLatMin     = uicontrol('style','edit',       'position',[ 80 30 70 20],    'visible','on', 'tag','Seg.navEditLatMin', 'BackgroundColor',lightGrey, 'HorizontalAlignment','right', 'FontName',fn, 'FontSize',fs);
    Seg.navUpdate         = uicontrol('style','pushbutton', 'position',[150 50 70 20],    'visible','on', 'tag','Seg.navUpdate', 'String','Update', 'callback','SegmentManagerFunctions(''Seg.navUpdate'')', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navBack           = uicontrol('style','pushbutton', 'position',[150 30 70 20],    'visible','on', 'tag','Seg.navBack',   'String','Back',   'callback','SegmentManagerFunctions(''Seg.navBack'')',   'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);

    % (Segment Manager) Zoom options
    Seg.navZoomIn         = uicontrol('style','pushbutton', 'position',[ 10 10 70 20],    'visible','on', 'tag','Seg.navZoomIn',    'callback','SegmentManagerFunctions(''Seg.navZoomIn'')',    'String','Zoom In',    'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navZoomOut        = uicontrol('style','pushbutton', 'position',[ 80 10 70 20],    'visible','on', 'tag','Seg.navZoomOut',   'callback','SegmentManagerFunctions(''Seg.navZoomOut'')',   'String','Zoom Out',   'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);
    Seg.navZoomRange      = uicontrol('style','pushbutton', 'position',[150 10 70 20],    'visible','on', 'tag','Seg.navZoomRange', 'callback','SegmentManagerFunctions(''Seg.navZoomRange'')', 'String','Zoom Range', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'FontName',fn, 'FontSize',fs);

    % (Segment Manager) Print, Save, Zumax
    Seg.pszCoords         = uicontrol('style','edit',       'position',[900 10 270 20],   'visible','on', 'tag','Seg.pszCoords', 'BackgroundColor',lightGrey, 'HorizontalAlignment','center', 'String',' ', 'FontName',fn, 'FontSize',fs);

    % (Segment Manager) Segment file figure axes
    Seg.axHandle = axes('parent',gcf, 'units','pixels', 'position',[335 60 850 750], 'visible','on', 'Tag','Seg.axHandle', 'Layer','top', 'XLim',[0 360], 'YLim',[-90 90], 'FontName',fn, 'FontSize',fs, 'Layer','top', 'NextPlot','add');

    % Create handles structure for easy use in the callback later
    Handles.Seg = Seg;
    set(hFig, 'userdata', Handles);

    % Clear the axes
    SegmentManagerFunctions('DrawClean');

    % Make all figure components normalized so that they auto-resize on figure resize
    set(findall(hFig,'-property','Units'),'Units','norm');

    % Maximize the GUI in its current screen
    drawnow;  % this is required for jFrame to be accessible
    warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
    jFrame = get(handle(hFig),'JavaFrame');
    if ~exist('nomaximize', 'var')
       jFrame.setMaximized(true);
    end
    
    % Making the GUI visible and give it a name
    set(hFig, 'visible','on', 'name', 'Segment Manager');
    set(hFig, 'DoubleBuffer', 'on');

end