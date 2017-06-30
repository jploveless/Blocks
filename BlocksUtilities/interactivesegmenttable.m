function seg = interactivesegmenttable(outdir, fign, del)
%INTERACTIVESEGMENTTABLE  Interactively writes segment data.
%   INTERACTIVESEGMENTTABLE(OUTDIR) uses the Mod.segment file in OUTDIR
%   as the basis for interactively writing a table of segment data.  
%   The segment geometry is drawn in a new window, and the user is prompted
%   for the name of the fault whose segments will be selected and whose data
%   will be written to a temporary file (with the entered name).  When "DONE"
%   is entered for the fault name, no more segments can be selected, and the
%   written data tables will be concatenated into a file named "FAULT.DATA" 
%   within OUTDIR.  Best performance results when no plotting tools (i.e., 
%   zoom, pan, etc.) are active when a fault name is entered.
%
%   INTERACTIVESEGMENTTABLE(OUTDIR, FIGN), where FIGN is an integer, runs
%   the function using the plot window FIGN, which may already exist, rather
%   than simply creating a new window.

%   INTERACTIVESEGMENTTABLE(OUTDIR, DEL), where DEL = 1, will delete the 
%   temporary files written for each fault, leaving only the concatenated 
%   file.  The default behavior is DEL = 0, that is, temporary files will
%   not be deleted.
%

% Load the segment file
seg = ReadSegmentTri([outdir filesep 'Mod.segment']);
newnames = repmat('0', size(seg.name));

% Check figure option
if ~exist('fign', 'var')
   fign = 1;
end

dfields = {'lon1', 'lat1', 'lon2', 'lat2', 'length', 'lDep', 'strike', 'dip', 'ssRate', 'ssRateSig', 'dsRate', 'dsRateSig', 'tsRate', 'tsRateSig'};
forma   = '%d %.3f %.3f %.3f %.3f %.3f %.1f %.1f %.0f %.1f %.1f %.1f %.1f %.1f %.1f\n';
[leng, strike] = distance(seg.lat1, seg.lon1, seg.lat2, seg.lon2, almanac('earth', 'wgs84'));
seg = setfield(seg, 'length', leng);
seg = setfield(seg, 'strike', strike);


% Plot the segment file
figure(fign)
if isempty(get(gca, 'children'))
   h = line([seg.lon1'; seg.lon2'], [seg.lat1'; seg.lat2'], 'color', 0.75*[1 1 1]); hold on
   % Plot segment centroid; this is what is actually selected
   sc = plot((seg.lon1 + seg.lon2)./2, (seg.lat1 + seg.lat2)./2, '.', 'markersize', 1);
else
   h = [findobj(gca, 'color', 0.75*[1 1 1]); findobj(gca, 'color', 'r')]; hold on
end

% While loop controls everything
fname = input('Fault name? ', 's');
while isempty(strmatch(lower(fname), 'done'))
   sel = selectdata('ignore', h);
   temp = structsubset(seg, sel);
   temp = OrderEndpoints(temp);
   tempo = ordersegs(temp); 
   temp = structsubset(temp, tempo);
   tname = [repmat([fname ' '], length(sel), 1) num2str([1:length(sel)]')];
   newnames(sel, 1:size(tname, 2)) = tname;
   set(h(sel), 'color', 'r');
   out = zeros(length(dfields) + 1, length(temp.lon1));
   out(1, :) = 1:length(temp.lon1);
   
   % Prepare data for writing
   for i = 1:length(dfields)
      out(i+1, :) = getfield(temp, dfields{i})';
   end
   
   % Write the text file
   fid = fopen([outdir filesep fname], 'w');
   fprintf(fid, '%s\n', fname);
   fprintf(fid, forma, out);
   fclose(fid);
   fname = input('Fault name? ', 's');
end

seg = setfield(seg, 'name', newnames);
   
   