function ge_Trirates(c, v, s, comp, file)
% ge_Trirates  Writes a .kml file for triangle slip rates.
%   ge_Trirates(C, V, S, COMP, FILE) writes colored slip rates to
%   the KML file FILE. C, V, and S are as read from:
%   [C, V, S] = PatchData('Mod.patch')
%   in a result directory, and COMP designates the component of 
%   slip rate written (1 = strike-slip, 2 = dip/tensile slip).
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% Check file extension
[p, f, e] = fileparts(file);
if isempty(e)
   file = [file '.kml'];
   e = '.kml';
end

% Colorbar construction
if comp == 1  % Strike-slip
   trate = s(:, 1);
   maxRate = max(trate(:));
   minRate = min(trate(:));
   sigs = s(:, 4);
   lims = [minRate maxRate];
   cmap = redwhiteblue(256, lims);
   userData = -[maxRate minRate];
   
else  % Dip-slip/tensile
   trate = s(:, 2) - s(:, 3);
   maxRate = max(trate(:));
   minRate = min(trate(:));
   sigs = s(:, 5) + s(:, 6);
   sw = abs(sigs/2) + eps;
   lims = [minRate maxRate];
   cmap = bluewhitered(256, lims);
   userData = [minRate maxRate];
end
strs = [strjust(num2str(trate, '%4.1f'), 'right') ...
        repmat('&#x00B1;', size(v, 1), 1) ...
        strjust(num2str(sigs, '%4.1f'), 'left')];

% Color code the slip rate
diffRate = maxRate - minRate;
trate(trate > maxRate) = maxRate;
trate(trate < minRate) = minRate;
cidx = ceil(255*(trate + abs(minRate))./diffRate + 1);
cvec = floor(255*cmap(cidx,:));


% Write the kml
kml = [];
for i = 1:length(v), 
   kml = strvcat(kml, ge_poly(c(v(i, :), 1), c(v(i, :), 2), 'polyColor', ['FF', reshape(dec2hex(cvec(i, :))', 1, 6)], ...
                              'lineColor', '00000000', 'altitudeMode', 'relativeToGround', 'altitude', 1e3, ...
                              'tessellate', 1, 'name', strs(i, :))); 
end 

% Make a PNG colorbar, write the file, and write the reference to in the KML

% Make a figure with just a colorbar in it
figure('position', [0 0 100 420], 'color', 'k');
axis off
caxis(lims);
colormap(bluewhitered);
cb = colorbar;

set(cb, 'ycolor', [1 1 1], 'linewidth', 2, 'fontsize', 12, 'fontweight', 'bold', 'axislocation', 'in')
set(cb, 'Position', [0.1 0.1095 0.3 0.8155])
if comp == 1
   ylabel(cb, 'TDE strike-slip rate (mm/yr)', 'color', [1 1 1], 'fontsize', 14)
else
   ylabel(cb, 'TDE dip/tensile-slip rate (mm/yr)', 'color', [1 1 1], 'fontsize', 14)
end
export_fig(gcf, [p filesep f '.png'])
close

% Add overlay information to kml
out = ge_screenoverlay([f '.png'], 'sizeLeft', 1-0.015, 'sizeBottom', 0.1, 'posLeft', 1-0.015, 'posBottom', 0.1);
kml = strvcat(kml, out);

% Output kml
ge_output(file, kml');