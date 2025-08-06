function runName = WriteOutput(Segment, Patches, Station, Sar, Block, Command, Model, Mogi)
% Write all sorts of output files
runName = GetRunName;
mkdir(runName);

% Write out labels
WriteStation(sprintf('.%s%s%slabel.sta', filesep, runName, filesep), Station.lon, Station.lat, zeros(size(Station.lon)), zeros(size(Station.lon)), Station.eastSig, Station.northSig, Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteSegment(sprintf('.%s%s%slabel.segment', filesep, runName, filesep), Segment.name, Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2, Segment.lDep, Segment.lDepSig, Segment.lDepTog, Segment.dip, Segment.dipSig, Segment.dipTog, Segment.westLabel, Segment.eastLabel, ones(size(Segment.ssRate)), ones(size(Segment.dsRate)), ones(size(Segment.dsRate)), ones(size(Segment.dsRate)), ones(size(Segment.tsRate)), ones(size(Segment.tsRate)), ones(size(Segment.tsRate)), Segment.bDep, Segment.bDepSig, Segment.bDepTog, Segment.res, Segment.resOver, Segment.resOther, Segment.patchFile, Segment.patchTog, Segment.other3, Segment.patchSlipFile, Segment.patchSlipTog, Segment.other6, Segment.rake, Segment.rakeSig, Segment.rakeTog, Segment.other7, Segment.other8, Segment.other9);

% Write out velocities
WriteStation(sprintf('.%s%s%sObs.sta', filesep, runName, filesep), Station.lon, Station.lat, Station.eastVel, Station.northVel, Station.eastSig, Station.northSig, Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sRes.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastResidVel, Model.northResidVel, Station.eastSig, Station.northSig, Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sMod.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastVel, Model.northVel, zeros(size(Station.eastSig)), zeros(size(Station.northSig)), Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sRot.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastRotVel, Model.northRotVel, zeros(size(Station.eastSig)), zeros(size(Station.northSig)), Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sDef.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastDefVel, Model.northDefVel, zeros(size(Station.eastSig)), zeros(size(Station.northSig)), Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sTri.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastTriVel, Model.northTriVel, zeros(size(Station.eastSig)), zeros(size(Station.northSig)), Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sStrain.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastStrainVel, Model.northStrainVel, zeros(size(Station.eastSig)), zeros(size(Station.northSig)), Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sMogi.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.eastMogiVel, Model.northMogiVel, zeros(size(Station.eastSig)), zeros(size(Station.northSig)), Station.corr, Station.blockLabel, Station.tog, Station.name);
WriteStation(sprintf('.%s%s%sModVertical.sta', filesep, runName, filesep), Station.lon, Station.lat, Model.upVel, zeros(size(Station.upVel)), zeros(size(Station.upVel)), zeros(size(Station.upVel)), Station.corr, Station.blockLabel, Station.tog, Station.name);

% Write out slip rates
WriteSegment(sprintf('.%s%s%sMod.segment', filesep, runName, filesep), Segment.name, Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2, Segment.lDep, Segment.lDepSig, Segment.lDepTog, Segment.dip, Segment.dipSig, Segment.dipTog, Model.ssRate, Model.ssRateSig, ones(size(Segment.ssRate)), Model.dsRate, Model.dsRateSig, ones(size(Segment.dsRate)), Model.tsRate, Model.tsRateSig, ones(size(Segment.tsRate)), Segment.bDep, Segment.bDepSig, Segment.bDepTog, Segment.res, Segment.resOver, Segment.resOther, Segment.patchFile, Segment.patchTog, Segment.other3, Segment.patchSlipFile, Segment.patchSlipTog, Segment.rake, Segment.rakeSig, Segment.rakeTog, Segment.other6, Segment.other7, Segment.other8, Segment.other9);

% Write out block motions
WriteBlocks(sprintf('.%s%s%sMod.block', filesep, runName, filesep), Block.name, Block.interiorLon, Block.interiorLat, Model.lonEuler, Model.lonEulerSig, Model.latEuler, Model.latEulerSig, Model.rateEuler./1e6, Model.rateEulerSig./1e6, ...
            Block.rotationInfo, Block.aprioriTog, Model.eLonLon, Model.eLonLat, Model.eLatLat, Model.eLonLonSig, Model.eLonLatSig, Model.eLatLatSig);

% Write out block strains
hl = {'Name', 'interior_long interior_lat', 'Reference_long Reference_long_sig', 'Reference_lat Reference_lat_sig', 'rotation_rate rotation_rate_sig', 'rotation_info apriori_toggle', 'eLonLon eLonLat eLatLat', 'eLonLonSig eLonLatSig eLatLatSig'};
WriteBlocks(sprintf('.%s%s%sStrain.block', filesep, runName, filesep), Block.name, Block.interiorLon, Block.interiorLat, Model.lonStrain, Model.lonStrainSig, Model.latStrain, Model.latStrainSig, zeros(numel(Model.latStrain), 1), zeros(numel(Model.latStrain), 1), ...
            Block.rotationInfo, Block.aprioriTog, Model.eLonLon, Model.eLonLat, Model.eLatLat, Model.eLonLonSig, Model.eLonLatSig, Model.eLatLatSig, hl);

% Write out a multi-segment file containing block coordinates circulated in their ordered way
WriteOrderedBlockCoords(sprintf('.%s%s%sBlock.coords', filesep, runName, filesep), Segment, Block)
        
% Write out triangular slips
if ~isfield(Patches, 'strike')
   Patches.strike = [];
end
WritePatches(sprintf('.%s%s%sMod.patch', filesep, runName, filesep), Patches.c, Patches.v, Model.trislipS, Model.trislipD, Model.trislipT, Model.trislipSSig, Model.trislipDSig, Model.trislipTSig, Patches.strike, Model.trislipSBlock, Model.trislipDBlock, Model.trislipTBlock);		

% Write SAR results
WriteSarResults(Sar, Model, runName);

% Write Mogi results
WriteMogi(sprintf('.%s%s%sMod.mogi', filesep, runName, filesep), Mogi, Model)

% Copy command file to results directory
[p, f, e] = fileparts(Command.fileName);
WriteCommand(Command, sprintf('%s%s%s%s', runName, filesep, f, e));
% system(sprintf('cp %s .%s%s%s.', Command.fileName, filesep, runName, filesep));

% Copy original input files to a directory, in case the files are subsequently changed but the names are the same
WriteInputCopies(Command, sprintf('%s%sinputs%s', runName, filesep, filesep));

% Write kernels to results directory if requested
if exist('./tempkernels.mat', 'file')
   movefile('./tempkernels.mat', sprintf('.%s%skernels.mat', filesep, runName));
end

% Calculate and write out stats
filename                                  = fopen(sprintf('.%s%s%sStats.txt', filesep, runName, filesep), 'w');

% Residual contribution statistics
% Build the station magnitude vectors
vel_mag                                   = sqrt(Model.eastResidVel.^2 + Model.northResidVel.^2);

% Build a sort of uncertainty magnitude vector
sig_mag                                   = sqrt(Station.eastSig.^2 + Station.northSig.^2);

% Build the weighted station magnitude vectors
wgt_vel_cont                              = (Model.eastResidVel.^2 ./ Station.eastSig.^2) + (Model.northVel.^2 ./ Station.northSig.^2);
[sorted_wgt_vel_cont, sort_idx]           = sort(wgt_vel_cont);
   
   
% Rearrange the components in the other vectors
[sort_vel_mag, sort_sig_mag]              = deal(zeros(size(vel_mag)));
sort_station_name                         = zeros(size(Station.name));
for cnt = 1 : length(sort_idx)
   sort_vel_mag(cnt)                      = vel_mag(sort_idx(cnt));
   sort_sig_mag(cnt)                      = sig_mag(sort_idx(cnt));
   sort_station_name(cnt, :)              = Station.name(sort_idx(cnt), :);      
end

% Calculate the total contribution
total_cont                                   = sum(sorted_wgt_vel_cont);
fprintf(filename, '\nThe station contributions are:\n');
fprintf(filename, '    Name     Contribution  %%Contribution   Accumulated cont.    Magnitude\n');
for cnt = 1 : length(sort_idx)
   cidx                                  = length(sort_idx) - (cnt - 1);
   fprintf(filename,'%d) %s    %4.3f        %3.3f              %3.3f              %4.3f\n', cnt, char(sort_station_name(cidx, :)), sorted_wgt_vel_cont(cidx), sorted_wgt_vel_cont(cidx) / total_cont * 100, sum(sorted_wgt_vel_cont(cidx:end)) / total_cont * 100, sort_vel_mag(cidx));
end

% Report Euler pole combinations
% Declare variables
big_cnt                                         = 1;
big_block_name                                  = [];
omega_x_sig                                     = Model.omegaXSig;
omega_y_sig                                     = Model.omegaYSig;
omega_z_sig                                     = Model.omegaZSig;

n_blocks                                        = length(Model.omegaX);


% Make meshgrids of indices of block combinations
[ide, idi]													= meshgrid(1:n_blocks, 1:n_blocks);
[ide, idi]													= deal(triu(ide, 1), triu(idi, 1));
[ide, idi]													= deal(ide(find(ide(:))), idi(find(idi(:))));

% Do the differencing
diff_omega_x 												= Model.omegaX(ide) - Model.omegaX(idi);
diff_omega_y 												= Model.omegaY(ide) - Model.omegaY(idi);
diff_omega_z 												= Model.omegaZ(ide) - Model.omegaZ(idi);

% convert rotation vector to pole and rotation rate
[rrate, Elon, Elat]										= omega_to_rate_and_Euler_DM(diff_omega_x, diff_omega_y, diff_omega_z);
quad_omega_x_sig                       			= sqrt(omega_x_sig(ide).^2 + omega_x_sig(idi).^2);
quad_omega_y_sig                       			= sqrt(omega_y_sig(ide).^2 + omega_y_sig(idi).^2);	 
quad_omega_z_sig                       			= sqrt(omega_z_sig(ide).^2 + omega_z_sig(idi).^2);

% estimate errors on pole parameters			
[Elon_sig, Elat_sig, rrate_sig] 						= calc_boot_Euler_sigmas(diff_omega_x, quad_omega_x_sig,...
           																					 diff_omega_y, quad_omega_y_sig,...
           																					 diff_omega_z, quad_omega_z_sig,...
           																					 zeros(size(Model.covariance)), zeros(size(Model.covariance)), 0);

% arrays of names for writing out
block_name1                        				   = strvcat(Block.name(ide, :));
block_name2													= strvcat(Block.name(idi, :));

% Range correction
sElon                                           = Elon;
sElon(find(sElon > 180))                        = sElon(find(sElon > 180)) - 360;

% Write out estimated poles
fprintf(filename, '\nLongitude [0  360]\n');
fprintf(filename, 'Block Name               Euler Pole Longitude          Euler Pole Latitude            Rotation Rate\n');
fprintf(filename, '                              [degrees]                     [degrees]                [degrees / Myr]\n');
for cnt = 1 : length(rrate)
   fprintf(filename, '%9s - %8s   %+10.3f +/- %6.3f         %+10.3f +/- %6.3f         %+10.3f +/- %6.3f\n', block_name1(cnt, :), block_name2(cnt, :), Elon(cnt), Elon_sig(cnt), Elat(cnt), Elat_sig(cnt), rrate(cnt)/1e6, rrate_sig(cnt)/1e6);
end

fprintf(filename, '\nLongitude [-180  180]\n');
for cnt = 1 : length(rrate)
   fprintf(filename, '%9s - %8s   %+10.3f +/- %6.3f         %+10.3f +/- %6.3f         %+10.3f +/- %6.3f\n', block_name1(cnt, :), block_name2(cnt, :), sElon(cnt), Elon_sig(cnt), Elat(cnt), Elat_sig(cnt), rrate(cnt)/1e6, rrate_sig(cnt)/1e6);
end

% Calculate antipodes
[aElat, aElon]                                      = antipode(Elat, Elon);
neg_vec                                             = find(aElon < 0);
aElon(neg_vec)                                      = aElon(neg_vec) + 360;

% Write out antipodes
fprintf(filename, '\nEquivalent antipode solutions\n');
fprintf(filename, '\nLongitude [0  360]\n');
fprintf(filename, 'Block Name               Euler Pole Longitude          Euler Pole Latitude            Rotation Rate\n');
fprintf(filename, '                              [degrees]                     [degrees]                [degrees / Myr]\n');
for cnt = 1 : length(rrate)
   fprintf(filename, '%9s - %8s   %+10.3f +/- %6.3f         %+10.3f +/- %6.3f         %+10.3f +/- %6.3f\n', block_name1(cnt, :), block_name2(cnt, :), aElon(cnt), Elon_sig(cnt), aElat(cnt), Elat_sig(cnt), -rrate(cnt)/1e6, rrate_sig(cnt)/1e6);
end
fprintf(filename, '\n');

saElon                                             = aElon;
saElon(find(saElon > 180))                         = saElon(find(saElon > 180)) - 360;
fprintf(filename, 'Longitude [-180  180]\n');
for cnt = 1 : length(rrate)
   fprintf(filename, '%9s - %8s   %+10.3f +/- %6.3f         %+10.3f +/- %6.3f         %+10.3f +/- %6.3f\n', block_name1(cnt, :), block_name2(cnt, :), saElon(cnt), Elon_sig(cnt), aElat(cnt), Elat_sig(cnt), -rrate(cnt)/1e6, rrate_sig(cnt)/1e6);
end

% ListVelStats
% Get the initial number of stations
nStations                                       = numel(Station.eastVel);

% Build some big vectors
big_vel_vec                                     = [Model.eastResidVel ; Model.northResidVel];
big_sig_vec                                     = [Station.eastSig ; Station.northSig];
big_wgt_vec                                     = big_vel_vec ./ big_sig_vec;
velMag                                          = sqrt(Model.eastResidVel.^2 + Model.northResidVel.^2);

% Find out how many residuals are smaller than their uncertainties
fitRes                                          = big_vel_vec - big_sig_vec;
nSmall                                          = length(find( (abs(big_vel_vec) - big_sig_vec) < 0 ) );

% Find out how many residual magnitudes are smaller than NN mm/yr
nMagLt01                                        = length(find(velMag < 1));
nMagLt02                                        = length(find(velMag < 2));
nMagLt03                                        = length(find(velMag < 3));
nMagLt04                                        = length(find(velMag < 4));
nMagLt05                                        = length(find(velMag < 5));
nMagLt06                                        = length(find(velMag < 6));
nMagLt07                                        = length(find(velMag < 7));
nMagLt08                                        = length(find(velMag < 8));
nMagLt09                                        = length(find(velMag < 9));
nMagLt10                                        = length(find(velMag < 10));

% Find out how many residual magnitudes are smaller than NN mm/yr
nMagLt01C                                       = length(find(abs(big_vel_vec) < 1));
nMagLt02C                                       = length(find(abs(big_vel_vec) < 2));
nMagLt03C                                       = length(find(abs(big_vel_vec) < 3));
nMagLt04C                                       = length(find(abs(big_vel_vec) < 4));
nMagLt05C                                       = length(find(abs(big_vel_vec) < 5));
nMagLt06C                                       = length(find(abs(big_vel_vec) < 6));
nMagLt07C                                       = length(find(abs(big_vel_vec) < 7));
nMagLt08C                                       = length(find(abs(big_vel_vec) < 8));
nMagLt09C                                       = length(find(abs(big_vel_vec) < 9));
nMagLt10C                                       = length(find(abs(big_vel_vec) < 10));

% Basic means
resMean                                         = mean(abs(big_vel_vec));
sigMean                                         = mean(big_sig_vec);
nResLtSig                                       = length(find(abs(big_vel_vec) < sigMean));

% Calculate some statistics
fprintf(filename, '\nResidual velocity statistics\n\n');
fprintf(filename, 'mean east velocity                       = %7.3f    [mm/yr]\n', mean(Station.eastVel)   );
fprintf(filename, 'mean east velocity (abs)                 = %7.3f    [mm/yr]\n', mean(abs(Station.eastVel))  );
fprintf(filename, 'weighted mean east velocity              = %7.3f    [mm/yr]\n', calc_weighted_mean(Station.eastVel, Station.eastSig)  );
fprintf(filename, 'weighted mean east velocity (abs)        = %7.3f    [mm/yr]\n', calc_weighted_mean(abs(Station.eastVel), Station.eastSig)  );
fprintf(filename, 'sum_sqrt_WS                              = %7.3f    [mm/yr]\n', sum(sqrt(Station.eastVel.^2 ./ Station.eastSig.^2)) / nStations );
fprintf(filename, 'sqrt_WSS                                 = %7.3f    [mm/yr]\n', sqrt(sum(Station.eastVel.^2 ./ Station.eastSig.^2)) / nStations );
fprintf(filename, 'sqrt_WSS/SSS                             = %7.3f    [mm/yr]\n\n', sqrt(sum(Station.eastVel.^2 ./ Station.eastSig.^2) / sum(1./Station.eastSig.^2)) / nStations );

fprintf(filename, 'mean north velocity                      = %7.3f    [mm/yr]\n', mean(Station.northVel)   );
fprintf(filename, 'mean north velocity (abs)                = %7.3f    [mm/yr]\n', mean(abs(Station.northVel))   );
fprintf(filename, 'weighted mean north velocity             = %7.3f    [mm/yr]\n', calc_weighted_mean(Station.northVel, Station.northSig)  );
fprintf(filename, 'weighted mean north velocity (abs)       = %7.3f    [mm/yr]\n', calc_weighted_mean(abs(Station.northVel), Station.northSig)  );
fprintf(filename, 'sum_sqrt_WS                              = %7.3f    [mm/yr]\n', sum(sqrt(Station.northVel.^2 ./ Station.northSig.^2)) / nStations );
fprintf(filename, 'sqrt_WSS                                 = %7.3f    [mm/yr]\n', sqrt(sum(Station.northVel.^2 ./ Station.northSig.^2)) / nStations );
fprintf(filename, 'sqrt_WSS/SSS                             = %7.3f    [mm/yr]\n\n', sqrt(sum(Station.northVel.^2 ./ Station.northSig.^2) / sum(1./Station.northSig.^2)) / nStations );

fprintf(filename, 'Number of stations                           = %d \n', nStations);
fprintf(filename, 'Percentage smaller than 1sig (components)    = %7.3f%%\n', nSmall / (2 * nStations) * 100);
fprintf(filename, 'mean residual magnitude                      = %7.3f    [mm/yr]\n', mean(velMag));
fprintf(filename, 'mean uncertainty magnitude (not component)   = %7.3f    [mm/yr]\n', mean(sqrt(Station.eastSig.^2 + Station.northSig.^2)));
fprintf(filename, 'mean component magnitude                     = %7.3f    [mm/yr]\n', mean(abs(big_vel_vec)));
fprintf(filename, 'mean uncertainty magnitude (component)       = %7.3f    [mm/yr]\n', mean(big_sig_vec));
fprintf(filename, 'normalized mean magnitude(component)         = %7.3f    [mm/yr]\n', mean(abs(big_vel_vec)./big_sig_vec));
fprintf(filename, 'mean uncertainty magnitude (component)       = %7.3f    [mm/yr]\n', mean(big_sig_vec));
fprintf(filename, 'velocity chi squared                         = %7.3f    [mm/yr]\n', sum(big_vel_vec.^2 ./ big_sig_vec.^2));
fprintf(filename, 'velocity chi squared / DOF (approx)          = %7.3f    [mm/yr]\n\n', sum(big_vel_vec.^2 ./ big_sig_vec.^2) / (2 * nStations - 3 * numel(Block.interiorLon)));

fprintf(filename, 'Percentage of magnitudes <  1 mm/yr = %f\n', nMagLt01 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  2 mm/yr = %f\n', nMagLt02 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  3 mm/yr = %f\n', nMagLt03 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  4 mm/yr = %f\n', nMagLt04 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  5 mm/yr = %f\n', nMagLt05 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  6 mm/yr = %f\n', nMagLt06 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  7 mm/yr = %f\n', nMagLt07 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  8 mm/yr = %f\n', nMagLt08 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes <  9 mm/yr = %f\n', nMagLt09 / nStations * 100);
fprintf(filename, 'Percentage of magnitudes < 10 mm/yr = %f\n\n', nMagLt10 / nStations * 100);

fprintf(filename, 'Percentage of components <  1 mm/yr = %f\n', nMagLt01C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  2 mm/yr = %f\n', nMagLt02C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  3 mm/yr = %f\n', nMagLt03C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  4 mm/yr = %f\n', nMagLt04C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  5 mm/yr = %f\n', nMagLt05C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  6 mm/yr = %f\n', nMagLt06C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  7 mm/yr = %f\n', nMagLt07C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  8 mm/yr = %f\n', nMagLt08C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components <  9 mm/yr = %f\n', nMagLt09C / nStations * 100 / 2);
fprintf(filename, 'Percentage of components < 10 mm/yr = %f\n', nMagLt10C / nStations * 100 / 2);
fprintf(filename, 'Percentage of residuals < mean uncertianty = %f\n', nResLtSig / nStations * 100 / 2);
fclose(filename);