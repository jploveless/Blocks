function [kmlStr] = ge_imagesc(x,y,data,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_imagesc.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );


if isempty(x)||isempty(y)
    error('empty coordinates passed to ge_imagesc().');
elseif isempty(data) 
    error('Empty data array passed to ge_imagesc().');    
end

           id = 'imagesc';
%       idTag = 'id';
   visibility = 1;
    lineColor = '00000000';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
    lineWidth = 0.25;
      snippet = ' ';
     altitude = 1.0;
      extrude = 0;
 altitudeMode = 'clampToGround';
  msgToScreen = 0;
         cMap = 'jet';
dataFormatStr = '%g';  
       imgURL = 'ge_imagesc.png';
         name = 'ge_imagesc';
   tessellate = 1;
       region = ' ';
  alphaMatrix = double(~isnan(data));
  crispFactor = 5;  
      nColors = 256;
 useSubBlocks = false;
       
%      cLimHigh: see further down
%       cLimLow: see further down


if size(x)~=size(data)
    error(['size of longitude array should be same as size of data array.'])
end
if size(y)~=size(data)
    error(['size of latitude array should be same as size of data array.'])
end

dy = y(2:end,1)-y(1:end-1,1);
dx = x(1,2:end)-x(1,1:end-1);

if dy<0
    y = flipud(y)
    data = flipud(data)
elseif dy==0
    error('Latitude resolution can not be zero.')
else
end

if dx<0
    x = fliplr(x)
    error('Longitude resolution can not be negative.')
elseif dx==0
    error('Longitude resolution can not be zero.')
else
end

% if any(abs(dy(2:end)-dy(1:end-1))>1e-12)||any(abs(dx(2:end)-dx(1:end-1))>1e-12)
%     error(['Function ' 39 mfilename 39 ' does not allow varying grid cell size.'])
% end
% clear dx dy
xResolution = abs(x(2)-x(1));
yResolution = abs(y(2)-y(1));

parsepairs %script that parses Parameter/Value pairs.


if msgToScreen
   disp(['Running ' mfilename '...']) 
end

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end   

if numel(xResolution)~=1
    error(['Function ',39,mfilename,39,': variable ',39,'xResolution',39,' should be scalar.'])
end

if numel(yResolution)~=1
    error(['Function ',39,mfilename,39,': variable ',39,'yResolution',39,' should be scalar.'])
end

if ~((length(x)>1)&&(length(y)>1))
    error(['Input variables ' 39 'x' 39 ' and ' 39 'y' 39 ' should at least contain 2 values.'])
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



halfLonRes = 0.5*xResolution;     
halfLatRes = 0.5*yResolution;
N = max(y)+halfLatRes;
E = max(x)+halfLonRes;
S = min(y)-halfLatRes;
W = min(x)-halfLonRes;

if useSubBlocks
    
    defaultLatBlockSize = 1
    defaultLonBlockSize = 1
    
    latVec = S:defaultLatBlockSize:N
    lonVec = W:defaultLonBlockSize:E

    inputParams = varargin;
    Ix = strmatch('useSubBlocks',inputParams(1:2:end));
    inputParams{Ix*2} = false;
    clear IX
    
    Ix = strmatch('imgURL',inputParams(1:2:end));
    inputParams = inputParams([1:Ix-1,Ix+2:6]);

    [lons,lats] = meshgrid(x,y);
    kmlStr = '';
    
    for iLat = 2:numel(latVec)
        for iLon = 2:numel(lonVec)
            
            IO = (lonVec(iLon-1)<=lons) & (lons < lonVec(iLon)) &...
                 (latVec(iLat-1)<=lats) & (lats < latVec(iLat))
           
            ind = find(IO,1,'first');
            [rs,cs] = ind2sub(size(IO),ind)
            clear ind
            
            ind = find(IO,1,'last')
            [re,ce] = ind2sub(size(IO),ind)
            clear ind
            
            lonBlock = lons(rs:re,cs:ce)
            latBlock = lats(rs:re,cs:ce)
            dataBlock = data(rs:re,cs:ce)

            figure(1)
            imagesc(lonBlock(1,:),latBlock(:,1),dataBlock)
            colorbar
            drawnow
            
            imgURLBlock = [imgURL(1:end-4),'_',num2str(iLon-1),'_',...
                num2str(iLat-1),imgURL(end-3:end)]
            
            kmlStr = [kmlStr,ge_imagesc(lonBlock(1,:),latBlock(:,1),dataBlock,...
                inputParams{:},'imgURL',imgURLBlock,'name',['[r,c] = [',...
                num2str(iLat-1),',',num2str(iLon-1),']'])]
        end
    end
    return

else

    [nRows,nCols] = size(data);


    if crispFactor == 1
        dataXL = data;
        alphaMatrixXL = alphaMatrix;
    else

        dataXL = repmat(NaN,[nRows,nCols]*crispFactor);
        alphaMatrixXL = repmat(NaN,[nRows,nCols]*crispFactor);

        for r=1:nRows
            for c=1:nCols

                sr = (r-1)*crispFactor+1;
                er = r*crispFactor;

                sc = (c-1)*crispFactor+1;
                ec = c*crispFactor;

                dataXL(sr:er,sc:ec) = data(r,c);

                if isnan(data(r,c))
                    alphaMatrixXL(sr:er,sc:ec) =  0;
                else
                    alphaMatrixXL(sr:er,sc:ec) =  alphaMatrix(r,c);
                end
            end
        end

    end

    data3 = mat2gray(dataXL,[cLimLow,cLimHigh]);

    if ischar(cMap)
        X = gray2ind(data3,nColors);
        eval(['data3 = ind2rgb(X,',cMap,'(',num2str(nColors),'));']);
    else
        nColors = size(cMap,1);
        X = gray2ind(data3,nColors);
        data3 = ind2rgb(X,cMap);    
    end

    imwrite(data3,imgURL,'png','alpha',alphaMatrixXL,...
        'CreationTime',datestr(now,21),...
        'Comment','Created by the GoogleEarth Toolbox for MATLAB');


    kmlStr = ge_groundoverlay(N,E,S,W,...
                               'name',name,...
                             'imgURL',imgURL,...
                            'snippet', snippet,...
                          'timeStamp',timeStamp,...
                      'timeSpanStart',timeSpanStart,...
                       'timeSpanStop',timeSpanStop,...
                         'visibility',visibility,...
                           'altitude',altitude,...
                            'extrude',extrude,...
                            'region',region,...
                       'altitudeMode',altitudeMode);


    if msgToScreen
       disp(['Running ' mfilename '...Done']) 
    end
end
