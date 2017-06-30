function [slipest, omegaEst, G] = TestNoiseEstimation(x, G, u, sig)
%

nx = length(x); % number of stations

% Augment G for noise estimation
G = [G eye(nx)];

% Make data covariance matrix
wd = 1./sig.^2;
%wd = sig.^2;
%wd = ones(nx, 1);
Wd = diag(wd);

% Make model covariance matrix
%slipSig = mean(sig./abs(G(:, 1)));
noiseSig = 1;
slipSig = 1;
%slipSig = noiseSig*1./mean((G(:, 1).^2)) % Scale slip weighting so that the strength of the model parameter partials are pretty similar for each station
%sigRatio = slipSig./noiseSig;
%slipSig = slipSig*sigRatio;
%wm = [1; noiseSig.*1./sig];
%wm = [slipSig; noiseSig.*1./sig.^2];
%wm = [slipSig; noiseSig.*sig];
%slipNoiseRatio = abs(G(:, 1));
%wm = [slipSig; noiseSig.*slipNoiseRatio];
wm = [slipSig; noiseSig.*ones(nx, 1)];
Wm = diag(wm);

%taurange = 10.^[-2:.1:2];
%etarange = 0;
%[L, mlik] = maxlike2d(taurange, etarange, 1, G, Wd, Wm, u);
%[~, midx] = min(-L);
%tauopt = taurange(midx);
%keyboard
%taurange = tauopt;
%etarange = 10.^[-2:.1:2];
%etaopt = cdfmatch(taurange, etarange, 1, G, Wd, Wm, u, sig);
taurange = 10.^[-3:.1:4];
etarange = 10.^[-3:.1:4];
[tauopt, etaopt] = optparams(taurange, etarange, 1, G, Wd, Wm, u, sig);


keyboard
%taurange = 1;
%etarange = 10.^[-2:.1:2];
%[L, mlik] = maxlike2d(taurange, etarange, 1, G, Wd, Wm, u);
%[~, midx] = min(-L);
%etaopt = etarange(midx);
%keyboard
%taurange = 10.^[-2:.1:2];
%etarange = etaopt;
%[L, mlik] = maxlike2d(taurange, etarange, 1, G, Wd, Wm, u);
%[~, midx] = min(-L);
%tauopt = taurange(midx);
%keyboard
%taurange = 10.^[-2:.1:2];
%etarange = 10.^[-2:.1:2];
%[L, mlik] = maxlike2d(taurange, etarange, 1, G, Wd, Wm, u);
%%[~, midx] = min(-L);
%%tauopt = taurange(midx);
%keyboard

tauopt
etaopt

%wm = [tauopt; etaopt.*sig];
%wm = [tauopt; etaopt*slipNoiseRatio];
wm = [tauopt; etaopt*ones(nx, 1)];
Wm = diag(wm);

% Max. likelihood inversion
inv1 = (Wd + G*Wm*G')\eye(size(G, 1));
omegaEst = Wm*G'*inv1*u;
res = u - G*omegaEst;
mlik = 1./length(res)*res'*inv1*res
%logdet = sum(log(diag(chol(Wd + G*Wm*G'))));
logdet = log(det(Wd + G*Wm*G'));
loglik = -0.5*(length(res) - length(res)*log(length(res))) - 0.5*logdet - 0.5*length(res)*log(res'*inv1*res);
toler = abs(mlik - 1);


%figure; hold on
%% Set up recursion for maximum likelihood scaling of model covariance
%niter = 1;
%maxiter = 1e6;
%while toler > 1e-6 & niter <= maxiter
%   noiseSig = noiseSig*mlik;
%   slipSig = slipSig*mlik;
%   wm(1) = slipSig;
%   wm(2:end) = noiseSig*sig.^2;
%%   wm(2:end) = noiseSig*1./sig.^2;
%   Wm = diag(wm);
%%   Wd = diag(noiseSig*(1./sig.^2));
%   inv1 = (Wd + G*Wm*G')\eye(size(G, 1));
%   omegaEst = Wm*G'*inv1*u;
%   omegaEst(1)
%   res = u - G*omegaEst;
%   mlik = 1./length(res)*res'*inv1*res;
%%   logdet = sum(log(diag(chol(Wd + G*Wm*G'))));
%   logdet = log(det(Wd + G*Wm*G'));
%   loglik = -0.5*(length(res) - length(res)*log(length(res))) - 0.5*logdet - 0.5*length(res)*log(res'*inv1*res);
%   toler = abs(mlik - 1);
%   plot(niter, noiseSig, '.r'); plot(niter, slipSig, '.'); plot(niter, mlik, 'g.')
%   niter = niter + 1;
%end

%while abs(mlik) > 1e-4 & niter <= maxiter
%   slipSig = slipSig + slipSig*mlik;
%   noiseSig = noiseSig + noiseSig*mlik;
%%   slipSig = (slipSig + slipSig/mlik)/noiseSig;
%   wm(1) = slipSig;
%%   wm(2:end) = noiseSig*sig.^2;
%   wm(2:end) = noiseSig*1./sig.^2;
%   Wm = diag(wm);
%%   Wd = diag(noiseSig*(1./sig.^2));
%   inv1 = (Wd + G*Wm*G')\eye(size(G, 1));
%   omegaEst = Wm*G'*inv1*u;
%   res = u - G*omegaEst;
%   mlik = 1./length(res)*res'*inv1*res;
%   logdet = log(det(Wd + G*Wm*G'));
%   loglik = -0.5*(length(res) - length(res)*log(length(res))) - 0.5*logdet - 0.5*length(res)*log(res'*inv1*res);
%   toler = abs(mlik - 1);
%   plot(niter, noiseSig, '.r'); plot(niter, slipSig, '.'); plot(niter, mlik, 'g.')
%   niter = niter + 1;
%end
%niter

model = G*omegaEst;
slipest(1) = omegaEst(1);
modelClean = G(:, 1)*slipest(1);


% Regular weighted least squares overdetermined case
slipest(2) = inv(G(:, 1)'*diag(wd)*G(:, 1))*G(:, 1)'*diag(wd)*u;
%slipest(2) = inv(G(:, 1)'*diag(1./sig.^2)*G(:, 1))*G(:, 1)'*diag(1./sig.^2)*u;

figure
[xs, si] = sort(x);
%plot(xs, G(si, 1)*10, 'k');
hold on
plot(x, u, '.');
plot(x, G(:, 1)*slipest(2), '*c');
plot(x, modelClean, '+k');
plot(x, model, 'or');

pred = G*omegaEst;
res = u - pred;
noiseest = pred - G(:, 1)*slipest(1);
[res noiseest res./noiseest]

keyboard

