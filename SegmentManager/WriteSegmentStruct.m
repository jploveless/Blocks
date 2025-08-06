function WriteSegment(segfilename, Segment)
%%  WriteSegment.m

%%  Open file stream
filestream                          = fopen(segfilename, 'w');

%%  Write header
fprintf(filestream, 'Name\n');
fprintf(filestream, 'st_long  st_lat   end_long  end_lat\n');
fprintf(filestream, 'lock_dep ld_sig   ld_toggle\n');
fprintf(filestream, 'dip      dip_sig  dip_toggle\n');
fprintf(filestream, 'ss_rate  ss_sig   ss_tog\n');
fprintf(filestream, 'ds_rate  ds_sig   ds_tog\n');
fprintf(filestream, 'ts_rate  ts_sig   ts_tog\n');
fprintf(filestream, 'bur_dep  bd_sig   bd_tog\n');
fprintf(filestream, 'fres     fres_ov  fres_other\n');
fprintf(filestream, 'patchFile  patchTog other3\n');
fprintf(filestream, 'patchSlipFile  patchSlipTog    other6\n');
fprintf(filestream, 'rake     rake_sig rake_toggle\n');
fprintf(filestream, 'other7   other8   other9\n');

% Set blank fields
names = fieldnames(Segment);
fullnames = {'name', 'lon1', 'lat1', 'lon2', 'lat2', 'lDep', 'lDepSig', 'lDepTog', 'dip', 'dipSig', 'dipTog' 'ssRate', 'ssRateSig', 'ssRateTog', 'dsRate', 'dsRateSig', 'dsRateTog', 'tsRate', 'tsRateSig', 'tsRateTog', 'bDep', 'bDepSig', 'bDepTog', 'res', 'resOver', 'resOther', 'patchFile', 'patchTog', 'other3', 'patchSlipFile', 'patchSlipTog', 'other6', 'rake', 'rakeSig', 'rakeTog', 'other7', 'other8', 'other9'};
diffnames = setdiff(fullnames, names);
for i = 1:length(diffnames)
   Segment = setfield(Segment, diffnames{i}, zeros(size(Segment.lon1)));
end

for cnt = 1 : numel(Segment.lon1)
   fprintf(filestream, '%s\n', Segment.name(cnt, :));
   fprintf(filestream, '%3.6f   %3.6f   %3.6f  %3.6f\n',   Segment.lon1(cnt),          Segment.lat1(cnt),         Segment.lon2(cnt),        Segment.lat2(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.lDep(cnt),          Segment.lDepSig(cnt),      Segment.lDepTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.dip(cnt),           Segment.dipSig(cnt),       Segment.dipTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.ssRate(cnt),        Segment.ssRateSig(cnt),    Segment.ssRateTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.dsRate(cnt),        Segment.dsRateSig(cnt),    Segment.dsRateTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.tsRate(cnt),        Segment.tsRateSig(cnt),    Segment.tsRateTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.bDep(cnt),          Segment.bDepSig(cnt),      Segment.bDepTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.res(cnt),           Segment.resOver(cnt),      Segment.resOther(cnt));   
   if isfield(Segment, 'patchFile')
      fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',        Segment.patchFile(cnt),     Segment.patchTog(cnt),     Segment.other3(cnt));
      fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',        Segment.patchSlipFile(cnt), Segment.patchSlipTog(cnt), Segment.other6(cnt));
   else
      fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',        Segment.other1(cnt),        Segment.other2(cnt),       Segment.other3(cnt));
      fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',        Segment.other4(cnt),        Segment.other5(cnt),       Segment.other6(cnt));
   end
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.rake(cnt),        Segment.rakeSig(cnt),       Segment.rakeTog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n',           Segment.other7(cnt),       Segment.other8(cnt),      Segment.other9(cnt));
end

%%  Close file
fclose(filestream);
