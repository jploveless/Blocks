function patchblock(Block, c)
% PATCHBLOCK  Plots blocks as colored patches.
%   PATCHBLOCK(BLOCK, C) colors the blocks defined by the structure BLOCK, 
%   which must include the fields "orderLon" and "orderLat", by the entries
%   in vector C.
%

figure; hold on

[~, includ] = setdiff(1:length(Block.interiorLon), Block.exteriorBlockLabel);

for i = includ
   patch(Block.orderLon{i}, Block.orderLat{i}, c(i));
end