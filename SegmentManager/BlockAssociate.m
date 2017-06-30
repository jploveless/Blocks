function [gblock new_exterior_block_label] = BlockAssociate(slong1, slat1, slong2, slat2, swest_label, seast_label, glong, glat, gnames)
% BlockAssociate.m
% 
% This script associates the fault labels with a block given in a 
% *.block(.mat) file.  This requires a call to auto_block_select.m 
% with the interior block points passed as station coordinates.  
% The station coordinate that is on the exterior block should be 
% returned with no reported block.  This will be zero (0).  All that 
% is left to do is figure out what the block hasn't been labeled yet
% and use that label for the exterior block.
% 
%  Feb 19 2002:  Drastically revised
%    First we loop over all blocks and see how many point are 
%    enclosed by each.  We have to do this to deal witht the 
%    external block.  They should all have one except for the
%    external.  This way we can indentify the external.
%    Once this is done we just loop over all the other blocks  
%    to get identifiers.  Anything unlabeled at the end is then
%    on the exterior block.
%
% Input arguments:
%    slong1:         segment startpt longitudes
%    slat1:          segment startpt latitudes
%    slong2:         segment startpt longitudes
%    slat2:          segment startpt latitudes
%    swest_label:    west bounding block
%    seast_label:    east bounding block
%    glong:          station longitudes
%    glat:           station latitudes
%    gnames:         station names
%
% Returned variables:
%    gblock:    block labels for each interior point

filestream                     = 0;
% fprintf(filestream, '\n--> Associating labels with blocks\n');
[seast_label swest_label]      = deal(seast_label(:)', swest_label(:)');
n_blocks                       = max([seast_label swest_label]);

% Loop over each block to determine the exterior block
for cnt = 1 : n_blocks
   % Find the indices of the segments that bound the current block
   [bound_idx_1 bound_idx_2]   = deal([], []);
   [bound_idx_1 bound_idx_2]   = deal(find(seast_label==cnt), find(swest_label==cnt));
   bound_idx                   = sort([bound_idx_1 bound_idx_2]);
   
   % Find the interior points
%    ni_block                    = auto_block_select_sphere(slong1(bound_idx), slat1(bound_idx), slong2(bound_idx), slat2(bound_idx), ones(size(slong1(bound_idx))), 2 * ones(size(slong1(bound_idx))), 1, glong, glat, gnames)
   ni_block                    = AutoBlockSelect(slong1(bound_idx), slat1(bound_idx), slong2(bound_idx), slat2(bound_idx), ones(size(slong1(bound_idx))), 2 * ones(size(slong1(bound_idx))), 1, glong, glat, gnames);
   
   % Store the number of interior points
   n_in_block(cnt)             = numel(find(ni_block > 0));
end

% Figure out the last block.  It's the one with the most points in it.  Of course will fail if your exterior block has the most stations on it.
[n_in exterior_block_idx]      = max(n_in_block);

% Announce the block index
% fprintf(filestream, '\nBlock %d identified as the exterior block\n', exterior_block_idx);

% Declare a blank association vector
gblock                         = zeros(n_blocks, 1);

% Loop over all blocks again except the exterior block any station not assigned will be put on the exterior block.
for cnt = 1 : n_blocks
   % Find the indices of the segments that bound the current block
   [bound_idx_1 bound_idx_2]   = deal([], []);
   [bound_idx_1 bound_idx_2]   = deal(find(seast_label==cnt), find(swest_label==cnt));
   bound_idx                   = sort([bound_idx_1, bound_idx_2]);
   
   % Find the interior points
%    ni_block                    = auto_block_select_sphere(slong1(bound_idx), slat1(bound_idx), slong2(bound_idx), slat2(bound_idx), ones(size(slong1(bound_idx))), 2 * ones(size(slong1(bound_idx))), 1, glong, glat, gnames);
   ni_block                    = AutoBlockSelect(slong1(bound_idx), slat1(bound_idx), slong2(bound_idx), slat2(bound_idx), ones(size(slong1(bound_idx))), 2 * ones(size(slong1(bound_idx))), 1, glong, glat, gnames);
   
   % If we're not on the exterior block then put things in the right place
   if (cnt ~= exterior_block_idx)
      crnt_idx                 = find(ni_block == 1);
      gblock(crnt_idx)         = cnt;
   end
end

% Assign an exterior block label not just idx
new_exterior_block_label       = find(gblock == 0);
% fprintf(filestream, '\nBlock %s identified as the exterior block\n', gnames(new_exterior_block_label, :));
new_exterior_block_label       = exterior_block_idx;

% Take care of anything not assigned to a block
gblock(find(gblock == 0))      = exterior_block_idx;

% Make sure there are no duplicates
if (numel(unique(gblock)) < numel(sort(gblock)))
%    fprintf(filestream, 'Interior block points (identifiers) are not unique!\n');
end

% Announce results
for s_cnt = 1 : length(glong)
%    fprintf(filestream, 'Block %s is labeled as block %d\n', gnames(s_cnt, :), gblock(s_cnt));
end
% fprintf(filestream, '<-- Done associating labels with blocks\n');