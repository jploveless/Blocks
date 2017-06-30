function WriteSegment(segfilename, faultname, fault_lon1, fault_lat1, fault_lon2, fault_lat2, ...
                               fault_ldep, fault_ldep_sig, fault_ldep_tog, fault_dip, fault_dip_sig, fault_dip_tog, ...
                               fault_ssrate, fault_ssrate_sig, fault_ssrate_tog, fault_dsrate, fault_dsrate_sig, fault_dsrate_tog, ...
                               fault_tsrate, fault_tsrate_sig, fault_tsrate_tog, fault_bdep, fault_bdep_sig, fault_bdep_tog, ...
			       fault_lres, fault_lres_ov, fault_lres_other, ...
			       fault_other1, fault_other2, fault_other3, ...
			       fault_other4, fault_other5, fault_other6, ...
			       fault_other7, fault_other8, fault_other9, ...
			       fault_other10, fault_other11, fault_other12)
% This script writes a *.segment file with the slip rates
% passed and fault geometry.
%
% Arguments:
%   segfilename       : name of file to write to.  We can't use
%                       basefilename.block because that already
%                       exists and is useful.
%   faultname         : a matrix of the fault name characters
%   fault_lon1        : longitude of fault endpoint one
%   fault_lat1        : latitude of fault endpoint one
%   fault_lon2        : longitude of fault endpoint two
%   fault_lat2        : latitude of fault endpoint two
%   fault_ldep        : fault locking depth
%   fault_ldep_sig    : fault locking depth sigma
%   fault_ldep_tog    : fault locking depth toggle
%   fault_dip         : fault dip
%   fault_dip_sig     : fault dip sigma
%   fault_dip_tog     : fault dip toggle
%   fault_ssrate      : fault strike slip rate
%   fault_ssrate_sig  : fault strike slip rate sigma
%   fault_ssrate_tog  : fault strike slip rate toggle
%   fault_dsrate      : fault dip slip rate 
%   fault_dsrate_sig  : fault dip slip rate sigma 
%   fault_dsrate_tog  : fault dip slip rate toggle 
%   fault_tsrate      : fault tensile slip rate 
%   fault_tsrate_sig  : fault tensile slip rate sigma 
%   fault_tsrate_tog  : fault tensile slip rate toggle
%   fault_bdep        : fault locking depth 
%   fault_bdep_sig    : fault locking depth sigma 
%   fault_bdep_tog    : fault locking depth toggle


% Open file stream
filestream                          = fopen(segfilename, 'w');

% Write header
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

% Loop over blocks and write to file
for cnt = 1 : numel(fault_lon1)
   fprintf(filestream, '%s\n', faultname(cnt, :));
   fprintf(filestream, '%3.3f   %3.3f   %3.3f  %3.3f\n', fault_lon1(cnt), fault_lat1(cnt), fault_lon2(cnt), fault_lat2(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_ldep(cnt), fault_ldep_sig(cnt), fault_ldep_tog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_dip(cnt), fault_dip_sig(cnt), fault_dip_tog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_ssrate(cnt), fault_ssrate_sig(cnt), fault_ssrate_tog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_dsrate(cnt), fault_dsrate_sig(cnt), fault_dsrate_tog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_tsrate(cnt), fault_tsrate_sig(cnt), fault_tsrate_tog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_bdep(cnt), fault_bdep_sig(cnt), fault_bdep_tog(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_lres(cnt), fault_lres_ov(cnt), fault_lres_other(cnt));   
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_other1(cnt), fault_other2(cnt), fault_other3(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_other4(cnt), fault_other5(cnt), fault_other6(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_other7(cnt), fault_other8(cnt), fault_other9(cnt));
   fprintf(filestream, '%3.1f   %3.1f  %3.1f\n', fault_other10(cnt), fault_other11(cnt), fault_other12(cnt));
end
fclose(filestream);
