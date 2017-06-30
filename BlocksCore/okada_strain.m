function [xx, yy, zz, xy, xz, yz] = okada_strain(xf, yf, strike, c, delta, L, W, Us, Ud, Ut, xs, ys, z, Pr)

% All coordinates are coming in with respect to the fault origin, having been
% processed with fault_params_to_okada_form.m

% Variable equivalents with Brendan's dislocation code:
% c = d
% Us, Ud, Ut = U1, U2, U3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare constants and variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tol                = 1.0e-4;
alpha              = 1./(2 * Pr + 1);
sindel             = sin(delta);
cosdel             = cos(delta);
%if abs(cosdel) < 1e-15
%   cosdel = eps;
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Get station locations relative to fault anchor  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xt                 = xs - xf;
yt                 = ys - yf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Rotate station locations to remove strike  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alpha_rot          = -strike;
[x, y]             = rotate_xy_vec(xt, yt, alpha_rot);


% Dislocation solution
[fxAs,fxBs,fxCs,fyAs,fyBs,fyCs,fzAs,fzBs,fzCs,...
 fxAd,fxBd,fxCd,fyAd,fyBd,fyCd,fzAd,fzBd,fzCd,...
 fxAt,fxBt,fxCt,fyAt,fyBt,fyCt,fzAt,fzBt,fzCt]...
 = chinnery(x, y, z, c, L, W, cosdel, sindel, alpha, tol);


% Whole space solution, strains
[dxfxAs,dxfxBs,dxfxCs,dxfyAs,dxfyBs,dxfyCs,dxfzAs,dxfzBs,dxfzCs,...
 dxfxAd,dxfxBd,dxfxCd,dxfyAd,dxfyBd,dxfyCd,dxfzAd,dxfzBd,dxfzCd,...
 dxfxAt,dxfxBt,dxfxCt,dxfyAt,dxfyBt,dxfyCt,dxfzAt,dxfzBt,dxfzCt,...
 dyfxAs,dyfxBs,dyfxCs,dyfyAs,dyfyBs,dyfyCs,dyfzAs,dyfzBs,dyfzCs,...
 dyfxAd,dyfxBd,dyfxCd,dyfyAd,dyfyBd,dyfyCd,dyfzAd,dyfzBd,dyfzCd,...
 dyfxAt,dyfxBt,dyfxCt,dyfyAt,dyfyBt,dyfyCt,dyfzAt,dyfzBt,dyfzCt,...
 dzfxAs,dzfxBs,dzfxCs,dzfyAs,dzfyBs,dzfyCs,dzfzAs,dzfzBs,dzfzCs,...
 dzfxAd,dzfxBd,dzfxCd,dzfyAd,dzfyBd,dzfyCd,dzfzAd,dzfzBd,dzfzCd,...
 dzfxAt,dzfxBt,dzfxCt,dzfyAt,dzfyBt,dzfyCt,dzfzAt,dzfzBt,dzfzCt]...
 = chinnery_del(x, y, z, c, L, W, cosdel, sindel, alpha, tol);

% Image solution, strains
[dxfxAsn,dxfyAsn,dxfzAsn,...
 dxfxAdn,dxfyAdn,dxfzAdn,...
 dxfxAtn,dxfyAtn,dxfzAtn,...
 dyfxAsn,dyfyAsn,dyfzAsn,...
 dyfxAdn,dyfyAdn,dyfzAdn,...
 dyfxAtn,dyfyAtn,dyfzAtn,...
 dzfxAsn,dzfyAsn,dzfzAsn,...
 dzfxAdn,dzfyAdn,dzfzAdn,...
 dzfxAtn,dzfyAtn,dzfzAtn]...
 = chinnery_deln(x, y, -z, c, L, W, cosdel, sindel, alpha, tol);

%calculate strains w.r.t. x
xx = Us/(2*pi)*(dxfxAs - dxfxAsn + dxfxBs + z.*dxfxCs)...
   + Ud/(2*pi)*(dxfxAd - dxfxAdn + dxfxBd + z.*dxfxCd)...
   + Ut/(2*pi)*(dxfxAt - dxfxAtn + dxfxBt + z.*dxfxCt);
yx = Us/(2*pi)*(cosdel*(dxfyAs - dxfyAsn + dxfyBs + z.*dxfyCs)...
              - sindel*(dxfzAs - dxfzAsn + dxfzBs + z.*dxfzCs))...     
   + Ud/(2*pi)*(cosdel*(dxfyAd - dxfyAdn + dxfyBd + z.*dxfyCd)...
              - sindel*(dxfzAd - dxfzAdn + dxfzBd + z.*dxfzCd))...
   + Ut/(2*pi)*(cosdel*(dxfyAt - dxfyAtn + dxfyBt + z.*dxfyCt)...
              - sindel*(dxfzAt - dxfzAtn + dxfzBt + z.*dxfzCt));
zx = Us/(2*pi)*(sindel*(dxfyAs - dxfyAsn + dxfyBs - z.*dxfyCs)...
              + cosdel*(dxfzAs - dxfzAsn + dxfzBs - z.*dxfzCs))...
   + Ud/(2*pi)*(sindel*(dxfyAd - dxfyAdn + dxfyBd - z.*dxfyCd)...
              + cosdel*(dxfzAd - dxfzAdn + dxfzBd - z.*dxfzCd))...
   + Ut/(2*pi)*(sindel*(dxfyAt - dxfyAtn + dxfyBt - z.*dxfyCt)...
              + cosdel*(dxfzAt - dxfzAtn + dxfzBt - z.*dxfzCt));
       
%calculate strains w.r.t. y
xy = Us/(2*pi)*(dyfxAs - dyfxAsn + dyfxBs + z.*dyfxCs)...
   + Ud/(2*pi)*(dyfxAd - dyfxAdn + dyfxBd + z.*dyfxCd)...
   + Ut/(2*pi)*(dyfxAt - dyfxAtn + dyfxBt + z.*dyfxCt);
yy = Us/(2*pi)*(cosdel*(dyfyAs - dyfyAsn + dyfyBs + z.*dyfyCs)...
              - sindel*(dyfzAs - dyfzAsn + dyfzBs + z.*dyfzCs))...     
   + Ud/(2*pi)*(cosdel*(dyfyAd - dyfyAdn + dyfyBd + z.*dyfyCd)...
              - sindel*(dyfzAd - dyfzAdn + dyfzBd + z.*dyfzCd))...
   + Ut/(2*pi)*(cosdel*(dyfyAt - dyfyAtn + dyfyBt + z.*dyfyCt)...
              - sindel*(dyfzAt - dyfzAtn + dyfzBt + z.*dyfzCt));
