function mem = checkmemory(s, varargin)
%
% CHECKMEMORY calculates the total memory currently used, plus memory that will
%   be used by not yet defined arrays.
%
%   CHECKMEMORY(WHOS) by itself returns the total number of bytes occupied by the 
%   variables currently stored in the workspace of the calling function.  WHOS
%   should be the stucture returned by calling WHOS in the calling function.
%
%   CHECKMEMORY(WHOS, VAR1, VAR2, VAR3, ...) returns the memory used by already 
%   defined variables, as well as an estimate of the memory used after 
%   defining variables of size VAR1, VAR2, VAR3, etc.
%
%   MEM = CHECKMEMORY(...) returns the total memory usage to MEM.
%

% Determine memory usage for variables in the workspace
by = zeros(1, numel(s) + (nargin-1));
by(1:numel(s)) = [s.bytes];

% Determine memory usage for optionally defined variables
if nargin > 1
   new = {varargin{:}};
   by(numel(s)+1:end) = 8*cellfun(@(x) (prod(x)), new);
end

mem = sum(by);