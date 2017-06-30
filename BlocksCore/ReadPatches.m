function Patches = ReadPatches(filenames, ignoreSpaces)
% ReadPatches.m
%
% This function reads in any triangulated patch files specified by
% Segment.other1 and returns their coordinates to Patches.
%
% Arguments:
%   filenames    : string containing all filenames of patch files
%   ignoreSpaces : flag (true/false) indicating whether to ignore spaces in filename (default: false)
%
% Returned variables:
%   Patches      : a structure containing:
%          .c    : all vertex coordinates (n x 3)
%          .v    : element vertex indices (m x 3)
%          .nEl  : number of elements in each patch file
%          .nc   : number of coordinates in each patch file

Patches.c = [];
Patches.v = [];
Patches.nEl = [];
Patches.nc = [];

if numel(filenames) > 0
   if size(filenames, 1) == 1 && (nargin<2 || ~ignoreSpaces)
      spaces = [0 strfind(filenames, ' ') length(filenames)+1];
      nfiles = length(spaces) - 1;
   else
      nfiles = size(filenames, 1);
   end
   
   for i = 1:nfiles
      if exist('spaces', 'var')
         filename = filenames(spaces(i)+1:spaces(i+1)-1);
      else
         filename = strtrim(filenames(i, :));
      end

      ext = filename(end-3:end);
      if strcmpi(ext, '.msh')
         [c, v] = msh2coords(filename);
      elseif strcmpi(ext, '.mat')
         load(filename, 'c', 'v')
      end
      crossd = cross([c(v(:,2),:) - c(v(:,1),:)], [c(v(:,3),:) - c(v(:,1),:)]);
      negp = find(crossd(:, 3) < 0);
      [v(negp, 2), v(negp, 3)] = swap(v(negp, 2), v(negp, 3));
      Patches.v = [Patches.v; v + sum(size(Patches.c, 1))];
      % Consistent with precision of station, segment files. We need a consistent precision when checking for existing kernels:
      c = [str2num(num2str(c(:, 1), '%3.3f')), ...
           str2num(num2str(c(:, 2), '%3.3f')), ...
           str2num(num2str(c(:, 3), '%3.3f'))];
      Patches.c = [Patches.c; c];
      Patches.nEl = [Patches.nEl; size(v, 1)];
      Patches.nc = [Patches.nc; size(c, 1)];
   end
end
