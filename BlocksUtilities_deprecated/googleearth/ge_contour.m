function varargout = ge_contour(x,y,z,varargin)
% Reference page in help browser:
%
% <a href="matlab:web(fullfile(ge_root,'html','ge_contour.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a>
%

% this function is based on ge_contourf_dev3.m


% tinyResFactor = 1e-8;
nearInf = abs(max(z(:))*10);
msgToScreen = false;
lineWidth = 4;
minz = min(z(:));
maxz = max(z(:));
% polyClosedThreshold = 1e-5;
altitudeMode = 'clampToGround';
altitude = 1.0;
lineColor = 'auto';
lineAlpha = 'FF';
region = '  ';
timeSpanStart = ' ';
timeSpanStop = ' ';
tessellate = 1;
extrude = 0;
visibility = 1;
colorMap = 'jet';
polyAlpha = '00';
vizProcessing = false;
numClassesDefault = 10;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

AuthorizedOptions = authoptions('ge_contour');

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

if ischar(colorMap)
    RIx = figure('visible','off');
    eval(['colorMapTMP = colormap(' colorMap '(256));']);
    close(RIx)
    clear RIx
    colorMap = colorMapTMP;
    clear colorMapTMP
end

X = linspace(0,1,size(colorMap,1))';


[kmlStrNotUsed,contourfCell] = ge_contourf(x,y,z,varargin{:});
polyColorStr = contourfCell(:,5);
clear kmlStrNotUsed

contourArray = contourc(x(1,:),y(:,1),z,lineValues);
contourCell = parseContArray(contourArray,nearInf);
nRecords = size(contourCell,1);

for iRecord=1:nRecords
    f = (contourCell{iRecord,1}-cLimLow)/(cLimHigh-cLimLow);

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


nRecords = size(contourCell);

kmlStr = '';
for iRecord = 1:nRecords % my

%     if isempty(polyColorStr{iRecord})
%         continue
%     end
% 
     lineValueIx = find(contourCell{iRecord,1}==lineValues);
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
         b=k-1;
         if max(max(z(2:end-1,2:end-1)))<lineValues(k)
             break
         end
     end
     switch lineValueIx
         case a-1
             nameStr = [' &lt; ',num2str(lineValues(a))];
         case b+1
             nameStr = [' &gt;= ',num2str(lineValues(b))];
         otherwise
             nameStr = [num2str(lineValues(lineValueIx)),' to ',num2str(lineValues(lineValueIx+1))];
     end

    if lineColorAuto
        actualLineColor = [lineAlpha,polyColorStr{iRecord}];
    else
        actualLineColor = [lineAlpha,lineColor];
    end


    kmlStr=[kmlStr,ge_plot(contourCell{iRecord,3},contourCell{iRecord,4},...
        'altitude',altitude,...
        'lineColor',actualLineColor,...
        'lineWidth',lineWidth,...
        'region', region, ...
        'timeSpanStart',timeSpanStart,...
        'timeSpanStop',timeSpanStop,...
        'altitudeMode',altitudeMode,...
        'tessellate',tessellate,...
        'extrude',extrude,...
        'visibility',visibility,...
        'name',nameStr)];
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