zy = Us/(2*pi)*(sindel*(dyfyAs - dyfyAsn + dyfyBs - z.*dyfyCs)...
              + cosdel*(dyfzAs - dyfzAsn + dyfzBs - z.*dyfzCs))...
   + Ud/(2*pi)*(sindel*(dyfyAd - dyfyAdn + dyfyBd - z.*dyfyCd)...
              + cosdel*(dyfzAd - dyfzAdn + dyfzBd - z.*dyfzCd))...
   + Ut/(2*pi)*(sindel*(dyfyAt - dyfyAtn + dyfyBt - z.*dyfyCt)...
              + cosdel*(dyfzAt - dyfzAtn + dyfzBt - z.*dyfzCt));
        
%calculate strains w.r.t. z
xz = Us/(2*pi)*(dzfxAs + dzfxAsn + dzfxBs + fxCs + z.*dzfxCs)...
   + Ud/(2*pi)*(dzfxAd + dzfxAdn + dzfxBd + fxCd + z.*dzfxCd)...
   + Ut/(2*pi)*(dzfxAt + dzfxAtn + dzfxBt + fxCt + z.*dzfxCt);
yz = Us/(2*pi)*(cosdel*(dzfyAs + dzfyAsn + dzfyBs + fyCs + z.*dzfyCs)...
              - sindel*(dzfzAs + dzfzAsn + dzfzBs + fzCs + z.*dzfzCs))...     
   + Ud/(2*pi)*(cosdel*(dzfyAd + dzfyAdn + dzfyBd + fyCd + z.*dzfyCd)...
              - sindel*(dzfzAd + dzfzAdn + dzfzBd + fzCd + z.*dzfzCd))...
   + Ut/(2*pi)*(cosdel*(dzfyAt + dzfyAtn + dzfyBt + fyCt + z.*dzfyCt)...
              - sindel*(dzfzAt + dzfzAtn + dzfzBt + fzCt + z.*dzfzCt));
zz = Us/(2*pi)*(sindel*(dzfyAs + dzfyAsn + dzfyBs - fyCs - z.*dzfyCs)...
              + cosdel*(dzfzAs + dzfzAsn + dzfzBs - fzCs - z.*dzfzCs))...
   + Ud/(2*pi)*(sindel*(dzfyAd + dzfyAdn + dzfyBd - fyCd - z.*dzfyCd)...
              + cosdel*(dzfzAd + dzfzAdn + dzfzBd - fzCd - z.*dzfzCd))...
   + Ut/(2*pi)*(sindel*(dzfyAt + dzfyAtn + dzfyBt - fyCt - z.*dzfyCt)...
              + cosdel*(dzfzAt + dzfzAtn + dzfzBt - fzCt - z.*dzfzCt));

% rotate strains back to orthogonal coordinates
cstrike = strike; % correct to convert from Okada coordinates to regular Cartesian
rot = [cos(cstrike) -sin(cstrike) 0; sin(cstrike) cos(cstrike) 0; 0 0 1];
for i = 1:length(xs)
   smat = [xx(i) yx(i) zx(i); xy(i) yy(i) zy(i); xz(i) yz(i) zz(i)];
   rmat = rot*smat*rot';
   xx(i) = rmat(1); yy(i) = rmat(5); zz(i) = rmat(9);
   xy(i) = 0.5*(rmat(2) + rmat(4));
   xz(i) = 0.5*(rmat(3) + rmat(7));
   yz(i) = 0.5*(rmat(6) + rmat(8));
end
%keyboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                          %
%               Subfunctions               %
%                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
%                      %
% Dislocation solution %
%                      %
%%%%%%%%%%%%%%%%%%%%%%%%

function [fxAs,fxBs,fxCs,fyAs,fyBs,fyCs,fzAs,fzBs,fzCs,...
          fxAd,fxBd,fxCd,fyAd,fyBd,fyCd,fzAd,fzBd,fzCd,...
          fxAt,fxBt,fxCt,fyAt,fyBt,fyCt,fzAt,fzBt,fzCt]...
          = chinnery(x, y, z, c, L, W, cosdel, sindel, alpha, tol);

      
d = c-z;
p = y*cosdel + d*sindel;
q = y*sindel - d*cosdel;
  
xi = [x x (x-L) (x-L)]; % Order is changed to make it conveninent to use -1^(i+1) as coefficient
eta = [p (p-W) (p-W) p];
[fxAs, fxBs, fxCs, fyAs, fyBs, fyCs, fzAs, fzBs, fzCs,... 
 fxAd, fxBd, fxCd, fyAd, fyBd, fyCd, fzAd, fzBd, fzCd,... 
 fxAt, fxBt, fxCt, fyAt, fyBt, fyCt, fzAt, fzBt, fzCt]... 
 = deal(zeros(length(x), 1));

