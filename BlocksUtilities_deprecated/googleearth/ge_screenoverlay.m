function output = ge_overlay(filename,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_overlay.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );

sizeWidth = 0;  % 0 = true size when sizeWidthUnits = 'pixels'
sizeWidthUnits = 'pixels';
sizeHeight = 0;  % 0 = true size when sizeHeigthUnits = 'pixels'
sizeHeightUnits = 'pixels';
sizeLeft = 0;
sizeLeftUnits = 'fraction';
sizeBottom = 0;
sizeBottomUnits = 'fraction';
posLeft = 0;
posLeftUnits = 'fraction';
posBottom = 0;
posBottomUnits = 'fraction';
         id = 'overlay';
         idTag = 'id';
       drawOrder = 0;
       name = 'ge_overlay';
description = '';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
 rotation = 0.0;
    color = 'ffffffff';
 visibility = 1;
  snippet = ' ';
  region = ' ';

    
parsepairs %script that parses Parameter/Value pairs.


if( isempty( filename ) )
    error('empty filename passed to ge_overlay');
end

finalColor = [color];

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end


id_chars = [ idTag '="', id '"' ];
name_chars = [ '<name>',10, name ,10,'</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10, int2str(visibility) ,10,'</visibility>',10 ];
finalColor_chars = [ '<color>',10,finalColor,10,'</color>',10,];
drawOrder_chars = ['<drawOrder>',int2str(drawOrder),'</drawOrder>'];
if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end
iconURL_chars =  ['<Icon><href>',10, filename,10, '</href></Icon>',10];

 

if timeStamp == ' '
    timeStamp_chars = '';
else
    timeStamp_chars = [ '<TimeStamp><when>' timeStamp '</when></TimeStamp>',10 ];
end

if timeSpanStart == ' '
    timeSpan_chars = '';
else
    if timeSpanStop == ' ' 
        timeSpan_chars = [ '<TimeSpan><begin>' timeSpanStart '</begin></TimeSpan>',10 ];
    else
        timeSpan_chars = [ '<TimeSpan><begin>' timeSpanStart '</begin><end>' timeSpanStop '</end></TimeSpan>',10 ];    
    end
        
end
overlayXY_chars = ['<overlayXY x="' num2str(sizeLeft) '" y="' num2str(sizeBottom) '" xunits="' sizeLeftUnits '" yunits="' sizeBottomUnits '"/>',char(10)];
screenXY_chars  = ['<screenXY x="' num2str(posLeft) '" y="' num2str(posBottom) '" xunits="' posLeftUnits '" yunits="' posBottomUnits '"/>',char(10)];
rotation_chars  = ['<rotation>' num2str(rotation) '</rotation>',char(10)];
size_chars      = ['<size x="',num2str(sizeWidth),'" y="',num2str(sizeHeight),'" xunits="' sizeWidthUnits '" yunits="' sizeHeightUnits '"/>',char(10)];

                             
%screen overlay
chunk = [ ...
    '<ScreenOverlay ',id_chars,'>',10,...
    name_chars,...
    timeStamp_chars,...
    timeSpan_chars,...
    snippet_chars,...
    description_chars,...
    finalColor_chars,...
    visibility_chars,...
    region_chars, ...
    '<open>1</open>',... 
    drawOrder_chars,...
    iconURL_chars,...
    overlayXY_chars,...
    screenXY_chars,...
    rotation_chars,...
    size_chars,...
    '</ScreenOverlay>',... 
];
    
output = [chunk];


