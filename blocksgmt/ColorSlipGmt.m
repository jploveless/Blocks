function ColorSlipGmt(s, comp, file, varargin)
%
%  Write colored slip rates to a file to be plotted in GMT using:
%  psxy -M
%

if nargin > 3
   for i = 1:length(varargin)
      if numel(varargin{i}) == 4
         lims = varargin{i};
         sin = union(find(inpolygon(s.lon1, s.lat1, [min(lims(1:2)) max(lims(1:2)) max(lims(1:2)) min(lims(1:2))], [min(lims(3:4)) min(lims(3:4)) max(lims(3:4)) max(lims(3:4))])), ...
                     find(inpolygon(s.lon2, s.lat2, [min(lims(1:2)) max(lims(1:2)) max(lims(1:2)) min(lims(1:2))], [min(lims(3:4)) min(lims(3:4)) max(lims(3:4)) max(lims(3:4))])));
         [s.lon1, s.lon2, s.lat1, s.lat2, s.ssRate, s.dsRate, s.tsRate] = deal(s.lon1(sin), s.lon2(sin), s.lat1(sin), s.lat2(sin), s.ssRate(sin), s.dsRate(sin), s.tsRate(sin));    
      elseif numel(varargin{i}) == 2
         clims = varargin{i};
      end
   end
end

[path, name, ext] = fileparts(file);

% Make sure that the segments are in order


fid = fopen(file, 'w');
if comp == 1
   if ~exist('clims', 'var')
      clims = [-1 1]*max(abs([min(s.ssRate) max(s.ssRate)]));
   end
   s.ssRate(s.ssRate > max(clims)) = max(clims);
   s.ssRate(s.ssRate < min(clims)) = min(clims);
   cmap = redwhiteblue(256, clims);
   cidx = ceil(255*(s.ssRate + max(clims))./diff(clims) + 1);
   pnc2cpt(cmap, clims, [path filesep name '.cpt'])
   cvec = 255*cmap(cidx,:);
   for i = 1:numel(s.lon1)
      fprintf(fid, '> -W5p/%d/%d/%d\n%d %d\n%d %d\n', round(cvec(i, 1)), round(cvec(i, 2)), round(cvec(i, 3)), s.lon1(i), s.lat1(i), s.lon2(i), s.lat2(i));
   end
%   out = [s.ssRate, s.lon1, s.lat1, s.lon2, s.lat2];
%   fprintf(fid, '>-Z%g\n %d %d\n%d %d\n', out');
else
   nslips = s.dsRate - s.tsRate;
   if ~exist('clims', 'var')
      clims = [-1 1]*max(abs([max(nslips) min(nslips)]));
   end
   diffRate = diff(clims);
   nslips(nslips > max(clims)) = max(clims);
   nslips(nslips < min(clims)) = min(clims);
   cmap = bluewhitered(256, clims);
   cidx = ceil(255*(nslips + max(clims))./diffRate + 1);
   pnc2cpt(cmap, clims, [path filesep name '.cpt'])
   cvec = 255*cmap(cidx,:);
   for i = 1:numel(s.lon1)
      fprintf(fid, '> -W5p/%d/%d/%d\n%d %d\n%d %d\n', round(cvec(i, 1)), round(cvec(i, 2)), round(cvec(i, 3)), s.lon1(i), s.lat1(i), s.lon2(i), s.lat2(i));
   end
%   out = [nslips, s.lon1, s.lat1, s.lon2, s.lat2];
%   fprintf(fid, '>-Z%g\n %d %d\n%d %d\n', out');
end

fclose(fid);