% define expressions requiring symbolic substitution
for i = 1:4;
    
    R = sqrt(xi(:,i).^2 + eta(:,i).^2 + q.^2);
    ybar = eta(:,i)*cosdel + q*sindel;
    dbar = eta(:,i)*sindel - q*cosdel;
    cbar = dbar + z;
    
    theta = atan(xi(:,i).*eta(:,i)./(q.*R));
    q0 = find(abs(q) < tol);
     theta(q0) = 0;
        
    bigX = sqrt(xi(:,i).^2 + q.^2);
    
    Y11 = 1./(R.*(R+eta(:,i)));
    logeta = log(R+eta(:,i));
    Reta0 = find(abs(R + eta(:,i)) < tol);
     Y11(Reta0) = 0;
     logeta(Reta0) = -log(R(Reta0)-eta(Reta0,i));

    xi0 = find(abs(xi(:,i)) < tol);
    
    if abs(cosdel) > tol % if dipping
       I3 = 1/cosdel*ybar./(R+dbar) - 1/cosdel^2*(logeta - sindel*log(R+dbar));
       I3(Reta0) = 1/cosdel*ybar(Reta0)./(R(Reta0)+dbar(Reta0)) - 1/cosdel^2*(logeta(Reta0) - sindel*log(R(Reta0)+dbar(Reta0)));
       I4 = sindel/cosdel*xi(:,i)./(R+dbar) + 2/cosdel^2*atan((eta(:,i).*(bigX + q*cosdel) + bigX.*(R+bigX)*sindel)./(xi(:,i).*(R+bigX)*cosdel));    
       I4(xi0) = 0;
    else
       I3 = 0.5*((eta(:,i)./(R+dbar)) + ((ybar.*q)./(R+dbar).^2) - log(R+eta(:, i)));
       I3(Reta0) = 0.5*((eta(Reta0,i)./(R(Reta0)+dbar(Reta0))) + ((ybar(Reta0).*q(Reta0))./(R(Reta0)+dbar(Reta0)).^2) + log(R(Reta0)-eta(Reta0,i)));
       I4 = 0.5*(xi(:,i).*ybar)./(R+dbar).^2;
       I4(xi0) = 0;
    end
    
  
    I1 = -xi(:,i)./(R+dbar)*cosdel - I4.*sindel;
    I2 = log(R+dbar) + I3.*sindel;
    
    X11 = 1./(R.*(R+xi(:,i)));
    logxi = log(R+xi(:,i));
    Rxi0 = find(abs(R + xi(:,i)) < tol);
        X11(Rxi0) = 0;
        logxi(Rxi0) = -log(R(Rxi0) - xi(Rxi0,i));
        
    X32 = ((2*R+xi(:,i))./R).*X11.^2;
    X53 = ((8*R.^2 + 9*R.*xi(:,i) + 3*xi(:,i).^2)./(R.^2)).*X11.^3;
    Y32 = ((2*R+eta(:,i))./R).*Y11.^2;
    Y53 = ((8*R.^2 + 9*R.*eta(:,i) + 3*eta(:,i).^2)./(R.^2)).*Y11.^3;
    h = q*cosdel - z;
    Z32 = sindel./R.^3 - h.*Y32;
    Z53 = 3*sindel./R.^5 - h.*Y53;

    % define displacement expressions
    fxAs = fxAs	+ (-1)^(i+1)*(theta./2 + alpha/2*q.*Y11.*xi(:,i));
    fxBs = fxBs	+ (-1)^(i+1)*(-xi(:,i).*q.*Y11 - theta - (1-alpha)/alpha*I1*sindel);
    fxCs = fxCs	+ (-1)^(i+1)*((1-alpha)*xi(:,i).*Y11*cosdel - alpha*xi(:,i).*q.*Z32);
    fyAs = fyAs	+ (-1)^(i+1)*(alpha/2*q./R);
    fyBs = fyBs	+ (-1)^(i+1)*(-q./R + (1-alpha)/alpha*ybar./(R+dbar)*sindel);
    fyCs = fyCs	+ (-1)^(i+1)*((1-alpha)*(cosdel./R + 2*q.*Y11.*sindel) - alpha*cbar.*q./R.^3);
    fzAs = fzAs	+ (-1)^(i+1)*((1-alpha)/2*logeta-alpha/2*(q.^2).*Y11);
    fzBs = fzBs	+ (-1)^(i+1)*((q.^2).*Y11 - (1-alpha)/alpha*I2*sindel);
    fzCs = fzCs	+ (-1)^(i+1)*((1-alpha)*q.*Y11.*cosdel - alpha*(cbar.*eta(:,i)./R.^3 - z.*Y11 + (xi(:,i).^2).*Z32));
    fxAd = fxAd	+ (-1)^(i+1)*(alpha/2*q./R);
    fxBd = fxBd	+ (-1)^(i+1)*(-q./R + (1-alpha)/alpha*I3*sindel*cosdel);
    fxCd = fxCd	+ (-1)^(i+1)*((1-alpha)*cosdel./R - q.*Y11.*sindel - alpha*cbar.*q./R.^3);
    fyAd = fyAd	+ (-1)^(i+1)*(theta./2+alpha/2*eta(:,i).*q.*X11);
    fyBd = fyBd	+ (-1)^(i+1)*(-eta(:,i).*q.*X11 - theta - (1-alpha)/alpha*xi(:,i)./(R+dbar)*sindel*cosdel);
    fyCd = fyCd	+ (-1)^(i+1)*((1-alpha)*ybar.*X11 - alpha*cbar.*eta(:,i).*q.*X32);
    fzAd = fzAd	+ (-1)^(i+1)*((1-alpha)/2*logxi - alpha/2*(q.^2).*X11);
    fzBd = fzBd	+ (-1)^(i+1)*((q.^2).*X11 + (1-alpha)/alpha*I4*sindel*cosdel);
    fzCd = fzCd	+ (-1)^(i+1)*(-dbar.*X11 - xi(:,i).*Y11*sindel - alpha*cbar.*(X11-(q.^2).*X32));
    fxAt = fxAt	+ (-1)^(i+1)*(-(1-alpha)/2*logeta - alpha/2*(q.^2).*Y11);
    fxBt = fxBt	+ (-1)^(i+1)*((q.^2).*Y11-(1-alpha)/alpha*I3*sindel^2);
    fxCt = fxCt	+ (-1)^(i+1)*(-(1-alpha)*(sindel./R + q.*Y11.*cosdel) - alpha*(z.*Y11 - (q.^2).*Z32));
    fyAt = fyAt	+ (-1)^(i+1)*(-(1-alpha)/2*logxi - alpha/2*(q.^2).*X11);
    fyBt = fyBt	+ (-1)^(i+1)*((q.^2).*X11 + (1-alpha)/alpha*xi(:,i)./(R+dbar)*sindel^2);
    fyCt = fyCt	+ (-1)^(i+1)*((1-alpha)*2*xi(:,i).*Y11.*sindel + dbar.*X11 - alpha*cbar.*(X11 - (q.^2).*X32));
    fzAt = fzAt	+ (-1)^(i+1)*(theta./2 - alpha/2*q.*(eta(:,i).*X11 + xi(:,i).*Y11));
    fzBt = fzBt	+ (-1)^(i+1)*(q.*(eta(:,i).*X11 + xi(:,i).*Y11) - theta - (1-alpha)/alpha*I4*sindel^2);
    fzCt = fzCt	+ (-1)^(i+1)*((1-alpha)*(ybar.*X11 + xi(:,i).*Y11*cosdel) + alpha*q.*(cbar.*eta(:,i).*X32 + xi(:,i).*Z32));
