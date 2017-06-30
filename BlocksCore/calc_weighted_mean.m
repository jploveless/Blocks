function [weighted_mean] = calc_weighted_mean(val, sig)
val                         = val(:);
sig                         = sig(:);

if length(find(sig == 0) > 0)
   disp('Exiting calc_weighted_mean to avoid divide by zero.')
else
   weighted_mean            = sum(val./(sig.^2))/sum(1./(sig.^2));
end
