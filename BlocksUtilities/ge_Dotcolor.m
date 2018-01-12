function ge_Dotcolor(lon, lat, val, filename, varargin)
% ge_Dotcolor  Writes a .kml file of colored circles.
%   ge_Dotcolor(LON, LAT, MAG, FILENAME) write a .kml file containing
%   colored circles at locations specified by vectors LON, LAT, corresponding
%   to values in vector MAG. The .kml file is written to FILENAME.
%
%   ge_Dotcolor(LON, LAT, MAG, FILENAME, CLABEL) also creates a color scale
%   to be displayed in Google Earth along with the colored dots. 
%
%   ge_Dotcolor(LON, LAT, MAG, FILENAME, RAD) makes the radius of the circles
%   equal to RAD (default is 1e4). 
%
%   ge_Dotcolor(LON, LAT, MAG, FILENAME, CLIM) uses the 2-element vector CLIM
%   to specify the limits on the color scale. By default, the full range of 
%   MAG is used. 
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% Check file extension
[p, f, e] = fileparts(filename);
if isempty(e)
   filename = [filename '.kml'];
   e = '.kml';
end

% Check for optional arguments
if nargin > 4
   for i = 1:length(varargin)
      if ischar(varargin{i})
         clabel = varargin{i};
      elseif numel(varargin{i}) == 2
         cax = varargin{i};
      elseif numel(varargin{i}) == 1
         rad = varargin{i};
      end
   end
end
% Set default scale if none is prescribed
if ~exist('rad', 'var')
   rad = 10000;
end

% Make colormap
cmap = jet(256);
nd = size(cmap, 1);

% Place values on color scale
if ~exist('cax', 'var')
   cax = [min(val) max(val)];
end
val(val < cax(1)) = cax(1);
val(val > cax(2)) = cax(2);
ival = ceil((nd-1)*((val - cax(1))./(diff(cax)))+1);
cvec = floor(255*cmap(ival, :));

% Make kml
fid = fopen(filename, 'wt');
name = filename;
header = ['<?xml version="1.0" encoding="UTF-8"?>',10,...
         '<kml xmlns="http://earth.google.com/kml/2.1">',10,...
         '<Document>',10,...
         '<name>',10,name,10,'</name>',10];

fprintf(fid,'%s',header);

for i = 1:length(lon)
   kml = ge_circle(wrapTo180(lon(i)), lat(i), rad, 'divisions', 5,...
                   'polyColor', ['FF', reshape(dec2hex(cvec(i, :))', 1, 6)], 'lineColor', '00000000', ...
                   'altitudeMode', 'relativeToGround', 'altitude', 100, 'name', sprintf('%g', val(i)));
   fprintf(fid, '%s', kml);                
end

% Make a PNG colorbar, write the file, and write the reference to in the KML
if exist('clabel', 'var')

   % Make a figure with just a colorbar in it
   figure('position', [0 0 100 420], 'color', 'k');
   axis off
   caxis(cax);
   colormap(cmap);
   cb = colorbar;
   
   set(cb, 'ycolor', [1 1 1], 'linewidth', 2, 'fontsize', 12, 'fontweight', 'bold', 'axislocation', 'in')
   set(cb, 'Position', [0.1 0.1095 0.3 0.8155])
   ylabel(cb, clabel, 'color', [1 1 1], 'fontsize', 14)
   export_fig(gcf, [p filesep f '.png'])
   close
   
   % Add overlay information to kml
   out = ge_screenoverlay([f '.png'], 'sizeLeft', 0.015, 'sizeBottom', 0.1, 'posLeft', 0.015, 'posBottom', 0.1);
   fprintf(fid, '%s', out);
end

footer = [10,'</Document>',10,'</kml>'];
fprintf(fid, '%s', footer);
fclose(fid);