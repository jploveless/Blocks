function [fault_ldep] = LockingDepthManager(fault_ldep, fault_ldep_sig, fault_ldep_tog, fault_name, command_ld_tog_2, command_ld_tog_3, command_ld_tog_4, command_ld_tog_5, ldOvTog, ldOvVal);
% LockingDepthManager.m
%
% This function assigns the locking depths given in the command file to any
% segment that has the same locking depth toggle.  Segments with toggle =
% 0, 1 are untouched.

filestream = 0;
% fprintf(filestream, '\nDone assigning new locking depths  -->\n');

% Find the indices for each of the toggles
toggle_2_idx                                      = find(fault_ldep_tog == 2);
toggle_3_idx                                      = find(fault_ldep_tog == 3);
toggle_4_idx                                      = find(fault_ldep_tog == 4);
toggle_5_idx                                      = find(fault_ldep_tog == 5);

% Announce the names of the faults we're changing the locking depths on
for cnt = 1 : numel(toggle_2_idx)
%    fprintf(filestream, '%s has been assigned a %3.2f [km] locking depth\n', fault_name(toggle_2_idx(cnt), :), command_ld_tog_2);
end

for cnt = 1 : numel(toggle_3_idx)
%    fprintf(filestream, '%s has been assigned a %3.2f [km] locking depth\n', fault_name(toggle_3_idx(cnt), :), command_ld_tog_3);
end

for cnt = 1 : numel(toggle_4_idx)
%    fprintf(filestream, '%s has been assigned a %3.2f [km] locking depth\n', fault_name(toggle_4_idx(cnt), :), command_ld_tog_4);
end

for cnt = 1 : numel(toggle_5_idx)
%    fprintf(filestream, '%s has been assigned a %3.2f [km] locking depth\n', fault_name(toggle_5_idx(cnt), :), command_ld_tog_5);
end

% Assign the locking depths from the command file
fault_ldep(toggle_2_idx)                          = command_ld_tog_2;
fault_ldep(toggle_3_idx)                          = command_ld_tog_3;
fault_ldep(toggle_4_idx)                          = command_ld_tog_4;
fault_ldep(toggle_5_idx)                          = command_ld_tog_5;

if strmatch(ldOvTog, 'yes')
   fault_ldep(:)                                  = ldOvVal;
end

% Announce the finish
% fprintf(filestream, '<--  Done assigning new locking depths\n');
