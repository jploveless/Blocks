function [slipCon, Index, Data, Sigma] = SlipConstraints(Segment, Block, Index, Data, Sigma);

fprintf('   Applying a priori slip constraints...')
% Build a priori slip rate constraints
for i = 1:numel(Segment.lon1)
   if Segment.ssRateTog(i)==1
      fprintf(1, '\n      Strike-slip constraint   : rate=%6.2f, sigma=%6.2f %s', Segment.ssRate(i), Segment.ssRateSig(i), Segment.name(i,:));
   end
   if Segment.dsRateTog(i)==1
      fprintf(1, '\n      Dip-slip constraint      : rate=%6.2f, sigma=%6.2f %s', Segment.dsRate(i), Segment.dsRateSig(i), Segment.name(i,:));
   end
   if Segment.tsRateTog(i)==1
      fprintf(1, '\n      Tensile-slip constraint  : rate=%6.2f, sigma=%6.2f %s', Segment.tsRate(i), Segment.tsRateSig(i), Segment.name(i,:));
   end
end
slipCon                                          = GetSlipPartials(Segment, Block);
slipToggle                                       = stack3([Segment.ssRateTog(:) Segment.dsRateTog(:) Segment.tsRateTog(:)]);
Index.slipCon                                    = find(slipToggle);
Data.nSlipCon                                    = length(Index.slipCon);
Data.slipCon                                     = stack3([Segment.ssRate(:) Segment.dsRate(:) Segment.tsRate(:)]);
Data.slipCon                                     = Data.slipCon(Index.slipCon);
Sigma.slipCon                                    = stack3([Segment.ssRateSig(:) Segment.dsRateSig(:) Segment.tsRateSig(:)]);
Sigma.slipCon                                    = Sigma.slipCon(Index.slipCon);
slipCon                                          = slipCon(Index.slipCon, :);
fprintf('done.')