end

%%%%%%%%%%%%%%%%%%
%                %
% Whole solution %
%                %
%%%%%%%%%%%%%%%%%%
function [dxfxAs,dxfxBs,dxfxCs,dxfyAs,dxfyBs,dxfyCs,dxfzAs,dxfzBs,dxfzCs,...
          dxfxAd,dxfxBd,dxfxCd,dxfyAd,dxfyBd,dxfyCd,dxfzAd,dxfzBd,dxfzCd,...
          dxfxAt,dxfxBt,dxfxCt,dxfyAt,dxfyBt,dxfyCt,dxfzAt,dxfzBt,dxfzCt,...
          dyfxAs,dyfxBs,dyfxCs,dyfyAs,dyfyBs,dyfyCs,dyfzAs,dyfzBs,dyfzCs,...
          dyfxAd,dyfxBd,dyfxCd,dyfyAd,dyfyBd,dyfyCd,dyfzAd,dyfzBd,dyfzCd,...
          dyfxAt,dyfxBt,dyfxCt,dyfyAt,dyfyBt,dyfyCt,dyfzAt,dyfzBt,dyfzCt,...
          dzfxAs,dzfxBs,dzfxCs,dzfyAs,dzfyBs,dzfyCs,dzfzAs,dzfzBs,dzfzCs,...
          dzfxAd,dzfxBd,dzfxCd,dzfyAd,dzfyBd,dzfyCd,dzfzAd,dzfzBd,dzfzCd,...
          dzfxAt,dzfxBt,dzfxCt,dzfyAt,dzfyBt,dzfyCt,dzfzAt,dzfzBt,dzfzCt]...
          = chinnery_del(x,y,z,c,L,W,cosdel,sindel,alpha,tol);

d = c-z;
p = y.*cosdel + d.*sindel;
q = y.*sindel - d.*cosdel;
  
xi = [x x (x-L) (x-L)]; % Order is changed to make it conveninent to use -1^(i+1) as coefficient
eta = [p (p-W) (p-W) p];
[dxfxAs,dxfxBs,dxfxCs,dxfyAs,dxfyBs,dxfyCs,dxfzAs,dxfzBs,dxfzCs,...
 dxfxAd,dxfxBd,dxfxCd,dxfyAd,dxfyBd,dxfyCd,dxfzAd,dxfzBd,dxfzCd,...
 dxfxAt,dxfxBt,dxfxCt,dxfyAt,dxfyBt,dxfyCt,dxfzAt,dxfzBt,dxfzCt,...
 dyfxAs,dyfxBs,dyfxCs,dyfyAs,dyfyBs,dyfyCs,dyfzAs,dyfzBs,dyfzCs,...
 dyfxAd,dyfxBd,dyfxCd,dyfyAd,dyfyBd,dyfyCd,dyfzAd,dyfzBd,dyfzCd,...
 dyfxAt,dyfxBt,dyfxCt,dyfyAt,dyfyBt,dyfyCt,dyfzAt,dyfzBt,dyfzCt,...
 dzfxAs,dzfxBs,dzfxCs,dzfyAs,dzfyBs,dzfyCs,dzfzAs,dzfzBs,dzfzCs,...
 dzfxAd,dzfxBd,dzfxCd,dzfyAd,dzfyBd,dzfyCd,dzfzAd,dzfzBd,dzfzCd,...
 dzfxAt,dzfxBt,dzfxCt,dzfyAt,dzfyBt,dzfyCt,dzfzAt,dzfzBt,dzfzCt]...
 = deal(zeros(size(x)));

