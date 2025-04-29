function varargout = segcount(direc, direc_levels)
% segcount   Creates a colored line plot of segment frequency
%    segcount(direc) looks for all Mod.segment files in result directories
%    within direc, counts the occurrence of each segment (surface 
%    coordinates only), and generates a colored line plot indicating
%    occurrences.
%
%    segcount(direc, direc_levels) allows a deeper level of directory 
%    crawling through specification of the integer direc_levels. To 
%    look for result directories in direc, set direc_levels = 0 (default).
%    To also look in subdirectories of direc, set direc_levels = 1;
% 
%    [seg_coords, seg_count] = segcount(...) returns the unique segment
%    coordinates to seg_coords (as [lon1, lon2, lat1, lat2]) and the 
%    number of occurrences of each set of coordinates to seg_count. 
%    

% Check number of directory levels
if ~exist('direc_levels', 'var')
	direc_levels = 0;
end

% Define search path
search_path = [direc, filesep, repmat('*/', 1, direc_levels), '000*/Mod.segment'];
segfiles = dir(search_path);

% Sequentially read .segment files
i = 1;
filename = [segfiles(i).folder, filesep, segfiles(i).name];
seg = ReadSegmentTri(filename);
% Order endpoints
seg = OrderEndpointsSphere(seg);
% Construct coordinate array
seg_coords = [seg.lon1, seg.lon2, seg.lat1, seg.lat2];
% Initialize the occurrence count
seg_count = ones(size(seg_coords, 1), 1);

for i = 2:length(segfiles)
   filename = [segfiles(i).folder, filesep, segfiles(i).name];
   seg = ReadSegmentTri(filename);
   seg = OrderEndpointsSphere(seg);
   % New coordinate array
   new_coords = [seg.lon1, seg.lon2, seg.lat1, seg.lat2];
   old_in_new = ismember(seg_coords, new_coords, 'rows');
   new_in_old = ismember(new_coords, seg_coords, 'rows');
%    if i == 5, keyboard; end
   seg_count(old_in_new) = seg_count(old_in_new) + 1;
   if sum(~old_in_new) > 0
      seg_coords = [seg_coords; new_coords(~new_in_old, :)];
      seg_count = [seg_count; ones(sum(~new_in_old), 1)];
   end
end

% Make plot of colored lines
cmap = colormap("parula");
% Generate range of color indices that map to cmap
yy=linspace(1,max(seg_count),size(cmap,1));  
% Interpolated color value
cm = spline(yy,cmap',seg_count);                 
cm(cm>1)=1;                               
cm(cm<0)=0;

figure; hold on
coast = load('WorldHiVectors.mat');
plot(coast.lon, coast.lat, 'color', 0.5*[1 1 1])
for i = 1:length(seg_count)
    line(seg_coords(i, 1:2), seg_coords(i, 3:4), 'color', cm(:, i), 'linewidth', 2);
end
caxis([1 max(seg_count)]);
colorbar
axis equal

% Prepare outputs
if nargout == 1
    varargout{1} = seg_coords;
elseif nargout == 2
    varargout{1} = seg_coords;
    varargout{2} = seg_count;
end


