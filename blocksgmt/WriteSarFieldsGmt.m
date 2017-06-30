function WriteSarFieldsGmt(direc, outroot)
% WriteSarFieldsGmt(direc, outroot) writes the SAR displacement fields contained 
% in direc/Sar.pred to the files outroot*.xy, where * is:
% obs, mod, res, def, tri, ramp, rot, shift, strain
%
% For example, to write files from the current directory to the Desktop, with
% root name "123" (corresponding to a run directory, for example), call
% >> WriteSarFieldsGmt('.', '/Users/jack/Desktop/123')
%

% Read file
sar = load([direc filesep 'Sar.pred']);

% Write files
obsn = [outroot 'obs.xy'];
obs = [sar(:, 1), sar(:, 2), sar(:, 3)];
save(obsn, 'obs', '-ascii');

modn = [outroot 'mod.xy'];
mod = [sar(:, 1), sar(:, 2), sar(:, 4)];
save(modn, 'mod', '-ascii');

resn = [outroot 'res.xy'];
res = [sar(:, 1), sar(:, 2), sar(:, 5)];
save(resn, 'res', '-ascii');

defn = [outroot 'def.xy'];
def = [sar(:, 1), sar(:, 2), sar(:, 6)];
save(defn, 'def', '-ascii');

rotn = [outroot 'rot.xy'];
rot = [sar(:, 1), sar(:, 2), sar(:, 7)];
save(rotn, 'rot', '-ascii');

rampn = [outroot 'ramp.xy'];
ramp = [sar(:, 1), sar(:, 2), sar(:, 8)];
save(rampn, 'ramp', '-ascii');

shiftn = [outroot 'shift.xy'];
shift = [sar(:, 1), sar(:, 2), sar(:, 9)];
save(shiftn, 'shift', '-ascii');

trin = [outroot 'tri.xy'];
tri = [sar(:, 1), sar(:, 2), sar(:, 10)];
save(trin, 'tri', '-ascii');

strainn = [outroot 'strain.xy'];
strain = [sar(:, 1), sar(:, 2), sar(:, 11)];
save(strainn, 'strain', '-ascii');

