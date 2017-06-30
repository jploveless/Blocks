function ns = structmath(s1, s2, op)
% STRUCTMATH  Carries out simple operations on structures.
%   NS = STRUCTMATH(S1, S2, OPERATION) carries out simple math operations
%   on structures S1 and S2.  Fields of common name and size will be related
%   using OPERATION, which can be any number of operations that acts column-
%   wise on an array, such as PLUS, MINUS, MTIMES, LDIVIDE, RDIVIDE, POWER.
%   OPERATION should be given as a string.  For example, to add the fields
%   of common name and size in structures S1 and S2 and return the results
%   to new structure NS, use NS = structmath(S1, S2, 'plus').
%
%   S2 can be a scalar, which can be used with selected operations, for 
%   example, added to each field.
%

% Make sure operation is a real operation
w = which(op);
if isempty(w)
   return
end

% If both arguments are structures
if isstruct(s2)
   % Check for common fields
   fn1 = fieldnames(s1);
   fn2 = fieldnames(s2);
   [junk, cf1] = ismember(fn2, fn1);
   [junk, cf2] = ismember(fn1, fn2);
   cf1 = cf1(find(cf1));
   cf2 = cf2(find(cf2));
   cfn = length(cf1);
   cf2 = sort(cf2);

   % Loop through fields, checking for common size
   for i = 1:cfn
      f1 = getfield(s1, fn1{cf1(i)});
      f2 = getfield(s2, fn2{cf2(i)});
      %if isequal(size(f1), size(f2))
         nf = eval(sprintf('%s(f1, f2)', op));
         eval(sprintf('ns.%s = nf;', fn1{cf1(i)}));
      %end
   end
else
   fn1 = fieldnames(s1);
   % Loop through fields, checking for common size
   for i = 1:length(fn1)
      f1 = getfield(s1, fn1{i});
         nf = eval(sprintf('%s(f1, s2)', op));
         eval(sprintf('ns.%s = nf;', fn1{i}));
      %end
   end
end