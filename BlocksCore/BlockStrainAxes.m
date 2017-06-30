function [e1, e2] = BlockStrainAxes(arg1, fig, c1, c2, varargin)
% BlockStrainAxes uses the information in a Strain.block file to plot
% the principal strain axes at the block's centroid coordinates.
%
% BlockStrainAxes(blockFile, FIG, C1, C2) reads the blocks structure out of the
% Strain.block file and plots the strain axes into the figure specified by FIG.
% FIG can either be an integer specifying a figure number, or an axes handle.
% C1 and C2 specify the colors of the positive and negative axes, respectively,
% and can be any acceptable Matlab color.
%
% BlockStrainAxes(Block,...) accepts a pre-loaded Block structure as its first input.

    % Parse the input
    if ischar(arg1)
        Block = ReadBlock(arg1);
        nBlocks = length(Block.interiorLon);
    else
        Block = arg1;
    end

    % get centroid coordinates (stored in Euler coordinate locations of Strain.block)
    x = Block.eulerLon;
    y = Block.eulerLat;

    nzind = find(x);
    x = x(nzind);
    y = y(nzind);

    % calculate the principal strains

    % direction
    theta1 = 0.5*atan2(2*Block.other2(nzind), (Block.other1(nzind) - Block.other3(nzind)));
    theta2 = theta1 - pi/2;

    % magnitude
    e1 = 0.5*(Block.other1(nzind) + Block.other3(nzind)) + ...
        sqrt(Block.other2(nzind).^2 + 0.25*(Block.other1(nzind) - Block.other3(nzind)).^2);
    e2 = 0.5*(Block.other1(nzind) + Block.other3(nzind)) - ...
        sqrt(Block.other2(nzind).^2 + 0.25*(Block.other1(nzind) - Block.other3(nzind)).^2);

    % set scale for plotting
    sc = 1e6;

    % convert direction and magnitude into axis coordinates
    p11 = sc*abs(e1).*cos(theta1);
    p21 = sc*abs(e1).*sin(theta1);
    p12 = sc*abs(e2).*cos(theta2);
    p22 = sc*abs(e2).*sin(theta2);

    % determine sign of each strain value, for coloring
    sign1 = sign(e1);
    sign2 = sign(e2);

    p1 = find(sign1 >= 0);
    p2 = find(sign2 >= 0);
    n1 = find(sign1 < 0);
    n2 = find(sign2 < 0);

    % determine where the axes will be plotted
    if round(double(fig)) == fig || isa(fig,'matlab.ui.Figure')  % Fix for HG2 (R2014b+)
        figure(fig);
        a = gca;
    else
        a = fig;
    end

    % plot
    hold on
    quiver(a, x(p1), y(p1),  p11(p1),  p21(p1), 0, 'showarrowhead', 'off', 'color', c1, varargin{:});
    quiver(a, x(p1) ,y(p1), -p11(p1), -p21(p1), 0, 'showarrowhead', 'off', 'color', c1, varargin{:});
    quiver(a, x(p2), y(p2),  p12(p2),  p22(p2), 0, 'showarrowhead', 'off', 'color', c1, varargin{:});
    quiver(a, x(p2), y(p2), -p12(p2), -p22(p2), 0, 'showarrowhead', 'off', 'color', c1, varargin{:});
    quiver(a, x(n1), y(n1),  p11(n1),  p21(n1), 0, 'showarrowhead', 'off', 'color', c2, varargin{:});
    quiver(a, x(n1), y(n1), -p11(n1), -p21(n1), 0, 'showarrowhead', 'off', 'color', c2, varargin{:});
    quiver(a, x(n2), y(n2),  p12(n2),  p22(n2), 0, 'showarrowhead', 'off', 'color', c2, varargin{:});
    quiver(a, x(n2), y(n2), -p12(n2), -p22(n2), 0, 'showarrowhead', 'off', 'color', c2, varargin{:});
