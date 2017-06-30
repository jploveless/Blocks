function [gblock] = AutoBlockSelect(slong1, slat1, slong2, slat2, swest_label, seast_label, n_blocks, glong, glat, gnames)
% AutoBlockSelect.m
% 
% We want to utilize the MATLAB function 'inpolygon' to determine 
% whether or not a site is withing the boundaries of a given block. 
% The trick to using this function is that the vertices defining 
% the block (polygon) must be ordered in either a clockwise or 
% counter clockwise manner.  The automation of this process from a 
% *.segment file is at the heart or this script.
% 
% This works by finding all fault segments that bound a given block.
% Of these, one is arbitrarily selected as a starting point.  With 
% this first segment we pick one endpoint as the start of an 
% ordered vertex vector.  We then search through the remaining 
% segments for a segment with a common point.  Once this segment is 
% identified the point not in common with the previous segment is 
% added to the ordered index vector.  This process is repeated n 
% times, where n is the number of segments that bound a given block.
% 
% Input arguments:
%    slong1:         segment startpt longitudes 
%    slat1:          segment startpt latitudes 
%    slong2:         segment startpt longitudes 
%    slat2:          segment startpt latitudes 
%    swest_label:    west bounding block 
%    seast_label:    east bounding block 
%    n_blocks:       total number of blocks 
%    glong:          station longitudes
%    glat:           station latitudes
%    gnames:         station names
%
% Returned variables:
%    gblock:    block labels for each station

filestream                     = 1;
gblock                         = zeros(size(glong));

% Rename variable for compatability.  Transposes are for convenience
seg_srtpt_x                    = slong1';
seg_srtpt_y                    = slat1';
seg_endpt_x                    = slong2';
seg_endpt_y                    = slat2';
seg_wb                         = swest_label;
seg_eb                         = seast_label;

% Loop over each block, find ordered vertices and then indetify that stations inside the polygon
for b_cnt = 1 : n_blocks
   % Get the indices of all segments that bound the current block
   bound_idx_1                 = find(seg_eb == b_cnt);
   bound_idx_2                 = find(seg_wb == b_cnt);
   bound_idx                   = sort([bound_idx_1, bound_idx_2]);
   
   % Grab first segment
   crnt_idx                    = bound_idx(1);
   crntpt_x                    = seg_srtpt_x(crnt_idx);
   crntpt_y                    = seg_srtpt_y(crnt_idx);
   
   % Clear the temporary polygon vectors
   temp_crnt_x                 = [];
   temp_crnt_y                 = [];
   
   for g_cnt = 1 : numel(bound_idx)
      % Store current vertices for calculating area later
      temp_crnt_x(g_cnt)      = crntpt_x;
      temp_crnt_y(g_cnt)      = crntpt_y;
      
      % If we have all vertices find the stations that lie within the block
      if (g_cnt == numel(bound_idx))
         current_block_sites_vec       = inpolygon(glong, glat, temp_crnt_x, temp_crnt_y);
         current_block_sites           = find(current_block_sites_vec(:) == 1);
         gblock(current_block_sites)   = b_cnt;
	 
         % Check to see if there are any sites on block boundaries
         onedge_sites                  = find(current_block_sites_vec == 0.5);
         if (length(onedge_sites) > 0)
            for br_cnt = 1 : length(onedge_sites)
               fprintf(filestream, 'Station %s on a block boundary, gonna crash', gnames(onedge_sites(br_cnt), :));
            end
         end

      end
           
      % Match endpoint to new start point
      srtpt_match_idx_x       = find(seg_srtpt_x(bound_idx) == crntpt_x);
      endpt_match_idx_x       = find(seg_endpt_x(bound_idx) == crntpt_x);
      srtpt_match_idx_y       = find(seg_srtpt_y(bound_idx) == crntpt_y);
      endpt_match_idx_y       = find(seg_endpt_y(bound_idx) == crntpt_y);
      new_match_idx_temp      = intersect([srtpt_match_idx_x endpt_match_idx_x], [srtpt_match_idx_y endpt_match_idx_y]);
      new_match_idx           = new_match_idx_temp(find(bound_idx(new_match_idx_temp)~=crnt_idx));
      
      if (crntpt_x == seg_srtpt_x(bound_idx(new_match_idx)) & crntpt_y == seg_srtpt_y(bound_idx(new_match_idx)))
         crntpt_x             = seg_endpt_x(bound_idx(new_match_idx));
         crntpt_y             = seg_endpt_y(bound_idx(new_match_idx));
         crnt_idx             = bound_idx(new_match_idx);
      else
         crntpt_x             = seg_srtpt_x(bound_idx(new_match_idx));
         crntpt_y             = seg_srtpt_y(bound_idx(new_match_idx));
         crnt_idx             = bound_idx(new_match_idx);
      end
   end
%    [temp_crnt_x temp_crnt_y] = deal([], []);
end
