% str2num_fast - faster alternative to str2num
%
% data = str2num_fast(str, numCols)
function data = str2num_fast(str, numCols)
    try
        % This is much faster:
        str = char(str);
        str(:,end+1) = ' ';
        data = sscanf(str','%f');
        if nargin>1 && ~isempty(numCols)
            data = reshape(data,numCols,[])';  % much faster
        end
    catch
        % This is much slower...
        data = str2num(str);
    end
end
