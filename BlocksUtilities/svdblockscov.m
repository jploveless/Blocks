% SVDBLOCKSRES
% Meant to be run with Blocks keyboarded before doing the inversion
%
% Specify variable "basefile" as a string containing full path and base file name.
%
% Make sure svdblocksres.bash is in the specified directory
%

[p, f, e] = fileparts(basefile);

interior = setdiff(1:length(Block.interiorLon), Block.exteriorBlockLabel);

% Calculate SVD of block part of the problem
W9 = W(1:rsta, 1:rsta);
G9x = W9*Rb(:, 1:3:end);
G9y = W9*Rb(:, 1:3:end);
G9z = W9*Rb(:, 1:3:end);
[U9x, L9x, V9x] = svd(G9x, 0);
[U9y, L9y, V9y] = svd(G9y, 0);
[U9z, L9z, V9z] = svd(G9z, 0);

nv = length(L9x);
labeltext = strcat(num2str([1:nv]'), repmat('/', nv, 1), repmat(num2str(nv), nv, 1));

inc = 1;
for j = 1:length(L9x); 
   vpx = V9x(:, 1:j);
   vpy = V9y(:, 1:j);
   vpz = V9z(:, 1:j);
   lpx = L9x(1:j, 1:j);
   lpy = L9y(1:j, 1:j);
   lpz = L9z(1:j, 1:j);
   covx = vpx*inv(lpx.^2)*vpx'; 
   covy = vpy*inv(lpy.^2)*vpy';
   covz = vpz*inv(lpz.^2)*vpz';
   covx = diag(covx); 
   covy = diag(covy);
   covz = diag(covz);
   figure
   for i = interior
      subplot(1, 3, 1);
      patch(Block.orderLon{i}, Block.orderLat{i}, log10(covx(i))); axis(socal)
      subplot(1, 3, 2);
      patch(Block.orderLon{i}, Block.orderLat{i}, covy(i)); axis(socal)
      subplot(1, 3, 3);
      patch(Block.orderLon{i}, Block.orderLat{i}, covz(i)); axis(socal); colorbar
   end   
%   fn = [basefile, '_', num2str(j) '.xy'];
%   ColorBlocksGmt(Block, covx, fn, interior);
%   system(sprintf('bash %s%ssvdblockscov.bash %s %s %d %s', p, filesep, fn(1:end-3), [p filesep], j, labeltext(j, :)));
end
