function StableReferenceFrame(infile, stable, outfile)

% Read data
S1                         = ReadStation(infile);

% Extract the subset of information pertaining the specified stations
lon1 								= S1.lon(stable);
lat1 								= S1.lat(stable);
ev   								= S1.eastVel(stable);
nv									= S1.northVel(stable);
esig								= S1.eastSig(stable);
nsig								= S1.northSig(stable);

% Solve for Euler pole which best describes motion at the specified stations
nStations                  = numel(lon1);
G                          = zeros(3*nStations, 3);
for i = 1:nStations
   rowIdx                  = (i-1)*3+1;
   colIdx                  = 1;
   [x y z]                 = sph2cart(deg2rad(lon1(i)), deg2rad(lat1(i)), 6371e6);
   R                       = GetCrossPartials([x y z]);
   [vn_wx ve_wx vu_wx]     = CartVecToSphVec(R(1,1), R(2,1), R(3,1), lon1(i), lat1(i));
   [vn_wy ve_wy vu_wy]     = CartVecToSphVec(R(1,2), R(2,2), R(3,2), lon1(i), lat1(i));
   [vn_wz ve_wz vu_wz]     = CartVecToSphVec(R(1,3), R(2,3), R(3,3), lon1(i), lat1(i));
   R                       = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   G(rowIdx:rowIdx+2,colIdx:colIdx+2) = R;
end

% Delete vertical components, estimate rotation vector and calculate residuals
G(3:3:end, :)              = [];
d                          = zeros(size(G,1), 1);
d(1:2:end)                 = ev;
d(2:2:end)                 = nv;
d                          = d(:);
s                          = zeros(size(G,1), 1);
s(1:2:end)                 = esig;
s(2:2:end)                 = nsig;
W                          = diag(s);
% omegaEst                   = G\d;
omegaEst                   = inv(G'*W*G)*G'*W*d;

dEst                       = G*omegaEst;
nvEst                      = dEst(2:2:end);
evEst                      = dEst(1:2:end);
resid                      = d-dEst;
nvRes                      = resid(2:2:end);
evRes                      = resid(1:2:end);

% Report goodness of fit
velMag                     = sqrt(nvRes.^2+evRes.^2);
sigMag                     = sqrt((nsig).^2+(esig).^2);
velMag                     = velMag(:);
sigMag                     = sigMag(:);
wmean                      = mean(velMag./sigMag);
fprintf(1, 'For the %d stations the mean residual magnitude is %5.2f (mm/yr)\n', numel(velMag), mean(velMag))
fprintf(1, 'For the %d stations the mean composite uncertainty is %5.2f (mm/yr)\n', numel(velMag), mean(sigMag))
fprintf(1, 'For the %d stations the mean weighted residual magnitude is %5.2f\n', numel(velMag), wmean);


% Calculate partials for new rotated velocites at all stations
lon1                       = S1.lon;
lat1                       = S1.lat;
nStations                  = numel(lon1);
G                          = zeros(3*nStations, 3);
for i = 1:nStations
   rowIdx                  = (i-1)*3+1;
   colIdx                  = 1;
   [x y z]                 = sph2cart(deg2rad(lon1(i)), deg2rad(lat1(i)), 6371e6);
   R                       = GetCrossPartials([x y z]);
   [vn_wx ve_wx vu_wx]     = CartVecToSphVec(R(1,1), R(2,1), R(3,1), lon1(i), lat1(i));
   [vn_wy ve_wy vu_wy]     = CartVecToSphVec(R(1,2), R(2,2), R(3,2), lon1(i), lat1(i));
   [vn_wz ve_wz vu_wz]     = CartVecToSphVec(R(1,3), R(2,3), R(3,3), lon1(i), lat1(i));
   R                       = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
   G(rowIdx:rowIdx+2,colIdx:colIdx+2) = R;
end
G(3:3:end, :)              = [];
dNew                       = G*omegaEst;
nvNew                      = dNew(2:2:end);
evNew                      = dNew(1:2:end);

% Write out newly aligned and combined velocity field
WriteStation(outfile, lon1, lat1, S1.eastVel-evNew, S1.northVel-nvNew, S1.eastSig, S1.northSig, S1.corr, zeros(size(lon1)), S1.tog, S1.name);
fprintf(1, 'Wrote %d stations to %s\n', numel(lon1), outfile);
