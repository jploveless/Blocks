function varargout = ge_contourf(x,y,z,varargin)
% Reference page in help browser:
%
% <a href="matlab:web(fullfile(ge_root,'html','ge_contourf.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a>
%

tinyResFactor = 1e-8;
nearInf = abs(max(z(:))*10);
msgToScreen = false;
lineWidth = 0.1;
minz = min(z(:));
maxz = max(z(:));
polyClosedThreshold = 1e-5;
altitudeMode = 'clampToGround';
altitude = 1.0;
lineColor = '000000';
lineAlpha = 'FF';
autoClose = true;
region = '  ';
timeSpanStart = ' ';
timeSpanStop = ' ';
tessellate = 1;
extrude = 0;
visibility = 1;
colorMap = 'jet';
polyAlpha = 'D0';
vizProcessing = false;
numClassesDefault = 10;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

AuthorizedOptions = authoptions('ge_contourf');

parsepairs %script that parses Parameter/value pairs.

if strcmp(lineColor,'auto')
    lineColorAuto = true;
elseif numel(lineColor)~=6
    error('Error with ''lineColor'' parameter (expects 6 elements).')
elseif all(ismember(lineColor,'0123456789ABCDEF'))
    lineColorAuto = false;
else
    error('Unknown string specified for parameter ''lineColor''.')
end

if msgToScreen
    disp(['Running ' mfilename '...'])
end

if lineWidth==0
    lineAlpha = '00';
end

if isempty(x) || isempty(y) || isempty(z)
    error(['Empty coordinates passed to function ',mfilename,'.']);
end