% define expressions requiring symbolic substitution
for i = 1:4;
    
    R = sqrt(xi(:,i).^2 + eta(:,i).^2 + q.^2);
    ybar = eta(:,i)*cosdel + q*sindel;
    dbar = eta(:,i)*sindel - q*cosdel;
    cbar = dbar + z;
    
    Y11 = 1./(R.*(R+eta(:,i)));
    logeta = log(R+eta(:,i));
    Reta0 = find(abs(R + eta(:,i)) < tol);
        Y11(Reta0) = 0;
        logeta(Reta0) = -log(R(Reta0)-eta(Reta0,i));

    D11 = 1./(R.*(R+dbar));
    J2 = (xi(:,i).*ybar./(R+dbar)).*D11; 
    J5 = -(dbar+(ybar.^2)./(R+dbar)).*D11;

    if abs(cosdel) > tol % if dipping
       K1 = (D11 - Y11*sindel).*(xi(:,i)/cosdel);
       K3 = 1/cosdel*(q.*Y11 - ybar.*D11);
       J3 = 1/cosdel*(K1 - J2*sindel);
       J6 = 1/cosdel*(K3 - J5*sindel);
    else
       K1 = (xi(:,i).*q)./(R+dbar).*D11;
       K3 = sindel./(R+dbar).*(xi(:,i).^2.*D11-1);
       J3 = -xi(:,i)./(R+dbar).^2.*(q.^2.*D11-0.5);
       J6 = -ybar./(R+dbar).^2.*(xi(:,i).^2.*D11-0.5);
    end
    K2 = 1./R + K3*sindel;
    K4 = xi(:,i).*Y11.*cosdel - K1*sindel;
    J4 = -xi(:,i).*Y11 - J2*cosdel + J3*sindel;
    J1 = J5*cosdel - J6*sindel;

    X11 = 1./(R.*(R+xi(:,i)));
    logxi = log(R+xi(:,i));
    Rxi0 = find(abs(R + xi(:,i)) < tol);
        X11(Rxi0) = 0;
        logxi(Rxi0) = -log(R(Rxi0) - xi(Rxi0,i)); 
   
    X32 = ((2*R+xi(:,i))./R).*X11.^2;
    X53 = ((8*R.^2 + 9*R.*xi(:,i) + 3*xi(:,i).^2)./(R.^2)).*X11.^3;
    Y32 = ((2*R+eta(:,i))./R).*Y11.^2;
    Y53 = ((8*R.^2 + 9*R.*eta(:,i) + 3*eta(:,i).^2)./(R.^2)).*Y11.^3;
    h = q*cosdel - z;
    Z32 = sindel./R.^3 - h.*Y32;
    Z53 = 3*sindel./R.^5 - h.*Y53;
    Y0 = Y11 - (xi(:,i).^2).*Y32;
    Z0 = Z32 - (xi(:,i).^2).*Z53;

    E = sindel./R - ybar.*q./(R.^3);
    F = dbar./(R.^3) + (xi(:,i).^2).*Y32*sindel;
    G = 2*X11.*sindel - ybar.*q.*X32;
    H = dbar.*q.*X32 + xi(:,i).*q.*Y32.*sindel;
    P = cosdel./(R.^3) + q.*Y32.*sindel;
    Q = 3*cbar.*dbar./(R.^5) - sindel*(z.*Y32 + Z32 + Z0);
    
    Ep = cosdel./R + dbar.*q./(R.^3);
    Fp = ybar./(R.^3) + (xi(:,i).^2).*Y32*cosdel;
    Gp = 2*X11.*cosdel + dbar.*q.*X32;
    Hp = ybar.*q.*X32 + xi(:,i).*q.*Y32.*cosdel;
    Pp = sindel./(R.^3) - q.*Y32.*cosdel;
    Qp = 3*cbar.*ybar./(R.^5) + q.*Y32 - cosdel*(z.*Y32 + Z32 + Z0);

    % define strain expressions w.r.t. x
    dxfxAs = dxfxAs	+ (-1)^(i+1)*(-(1-alpha)/2*q.*Y11 - alpha/2*(xi(:,i).^2).*q.*Y32);
    dxfxBs = dxfxBs	+ (-1)^(i+1)*((xi(:,i).^2).*q.*Y32 - (1-alpha)./alpha.*J1.*sindel);
    dxfxCs = dxfxCs	+ (-1)^(i+1)*((1-alpha).*Y0.*cosdel - alpha.*q.*Z0);
    dxfyAs = dxfyAs	+ (-1)^(i+1)*(-alpha/2.*xi(:,i).*q./(R.^3));
    dxfyBs = dxfyBs	+ (-1)^(i+1)*(xi(:,i).*q./(R.^3) - (1-alpha)./alpha.*J2.*sindel);
    dxfyCs = dxfyCs	+ (-1)^(i+1)*(-(1-alpha)*xi(:,i).*(cosdel./(R.^3) + 2*q.*Y32*sindel) + alpha*3*cbar.*xi(:,i).*q./(R.^5));
    dxfzAs = dxfzAs	+ (-1)^(i+1)*((1-alpha)/2*xi(:,i).*Y11 + alpha/2*xi(:,i).*(q.^2).*Y32);
    dxfzBs = dxfzBs	+ (-1)^(i+1)*(-xi(:,i).*(q.^2).*Y32 - (1-alpha)/alpha*J3*sindel);
    dxfzCs = dxfzCs	+ (-1)^(i+1)*(-(1-alpha)*xi(:,i).*q.*Y32.*cosdel + alpha*xi(:,i).*(3*cbar.*eta(:,i)./(R.^5) - z.*Y32 - Z32 - Z0));
    dxfxAd = dxfxAd	+ (-1)^(i+1)*(-alpha/2*xi(:,i).*q./(R.^3));
    dxfxBd = dxfxBd	+ (-1)^(i+1)*(xi(:,i).*q./(R.^3) + (1-alpha)/alpha*J4*sindel*cosdel);
    dxfxCd = dxfxCd	+ (-1)^(i+1)*(-(1-alpha)*xi(:,i)./(R.^3).*cosdel + xi(:,i).*q.*Y32.*sindel + alpha*3*cbar.*xi(:,i).*q./(R.^5));
    dxfyAd = dxfyAd	+ (-1)^(i+1)*(-0.5*q.*Y11 - alpha/2*eta(:,i).*q./(R.^3));
    dxfyBd = dxfyBd	+ (-1)^(i+1)*(eta(:,i).*q./(R.^3) + q.*Y11 + (1-alpha)/alpha*J5*sindel*cosdel);
    dxfyCd = dxfyCd	+ (-1)^(i+1)*(-(1-alpha)*ybar./(R.^3) + alpha*3*cbar.*eta(:,i).*q./(R.^5));
    dxfzAd = dxfzAd	+ (-1)^(i+1)*((1-alpha)/2*1./R + alpha/2*(q.^2)./(R.^3));
    dxfzBd = dxfzBd	+ (-1)^(i+1)*(-(q.^2)./(R.^3) + (1-alpha)/alpha*J6.*sindel*cosdel);
    dxfzCd = dxfzCd	+ (-1)^(i+1)*(dbar./(R.^3) - Y0.*sindel + alpha*(cbar./(R.^3)).*(1 - 3*(q.^2)./(R.^2)));
    dxfxAt = dxfxAt	+ (-1)^(i+1)*(-(1-alpha)/2*xi(:,i).*Y11 + alpha/2*xi(:,i).*(q.^2).*Y32);
    dxfxBt = dxfxBt	+ (-1)^(i+1)*(-xi(:,i).*(q.^2).*Y32 - (1-alpha)/alpha*J4.*sindel^2);
    dxfxCt = dxfxCt	+ (-1)^(i+1)*((1-alpha)*xi(:,i)./(R.^3)*sindel + xi(:,i).*q.*Y32*cosdel + alpha*xi(:,i).*(3*cbar.*eta(:,i)./(R.^5) - 2*Z32 - Z0));
    dxfyAt = dxfyAt	+ (-1)^(i+1)*(-(1-alpha)/2*(1./R) + alpha/2*(q.^2)./(R.^3));
    dxfyBt = dxfyBt	+ (-1)^(i+1)*(-(q.^2)./(R.^3) - (1-alpha)/alpha*J5.*sindel^2);
    dxfyCt = dxfyCt	+ (-1)^(i+1)*((1-alpha)*2*Y0.*sindel - dbar./(R.^3) + alpha*(cbar./(R.^3)).*(1 - 3*(q.^2)./(R.^2)));
    dxfzAt = dxfzAt	+ (-1)^(i+1)*(-(1-alpha)/2*q.*Y11 - alpha/2*(q.^3).*Y32);
    dxfzBt = dxfzBt	+ (-1)^(i+1)*((q.^3).*Y32 - (1-alpha)/alpha*J6*sindel^2);
    dxfzCt = dxfzCt	+ (-1)^(i+1)*(-(1-alpha)*(ybar./(R.^3) -Y0.*cosdel) - alpha*(3*cbar.*eta(:,i).*q./(R.^5) - q.*Z0));
    
    % define strain expressions w.r.t. y
    
    dyfxAs = dyfxAs	+ (-1)^(i+1)*((1-alpha)/2*xi(:,i).*Y11.*sindel + 0.5*dbar.*X11 + alpha/2*xi(:,i).*F);
    dyfxBs = dyfxBs	+ (-1)^(i+1)*(-xi(:,i).*F - dbar.*X11 + (1-alpha)/alpha*(xi(:,i).*Y11 + J4)*sindel);
    dyfxCs = dyfxCs	+ (-1)^(i+1)*(-(1-alpha)*xi(:,i).*P*cosdel - alpha*xi(:,i).*Q);
    dyfyAs = dyfyAs	+ (-1)^(i+1)*(alpha/2*E);
    dyfyBs = dyfyBs	+ (-1)^(i+1)*(-E + (1-alpha)/alpha*(1./R + J5)*sindel);
    dyfyCs = dyfyCs	+ (-1)^(i+1)*(2*(1-alpha)*(dbar./(R.^3) - Y0.*sindel)*sindel - ybar./(R.^3)*cosdel - alpha*((cbar+dbar)./(R.^3)*sindel - eta(:,i)./(R.^3) - 3*cbar.*ybar.*q./(R.^5)));
    dyfzAs = dyfzAs	+ (-1)^(i+1)*((1-alpha)/2*(cosdel./R + q.*Y11*sindel) - alpha/2*q.*F);
    dyfzBs = dyfzBs	+ (-1)^(i+1)*(q.*F - (1-alpha)/alpha*(q.*Y11 - J6)*sindel);
    dyfzCs = dyfzCs	+ (-1)^(i+1)*(-(1-alpha)*q./(R.^3) + (ybar./(R.^3) - Y0*cosdel)*sindel + alpha*((cbar+dbar)./(R.^3)*cosdel + 3*cbar.*dbar.*q./(R.^5) - (Y0*cosdel + q.*Z0)*sindel));
    dyfxAd = dyfxAd	+ (-1)^(i+1)*(alpha/2*E);
    dyfxBd = dyfxBd	+ (-1)^(i+1)*(-E + (1-alpha)/alpha*J1*sindel*cosdel);
    dyfxCd = dyfxCd	+ (-1)^(i+1)*(-(1-alpha)*eta(:,i)./(R.^3) + Y0.*sindel^2 - alpha*((cbar+dbar)./(R.^3)*sindel - 3*cbar.*ybar.*q./(R.^5)));
    dyfyAd = dyfyAd	+ (-1)^(i+1)*((1-alpha)/2*dbar.*X11 + 0.5*xi(:,i).*Y11*sindel + alpha/2*eta(:,i).*G);
    dyfyBd = dyfyBd	+ (-1)^(i+1)*(-eta(:,i).*G - xi(:,i).*Y11*sindel + (1-alpha)/alpha*J2*sindel*cosdel);
    dyfyCd = dyfyCd	+ (-1)^(i+1)*((1-alpha)*(X11 - (ybar.^2).*X32) - alpha*cbar.*((dbar+2*q*cosdel).*X32 - ybar.*eta(:,i).*q.*X53));
    dyfzAd = dyfzAd	+ (-1)^(i+1)*((1-alpha)/2*ybar.*X11 - alpha/2*q.*G);
    dyfzBd = dyfzBd	+ (-1)^(i+1)*(q.*G + (1-alpha)/alpha*J3.*sindel*cosdel);
    dyfzCd = dyfzCd	+ (-1)^(i+1)*(xi(:,i).*P*sindel + ybar.*dbar.*X32 + alpha*cbar.*((ybar+2*q*sindel).*X32 - ybar.*(q.^2).*X53));
    dyfxAt = dyfxAt	+ (-1)^(i+1)*(-(1-alpha)/2*(cosdel./R + q.*Y11*sindel) - alpha/2*q.*F);
    dyfxBt = dyfxBt	+ (-1)^(i+1)*(q.*F - (1-alpha)/alpha*J1.*sindel^2);
    dyfxCt = dyfxCt	+ (-1)^(i+1)*((1-alpha)*(q./(R.^3) + Y0.*sindel*cosdel) + alpha*(z./(R.^3)*cosdel + (3*cbar.*dbar.*q./(R.^5) - q.*Z0*sindel)));
    dyfyAt = dyfyAt	+ (-1)^(i+1)*(-(1-alpha)/2*ybar.*X11 - alpha/2*q.*G);
    dyfyBt = dyfyBt	+ (-1)^(i+1)*(q.*G - (1-alpha)/alpha*J2.*sindel^2);
    dyfyCt = dyfyCt	+ (-1)^(i+1)*(-(1-alpha)*2*xi(:,i).*P*sindel - ybar.*dbar.*X32 + alpha*cbar.*((ybar+2*q.*sindel).*X32 - ybar.*(q.^2).*X53));
    dyfzAt = dyfzAt	+ (-1)^(i+1)*((1-alpha)/2*(dbar.*X11+xi(:,i).*Y11*sindel) + alpha/2*q.*H);
    dyfzBt = dyfzBt	+ (-1)^(i+1)*(-q.*H - (1-alpha)/alpha*J3*sindel^2);
    dyfzCt = dyfzCt	+ (-1)^(i+1)*(-(1-alpha)*(xi(:,i).*P*cosdel - X11 + (ybar.^2).*X32) + alpha*cbar.*((dbar+2*q*cosdel).*X32 - ybar.*eta(:,i).*q.*X53) + alpha*xi(:,i).*Q);


    % define strain expressions w.r.t. z
    
    dzfxAs = dzfxAs	+ (-1)^(i+1)*((1-alpha)/2*xi(:,i).*Y11*cosdel + 0.5*ybar.*X11 + alpha/2*xi(:,i).*Fp);
    dzfxBs = dzfxBs	+ (-1)^(i+1)*(-xi(:,i).*Fp - ybar.*X11 + (1-alpha)/alpha*K1*sindel);
    dzfxCs = dzfxCs	+ (-1)^(i+1)*((1-alpha)*xi(:,i).*Pp*cosdel - alpha*xi(:,i).*Qp);
    dzfyAs = dzfyAs	+ (-1)^(i+1)*(alpha/2*Ep);
    dzfyBs = dzfyBs	+ (-1)^(i+1)*(-Ep + (1-alpha)/alpha*ybar.*D11*sindel);
    dzfyCs = dzfyCs	+ (-1)^(i+1)*(2*(1-alpha)*(ybar./(R.^3) - Y0*cosdel).*sindel + dbar./(R.^3).*cosdel - alpha*((cbar+dbar)./(R.^3).*cosdel + 3*cbar.*dbar.*q./(R.^5)));
    dzfzAs = dzfzAs	+ (-1)^(i+1)*(-(1-alpha)/2*(sindel./R - q.*Y11*cosdel) - alpha/2*q.*Fp);
    dzfzBs = dzfzBs	+ (-1)^(i+1)*(q.*Fp + (1-alpha)/alpha*K2*sindel);
    dzfzCs = dzfzCs	+ (-1)^(i+1)*((ybar./(R.^3) - Y0*cosdel)*cosdel - alpha*((cbar+dbar)./(R.^3)*sindel - 3*cbar.*ybar.*q./(R.^5) - Y0*sindel^2 + q.*Z0*cosdel));
    dzfxAd = dzfxAd	+ (-1)^(i+1)*(alpha/2*Ep);
    dzfxBd = dzfxBd	+ (-1)^(i+1)*(-Ep - (1-alpha)/alpha*K3*sindel*cosdel);
    dzfxCd = dzfxCd	+ (-1)^(i+1)*(-q./(R.^3) + Y0*sindel*cosdel - alpha*((cbar+dbar)./(R.^3)*cosdel + 3*cbar.*dbar.*q./(R.^5)));
    dzfyAd = dzfyAd	+ (-1)^(i+1)*((1-alpha)/2*ybar.*X11 + 0.5*xi(:,i).*Y11*cosdel + alpha/2*eta(:,i).*Gp);
    dzfyBd = dzfyBd	+ (-1)^(i+1)*(-eta(:,i).*Gp - xi(:,i).*Y11*cosdel - (1-alpha)/alpha*xi(:,i).*D11*sindel*cosdel);
    dzfyCd = dzfyCd	+ (-1)^(i+1)*((1-alpha)*ybar.*dbar.*X32 - alpha*cbar.*((ybar - 2*q*sindel).*X32 + dbar.*eta(:,i).*q.*X53));
    dzfzAd = dzfzAd	+ (-1)^(i+1)*(-(1-alpha)/2*dbar.*X11 - alpha/2*q.*Gp);
    dzfzBd = dzfzBd	+ (-1)^(i+1)*(q.*Gp - (1-alpha)/alpha*K4.*sindel*cosdel);
    dzfzCd = dzfzCd	+ (-1)^(i+1)*(-xi(:,i).*Pp*sindel + X11 - (dbar.^2).*X32 - alpha*cbar.*((dbar-2*q*cosdel).*X32 - dbar.*(q.^2).*X53));
    dzfxAt = dzfxAt	+ (-1)^(i+1)*((1-alpha)/2*(sindel./R - q.*Y11*cosdel) - alpha/2*q.*Fp);
    dzfxBt = dzfxBt	+ (-1)^(i+1)*(q.*Fp + (1-alpha)/alpha*K3.*sindel^2);
    dzfxCt = dzfxCt	+ (-1)^(i+1)*(-eta(:,i)./(R.^3) + Y0*cosdel^2 - alpha*(z./(R.^3)*sindel - 3*cbar.*ybar.*q./(R.^5) - Y0*sindel^2 + q.*Z0*cosdel));
    dzfyAt = dzfyAt	+ (-1)^(i+1)*((1-alpha)/2*dbar.*X11 - alpha/2*q.*Gp);
    dzfyBt = dzfyBt	+ (-1)^(i+1)*(q.*Gp + (1-alpha)/alpha*xi(:,i).*D11*sindel^2);
    dzfyCt = dzfyCt	+ (-1)^(i+1)*((1-alpha)*2*xi(:,i).*Pp*sindel - X11 + (dbar.^2).*X32 - alpha*cbar.*((dbar-2*q*cosdel).*X32 - dbar.*(q.^2).*X53));
    dzfzAt = dzfzAt	+ (-1)^(i+1)*((1-alpha)/2*(ybar.*X11 + xi(:,i).*Y11*cosdel) + alpha/2*q.*Hp);
    dzfzBt = dzfzBt	+ (-1)^(i+1)*(-q.*Hp + (1-alpha)/alpha*K4*sindel^2);
    dzfzCt = dzfzCt	+ (-1)^(i+1)*((1-alpha)*(xi(:,i).*Pp*cosdel + ybar.*dbar.*X32) + alpha*cbar.*((ybar-2*q*sindel).*X32 +dbar.*eta(:,i).*q.*X53) + alpha*xi(:,i).*Qp);
