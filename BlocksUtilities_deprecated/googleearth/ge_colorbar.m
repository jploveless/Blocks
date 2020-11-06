function [output] = ge_colorbar(x,y,data,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_colorbar.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions(mfilename);


if isempty(data)
    error(['Empty data array passed to function ', mfilename])
end
% Assign default parameter values:
           altitude = 1.0;
       altitudeMode = 'clampToGround';
    cBarBorderWidth = 1;
      cBarFormatStr = '%g';
           cLimHigh = max(data(:));
            cLimLow = min(data(:));
           colorMap = 'jet';
            extrude = 1;      
          iconScale = 1.0;
                 id = 'colorbar';
              idTag = 'id';
        msgToScreen = false;
               name = 'ge_colorbar';
         numClasses = 15;
      timeSpanStart = ' ';
       timeSpanStop = ' ';
          timeStamp = ' ';
             region = ' ';
             labels = {};
         visibility = 1;
  numClassesDefault = 10;
  showNumbersColumn = true;

parsepairs %script that parses Parameter/value pairs.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end

if( isempty( x ) || isempty( y ))
    error('empty coordinates passed to ge_colorbar(...).');
else
    coords(:,1) = x(:);
    coords(:,2) = y(:);
end

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end 

if exist('nanValue','var')&&~isnan(nanValue)
    data(data==nanValue)=NaN;
end
if ~exist('cLimHigh','var')
    cLimHigh = max(data(:));
end
if ~exist('cLimLow','var')
    cLimLow = min(data(:));
end



if ischar(colorMap)
    RIx = figure('visible','off');
    eval(['colorMapTMP = colormap(' colorMap '(256));']);
    close(RIx)
    clear RIx
    colorMap = colorMapTMP;
    X = linspace(0,1,size(colorMapTMP,1))';    
    clear colorMapTMP
else
    X = linspace(0,1,size(colorMap,1))';
end


IOa = ~isempty(strmatch('lineValues',varargin(1:2:end),'exact'));
IOb = ~isempty(strmatch('numClasses',varargin(1:2:end),'exact'));

if IOa && IOb
    error('Can''t have both ''lineValues'' and ''numClasses'' as input parameters.')
elseif IOa && ~IOb
    Ix = strmatch('lineValues',varargin(1:2:end),'exact');
    lineValues = varargin{2*max(Ix)};
elseif ~IOa && IOb
    Ix = strmatch('numClasses',varargin(1:2:end),'exact');
    numClasses = varargin{2*max(Ix)};
    lineValues = linspace(cLimLow,cLimHigh,numClasses+1);
    clear numClasses
elseif ~IOa && ~IOb
    numClasses = numClassesDefault;
    lineValues = linspace(cLimLow,cLimHigh,numClasses+1);
    clear numClasses
else
    error('Something''s wrong here.')
end



if ~isempty(labels)
    if (length(labels) ~= 1) && (length(labels) ~= numel(lineValues))
        error(['dataLabels array is of improper length.']);   
    end

    if length(labels) == 1
        for r=1:numClasses
            labels{r} = labels{1};
        end
    end  
end


html = ['<TABLE border=' num2str(cBarBorderWidth) ' bgcolor=#FFFFFF>',10];

for k=numel(lineValues):-1:1
    
    f = (lineValues(k)-cLimLow)/(cLimHigh-cLimLow);

    if f<0
        f=0;
    end
    if f>1
        f=1;
    end

    polyColor(1,1) = interp1(X,colorMap(:,1),f);
    polyColor(1,2) = interp1(X,colorMap(:,2),f);
    polyColor(1,3) = interp1(X,colorMap(:,3),f);

    polyColorStr(1:2) = dec2hex(round(polyColor(1)*255),2);
    polyColorStr(3:4) = dec2hex(round(polyColor(2)*255),2);
    polyColorStr(5:6) = dec2hex(round(polyColor(3)*255),2);

    html = [html,'<TR><TD width="15px" bgcolor=#',polyColorStr, '>&nbsp;</TD>',...
        '<TD bgcolor=#FFFFFF>'];
    if showNumbersColumn
        if k<numel(lineValues)
            html=[html,num2str(lineValues(k),cBarFormatStr),...
            ' to ',...
            num2str(lineValues(k+1),cBarFormatStr),'</TD>'];
        else
            html=[html,'&gt;= ',num2str(lineValues(k),cBarFormatStr)];
        end
    end

    if ~isempty(labels)
        html=[html,'<TD>',labels{k},'</TD>'];
    end

    html = [html,'</TR>',10];

end

html = [html,'</TABLE>'];

coords(:,3) = altitude;
id_chars = [ idTag '="' id '"' ];
poly_id_chars = [ idTag '="poly_' id '"' ];
name_chars = [ '<name>',10, name,10, '</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' html ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10,int2str(visibility),10,'</visibility>',10 ];
% lineColor_chars = [ '<color>',10, LineColor,10, '</color>',10 ];
% polyColor_chars = [ '<color>',10, PolyColor ,10,'</color>',10 ];
% lineWidth_chars= [ '<width>',10, num2str(LineWidth, '%.2f') ,10,'</width>',10 ];
altitudeMode_chars = [ '<altitudeMode>',10, altitudeMode,10, '</altitudeMode>',10 ];
% snippet_chars = [ '<Snippet>',10, Snippet ,10,'</Snippet>' ];
extrude_chars = [ '<extrude>',10, int2str(extrude),10, '</extrude>' ];

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

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end


    
header=['<Placemark ',id_chars,'>',10,...
    name_chars,10,...
    timeStamp_chars,...
    timeSpan_chars,...
    visibility_chars,10,...
    description_chars,...
    region_chars, ...
    '	<Style>',...
		'<IconStyle>',...
			'<scale>',num2str(iconScale),'</scale>',...
			'<Icon>',...
				'<href>http://maps.google.com/mapfiles/kml/shapes/donut.png</href>',...
			'</Icon>',...
		'</IconStyle>',...
		'<ListStyle>',...
		'</ListStyle>',...
	'</Style>',...
  '<Point ',poly_id_chars,'>',10,...
    altitudeMode_chars,...
    extrude_chars,...
    '<tessellate>',10,'1',10,'</tessellate>',10,...
    '<coordinates>',10];


footer = ['</coordinates>',10,...
    10,'</Point>',10,...
    10,'</Placemark>',10];  

output = '';

if ~isnan(coords)
    coordinates = conv_coord(coords);
    output = [ header, coordinates, footer ]; 
end

if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS START HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function s = conv_coord(M)
%% conv_coord(M)
% helper function to conver decimal degree coordinates into character array
s=[];

for r=1:size(M,1)
    for c=1:size(M,2)
        s = [s,sprintf('%.6f',M(r,c))];
        s = trim_trail_zero(s);
        if c==size(M,2)
            s=[s,10];
        else
            s=[s,','];          
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s_out = trim_trail_zero(s_in)
%   helper function meant to trim trailing character zeros from a character
%   array.

dig = 1;
L = length(s_in);
last_char = s_in(L);

cont = true;

while (strcmp(last_char,'0') || strcmp(last_char,'.')) && cont==1
    if strcmp((last_char),'.')
        cont = 0;
    end
    s_in = s_in(1:L-dig);
    last_char = s_in(length(s_in));
    dig = dig+1;
end

s_out = s_in;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = conv2colorstr(R,G,B)
% Please note that this conv2colorstr is different from that in
% ge_imagesc. This one writes HTML formatted hexadecimal 
% colorstrings, ge_imagesc() writes KML formatted colorstr.

S='000000';

hexR = dec2hex(round(R*255));
hexG = dec2hex(round(G*255));
hexB = dec2hex(round(B*255));

LR = length(hexR);
LG = length(hexG);
LB = length(hexB);

S(3-LR:2)=hexR;
S(5-LG:4)=hexG;
S(7-LB:6)=hexB;

