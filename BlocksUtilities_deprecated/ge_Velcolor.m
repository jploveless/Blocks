function ge_Velcolor(s, filename, cmap, varargin)
% ge_Velcolor  Writes a .kml file with colored, scaled vectors
%   ge_Velcolor(S, OUT, CMAP) writes .kml file with colored, scaled 
%   vectors based on the station structure S to file OUT. CMAP can 
%   be the name of any valid colormap, or an n-by-3 colormap array.
%
%   ge_Velcolor(S, OUT, CMAP, CAX) uses the 2-element vector CAX
%   to specify the limits on the color scale. By default, the full range of 
%   velocities is used. 
%
%   ge_Velcolor(S, OUT, CMAP, SCALE) modifies the SCALE of the vectors. The
%   default value is 100. 
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% Detect this function's directory
a = which('ge_Velcolor');
pa = fileparts(a);

% Check file extension
[p, f, e] = fileparts(filename);
if isempty(e)
   filename = [filename '.kml'];
   e = '.kml';
end
% Check path 
if isempty(p)
   filename = ['.' filesep filename];
   p = '.';
end

% Check for optional arguments
if nargin > 3
   for i = 1:length(varargin)
      if numel(varargin{i}) == 1
         sca = varargin{i};
      elseif numel(varargin{i}) == 2
         cax = varargin{i};
      end
   end
end
if ~exist('sca', 'var')
   sca = 100;
end

% Write color arrow templates
if ischar(cmap)
   cmap = colormap([cmap '(200)']);
end
cmaparrows([pa filesep 'velarrows/arrow.dae'], cmap, [p filesep 'colvelarrows/']);
nd = size(cmap, 1);

% Calculate speeds and place on scale
speed = sqrt(s.eastVel.^2 + s.northVel.^2);
if ~exist('cax', 'var')
   cax = [min(speed) max(speed)];
end
speed(speed < cax(1)) = cax(1);
speed(speed > cax(2)) = cax(2);
ispeed = ceil((nd-1)*((speed - cax(1))./(diff(cax)))+1);

% Make kml
fid = fopen(filename, 'wt');
name = filename;
header = ['<?xml version="1.0" encoding="UTF-8"?>',10,...
         '<kml xmlns="http://earth.google.com/kml/2.1">',10,...
         '<Document>',10,...
         '<name>',10,name,10,'</name>',10];

fprintf(fid,'%s',header);

for i = 1:length(s.lon)
   kml = ge_quiver3(wrapTo180(s.lon(i)), s.lat(i), 100, sca*s.eastVel(i), sca*s.northVel(i), sca*s.upVel(i), 'modelLinkStr', sprintf('colvelarrows%sarrow%g.dae', filesep, ispeed(i)), 'altitudeMode', 'relativeToGround', 'name', sprintf('%s: (%g, %g)', s.name(i, :), s.eastVel(i), s.northVel(i)));
   fprintf(fid, '%s', kml);
end

% Make a PNG colorbar, write the file, and write the reference to in the KML

% Make a figure with just a colorbar in it
figure('position', [0 0 100 420], 'color', 'k');
axis off
caxis(cax);
colormap(cmap);
cb = colorbar;

set(cb, 'ycolor', [1 1 1], 'linewidth', 2, 'fontsize', 12, 'fontweight', 'bold', 'axislocation', 'in')
set(cb, 'Position', [0.1 0.1095 0.3 0.8155])
ylabel(cb, 'GPS Velocity (mm/yr)', 'color', [1 1 1], 'fontsize', 14)
export_fig(gcf, [p filesep f '.png'])
close

% Add overlay information to kml
out = ge_screenoverlay([f '.png'], 'sizeLeft', 0.015, 'sizeBottom', 0.1, 'posLeft', 0.015, 'posBottom', 0.1);
fprintf(fid, '%s', out);

% KML footer
footer = [10,'</Document>',10,'</kml>'];
fprintf(fid, '%s', footer);
fclose(fid);