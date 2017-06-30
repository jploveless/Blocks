figure
m_proj('lambert','lon',[60 120],'lat',[10 50]);
%m_tbase('contour', [0 2000 4000 6000], 'edgecolor', 0.5*[1 1 1]);
m_grid('linestyle','none','tickdir','out','linewidth',1);


% Read in block file
b = load('Block.coords');
NanIdx = find(isnan(b(:, 1)));
% Index arrays identifying the bounds of each block's coordinates
cidx1 = [1; NanIdx(:)+1];
cidx2 = [NanIdx(:)-1];

% Make a big indexing array

keyboard

m_line(b(:, 1), b(:, 2), 'color', 0.5*[1 1 1]);

BB = ReadBlock('Mod.block');

dt = 5e4;
endtime = 1e7;
timevec = 0:dt:endtime;

% blockIdxVec = [1 2 3 4 5 6 7 9 11 12 13 14 16 17 18 20 21 22 23 24]; % Just for Asia
%blockIdxVec = [2 3 4 5 6 7 9 11 12 13 14 16 17 19 20 21 22 23]; % Just for Asia
% Names of blocks to exclude
exclud = {'rest_of_the_world', 'Indo_Austrailia', 'Eurasia', 'SouthEastAsia', 'south_china'};
% Find the indices of the block to INCLUDE
[junk, plateau] = setdiff(BB.name, exclud);
blockIdxVec = sort(plateau);

% blockIdxVec = [4]; % Just for Asia

XX = cell(length(blockIdxVec), length(0:dt:endtime));
YY = XX;

for k = blockIdxVec
   blockIdx = blockIdxVec(k);
   % Get block coordinates
   x1 = b(cidx1(blockIdx):cidx2(blockIdx), 1);
   y1 = b(cidx1(blockIdx):cidx2(blockIdx), 2);
   
   % Store original coordinates
   XX{blockIdx, 1} = x1;
   YY{blockIdx, 1} = y1;

   for j = 2:numel(timevec)
       
      % Convert Euler pole to rotation vector
      [xo yo zo] = sph2cart(deg2rad(BB.eulerLon(blockIdx)), deg2rad(BB.eulerLat(blockIdx)), 1);
      xo = BB.rotationRate(blockIdx)*1e-6.*dt*xo;
      yo = BB.rotationRate(blockIdx)*1e-6.*dt*yo;
      zo = BB.rotationRate(blockIdx)*1e-6.*dt*zo;

      [x y z] = sph2cart(deg2rad(x1), deg2rad(y1), 1);
      G                                           = zeros(3*numel(x1), 3);
      for iStation = 1:numel(x1)
         rowIdx                                   = (iStation-1)*3+1;
         R                                        = GetCrossPartials([x(iStation) y(iStation) z(iStation)]);
         [vn_wx ve_wx vu_wx]                      = CartVecToSphVec(R(1,1), R(2,1), R(3,1), x1(iStation), y1(iStation));
         [vn_wy ve_wy vu_wy]                      = CartVecToSphVec(R(1,2), R(2,2), R(3,2), x1(iStation), y1(iStation));
         [vn_wz ve_wz vu_wz]                      = CartVecToSphVec(R(1,3), R(2,3), R(3,3), x1(iStation), y1(iStation));
         R                                        = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
         G(rowIdx:rowIdx+2,1:3)                   = R;
      end
      vb1 = G*[xo;yo;zo];
      
      x1 = x1+vb1(1:3:end);
      y1 = y1+vb1(2:3:end);
      
      XX{blockIdx, j} = x1;
      YY{blockIdx, j} = y1; 

   end
   % Plot the evolving boundaries     
   m_patch(x1, y1, 'r', 'FaceColor', 'r')
   drawnow;
end

