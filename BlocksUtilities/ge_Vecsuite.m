function ge_Vecsuite(indir, outdir, daedir, sca)
% ge_Vecsuite  Writes a .kml file for a station structure.
%   ge_Vecsuite(IN, OUT, DAE) writes .kml files for each of the 
%   .sta files within the results directory IN to files in directory
%   OUT. It is necessary to specify where the Collada source files
%   are located, in directory DAE. 
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% Check which velocity field file extension is used here
if exist([indir filesep 'Obs.sta'], 'file')
   e = '.sta';
elseif exist([indir filesep 'Obs.sta.data'], 'file')
   e = '.sta.data';
end

% Check for optional scale
if ~exist('sca', 'var')
   sca = 100;
end

% Make directory if it doesn't already exist
if ~exist(outdir, 'dir')
   mkdir(outdir)
end  
   
% Write observed
s = ReadStation([indir filesep 'Obs' e]);
kml = ge_quiver3(wrapTo180(s.lon), s.lat, 100*ones(size(s.lon)), sca*s.eastVel, sca*s.northVel, sca*s.upVel, 'modelLinkStr', [daedir filesep 'bluearrow.dae'], 'altitudeMode', 'relativeToGround');
ge_output([outdir filesep 'Obs.kml'], kml');

% Write modeled
s = ReadStation([indir filesep 'Mod' e]);
kml = ge_quiver3(wrapTo180(s.lon), s.lat, 100*ones(size(s.lon)), sca*s.eastVel, sca*s.northVel, sca*s.upVel, 'modelLinkStr', [daedir filesep 'redarrow.dae'], 'altitudeMode', 'relativeToGround');
ge_output([outdir filesep 'Mod.kml'], kml');

% Write block
s = ReadStation([indir filesep 'Rot' e]);
kml = ge_quiver3(wrapTo180(s.lon), s.lat, 100*ones(size(s.lon)), sca*s.eastVel, sca*s.northVel, sca*s.upVel, 'modelLinkStr', [daedir filesep 'brightgreenarrow.dae'], 'altitudeMode', 'relativeToGround');
ge_output([outdir filesep 'Rot.kml'], kml');

% Write elastic
s = ReadStation([indir filesep 'Def' e]);
kml = ge_quiver3(wrapTo180(s.lon), s.lat, 100*ones(size(s.lon)), sca*s.eastVel, sca*s.northVel, sca*s.upVel, 'modelLinkStr', [daedir filesep 'cyanarrow.dae'], 'altitudeMode', 'relativeToGround');
ge_output([outdir filesep 'Def.kml'], kml');

% Write triangular
s = ReadStation([indir filesep 'Tri' e]);
kml = ge_quiver3(wrapTo180(s.lon), s.lat, 100*ones(size(s.lon)), sca*s.eastVel, sca*s.northVel, sca*s.upVel, 'modelLinkStr', [daedir filesep 'orangearrow.dae'], 'altitudeMode', 'relativeToGround');
ge_output([outdir filesep 'Tri.kml'], kml');

% Write residual
s = ReadStation([indir filesep 'Res' e]);
kml = ge_quiver3(wrapTo180(s.lon), s.lat, 100*ones(size(s.lon)), sca*s.eastVel, sca*s.northVel, sca*s.upVel, 'modelLinkStr', [daedir filesep 'pinkarrow.dae'], 'altitudeMode', 'relativeToGround');
ge_output([outdir filesep 'Res.kml'], kml');