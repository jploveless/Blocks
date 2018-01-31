function ge_Sliprates(s, comp, file)
% ge_Sliprates  Writes a .kml file for segment slip rates.
%   ge_Sliprates(SEGMENT, COMP, FILE) writes colored slip rates to
%   the KML file FILE. COMP designates the component of slip rate
%   written (1 = strike-slip, 2 = dip/tensile slip).
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

if ~isstruct(s)
   s = ReadSegmentTri(s);
end

% Check file extension
[p, f, e] = fileparts(file);
if isempty(e)
   file = [file '.kml'];
   e = '.kml';
end
% Check path 
if isempty(p)
   file = ['.' filesep file];
   p = '.';
end

% Colorbar construction
if comp == 1  % Strike-slip
   trate = s.ssRate;
   maxRate = max(trate(:));
   minRate = min(trate(:));
   sigs = s.ssRateSig;
   lims = [minRate maxRate];
   cmap = redwhiteblue(256, lims);
   userData = -[maxRate minRate];
   
else  % Dip-slip/tensile
   trate = s.dsRate - s.tsRate;
   maxRate = max(trate(:));
   minRate = min(trate(:));
   sigs = s.dsRateSig + s.tsRateSig;
   sw = abs(sigs/2) + eps;
   lims = [minRate maxRate];
   cmap = bluewhitered(256, lims);
   userData = [minRate maxRate];
end
strs = [strjust(num2str(trate, '%4.1f'), 'right') ...
        repmat('&#x00B1;', numel(s.lon1), 1) ...
        strjust(num2str(sigs, '%4.1f'), 'left')];

% Color code the slip rate
diffRate = maxRate - minRate;
trate(trate > maxRate) = maxRate;
trate(trate < minRate) = minRate;
cidx = ceil(255*(trate + abs(minRate))./diffRate + 1);
cvec = floor(255*cmap(cidx,:));


% Write the kml
kml = [];
for i = 1:length(s.lon1), 
   kml = strvcat(kml, ge_plot([s.lon1(i), s.lon2(i)], [s.lat1(i), s.lat2(i)], ...
                              'lineWidth', 3, 'lineColor', ['FF', reshape(dec2hex(cvec(i, :))', 1, 6)], ...
                              'name', strs(i, :)                              )); 
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
   ylabel(cb, 'Strike-slip rate (mm/yr)', 'color', [1 1 1], 'fontsize', 14)
else
   ylabel(cb, 'Dip/tensile-slip rate (mm/yr)', 'color', [1 1 1], 'fontsize', 14)
end
export_fig(gcf, [p filesep f '.png'])
close

% Add overlay information to kml
out = ge_screenoverlay([f '.png'], 'sizeLeft', 0.015, 'sizeBottom', 0.1, 'posLeft', 0.015, 'posBottom', 0.1);
kml = strvcat(kml, out);

% Output kml
ge_output(file, kml');