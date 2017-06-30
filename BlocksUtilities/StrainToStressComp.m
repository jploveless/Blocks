function s = StrainToStressComp(e, lambda, mu)
% StressToStrain.m
%
% Calculate stress components given a strain tensor and elastic
% moduli lambda and mu.
%
% Stress and strain are n-by-6 arrays structured as:
%   [xx yy zz xy xz yz]
%
% Strain can also be a n-by-m*6 array, giving multiple strain tensors.
%

net = size(e, 2)./6; % number of strain tensors
s = e;
en = e(:, 1:6:end) + e(:, 2:6:end) + e(:, 3:6:end); % normal strains summed

s(:, 1:6:end) = 2.*mu.*e(:, 1:6:end) + lambda.*en;
s(:, 2:6:end) = 2.*mu.*e(:, 2:6:end) + lambda.*en;
s(:, 3:6:end) = 2.*mu.*e(:, 3:6:end) + lambda.*en;
s(:, 4:6:end) = 2.*mu.*e(:, 4:6:end);
s(:, 5:6:end) = 2.*mu.*e(:, 5:6:end);
s(:, 6:6:end) = 2.*mu.*e(:, 6:6:end);


