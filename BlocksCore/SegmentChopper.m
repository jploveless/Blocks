function SegmentChopper(inFileName, outFileName, d1, d2)
% SegmentChopper.m
% This will "chop-up" a .segment file into smaller pieces.
% inFileName is the name of the .segment file to be chopped.
% outFileName is the name of the new .segment file to be written.
% Segments longer than d1 km will be chopped into pieces no longer than d1.
% Segments shorther than d1 km will be chopped into pieces no longer than
% d2.

if ischar(inFileName)
   S                                             = ReadSegmentTri(inFileName);
else
   S = inFileName;
end
filestream                                       = fopen(outFileName, 'w');
% d1                                               = 500;
% d2                                               = 25;

% S                                                = ReadSegmentStruct('cal2.b03.segment');
% filestream                                       = fopen('cal2.b03.choptest.segment', 'w');
% d1                                               = 500;
% d2                                               = 25;

% Write new segment file header
fprintf(filestream, 'Name\n');
fprintf(filestream, 'st_long  st_lat   end_long  end_lat\n');
fprintf(filestream, 'lock_dep ld_sig   ld_toggle\n');
fprintf(filestream, 'dip      dip_sig  dip_toggle\n');
fprintf(filestream, 'ss_rate  ss_sig   ss_tog\n');
fprintf(filestream, 'ds_rate  ds_sig   ds_tog\n');
fprintf(filestream, 'ts_rate  ts_sig   ts_tog\n');
fprintf(filestream, 'bur_dep  bd_sig   bd_tog\n');
fprintf(filestream, 'fres     fres_ov  fres_other\n');
fprintf(filestream, 'other1   other2   other3\n');
fprintf(filestream, 'other4   other5   other6\n');
fprintf(filestream, 'other7   other8   other9\n');
fprintf(filestream, 'other10  other11  other12\n');

% Loop over all segments
delta                                            = zeros(size(S.lon1));
for i = 1:numel(S.lon1)
  delta(i)                                      = 6371*deg2rad(distance(S.lat1(i), S.lon1(i), S.lat2(i), S.lon2(i)));
  [S.lon1(i) S.lat1(i) S.lon2(i) S.lat2(i)]     = order_lon_lat_pairs(S.lon1(i), S.lat1(i), S.lon2(i), S.lat2(i));

  % Anything longer than d1 km gets cut to d1 km
  if (delta(i) > d1)
     fprintf(1, 'Chopping %s to < 500 km segments\n', S.name(i,:))
     n                                          = floor(delta(i)/d1)+1;
     dlon                                       = -(S.lon1(i)-S.lon2(i))/n;
     dlat                                       = -(S.lat1(i)-S.lat2(i))/n;

     % Break into smaller pieces
     nlon1                                      = zeros(1,n);
     nlat1                                      = zeros(1,n);
     nlon2                                      = zeros(1,n);
     nlat2                                      = zeros(1,n);
     nlon1(1)                                   = S.lon1(i);
     nlat1(1)                                   = S.lat1(i);
     nlon2(1)                                   = S.lon1(i)+dlon;
     nlat2(1)                                   = S.lat1(i)+dlat;

     for j = 2:n
        nlon1(j)                                = nlon2(j-1);
        nlat1(j)                                = nlat2(j-1);
        nlon2(j)                                = nlon2(j-1)+dlon;
        nlat2(j)                                = nlat2(j-1)+dlat;
     end

     % Write to new segment file
     for j = 1:n
        fprintf(filestream, '%s\n', sprintf('%s%d', S.name(i, :), j));
        fprintf(filestream, '%3.3f   %3.3f   %3.3f  %3.3f\n',   nlon1(j),      nlat1(j),         nlon2(j),       nlat2(j));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.lDep(i),     S.lDepSig(i),     S.lDepTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.dip(i),      S.dipSig(i),      S.dipTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.ssRate(i),   S.ssRateSig(i),   S.ssRateTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.dsRate(i),   S.dsRateSig(i),   S.dsRateTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.tsRate(i),   S.tsRateSig(i),   S.tsRateTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.bDep(i),     S.bDepSig(i),     S.bDepTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.res(i),      S.resOver(i),     S.resOther(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.patchFile(i),S.patchTog(i),    S.other3(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.patchSlipFile(i),   S.patchSlipTog(i),      S.other6(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.other7(i),   S.other8(i),      S.other9(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.other10(i),  S.other11(i),     S.other12(i));
     end
  end

  % Anything less than d1 km gets cut to d2 km
  if (delta(i) < d1)
     fprintf(1, 'Chopping %s to < 10 km segments\n', S.name(i,:))
     n                                          = floor(delta(i)/d2)+1;
     dlon                                       = -(S.lon1(i)-S.lon2(i))/n;
     dlat                                       = -(S.lat1(i)-S.lat2(i))/n;

     % Break into smaller pieces
     nlon1                                      = zeros(1,n);
     nlat1                                      = zeros(1,n);
     nlon2                                      = zeros(1,n);
     nlat2                                      = zeros(1,n);
     nlon1(1)                                   = S.lon1(i);
     nlat1(1)                                   = S.lat1(i);
     nlon2(1)                                   = S.lon1(i)+dlon;
     nlat2(1)                                   = S.lat1(i)+dlat;

     for j = 2:n
        nlon1(j)                                = nlon2(j-1);
        nlat1(j)                                = nlat2(j-1);
        nlon2(j)                                = nlon2(j-1)+dlon;
        nlat2(j)                                = nlat2(j-1)+dlat;
     end

     % Write to new segment file
     for j = 1:n
        fprintf(filestream, '%s\n', sprintf('%s%d', S.name(i, :), j));
        fprintf(filestream, '%3.3f   %3.3f   %3.3f  %3.3f\n',   nlon1(j),      nlat1(j),         nlon2(j),       nlat2(j));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.lDep(i),     S.lDepSig(i),     S.lDepTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.dip(i),      S.dipSig(i),      S.dipTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.ssRate(i),   S.ssRateSig(i),   S.ssRateTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.dsRate(i),   S.dsRateSig(i),   S.dsRateTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.tsRate(i),   S.tsRateSig(i),   S.tsRateTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.bDep(i),     S.bDepSig(i),     S.bDepTog(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.res(i),      S.resOver(i),     S.resOther(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.patchFile(i),S.patchTog(i),    S.other3(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.patchSlipFile(i),   S.patchSlipTog(i),      S.other6(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.other7(i),   S.other8(i),      S.other9(i));
        fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           S.other10(i),  S.other11(i),     S.other12(i));
     end
  end
end

