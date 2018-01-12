function ge_Velcolor(s, filename, cmap, varargin)
% ge_Vecsuite  Writes a .kml file for a station structure.
%   ge_Vecsuite(S, OUT, DAE) writes .kml files for each of the 
%   .sta files within the results directory IN to files in directory
%   OUT. It is necessary to specify where the Collada source files
%   are located, in directory DAE. 
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
kml = [];
for i = 1:length(s.lon)
   kml = strvcat(kml, ge_quiver3(wrapTo180(s.lon(i)), s.lat(i), 100, sca*s.eastVel(i), sca*s.northVel(i), sca*s.upVel(i), 'modelLinkStr', sprintf('colvelarrows%sarrow%g.dae', filesep, ispeed(i)), 'altitudeMode', 'relativeToGround', 'name', sprintf('%s: (%g, %g)', s.name(i, :), s.eastVel(i), s.northVel(i))));
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
kml = strvcat(kml, out);

ge_output(filename, kml');
