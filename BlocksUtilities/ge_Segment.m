function ge_Segment(s, comp, file)
% ge_Segment  Writes a .kml file for a segment structure.
%   ge_Station(SEGMENT, FILE) writes the coordinate information
%   in fields SEGMENT.lon1, SEGMENT.lat1, SEGMENT.lon1, SEGMENT.lat1
%   to FILE, a KML file viewable using Google Earth.
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

if ~isstruct(s)
   s = ReadSegmentTri(s);
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
   sw = abs(consigs/2) + eps;
   lims = [minRate maxRate];
   cmap = bluewhitered(256, lims);
   userData = [minRate maxRate];
end
strs = [strjust(num2str(trate, '%4.1f'), 'right') ...
        repmat('+/-', numel(s.lon1), 1) ...
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

ge_output(file, kml');