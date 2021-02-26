function blockspath(varargin)
% BLOCKSPATH  Adds essential Blocks directories to the MATLAB path.
%   BLOCKSPATH without input arguments, when run from the $Blocks 
%   parent directory (e.g., ~/MATLAB/Blocks/) adds essential Blocks
%   directories to the MATLAB path.
%
%   BLOCKSPATH(dir) adds the essential Blocks directories to the path,
%   assuming they exist within the specified parent directory dir.
%

if nargin == 0
   broot = pwd;
else
   broot = varargin{1};
end

if ~exist([broot filesep 'BlocksCore'], 'dir')
   error('Blocks directories not found. Change to $Blocks directory or specify its full path.')
end

broot = [broot filesep];

bp = strcat(broot, fliplr({'tridisl', 'BlocksCore', 'BlocksUtilities', 'ResultManager', 'SegmentManager'}));
for i = 1:numel(bp)
   addpath(bp{i})
end

savepath