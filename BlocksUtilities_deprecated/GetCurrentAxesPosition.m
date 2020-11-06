function [x, y] = GetCurrentAxesPosition
    %%  GetCurrentAxesPosition
    %%  Returns pointer position on current axes in map units
    %%  Authors: David Liebowitz, Seeing Machines
    %%           Tom Herring, MIT
    %%  Fixed by Yair Altman, May 2015

    %% Get the current figure and axes
    hFig = gcf;
    hAxes = get(gcf,'CurrentAxes');  %faster than gca

    %% Get dimension information
    figsize = getpixelposition(hFig);
    axesize = getpixelposition(hAxes, true);
    asprat  = get(hAxes, 'DataAspectRatio');
    xlimits = get(hAxes, 'Xlim');
    ylimits = get(hAxes, 'Ylim');
    dx = diff(xlimits);
    dy = diff(ylimits);

    %%  Based on the aspect ratio, find the actual coordinates covered by axesize
    ratio = (1/asprat(2)) * (dy / dx) * (axesize(3) / axesize(4));
    if ratio < 1   % Longitude covers the full pixel X range
        xoff = figsize(1) + axesize(1);
        xscl = dx / axesize(3);
        dyht = axesize(4) * (1 - ratio) / 2;  % offset of Y-axes margin due to the aspect
        yoff = figsize(2) + axesize(2) + dyht;
        yscl = dy / (axesize(4) * ratio);
    else   % Latitude covers the full pixel Y range
        dxwd = axesize(3) * (1 - 1/ratio) / 2;  % offset of X-axes margin due to the aspect
        xoff = figsize(1) + axesize(1) + dxwd;
        xscl = dx / (axesize(3) / ratio);
        yoff = figsize(2) + axesize(2);
        yscl = dy / axesize(4);
    end

    %%  Get the pointer's screen position in pixels
    pix = get(0, 'PointerLocation');

    % Return the x,y coordinates in map (not pixel) units
    x = (pix(1) - xoff) * xscl + xlimits(1);
    y = (pix(2) - yoff) * yscl + ylimits(1);
