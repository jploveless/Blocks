function seg2table(seg, tex, varargin)
% SEG2TABLE  Writes segment structure information a LaTeX table.
%   SEG2TABLE(SEG, TEX) writes the segment data contained in the structure
%   or .segment file SEG to the LaTeX code in file TEX.  By default, the 
%   following fields of SEG are written:
%
%   number, lon1, lat1, lon2, lat2, Locking depth, Dip, ...
%   Strike slip rate +/- std., Dip slip rate +/- std., Tensile slip rate +/- std.
%
%   SEG2TABLE(SEG, TEX, FIELDS) allows specification of valid segment field names
%   *not* to be written to the table, using the cell array of strings FIELDS.  In addition
%   to the fields contained in the segment structure, valid additional field names 
%   are 'length' (in km) and 'strike', which will be calculated if they are to be output.
%
%   SEG2TABLE(SEG, TEX, APPEND) where APPEND is a string, will append the data in 
%   structure SEG to the file TEX, with a header of APPEND.  This could be useful
%   in writing particular faults that are not named obviously.  For example, a 
%   subset of segments may be selected and their indices found, then a temporary
%   structure could be constructed using STRUCTSUBSET and then written to the table.
%   For example, if the Imperial Fault is comprised of segments idx = [1:10, 32, 104],
%   use the workflow:
%   >> temp = structsubset(seg, idx);
%   >> seg2table(temp, 'table.tex', 'Imperial');
%
%   The resulting output will be:
%   Imperial & & & & & & & & & & \\
%   1 & 244.253 & 33.504 & 244.271 & 33.476 & 2 & 90 & -23.8$\pm$0.2 & -- & 0.6$pm$0.3 \\
%   .
%   .
%   .
%   12 & ...
%
%   SEG2TABLE(SEG, TEX, FIELDS, APPEND) allows specification of a subset of field names
%   and an appended fault name.
% 
%   OUT = SEG2TABLE(...) returns the actual data to the array OUT, which contains the 
%   slip rate uncertainties as columns.
%

% Check to see if we need to load the segment file
if ischar(seg)
   seg = ReadSegmentTri(seg);
end

dfields = {'lon1', 'lat1', 'lon2', 'lat2', 'length', 'lDep', 'strike', 'dip', 'ssRate', 'ssRateSig', 'dsRate', 'dsRateSig', 'tsRate', 'tsRateSig'};
forma   = {' & %.3f', ' & %.3f', ' & %.3f', ' & %.3f', ' & %.3f', ' & %.1f', ' & %.1f' ' & %.0f' ' & %.1f', '$\\pm$%.1f', ' & %.1f', '$\\pm$%.1f', ' & %.1f', '$\\pm$%.1f'};

% Check optional inputs
if nargin == 3
   if iscell(varargin{:})
      fields = varargin{:};
      append = 0;
   else
      if isfield(seg, varargin{:})
         fields = varargin{:};
         append = 0;
      else
         append = varargin{:};
         fields = [];
      end
   end
elseif nargin == 4
   if iscell(varargin{1})
      fields = varargin{1};
      append = varargin{2};
   else
      if isfield(seg, varargin{1})
         fields = varargin{1};
         append = varargin{2};
      else
         fields = varargin{2};
         append = varargin{1};
      end
   end
else
   fields = [];
   append = 0;
end

% Remove any ignored fields...
[fields, i] = setdiff(dfields, fields);
fields = dfields(sort(i));
% ...and their formatting strings
forma = strcat(forma{sort(i)}); if forma(1:3) == ' & ', forma(1:3) = []; forma = ['%d & ' forma]; end

% Check to see if any of the optional fields need to be calculated
if sum(ismember(fields, 'length')) == 1
    [leng, strike] = distance(seg.lat1, seg.lon1, seg.lat2, seg.lon2, almanac('earth', 'wgs84'));
    seg = setfield(seg, 'length', leng);
    seg = setfield(seg, 'strike', strike);
end

out = zeros(length(fields) + 1, length(seg.lon1));
out(1, :) = 1:length(seg.lon1);

% Prepare data for writing
for i = 1:length(fields)
   out(i+1, :) = getfield(seg, fields{i})';
end


% Write the text file
if append
   fid = fopen(tex, 'a');
   fprintf(fid, '\\multicolumn{%g}{l}{%s}\\\\ \n\\hline\n', length(fields)-2, append);
else
   fid = fopen(tex, 'w');
end

fprintf(fid, [forma '\\\\ \n'], out);

fclose(fid);