end

%%%%%%%%%%%%%%%%%%
%                %
% Image solution %
%                %
%%%%%%%%%%%%%%%%%%
function [dxfxAsn,dxfyAsn,dxfzAsn,...
          dxfxAdn,dxfyAdn,dxfzAdn,...
          dxfxAtn,dxfyAtn,dxfzAtn,...
          dyfxAsn,dyfyAsn,dyfzAsn,...
          dyfxAdn,dyfyAdn,dyfzAdn,...
          dyfxAtn,dyfyAtn,dyfzAtn,...
          dzfxAsn,dzfyAsn,dzfzAsn,...
          dzfxAdn,dzfyAdn,dzfzAdn,...
          dzfxAtn,dzfyAtn,dzfzAtn]...
          = chinnery_deln(x,y,z,c,L,W,cosdel,sindel,alpha,tol);

      
d = c-z;
p = y.*cosdel + d.*sindel;
q = y.*sindel - d.*cosdel;
  
xi = [x x (x-L) (x-L)]; % Order is changed to make it conveninent to use -1^(i+1) as coefficient
eta = [p (p-W) (p-W) p];
[dxfxAsn,dxfyAsn,dxfzAsn,...
 dxfxAdn,dxfyAdn,dxfzAdn,...
 dxfxAtn,dxfyAtn,dxfzAtn,...
 dyfxAsn,dyfyAsn,dyfzAsn,...
 dyfxAdn,dyfyAdn,dyfzAdn,...
 dyfxAtn,dyfyAtn,dyfzAtn,...
 dzfxAsn,dzfyAsn,dzfzAsn,...
 dzfxAdn,dzfyAdn,dzfzAdn,...
 dzfxAtn,dzfyAtn,dzfzAtn]...
 = deal(zeros(size(x)));
 
