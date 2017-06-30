function [c, v, slip] = PatchData(filename)
% PatchData reads slip data written by WritePatches.  
%
% [C, V, S] = PatchData reads the element coordinates into an n-by-3 array C,
%				  the vertex connections into an m-by-3 (or 4) array V, and the slip rates
%				  into an m-by-10 array with columns:
%				  [strike-slip | dip-slip | tensile-slip | strike unc. | dip unc. | tens unc. | strike | block strike-slip | block dip-slip | block tensile-slip]
%
% The data can then be plotted using MESHVIEW(C, V, S(:, [1..6], ...)

    in = opentxt(filename);
    ncol = size(in, 2);
    if ncol > 1
        nc = str2double(in(1, :));
        c = str2num_fast(in(2:1+nc, :), 3);
        %ne = str2num(in(1+nc, :));
        numCols = numel(str2num_fast(in(3+nc, :)));
        data = str2num_fast(in(3+nc:end, :), numCols);
        if numCols == 13
            [v, slip] = deal(data(:, 1:3), data(:, 4:size(data, 2)));
        elseif numCols == 14
            [v, slip] = deal(data(:, 1:4), data(:, 4:size(data, 2)));
        else
            [v, slip] = deal([]);
        end
    else
        [c, v, slip] = deal([]);
    end
end
