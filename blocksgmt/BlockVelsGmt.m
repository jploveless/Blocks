function out = BlockVelsGmt(blockfile, cpoints, outfile)
%
% BLOCKVELSGMT outputs a single block motion vector at the
% centroid of each block, formatted for plotting with GMT.
%
%    BLOCKVELSGMT(BLOCKFILE, SEGFILE, OUTFILE) uses the block model
%    parameters contained in the .block BLOCKFILE (usually Mod.block),
%    and the ordered block coordinates contained in SEGFILE (usually
%    Block.coords) and writes one vector per block to OUTFILE.  The
%    velocity vector is located at the block centroid and is the 
%    magnitude and direction dictated by the block's Euler pole.
%
%    BLOCKVELSGMT(BLOCKFILE, CPOINTS, OUTFILE) calculates the block 
%    velocities at the points specified by CPOINTS instead of the block
%    centroids.  CPOINTS should by an n-by-2 array (where n is the number
%    of blocks) containing the latitude and longitude of each calculation 
%    point.

% Read input files
b = ReadBlock(blockfile);

if ischar(cpoints)
	s = opentxt(cpoints);
	% Find the block separation lines
	bsep = strfind(s(:, 1)', '>');
	% Replace with NaNs and convert to numeric
	s(bsep, :) = repmat(['NaN NaN' repmat(' ', 1, size(s, 2) - 7)], numel(bsep), 1);
	s = str2num(s);
	% Make coordinate arrays
	[lon, lat] = deal(s(:, 1), s(:, 2));
	
	% Make an array containing the indices to the data points
	dind = [1 bsep(1:end-1)+1; bsep-1];
	
	out = zeros(numel(b.interiorLon), 4);
	
	% Loop over blocks
	for i = 1:numel(b.interiorLon)
		% Find the block centroid
		[Station.lon, Station.lat] = centroid3(lon(dind(1, i):dind(2, i))', lat(dind(1, i):dind(2, i))', zeros(diff(dind(:, i))+1, 1)');
		% Convert to Cartesian
		[Station.x, Station.y, Station.z] = sph2cart(deg2rad(Station.lon), deg2rad(Station.lat), 6371);
		Station.blockLabel = 1;
		% Convert Euler pole to Cartesian coordinates
		[epx, epy, epz] = sph2cart(deg2rad(b.eulerLon(i)), deg2rad(b.eulerLat(i)), deg2rad(b.rotationRate(i)));
		block.eulerLon = 1;
		% Calculate rotation partials
		G               = GetRotationPartials([], Station, [], block);
		% Calculate velocities
		dEst = G*[epx; epy; epz];
		% Create output array
		out(i, :) = [Station.lon, Station.lat, dEst(1), dEst(2)];
	end
else
   % Loop over blocks
	for i = 1:numel(b.interiorLon)
		% Find the block centroid
		[Station.lon, Station.lat] = deal(cpoints(i, 1), cpoints(i, 2));
		% Convert to Cartesian
		[Station.x, Station.y, Station.z] = sph2cart(deg2rad(Station.lon), deg2rad(Station.lat), 6371);
		Station.blockLabel = 1;
		% Convert Euler pole to Cartesian coordinates
		[epx, epy, epz] = sph2cart(deg2rad(b.eulerLon(i)), deg2rad(b.eulerLat(i)), deg2rad(b.rotationRate(i)));
		block.eulerLon = 1;
		% Calculate rotation partials
		G               = GetRotationPartials([], Station, [], block);
		% Calculate velocities
		dEst = G*[epx; epy; epz];
		% Create output array
		out(i, :) = [Station.lon, Station.lat, dEst(1), dEst(2), 0, 0, 0, mag([dEst(1) dEst(2)], 2)];
	end
end

% Write file containing velocities
fid = fopen(outfile, 'w');
fprintf(fid, '%g %g %g %g %g %g %g %.2f\n', out');
fclose(fid);

% Also copy the block segment coordinate file for plotting
[p, n, x] = fileparts(outfile);
newsegname = [p filesep n '.blockcoords'];
[p, n, x] = fileparts(blockfile);
segcoordname = [p filesep 'Block.coords'];
system(sprintf('cp %s %s', segcoordname, newsegname));