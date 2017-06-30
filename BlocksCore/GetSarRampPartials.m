function [ramp, Index] = GetSarRampPartials(Sar, Command, Index)
% Wrapper function for calculating SAR ramp partials

ramp               = zeros(numel(Sar.lon), 0);

switch Command.sarRamp
   case 1 % Linear ramp
      ramp         = GetSarLinearRampPartials(Sar);
   case 2 % Quadratic ramp
      ramp         = GetSarQuadRampPartials(Sar);
   case 3 % Cubic ramp
      ramp         = GetSarCubicRampPartials(Sar);
end      
Index.szramp       = size(ramp);