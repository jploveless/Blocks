N = 20;
D = 20;
W = 20;
sigma = 0.1;
alpha = 20; % width of geodetic array aperture

% Iterate over many realizations of noise
NN = 1000;
s1 = zeros(NN, 1);
s2 = zeros(NN, 1);
s1u = zeros(NN, 1);
s2u = zeros(NN, 1);
s1c = zeros(NN, 1);
s2c = zeros(NN, 1);
s1uc = zeros(NN, 1);
s2uc = zeros(NN, 1);

s1True = 0.75;
s2True = 1.25;
% s1True = 1.0;
% s2True = 1.0;


epsilon = 1e-2;
for i = 1:NN
   % Realize synthetic observed velocities
%    x = (rand(N,1)*200)-100;
   x = (rand(N,1)*alpha)-alpha/2;

   v1 = s1True/pi.*atan((x-W/2)./D);
   v2 = s1True/pi.*atan((x+W/2)./D);
   v3 = v1+v2;
   v3n = v3 + sigma.*randn(size(v3));
      
   % Over determined case
   G = [v1(:)./s1True v2(:)./s2True];
   mest = inv(G'*G)*G'*v3n(:);
   s1(i) = mest(1);
   s2(i) = mest(2);
   
   % Over determined case with far-field constraint
   G = [v1(:)./s1True v2(:)./s2True];
   G = [G ; 1 1];
   mest = inv(G'*G)*G'*[v3n(:) ; s1True+s2True];
   s1c(i) = mest(1);
   s2c(i) = mest(2);
   
   % Underdetermined case
   G2 = [v1(:)./s1True v2(:)./s2True epsilon.*eye(numel(v1))];
   mest = G2'*inv(G2*G2')*v3n(:);
   s1u(i) = mest(1);
   s2u(i) = mest(2);
   
   % Underdetermined case with far-filed constraint and noise on far-field constraint
   G2 = [v1(:)./s1True v2(:)./s2True epsilon.*eye(numel(v1))];
   G2 = [G2 ; 1 1 zeros(1, N)]; 
   G2 = [G2 zeros(N+1, 1)];
   G2(end,end) = epsilon*1;
   mest = G2'*inv(G2*G2')*[v3n(:) ; s1True+s2True];
   s1uc(i) = mest(1);
   s2uc(i) = mest(2);
end

figure; hold on;

line([0 1; 1 1], [1 1; 1 0], 'linestyle', '--', 'color', 0.5*[1 1 1]) % Plot true slip rates
%k = convhull(s1u, s2u);
%plot(s1u(k), s2u(k), 'b-');
%k = convhull(s1uc, s2uc);
%plot(s1uc(k), s2uc(k), 'g-');
k = convhull(s1, s2);
hl = plot(s1(k)./s1True, s2(k)./s2True, 'r-');
k = convhull(s1c, s2c);
hlc = plot(s1c(k)./s1True, s2c(k)./s2True, 'k-');

set(gca, 'XLim', [0 3]);
set(gca, 'YLim', [0 3]);
set(gca, 'XTick', [0 1 2 3]);
set(gca, 'YTick', [0 1 2 3]);
xlabel('s_1^{est}/s_1');
ylabel('s_2^{est}/s_2');
sigma./(s1True+s2True)
title(sprintf('\\alpha/d = %3.1f, \\deltax/d = %3.1f, N = %d, \\sigma/(s_1+s_2) = %4.2f', alpha/D, W/D, N, sigma./(s1True+s2True)));
%lh = legend('underdetermined', 'underdetermined + con', 'overdetermined', 'overdetermined + con', 'location', 'southeast');
lh = legend([hl, hlc], 'Without far-field constraint', 'With far-field constraint', 'location', 'southeast');
set(lh, 'fontsize', 10);
legend boxoff

axes('position', [0.34 0.70 0.55 0.2]); hold on;
fs = 10;
xlabel('x/D', 'FontSize', fs);
ylabel('v/v_0', 'FontSize', fs);
xplot = linspace(-100, 100, 1000);
v1plot = s1True./pi.*atan((xplot-W/2)./D);
v2plot = s2True./pi.*atan((xplot+W/2)./D);
v3plot = v1plot+v2plot;
v3nplot = v3plot + sigma.*randn(size(v3plot));
plot(xplot./D, v3nplot, 'ok', 'MarkerFaceColor', 0.00*[1 1 1], 'MarkerEdgeColor', 'none', 'MarkerSize', 1);
plot(xplot./D, v1plot, '-r');
plot(xplot./D, v2plot, '-b');
plot(xplot./D, v1plot+v2plot, '-k');
set(gca, 'YLim', [-1 1]);
set(gca, 'YTick', [-1 0 1]);
set(gca, 'FontSize', fs)


% figure; hold on;
ax = axes('position', [0.58 0.38 0.3 0.21]); hold on;
fs = 10;
x = linspace(-0.5, 0.5, 20);
%y = s2u-s2True;
%y(y<min(x)) = [];
%y(y>max(x)) = [];
%n2u = hist(y, x);
%
%y = s2uc-s2True;
%y(y<min(x)) = [];
%y(y>max(x)) = [];
%n2uc = hist(y, x);

y = s2-s2True;
y(y<min(x)) = [];
y(y>max(x)) = [];
n2 = hist(y, x);

y = s2c-s2True;
y(y<min(x)) = [];
y(y>max(x)) = [];
n2c = hist(y, x);

%stairs(x, n2u, '-b');
%stairs(x, n2uc, '-g');
stairs(x, n2/NN, '-r');
stairs(x, n2c/NN, '-k');
set(gca, 'FontSize', fs);
xlabel('residual', 'FontSize', fs);
ylabel('N', 'FontSize', fs);