% define expressions requiring symbolic substitution
for i = 1:4;
    
    R = sqrt(xi(:,i).^2 + eta(:,i).^2 + q.^2);
    ybar = eta(:,i).*cosdel + q.*sindel;
    dbar = eta(:,i).*sindel - q.*cosdel;
    cbar = dbar + z;
    

    Y11 = 1./(R.*(R+eta(:,i)));
    logeta = log(R+eta(:,i));
    Reta0 = find(abs(R + eta(:,i)) < tol);
        Y11(Reta0) = 0;
        logeta(Reta0) = -log(R(Reta0)-eta(Reta0,i));
    
    X11 = 1./(R.*(R+xi(:,i)));
    logxi = log(R+xi(:,i));
    Rxi0 = find(abs(R + xi(:,i)) < tol);
        X11(Rxi0) = 0;
        logxi(Rxi0) = -log(R(Rxi0) - xi(Rxi0,i));
        
    X32 = ((2*R+xi(:,i))./R).*X11.^2;
    Y32 = ((2*R+eta(:,i))./R).*Y11.^2;
    
    E = sindel./R - ybar.*q./(R.^3);
    F = dbar./(R.^3) + (xi(:,i).^2).*Y32*sindel;
    G = 2*X11.*sindel - ybar.*q.*X32;
    H = dbar.*q.*X32 + xi(:,i).*q.*Y32.*sindel;
    
    Ep = cosdel./R + dbar.*q./(R.^3);
    Fp = ybar./(R.^3) + (xi(:,i).^2).*Y32*cosdel;
    Gp = 2*X11.*cosdel + dbar.*q.*X32;
    Hp = ybar.*q.*X32 + xi(:,i).*q.*Y32.*cosdel;
    
    % define strain expressions w.r.t. x
    dxfxAsn = dxfxAsn + (-1)^(i+1)*(-(1-alpha)/2*q.*Y11 - alpha/2*(xi(:,i).^2).*q.*Y32);
    dxfyAsn = dxfyAsn + (-1)^(i+1)*(-alpha/2.*xi(:,i).*q./(R.^3));
    dxfzAsn = dxfzAsn + (-1)^(i+1)*((1-alpha)/2*xi(:,i).*Y11 + alpha/2*xi(:,i).*(q.^2).*Y32);
    dxfxAdn = dxfxAdn + (-1)^(i+1)*(-alpha/2*xi(:,i).*q./(R.^3));
    dxfyAdn = dxfyAdn + (-1)^(i+1)*(-0.5*q.*Y11 - alpha/2*eta(:,i).*q./(R.^3));
    dxfzAdn = dxfzAdn + (-1)^(i+1)*((1-alpha)/2*1./R + alpha/2*(q.^2)./(R.^3));
    dxfxAtn = dxfxAtn + (-1)^(i+1)*(-(1-alpha)/2*xi(:,i).*Y11 + alpha/2*xi(:,i).*(q.^2).*Y32);
    dxfyAtn = dxfyAtn + (-1)^(i+1)*(-(1-alpha)/2*(1./R) + alpha/2*(q.^2)./(R.^3));
    dxfzAtn = dxfzAtn + (-1)^(i+1)*(-(1-alpha)/2*q.*Y11 - alpha/2*(q.^3).*Y32);
    
    % define strain expressions w.r.t. y
    
    dyfxAsn = dyfxAsn + (-1)^(i+1)*((1-alpha)/2*xi(:,i).*Y11.*sindel + 0.5*dbar.*X11 + alpha/2*xi(:,i).*F);
    dyfyAsn = dyfyAsn + (-1)^(i+1)*(alpha/2*E);
    dyfzAsn = dyfzAsn + (-1)^(i+1)*((1-alpha)/2*(cosdel./R + q.*Y11*sindel) - alpha/2*q.*F);
    dyfxAdn = dyfxAdn + (-1)^(i+1)*(alpha/2*E);
    dyfyAdn = dyfyAdn + (-1)^(i+1)*((1-alpha)/2*dbar.*X11 + 0.5*xi(:,i).*Y11*sindel + alpha/2*eta(:,i).*G);
    dyfzAdn = dyfzAdn + (-1)^(i+1)*((1-alpha)/2*ybar.*X11 - alpha/2*q.*G);
    dyfxAtn = dyfxAtn + (-1)^(i+1)*(-(1-alpha)/2*(cosdel./R + q.*Y11*sindel) - alpha/2*q.*F);
    dyfyAtn = dyfyAtn + (-1)^(i+1)*(-(1-alpha)/2*ybar.*X11 - alpha/2*q.*G);
    dyfzAtn = dyfzAtn + (-1)^(i+1)*((1-alpha)/2*(dbar.*X11+xi(:,i).*Y11*sindel) + alpha/2*q.*H);

    % define strain expressions w.r.t. z
    
    dzfxAsn = dzfxAsn + (-1)^(i+1)*((1-alpha)/2*xi(:,i).*Y11*cosdel + 0.5*ybar.*X11 + alpha/2*xi(:,i).*Fp);
    dzfyAsn = dzfyAsn + (-1)^(i+1)*(alpha/2*Ep);
    dzfzAsn = dzfzAsn + (-1)^(i+1)*(-(1-alpha)/2*(sindel./R - q.*Y11*cosdel) - alpha/2*q.*Fp);
    dzfxAdn = dzfxAdn + (-1)^(i+1)*(alpha/2*Ep);
    dzfyAdn = dzfyAdn + (-1)^(i+1)*((1-alpha)/2*ybar.*X11 + 0.5*xi(:,i).*Y11*cosdel + alpha/2*eta(:,i).*Gp);
    dzfzAdn = dzfzAdn + (-1)^(i+1)*(-(1-alpha)/2*dbar.*X11 - alpha/2*q.*Gp);
    dzfxAtn = dzfxAtn + (-1)^(i+1)*((1-alpha)/2*(sindel./R - q.*Y11*cosdel) - alpha/2*q.*Fp);
    dzfyAtn = dzfyAtn + (-1)^(i+1)*((1-alpha)/2*dbar.*X11 - alpha/2*q.*Gp);
    dzfzAtn = dzfzAtn + (-1)^(i+1)*((1-alpha)/2*(ybar.*X11 + xi(:,i).*Y11*cosdel) + alpha/2*q.*Hp);
end
