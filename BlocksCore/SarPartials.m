function [psta, psar] = SarPartials(p, sar)
% SarPartials   Separates GPS and SAR partials and projects SAR partials.
%    [PSTA, PSAR] = SarPartials(P, SAR) separates the partials matrix P into
%    partials for the stations, PSTA, and the partials for the SAR data, PSAR.
%    PSAR reflects displacements projected onto the look vector, using field
%    SAR.look_vec.
%

% Do the separation
sp   = size(p);
nsar = length(sar.lon);
psta = p(1:(sp(1) - 3*nsar), :);
psar = p((sp(1) - 3*nsar)+1:end, :);

% Project SAR partials based on look vector
lv = repmat(sar.look_vec(:), nsar, sp(2)); % Replicate: number of SAR coords-by-number of partials columns
psar = lv.*psar; % Element-wise multiplication
psar = psar(1:3:end, :) + psar(2:3:end, :) + psar(3:3:end, :); % Sum components at each station