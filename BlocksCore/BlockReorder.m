function [Block] = BlockReorder(reorder_vec, Block)
% BlockReorder.m 
%
% This function reorders the blocks.  So that the proper block information from 
% block_associate.m is associated with the current internal labeling of that block.
%
% Arguments:
%   reorder_vec
%   Block
%
% Returned variables:
%   Block
%
% Modif 08/02/04 Phil Vernant to correct the wrong block name - block number association

filestream               = 0;
% fprintf(filestream, '\n--> Reordering block indices\n');

% % Swap the indices
% Block.eulerLat           = Block.eulerLat(reorder_vec);
% Block.eulerLatSig        = Block.eulerLatSig(reorder_vec);
% Block.eulerLon           = Block.eulerLon(reorder_vec);
% Block.eulerLonSig        = Block.eulerLonSig(reorder_vec);
% Block.aprioriTog         = Block.aprioriTog(reorder_vec);
% Block.interiorLat        = Block.interiorLat(reorder_vec);
% Block.interiorLon        = Block.interiorLon(reorder_vec);
% Block.other1             = Block.other1(reorder_vec);
% Block.other2             = Block.other2(reorder_vec);
% Block.other3             = Block.other3(reorder_vec);
% Block.other4             = Block.other4(reorder_vec);
% Block.other5             = Block.other5(reorder_vec);
% Block.other6             = Block.other6(reorder_vec);
% Block.rotationInfo       = Block.rotationInfo(reorder_vec);
% Block.rotationRate       = Block.rotationRate(reorder_vec);
% Block.rotationRateSig    = Block.rotationRateSig(reorder_vec);
% 
% [n_names n_chars]        = size(Block.name);
% for cnt = 1 : n_chars
%    Block.name(:, cnt)    = Block.name(reorder_vec, cnt);
% end

% Try the old style swapping.  Does this fix the structure issue?

Block.eulerLat           = swap_index(Block.eulerLat, reorder_vec);
Block.eulerLatSig        = swap_index(Block.eulerLatSig, reorder_vec);
Block.eulerLon           = swap_index(Block.eulerLon, reorder_vec);
Block.eulerLonSig        = swap_index(Block.eulerLonSig, reorder_vec);
Block.aprioriTog         = swap_index(Block.aprioriTog, reorder_vec);
Block.interiorLat        = swap_index(Block.interiorLat, reorder_vec);
Block.interiorLon        = swap_index(Block.interiorLon, reorder_vec);
Block.other1             = swap_index(Block.other1, reorder_vec);
Block.other2             = swap_index(Block.other2, reorder_vec);
Block.other3             = swap_index(Block.other3, reorder_vec);
Block.other4             = swap_index(Block.other4, reorder_vec);
Block.other5             = swap_index(Block.other5, reorder_vec);
Block.other6             = swap_index(Block.other6, reorder_vec);
Block.rotationInfo       = swap_index(Block.rotationInfo, reorder_vec);
Block.rotationRate       = swap_index(Block.rotationRate, reorder_vec);
Block.rotationRateSig    = swap_index(Block.rotationRateSig, reorder_vec);

[n_names, n_chars]       = size(Block.name);
for cnt = 1 : n_chars
   Block.name(:, cnt)         = swap_index(Block.name(:, cnt), reorder_vec);
end


% fprintf(filestream, '<--  Done reodering block indices\n');