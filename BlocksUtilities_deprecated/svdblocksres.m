% SVDBLOCKSRES
% Meant to be run with Blocks keyboarded before doing the inversion
%
% Specify variable "basefile" as a string containing full path and base file name.
%
% Make sure svdblocksres.bash is in the specified directory
%

[p, f, e] = fileparts(basefile);

interior = setdiff(1:length(Block.interiorLon), Block.exteriorBlockLabel);
socal = [238.5449  245.2105   32.1488   37.6233];

% Calculate SVD of block part of the problem
%W9 = W(1:rsta, 1:rsta);
%G9 = W9*Rb;
%G9x = W9*Rb(:, 1:3:end);
%G9y = W9*Rb(:, 2:3:end);
%G9z = W9*Rb(:, 3:3:end);
%[U9, L9, V9] = svd(G9, 0);
%[U9x, L9x, V9x] = svd(G9x, 0);
%[U9y, L9y, V9y] = svd(G9y, 0);
%[U9z, L9z, V9z] = svd(G9z, 0);

nv = size(L, 2);
%nv = length(L9x);
labeltext = strcat(num2str([1:nv]'), repmat('/', nv, 1), repmat(num2str(nv), nv, 1));

inc = 1;
for j = 1:nv; 
   vp = V(:, 1:j);
%   vpx = V9x(:, 1:j);
%   vpy = V9y(:, 1:j);
%   vpz = V9z(:, 1:j);
   res = vp*vp';
%   resx = vpx*vpx'; 
%   resy = vpy*vpy';
%   resz = vpz*vpz';
   res = diag(res);
%   resx = diag(resx); 
%   resy = diag(resy);
%   resz = diag(resz);
   pres = mag([res(1:3:end), res(2:3:end), res(3:3:end)], 2)./sqrt(3);
%   figure
%   for i = interior
%      patch(Block.orderLon{i}, Block.orderLat{i}, pres(i)); caxis([0 1]); axis equal; axis(socal); title(sprintf('N = %d', j))
%      subplot(1, 3, 1);
%      patch(Block.orderLon{i}, Block.orderLat{i}, resx(i)); caxis([0 1]); axis(socal)
%      subplot(1, 3, 2);
%      patch(Block.orderLon{i}, Block.orderLat{i}, resy(i)); caxis([0 1]); axis(socal)
%      subplot(1, 3, 3);
%      patch(Block.orderLon{i}, Block.orderLat{i}, resz(i)); caxis([0 1]); axis(socal)
%   end   
   fn = [basefile, '_', num2str(j) '.xy'];
   ColorBlocksGmt(Block, pres, fn, interior);
   system(sprintf('bash %s%ssvdblocksres.bash %s %s %d %s', p, filesep, fn(1:end-3), [p filesep], j, labeltext(j, :)));
end
