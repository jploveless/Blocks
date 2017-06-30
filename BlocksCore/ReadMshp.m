function [p, pp] = ReadMshp(file, pp)
% readmshp  Reads a mesh property file. 
%   [P, PP] = ReadMshp(FILE) reads mesh names and properties from the 
%   specified FILE. The .mshp file contains groups of 3 lines and
%   specifies the file name for a mesh along with its properties:
%
%   1. Full path to mesh file (.msh or .mat), readable using ReadPatches
%   2. Smoothing coefficient (double)
%   3. A priori edge constraints as a triplet, with values corresponding
%      to conditions on the [updip downdip lateral] edges of the mesh. 
%      Numerical values can be 0 (no constraint), 1 (creeping), or 2 
%      (fully coupled).
%   4. Full path to associated a priori slip file (.mat) (blank if none)
%   
%   File contents are returned to structure P, containing the actual 
%   triangular meshes, and PP, containing properties of the meshes. 
%
%   [P, COMMAND] = ReadMshp(FILE, COMMAND) updates an input COMMAND structure
%   with mesh properties. 

% Read file contents
fid = fopen(file, 'r');
c = textscan(fid, '%s\n%f\n%f%f%f\n%s\n');
pp.patchFileNames = char(c{1}(1, :));
for i = 2:size(c{1}, 1)
   pp.patchFileNames = [pp.patchFileNames, ' ', char(c{1}(i, :))];
end

% Read patches
p = ReadPatches(pp.patchFileNames);

% Define mesh properties
if exist('command', 'var')
   pp = command;
end

pp.triSmooth = c{2}(:)';
pp.triEdge = reshape([c{3} c{4} c{5}]', 1, 3*size(c{3}, 1));
% If any a priori slip files are specified
if size(char(c{6}), 2) ~= 0
   % Overwrite whatever was specified in the .command file
   pp.slipFileNames = char(c{6});
   % Else keep what was specified in the .command file (including blank)
end

%if isfield(pp, 'changed')
%   if isempty(findstr('triSmooth', pp.changed))
%      pp.triSmooth = c{2}(:)';
%   end
%
%   if isempty(findstr('triEdge', pp.changed))
%      pp.triEdge = reshape([c{3} c{4} c{5}]', 1, 3*size(c{3}, 1));
%   end
%
%   if isempty(findstr('slipFileNames', pp.changed))
%      pp.slipFileNames = char(c{6});
%   end
%end
