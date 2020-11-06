function e = StressToStrainComp(s, lambda, mu)
% StressToStrain.m
%
% Calculate strain components given a stress tensor and elastic
% moduli lambda and mu.
%
% Stress and strain are n-by-6 arrays structured as:
%   [xx yy zz xy xz yz]
%
% Stress can also be a n-by-m*6 array, giving a tensor in each row.
%

net = size(s, 2)./6; % number of stress tensors
e = s;
sn = s(:, 1:6:end) + s(:, 2:6:end) + s(:, 3:6:end); % trace of stress tensor

ncoef = lambda./(2*mu*(3*lambda + 2*mu)); % Normal coefficient 

e(:, 1:6:end) = 0.5./mu.*s(:, 1:6:end) - ncoef.*sn;
e(:, 2:6:end) = 0.5./mu.*s(:, 2:6:end) - ncoef.*sn;
e(:, 3:6:end) = 0.5./mu.*s(:, 3:6:end) - ncoef.*sn;
e(:, 4:6:end) = 0.5./mu.*s(:, 4:6:end);
e(:, 5:6:end) = 0.5./mu.*s(:, 5:6:end);
e(:, 6:6:end) = 0.5./mu.*s(:, 6:6:end);


