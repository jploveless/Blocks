function meshidx = idmeshes(p, elidx)
% IDMESHES  Identifies which mesh an element belongs to.
%   meshidx = IDMESHES(p, elidx) identifies which of the meshes
%   within structure p to which each element in n-by-1 vector elidx
%   belong.
%
%   The output n-by-1 vector meshidx contains values from 1:length(p.nEl).
%

cnel = cumsum(p.nEl); % Cumulative number of elements
cnel = repmat(cnel(:)', length(elidx(:)), 1); % Replicate to make a matrix
elidx = repmat(elidx(:), 1, size(cnel, 2)); % Replicate elidx to make a matrix
meshidx = 1 + sum(elidx > cnel, 2); % Sum of logical array where elidx > cnel gives meshidx
meshidx = double(elidx(:, 1)~=0).*meshidx; % Return zero for zero input