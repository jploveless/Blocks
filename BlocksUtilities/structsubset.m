function sn = structsubset(s, idx, except)
% STRUCTSUBSET   Returns a subset of the segment structure
%    SNEW = STRUCTSUBSET(S, I) returns a subset of structure S, assuming
%    that each field of S is an n-by-1 array.  The subset is identified 
%    by the vector I containing the indices of the desired field entries.
%    

f = fieldnames(s);
if ~exist('except', 'var')
   except = {};
end   
f = setdiff(f, except);
sn = s;
for i = 1:length(f)
   d = getfield(s, f{i});
   if iscell(d)
      d = d{idx};
   else
      d = d(idx, :);
   end
   sn = setfield(sn, f{i}, d);
end