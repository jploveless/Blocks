function plotsarfields(direc, save)
% PLOTSARFIELDS  Plots SAR velocity fields from a block model run.
%   PLOTSARFIELDS(DIREC) plots the velocity fields contained in DIREC/Sar.pred.
%
%   PLOTSARFIELDS(DIREC, SAVE), where SAVE = 1, saves each figure to a .fig file
%   within DIREC.
%

% Load the SAR fields
b = load([direc filesep 'Sar.pred']);
% Load the model segment file, for plotting
Segment = ReadSegmentTri([direc filesep 'Mod.segment']);

% Set the figure titles
titles = {'Observed', 'Modeled', 'Residual', 'Elastic', 'Block', 'Ramp', 'Shift (Block + Ramp)', 'Triangle', 'Strain'};

% For each field (start at 3 because coordinates are in the first 2 columns
for i = 3:11
   figure
   % Establish the color scale; we need to do this before plotting because we're using plot3k
   ca = mean(b(:, i)) + [-2*std(b(:, i)) 2*std(b(:, i))]; 
   ca = [floor(ca(1)) ceil(ca(2))];
   % Special case for residual field: use bluewhitered instead of jet as the colormap
   if i == 5
      caxis(ca); colormap(bluewhitered)
   end
   % Plot using plot3k; the "ca" specification indicates the color range
   plot3k([b(:, 1:2) zeros(size(b, 1), 1)], b(:, i), ca); view(2);
   caxis(ca); colorbar
   aa = axis;
   hold on
   % Plot the segments for geographic reference
   line([Segment.lon1'; Segment.lon2'], [Segment.lat1'; Segment.lat2'], 'color', 0.5*[1 1 1]);
   axis equal; axis(aa);
   title(titles{i-2});
   % Save files if requested
   if exist('save', 'var')
      if save == 1
         fname = [direc filesep titles{i-2} '.fig'];
         saveas(gcf, fname, 'fig')
      end 
   end
end