if ~(isequal(altitudeMode,'clampToGround')||...
        isequal(altitudeMode,'relativeToGround')||...
        isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
end

if isequal(size(x),size(z))
    xv = x(1,:);
else
    error('First 3 input argument should be of identical size.')
end

if isequal(size(y),size(z))
    yv = y(:,1);
else
    error('First 3 input argument should be of identical size.')
end

if ~exist('cLimLow','var')
    cLimLow = minz;
end
if ~exist('cLimHigh','var')
    cLimHigh = maxz;
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



if ischar(colorMap)
    RIx = figure('visible','off');
    eval(['colorMapTMP = colormap(' colorMap '(256));']);
    close(RIx)
    clear RIx
    colorMap = colorMapTMP;
    clear colorMapTMP
end


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


[nR,nC] = size(z);
tmp_z = ones([nR,nC]+2)*nearInf;
tmp_z(2:end-1,2:end-1) = z;
z = tmp_z;

dx = ((xv(end)-xv(1))/(size(xv,2)-1))*tinyResFactor;
xv = [xv(1)-dx,xv,xv(end)+dx];

if dx<0
    error('First input argument should be increasing with increasing column number.')
end

dy = ((yv(1)-yv(end))/(size(yv,1)-1))*tinyResFactor;
yv = [yv(1)+dy;yv;yv(end)-dy];

if dy<0
    error('Second input argument should be decreasing with increasing row number.')
end


contourArray = contourc(xv,yv,z,lineValues);
contourCell = parseContArray(contourArray,nearInf);

nRecords = size(contourCell,1);
for m = 1:nRecords
    contourCell{m,7} = calcIsAdjacent(contourCell,m,lineValues);
end

contourCell = calcIsInner(contourCell);

contourCell = calcArea(contourCell);

% calculate how small the smallest non-artificial polygon could be
lowThresPoly = 4*dx*dy+... % corners
               dx*(yv(2)-yv(end-1))+... % left and right sides
               dy*(xv(end-1)-xv(2));   % top and bottom sides

[polyColorStr,contourCell] = detPolyColorStr(contourCell,xv,yv,z,...
    cLimLow,cLimHigh,colorMap,lineValues,lowThresPoly,vizProcessing);



% % % % % % % % % % % % % % % % % % % % % % % % % %           
% disp('')
% for m=1:nRecords
%     figure(1)
%     clf
%     for iRecord=1:nRecords
%         h=plot(contourCell{iRecord,3},contourCell{iRecord,4});
%         set(h,'color',[0.7,0.7,0.7])
%         hold on
%     end
%     plot(contourCell{m,3},contourCell{m,4},'Color',[0,0,1],'LineWidth',2)
% 
% %     for iBlack = find(contourCell{m,5})'
% %         plot(contourCell{iBlack,3},contourCell{iBlack,4},'-k.')
% %     end
% % 
% %     for iYellow = find(contourCell{m,7})'
% %         plot(contourCell{iYellow,3},contourCell{iYellow,4},'-y.')
% %     end
% 
%     for iPink = find(contourCell{m,8})'
%         plot(contourCell{iPink,3},contourCell{iPink,4},'Color',[0,0,1],'LineWidth',0.2)
%     end
% 
%     drawnow
% %     pause(1)
% end
% % % % % % % % % % % % % % % % % % % % % % % % % %           




kmlStr = '';
for iRecord = 1:nRecords % my

    if isempty(polyColorStr{iRecord})
        continue
    end

    if isClosed(contourCell(iRecord,:),polyClosedThreshold)

        innerBoundsStr = buildInnerStr(contourCell,iRecord,altitude);
        lineValueIx = find(contourCell{iRecord,10}==lineValues);
        if isempty(lineValueIx)
            continue
        end
        for k=1:numel(lineValues)
            a=k;            
            if min(min(z(2:end-1,2:end-1)))<lineValues(k)
                break
            end
        end
        for k=1:numel(lineValues)
            b=k;
            if max(max(z(2:end-1,2:end-1)))<lineValues(k)
                break
            end
        end        
        switch lineValueIx
            case a-1
                nameStr = [' &lt; ',num2str(lineValues(a))];
            case b
                nameStr = [' &gt;= ',num2str(lineValues(b))];
            otherwise
                nameStr = [num2str(lineValues(lineValueIx)),' to ',num2str(lineValues(lineValueIx+1))];
        end
        
        if lineColorAuto
            actualLineColor = [lineAlpha,polyColorStr{iRecord}];
        else
            actualLineColor = [lineAlpha,lineColor];
        end
        
        kmlStr=[kmlStr,ge_poly(contourCell{iRecord,3},contourCell{iRecord,4},...
            'altitude',altitude,...
            'innerBoundsStr',innerBoundsStr,...
            'lineColor',actualLineColor,...
            'lineWidth',lineWidth,...
            'polyColor',[polyAlpha,polyColorStr{iRecord}],...
            'autoClose',autoClose,...
            'region', region, ...
            'timeSpanStart',timeSpanStart,...
            'timeSpanStop',timeSpanStop,...
            'altitudeMode',altitudeMode,...
            'tessellate',tessellate,...
            'extrude',extrude,...
            'visibility',visibility,...
            'name',nameStr)];
    else
        warning(['Contour line record in ',39,'contourCell{',...
            num2str(m),',1}',39,' skipped',10,...
            'because it is not closed.'])
    end
end

if msgToScreen
    disp(['Running ' mfilename '...Done.'])
end


if nargout==1
    varargout{1} = kmlStr;
elseif nargout==2
    varargout{1} = kmlStr;
    varargout{2} = [contourCell(:,[3,4,9,10]),polyColorStr];
else
end

% aa








% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % %      LOCAL FUNCTIONS START HERE       % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function A = parseContArray(C,nearInf)

% column 1: level
% column 2: number of points
% column 3: xcoords
% column 4: ycoords
% column 5: the current polygon contains these polygons

curCol = 1;
n = 1;

while curCol<size(C,2)

    L = C(2,curCol);
    lineValue = C(1,curCol);
    if lineValue~=nearInf
        A{n,1} = C(1,curCol);
        A{n,2} = L;
        A{n,3} = C(1,curCol+1:curCol+L);
        A{n,4} = C(2,curCol+1:curCol+L);
        %lineValuesTmp(n,1) = C(1,curCol);
        n = n + 1;
    end

    curCol = curCol + L + 1;

end

% % % % % % % % % % % % % % % % 
nRecords = size(A,1);
for iRecord = 1:nRecords
    IN = repmat(false,[nRecords,1]);
    for iRecordOther = [1:iRecord-1,iRecord+1:nRecords]
        IN(iRecordOther,1) = all(inpolygon(A{iRecordOther,3},A{iRecordOther,4},...
                                  A{iRecord,3},A{iRecord,4}));
    end
    A{iRecord,5} = IN;
end
% % % % % % % % % % % % % % % % 

nRecords = size(A,1);
for iRecord = 1:nRecords
    A{iRecord,6} = polyarea(A{iRecord,3},A{iRecord,4});
end
% % % % % % % % % % % % % % % % 





% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function isAdjacentLevel = calcIsAdjacent(contourCell,m,lineValues)

nRecords = size(contourCell,1);
isAdjacentLevel = repmat(false,[nRecords,1]);


% It seems that contourc sometimes rounds off in a weird way...therefore
% a tweak is necessary here, in order not to end up with empty 'myIndexVec'
% and 'otherIndexVec' variables.

TMP = unique(lineValues);
dTMP = TMP(2:end)-TMP(1:end-1);
smallestDist = min(unique(dTMP));
roundOffFactor = 100;

for o = [1:m-1,m+1:nRecords]

    myRecord = contourCell(m,1:4);
    otherRecord = contourCell(o,1:4);

    f = smallestDist/roundOffFactor;
    myRecordRound = round(myRecord{1,1}/f) * f;
    otherRecordRound = round(otherRecord{1,1}/f) * f;

    lineValuesRound = round(lineValues/f) * f;

    myIndexVec = find(lineValuesRound==myRecordRound);
    otherIndexVec = find(lineValuesRound==otherRecordRound);

    % test whether the levels are adjacent:
    isAdjacentLevel(o,1) = ismember(myIndexVec-otherIndexVec,[-1,0,1]);
    
end

% end function calcIsAdjacent
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %




function contourCell = calcIsInner(contourCell)
nRecords = size(contourCell,1);
for iRecord = 1:nRecords

    isInner = contourCell{iRecord,5} & contourCell{iRecord,7};
    TMP = find(isInner)';

    if numel(TMP)<=1

    else
        for me=TMP
            for he=TMP
                if me<he
                    % clf
                    % plot(contourCell{iRecord,3},contourCell{iRecord,4},'-b.',...
                    %     contourCell{he,3},contourCell{he,4},'-k.',...
                    %      contourCell{me,3},contourCell{me,4},'-m.')
                     
                    if all(inpolygon(contourCell{he,3},contourCell{he,4},...
                         contourCell{me,3},contourCell{me,4}))
                        isInner(he,1) = false;
                    else
                        disp('')
                    end
                end            
            end
        end
    end
    contourCell{iRecord,8} = isInner;
end
% end function calcIsInner
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %



function IO = isClosed(myRecord,thresholdDiff)

L = myRecord{1,2};
xDiff = myRecord{1,3}(1)-myRecord{1,3}(L);
yDiff = myRecord{1,4}(1)-myRecord{1,4}(L);

IO = sqrt(xDiff^2+yDiff^2) <thresholdDiff;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


function innerBoundsStr = buildInnerStr(contourCell,iRecord,altitude)

innerBoundsStr = ['<innerBoundaryIs>',char(10)'];

for elem = find(contourCell{iRecord,8})'
    innerBoundsStr = [innerBoundsStr,...
        '   <LinearRing>',char(10),...
        '      <coordinates>',char(10),...
        sprintf('          %.16g,%.16g,%.16g \n',...
        [contourCell{elem,3}',contourCell{elem,4}',...
        altitude*ones(size(contourCell{elem,4}'))]'),...
        '      </coordinates>',char(10),...
        '   </LinearRing>',char(10)];
end
innerBoundsStr = [innerBoundsStr,'</innerBoundaryIs>',char(10)];


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


function [polyColorStr,contourCell] = detPolyColorStr(contourCell,xv,yv,Z,...
    cLimLow,cLimHigh,colorMap,lineValues,lowThresPoly,vizProcessing)

% somehow, I can't get the right colors in the filled contours --it's got
% something to do with what boundary is defined as an inner, and what as an
% outer boundary of a polygon.
%
% This function tries to fix the color filling scheme (it pretty 
% inefficient, but at least it seems to work)
% 

roundedZ = Z;
for k=1:numel(lineValues)
    
    IO = Z(2:end-1,2:end-1)>=lineValues(k);
    roundedZ(2:end-1,2:end-1) = IO.*lineValues(k)+ ~IO.*roundedZ(2:end-1,2:end-1);
    
end

IO = Z(2:end-1,2:end-1)<lineValues(1);
roundedZ(2:end-1,2:end-1) = IO.*-Z(1,1)+ ~IO.*roundedZ(2:end-1,2:end-1);


% figure
% imagesc(xv,yv,roundedZ);
% caxis([cLimLow,cLimHigh])
% set(gca,'ydir','normal')

nRecords = size(contourCell,1);
polyColorStr = cell(nRecords,1);

TMP = reshape(1:numel(roundedZ),size(roundedZ));
M = TMP(2:end-1,2:end-1);
nElems = numel(M);
Ix(1,1:nElems) = M(randperm(nElems));
clear M
k=1;

unassigneds = repmat(true,[nRecords,1]);

X = linspace(0,1,size(colorMap,1))';

while any(unassigneds)
    
    [r,c]=ind2sub(size(roundedZ),Ix(k));

    for iRecord = find(unassigneds)'
        
        if contourCell{iRecord,9}<lowThresPoly
            % part of the artificial edge polygons
            unassigneds(iRecord)=false;
        end
        
        [test1IN, test1ON] = inpolygon(xv(c),yv(r),contourCell{iRecord,3},contourCell{iRecord,4});
        if test1IN || test1ON
            
            % retrieve all polygons that fall within the current one
            test2 = false;
            for p = find(contourCell{iRecord,5})'
                test2 = inpolygon(xv(c),yv(r),contourCell{p,3},contourCell{p,4});
                if test2
                    break
                end
            end
            
            if ~test2
                
                if vizProcessing
                    figure(1)
                    clf

                    imagesc(xv(1,2:end-1),yv(2:end-1,1),roundedZ(2:end-1,2:end-1))
                    caxis([cLimLow,cLimHigh])
                    hold on
                    for iRecord2=1:nRecords
                        h(iRecord2)=plot(contourCell{iRecord2,3},contourCell{iRecord2,4});
                        set(h(iRecord2),'color',[0.7,0.7,0.7])
                        hold on
                    end

                    set(h(contourCell{iRecord,5}),'color',[0,0,0])
                    plot(contourCell{iRecord,3},contourCell{iRecord,4},'-m')
                    plot(xv(c),yv(r),'+m')

                    for kk=find(contourCell{iRecord,8})'
                        plot(contourCell{kk,3},contourCell{kk,4},'-y')
                    end
                end
                    
                
                unassigneds(iRecord) = false;
                
                contourCell{iRecord,10} = roundedZ(r,c);


                f = (contourCell{iRecord,10}-cLimLow)/(cLimHigh-cLimLow);

                if f<0
                    f=0;
                end
                if f>1
                    f=1;
                end

                polyColor(1,1) = interp1(X,colorMap(:,1),f);
                polyColor(1,2) = interp1(X,colorMap(:,2),f);
                polyColor(1,3) = interp1(X,colorMap(:,3),f);

                polyColorStr{iRecord,1}(1:2) = dec2hex(round(polyColor(1)*255),2);
                polyColorStr{iRecord,1}(3:4) = dec2hex(round(polyColor(2)*255),2);
                polyColorStr{iRecord,1}(5:6) = dec2hex(round(polyColor(3)*255),2);

            end

        else
            
        end
    end
    
    k=k+1;
    if (k>numel(Ix)) & any(unassigneds)
        
        % When the user selects contours which are closed together, there
        % may not be a grid cell associated with each contour level. Prompt
        % the user to interpolate:
        
        error([mfilename,' is having trouble determining the level of ',char(10),...
            'some contours. Interpolating the data will likely ',char(10),...
            'solve this problem.'])
       
        break
    end

end






% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %



function contourCell = calcArea(contourCell)

nRecords = size(contourCell,1);
for iRecord=1:nRecords
    
    minArea=0;
    for k=find(contourCell{iRecord,8})'
        minArea = minArea + contourCell{k,6};
    end
    contourCell{iRecord,9} = contourCell{iRecord,6}-minArea;
    
end


