function [xx, yy, zz, xy, xz, yz, normVec] = tri_strain_fast(x, y, z, sx, sy, sz, ss, ds, ts, pr)
%
% tri_strain.m
%
% Calculates strains due to slip on a triangular dislocation in an
% elastic half space utilizing the symbolically differentiated
% displacement gradient tensor derived from the expressions for
% the displacements due to an angular dislocation in an elastic half
% space (Comninou and Dunders, 1975).
%
% Arguments
%  sx : x-coordinates of observation points
%  sy : y-coordinates of observation points
%  sz : z-coordinates of observation points
%  x  : x-coordinates of triangle vertices.
%  y  : y-coordinates of triangle vertices.
%  z  : z-coordinates of triangle vertices.
%  pr : Poisson's ratio
%  ss : strike slip displacement
%  ts : tensile slip displacement
%  ds : dip slip displacement
%
% Returns
%  ij  : strain components (xx, yy, zz, xy, xz, yz)
%


% Calculate the slip vector in XYZ coordinates
normVec                      = cross([x(2);y(2);z(2)]-[x(1);y(1);z(1)], [x(3);y(3);z(3)]-[x(1);y(1);z(1)]);
normVec                      = normVec./norm(normVec);
if (normVec(3) < 0) % Enforce clockwise circulation
   normVec                   = -normVec;
   [x(2) x(3)]               = swap(x(2), x(3));
   [y(2) y(3)]               = swap(y(2), y(3));
   [z(2) z(3)]               = swap(z(2), z(3));
end
strikeVec                    = [-sin(atan2(normVec(2),normVec(1))) cos(atan2(normVec(2),normVec(1))) 0];
dipVec                       = cross(normVec, strikeVec);
slipComp                     = [ss ds ts];
slipVec                      = [strikeVec(:) dipVec(:) normVec(:)] * slipComp(:);

% Solution vectors
xx                           = zeros(size(sx));
yy                           = xx;
zz                           = xx;
xy                           = xx;
xz                           = xx;
yz                           = xx;

% Add a copy of the first vertex to the vertex list for indexing
x(4)                         = x(1);
y(4)                         = y(1);
z(4)                         = z(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Leg 1 contribution %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate strike and dip of leg 1
strike                   = 180/pi*(atan2(y(2)-y(1), x(2)-x(1)));
segMapLength             = sqrt((x(1)-x(2))^2 + (y(1)-y(2))^2);
[rx ry]                  = RotateXyVec(x(2)-x(1), y(2)-y(1), -strike);
dip                      = 180/pi*(atan2(z(2)-z(1), rx));

if dip >= 0
  beta                  = pi/180*(90-dip);
  if beta > pi/2
	 beta               = pi/2-beta;
  end
else
  beta                  = -pi/180*(90+dip);
  if beta < -pi/2
	 beta = pi/2-abs(beta);
  end
end
ssVec                    = [cos(strike/180*pi) sin(strike/180*pi) 0];
dsVec                    = [-sin(strike/180*pi) cos(strike/180*pi) 0];
tsVec                    = cross(ssVec, dsVec);
lss                      = dot(slipVec, ssVec);
lts                      = dot(slipVec, tsVec);
lds                      = dot(slipVec, dsVec);

if (abs(beta) > 0.000001) && (abs(beta-pi) > 0.000001)
  % First angular dislocation
  [sx1 sy1]                 = RotateXyVec(sx-x(1), sy-y(1), -strike);
  [a11 a22 a33 a12 a13 a23] = advs(sx1, sy1, sz-z(1), z(1), beta, pr, lss, lds, lts);
							   
  % Second angular dislocation
  [sx2 sy2]                 = RotateXyVec(sx-x(2), sy-y(2), -strike); 
  [b11 b22 b33 b12 b13 b23] = advs(sx2, sy2, sz-z(2), z(2), beta, pr, lss, lds, lts);

  % Rotate tensors to correct for strike
  bxx                       = a11-b11;
  byy                       = a22-b22;
  bzz                       = a33-b33;
  bxy                       = a12-b12;
  bxz                       = a13-b13;
  byz                       = a23-b23;
  
  g                         = pi/180*strike;
  e11n                      = (cos(g)*bxx-sin(g)*bxy)*cos(g)-(cos(g)*bxy-sin(g)*byy)*sin(g);
  e12n                      = (cos(g)*bxx-sin(g)*bxy)*sin(g)+(cos(g)*bxy-sin(g)*byy)*cos(g);
  e13n                      = cos(g)*bxz-sin(g)*byz;
  e22n                      = (sin(g)*bxx+cos(g)*bxy)*sin(g)+(sin(g)*bxy+cos(g)*byy)*cos(g);
  e23n                      = sin(g)*bxz+cos(g)*byz;
  e33n                      = bzz;
  
  % Add the strains from leg 1
  xx                        = xx + e11n;
  yy                        = yy + e22n;
  zz                        = zz + e33n;
  xy                        = xy + e12n;
  xz                        = xz + e13n;
  yz                        = yz + e23n;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Leg 2 contribution %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate strike and dip of leg 2
strike                   = 180/pi*(atan2(y(3)-y(2), x(3)-x(2)));
segMapLength             = sqrt((x(2)-x(3))^2 + (y(2)-y(3))^2);
[rx ry]                  = RotateXyVec(x(3)-x(2), y(3)-y(2), -strike);
dip                      = 180/pi*(atan2(z(3)-z(2), rx));

if dip >= 0
  beta                  = pi/180*(90-dip);
  if beta > pi/2
	 beta               = pi/2-beta;
  end
else
  beta                  = -pi/180*(90+dip);
  if beta < -pi/2
	 beta = pi/2-abs(beta);
  end
end
ssVec                    = [cos(strike/180*pi) sin(strike/180*pi) 0];
dsVec                    = [-sin(strike/180*pi) cos(strike/180*pi) 0];
tsVec                    = cross(ssVec, dsVec);
lss                      = dot(slipVec, ssVec);
lts                      = dot(slipVec, tsVec);
lds                      = dot(slipVec, dsVec);

if (abs(beta) > 0.000001) && (abs(beta-pi) > 0.000001)
  % First angular dislocation
  [sx1 sy1]                 = RotateXyVec(sx-x(2), sy-y(2), -strike);
  [a11 a22 a33 a12 a13 a23] = advs(sx1, sy1, sz-z(2), z(2), beta, pr, lss, lds, lts);
							   
  % Second angular dislocation
  [sx2 sy2]                 = RotateXyVec(sx-x(3), sy-y(3), -strike); 
  [b11 b22 b33 b12 b13 b23] = advs(sx2, sy2, sz-z(3), z(3), beta, pr, lss, lds, lts);

  % Rotate tensors to correct for strike
  bxx                       = a11-b11;
  byy                       = a22-b22;
  bzz                       = a33-b33;
  bxy                       = a12-b12;
  bxz                       = a13-b13;
  byz                       = a23-b23;
  
  g                         = pi/180*strike;
  e11n                      = (cos(g)*bxx-sin(g)*bxy)*cos(g)-(cos(g)*bxy-sin(g)*byy)*sin(g);
  e12n                      = (cos(g)*bxx-sin(g)*bxy)*sin(g)+(cos(g)*bxy-sin(g)*byy)*cos(g);
  e13n                      = cos(g)*bxz-sin(g)*byz;
  e22n                      = (sin(g)*bxx+cos(g)*bxy)*sin(g)+(sin(g)*bxy+cos(g)*byy)*cos(g);
  e23n                      = sin(g)*bxz+cos(g)*byz;
  e33n                      = bzz;
  
  % Add the strains from leg 2
  xx                        = xx + e11n;
  yy                        = yy + e22n;
  zz                        = zz + e33n;
  xy                        = xy + e12n;
  xz                        = xz + e13n;
  yz                        = yz + e23n;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Leg 3 contribution %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate strike and dip of leg 1
strike                   = 180/pi*(atan2(y(4)-y(3), x(4)-x(3)));
segMapLength             = sqrt((x(3)-x(4))^2 + (y(3)-y(4))^2);
[rx ry]                  = RotateXyVec(x(4)-x(3), y(4)-y(3), -strike);
dip                      = 180/pi*(atan2(z(4)-z(3), rx));

if dip >= 0
  beta                  = pi/180*(90-dip);
  if beta > pi/2
	 beta               = pi/2-beta;
  end
else
  beta                  = -pi/180*(90+dip);
  if beta < -pi/2
	 beta = pi/2-abs(beta);
  end
end
ssVec                    = [cos(strike/180*pi) sin(strike/180*pi) 0];
dsVec                    = [-sin(strike/180*pi) cos(strike/180*pi) 0];
tsVec                    = cross(ssVec, dsVec);
lss                      = dot(slipVec, ssVec);
lts                      = dot(slipVec, tsVec);
lds                      = dot(slipVec, dsVec);

if (abs(beta) > 0.000001) && (abs(beta-pi) > 0.000001)
  % First angular dislocation
  [sx1 sy1]                 = RotateXyVec(sx-x(3), sy-y(3), -strike);
  [a11 a22 a33 a12 a13 a23] = advs(sx1, sy1, sz-z(3), z(3), beta, pr, lss, lds, lts);
							   
  % Second angular dislocation
  [sx2 sy2]                 = RotateXyVec(sx-x(4), sy-y(4), -strike); 
  [b11 b22 b33 b12 b13 b23] = advs(sx2, sy2, sz-z(4), z(4), beta, pr, lss, lds, lts);

  % Rotate tensors to correct for strike
  bxx                       = a11-b11;
  byy                       = a22-b22;
  bzz                       = a33-b33;
  bxy                       = a12-b12;
  bxz                       = a13-b13;
  byz                       = a23-b23;
  
  g                         = pi/180*strike;
  e11n                      = (cos(g)*bxx-sin(g)*bxy)*cos(g)-(cos(g)*bxy-sin(g)*byy)*sin(g);
  e12n                      = (cos(g)*bxx-sin(g)*bxy)*sin(g)+(cos(g)*bxy-sin(g)*byy)*cos(g);
  e13n                      = cos(g)*bxz-sin(g)*byz;
  e22n                      = (sin(g)*bxx+cos(g)*bxy)*sin(g)+(sin(g)*bxy+cos(g)*byy)*cos(g);
  e23n                      = sin(g)*bxz+cos(g)*byz;
  e33n                      = bzz;
  
  % Add the strains from leg 3
  xx                        = xx + e11n;
  yy                        = yy + e22n;
  zz                        = zz + e33n;
  xy                        = xy + e12n;
  xz                        = xz + e13n;
  yz                        = yz + e23n;
end


function [a b] = swap(a, b)
% Swap two values
temp                            = a;
a                               = b;
b                               = temp;


function [xp yp] = RotateXyVec(x, y, alpha)
% Rotate a vector by an angle alpha
x                             = x(:);
y                             = y(:);
alpha                         = pi/180*alpha;
xp                            = cos(alpha).*x - sin(alpha).*y;
yp                            = sin(alpha).*x + cos(alpha).*y;


function [e11 e22 e33 e12 e13 e23] = advs(y1, y2, y3, a, b, nu, B1, B2, B3)
% These are the strains in a uniform elastic half space due to slip
% on an angular dislocation.  They were calculated by symbolically
% differentiating the expressions for the displacements (Comninou and
% Dunders, 1975, with typos noted by Thomas 1993) then combining the
% elements of the displacement gradient tensor to form the strain tensor.

sinb = sin(b);
sinb2 = sinb.^2;
cosb = cos(b);
cosb2 = cosb.^2;
cotb = 1./tan(b);
cotb2 = cotb.^2;

y12 = y1.^2;
y22 = y2.^2;
y32 = y3.^2;
y122 = y1.^2 + y2.^2;
y13 = y1.^3;
y23 = y2.^3;

y1cb = y1.*cosb;
y1sb = y1.*sinb;
y3sb = y3.*sinb;
y3cb = y3.*cosb;
y22cb2 = y22.*cosb2; 
y22cb = y22.*cosb;
y22cbp2 = y22cb.^2; %%%%%%%%%%
ycys2 = (y1cb-y3sb).^2;

oh = 1./2;
th = 3./2;
fh = 5./2;
oe = 1./8;

sys = y12+y22+y32;
systh = sys.^th;
sysq = sys.^(oh);
isysq = 1./sysq;

nunu = 2.*nu;
omnunu = 1-nunu;
tmnunu = 2-nunu;
aa = 2.*a;
y3aa = y3+2.*a;
y3aa2 = (y3+2.*a).^2;
yy2 = y122+y3aa2;
iyy2 = 1./yy2;
yy22 = yy2.^2;
y1y22 = y1./yy22;
yy2q = yy2.^oh;
iyy2q = 1./yy2q;
yy2th = yy2.^th;
yy2fh = yy2.^fh;

yya = (yy2q+y3+aa);
yyas = yya.^2;
yysb = (y1cb+y3aa.*sinb);
yysb2 = yysb.^2;
yyysby = (y1.*yysb+y22cb);
yyysby2 = yyysby.^2;
yyycb = (yy2q-y1sb+y3aa.*cosb);
yyycb2 = yyycb.^2;
smymy = (sysq-y1sb-y3cb);
syy2 = smymy.^2;
yyyy = (y1.*(y1cb-y3sb)+y22cb);
yyyy2 = yyyy.^2;
sy2 = (sysq-y3).^2;
ysby = (yy2q.*sinb-y1);
ssby = (sysq.*sinb-y1);
ty3fa = (2.*y3+4.*a);
ycbya = (yy2q.*cosb+y3+aa);
hytcb = oh./yy2q.*ty3fa+cosb;
cbay = cosb+a./yy2q;
iyysb = iyy2q.*y1-sinb;
hyto = oh./yy2q.*ty3fa+1;
nay = nunu+a./yy2q;
oay = 1+a./yy2q;
scby = sysq.*cosb-y3;
sby7 = sinb-y3aa.*yysb./yy2-yysb.*ycbya./yy2q./yyycb;
oyysby = 1+y22.*yy2.*sinb2./yyysby2;
piomn = pi./(1-nu);
yCyY2 = ycbya./yyycb2;
yCyY = ycbya./yyycb;
ythycb = yy2th./yyycb;

%e11 = zeros(size(y1));
%e22 = e11; 
%e33 = e11; 
%e12 = e11; 
%e13 = e11; 
%e23 = e11; 

e11 = B1.*(oe.*((tmnunu).*(2.*y2./y12./(1+y22./y12)-y2./ycys2.*cosb./(1+y22./ycys2)+(y2./sysq.*sinb./yyyy.*y1-y2.*sysq.*sinb./yyyy2.*(2.*y1cb-y3sb))./(1+y22.*(sys).*sinb2./yyyy2)-y2./yysb2.*cosb./(1+y22./yysb2)+(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby)-y2.*(isysq./(sysq-y3)+iyy2q./yya)-y1.*y2.*(-1./systh./(sysq-y3).*y1-1./(sys)./sy2.*y1-1./yy2th./yya.*y1-iyy2./yyas.*y1)-y2.*cosb.*((isysq.*sinb.*y1-1)./sysq./smymy-ssby./systh./smymy.*y1-ssby./sysq./syy2.*(isysq.*y1-sinb)+(iyy2q.*sinb.*y1-1)./yy2q./yyycb-ysby./yy2th./yyycb.*y1-ysby./yy2q./yyycb2.*iyysb))./pi./(1-nu)+1./4.*((-2+nunu).*(omnunu).*(y2./y12./(1+y22./y12)-y2./yysb2.*cosb./(1+y22./yysb2)+(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby).*cotb2-(omnunu).*y2./yyas.*((omnunu-a./yy2q).*cotb-y1./yya.*(nu+a./yy2q))./yy2q.*y1+(omnunu).*y2./yya.*(a./yy2th.*y1.*cotb-1./yya.*(nu+a./yy2q)+y12./yyas.*(nu+a./yy2q)./yy2q+y12./yya.*a./yy2th)-(omnunu).*y2.*cosb.*cotb./yyycb2.*cbay.*iyysb-(omnunu).*y2.*cosb.*cotb./yyycb.*a./yy2th.*y1-3.*a.*y2.*(y3+a).*cotb./yy2fh.*y1-y2.*(y3+a)./yy2th./yya.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2).*y1-y2.*(y3+a)./yy2./yyas.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2).*y1+y2.*(y3+a)./yy2q./yya.*(1./yya.*nay-y12./yyas.*nay./yy2q-y12./yya.*a./yy2th+a./yy2-aa.*y12./yy22)-y2.*(y3+a)./yy2th./yyycb.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2).*y1-y2.*(y3+a)./yy2q./yyycb2.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2).*iyysb+y2.*(y3+a)./yy2q./yyycb.*(-cosb./yyycb2.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb).*iyysb+cosb./yyycb.*(iyy2q.*cosb.*y1.*((omnunu).*cosb-a./yy2q).*cotb+ycbya.*a./yy2th.*y1.*cotb+(tmnunu).*(iyy2q.*sinb.*y1-1).*cosb)+aa.*y3aa.*cosb.*cotb./yy22.*y1))./pi./(1-nu));
e11 = e11 + B2.*(oe.*((-1+nunu).*(isysq.*y1./(sysq-y3)+iyy2q.*y1./yya-cosb.*((isysq.*y1-sinb)./smymy+iyysb./yyycb))+2.*y1.*(isysq./(sysq-y3)+iyy2q./yya)+y12.*(-1./systh./(sysq-y3).*y1-1./(sys)./sy2.*y1-1./yy2th./yya.*y1-iyy2./yyas.*y1)+cosb.*ssby./sysq./smymy+(y1cb-y3sb).*(isysq.*sinb.*y1-1)./sysq./smymy-(y1cb-y3sb).*ssby./systh./smymy.*y1-(y1cb-y3sb).*ssby./sysq./syy2.*(isysq.*y1-sinb)+cosb.*ysby./yy2q./yyycb+yysb.*(iyy2q.*sinb.*y1-1)./yy2q./yyycb-yysb.*ysby./yy2th./yyycb.*y1-yysb.*ysby./yy2q./yyycb2.*iyysb)./pi./(1-nu)+1./4.*((omnunu).*(((tmnunu).*cotb2+nu)./yy2q.*y1./yya-((tmnunu).*cotb2+1).*cosb.*iyysb./yyycb)-(omnunu)./yyas.*((-1+nunu).*y1.*cotb+nu.*y3aa-a+a.*y1.*cotb./yy2q+y12./yya.*(nu+a./yy2q))./yy2q.*y1+(omnunu)./yya.*((-1+nunu).*cotb+a.*cotb./yy2q-a.*y12.*cotb./yy2th+2.*y1./yya.*(nu+a./yy2q)-y13./yyas.*(nu+a./yy2q)./yy2q-y13./yya.*a./yy2th)+(omnunu).*cotb./yyycb2.*(yysb.*cosb-a.*ysby./yy2q./cosb).*iyysb-(omnunu).*cotb./yyycb.*(cosb2-a.*(iyy2q.*sinb.*y1-1)./yy2q./cosb+a.*ysby./yy2th./cosb.*y1)-a.*(y3+a).*cotb./yy2th+3.*a.*y12.*(y3+a).*cotb./yy2fh-(y3+a)./yyas.*(nunu+iyy2q.*((omnunu).*y1.*cotb+a)-y12./yy2q./yya.*nay-a.*y12./yy2th)./yy2q.*y1+(y3+a)./yya.*(-1./yy2th.*((omnunu).*y1.*cotb+a).*y1+iyy2q.*(omnunu).*cotb-2.*y1./yy2q./yya.*nay+y13./yy2th./yya.*nay+y13./yy2./yyas.*nay+y13./yy22./yya.*a-aa./yy2th.*y1+3.*a.*y13./yy2fh)-(y3+a).*cotb./yyycb2.*(-cosb.*sinb+a.*y1.*y3aa./yy2th./cosb+ysby./yy2q.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb))).*iyysb+(y3+a).*cotb./yyycb.*(a.*y3aa./yy2th./cosb-3.*a.*y12.*y3aa./yy2fh./cosb+(iyy2q.*sinb.*y1-1)./yy2q.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb))-ysby./yy2th.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb)).*y1+ysby./yy2q.*(-iyy2q.*cosb.*y1./yyycb.*(1+a./yy2q./cosb)+yCyY2.*(1+a./yy2q./cosb).*iyysb+yCyY.*a./yy2th./cosb.*y1)))./pi./(1-nu));
e11 = e11 + B3.*(oe.*y2.*sinb.*((isysq.*sinb.*y1-1)./sysq./smymy-ssby./systh./smymy.*y1-ssby./sysq./syy2.*(isysq.*y1-sinb)+(iyy2q.*sinb.*y1-1)./yy2q./yyycb-ysby./yy2th./yyycb.*y1-ysby./yy2q./yyycb2.*iyysb)./pi./(1-nu)+1./4.*((omnunu).*(-y2./yyas.*oay./yy2q.*y1-y2./yya.*a./yy2th.*y1+y2.*cosb./yyycb2.*cbay.*iyysb+y2.*cosb./yyycb.*a./yy2th.*y1)+y2.*(y3+a)./yy2th.*(a./yy2+1./yya).*y1-y2.*(y3+a)./yy2q.*(-aa./yy22.*y1-1./yyas./yy2q.*y1)-y2.*(y3+a).*cosb./yy2th./yyycb.*(yCyY.*cbay+a.*y3aa./yy2).*y1-y2.*(y3+a).*cosb./yy2q./yyycb2.*(yCyY.*cbay+a.*y3aa./yy2).*iyysb+y2.*(y3+a).*cosb./yy2q./yyycb.*(iyy2q.*cosb.*y1./yyycb.*cbay-yCyY2.*cbay.*iyysb-yCyY.*a./yy2th.*y1-aa.*y3aa./yy22.*y1))./pi./(1-nu));

e22 = B1.*(oe.*((omnunu).*(isysq.*y2./(sysq-y3)+iyy2q.*y2./yya-cosb.*(isysq.*y2./smymy+iyy2q.*y2./yyycb))-2.*y2.*(isysq./(sysq-y3)+iyy2q./yya-cosb.*(isysq./smymy+iyy2q./yyycb))-y22.*(-1./systh./(sysq-y3).*y2-1./(sys)./sy2.*y2-1./yy2th./yya.*y2-iyy2./yyas.*y2-cosb.*(-1./systh./smymy.*y2-1./(sys)./syy2.*y2-1./yy2th./yyycb.*y2-iyy2./yyycb2.*y2)))./pi./(1-nu)+1./4.*((omnunu).*(((tmnunu).*cotb2-nu)./yy2q.*y2./yya-((tmnunu).*cotb2+omnunu).*cosb./yy2q.*y2./yyycb)+(omnunu)./yyas.*(y1.*cotb.*(omnunu-a./yy2q)+nu.*y3aa-a+y22./yya.*(nu+a./yy2q))./yy2q.*y2-(omnunu)./yya.*(a.*y1.*cotb./yy2th.*y2+2.*y2./yya.*(nu+a./yy2q)-y23./yyas.*(nu+a./yy2q)./yy2q-y23./yya.*a./yy2th)+(omnunu).*yysb.*cotb./yyycb2.*cbay./yy2q.*y2+(omnunu).*yysb.*cotb./yyycb.*a./yy2th.*y2+3.*a.*y2.*(y3+a).*cotb./yy2fh.*y1-(y3+a)./yyas.*(-nunu+iyy2q.*((omnunu).*y1.*cotb-a)+y22./yy2q./yya.*nay+a.*y22./yy2th)./yy2q.*y2+(y3+a)./yya.*(-1./yy2th.*((omnunu).*y1.*cotb-a).*y2+2.*y2./yy2q./yya.*nay-y23./yy2th./yya.*nay-y23./yy2./yyas.*nay-y23./yy22./yya.*a+aa./yy2th.*y2-3.*a.*y23./yy2fh)-(y3+a)./yyycb2.*(cosb2-iyy2q.*((omnunu).*yysb.*cotb+a.*cosb)+a.*y3aa.*yysb.*cotb./yy2th-iyy2q./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya))./yy2q.*y2+(y3+a)./yyycb.*(1./yy2th.*((omnunu).*yysb.*cotb+a.*cosb).*y2-3.*a.*y3aa.*yysb.*cotb./yy2fh.*y2+1./yy2th./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya).*y2+iyy2./yyycb2.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya).*y2-iyy2q./yyycb.*(2.*y2.*cosb2+a.*yysb.*cotb./yy2th.*ycbya.*y2-a.*yysb.*cotb./yy2.*cosb.*y2)))./pi./(1-nu));
e22 = e22 + B2.*(oe.*((tmnunu).*(-2./y1./(1+y22./y12)+1./(y1cb-y3sb)./(1+y22./ycys2)+(sysq.*sinb./yyyy+y22./sysq.*sinb./yyyy-2.*y22.*sysq.*sinb./yyyy2.*cosb)./(1+y22.*(sys).*sinb2./yyyy2)+1./yysb./(1+y22./yysb2)+(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby)+y1.*(isysq./(sysq-y3)+iyy2q./yya)+y1.*y2.*(-1./systh./(sysq-y3).*y2-1./(sys)./sy2.*y2-1./yy2th./yya.*y2-iyy2./yyas.*y2)-(y1cb-y3sb)./sysq./smymy-yysb./yy2q./yyycb-y2.*(-(y1cb-y3sb)./systh./smymy.*y2-(y1cb-y3sb)./(sys)./syy2.*y2-yysb./yy2th./yyycb.*y2-yysb./yy2./yyycb2.*y2))./pi./(1-nu)+1./4.*((tmnunu).*(omnunu).*(-1./y1./(1+y22./y12)+1./yysb./(1+y22./yysb2)+(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby).*cotb2+(omnunu)./yya.*((-1+nunu+a./yy2q).*cotb+y1./yya.*(nu+a./yy2q))-(omnunu).*y22./yyas.*((-1+nunu+a./yy2q).*cotb+y1./yya.*(nu+a./yy2q))./yy2q+(omnunu).*y2./yya.*(-a./yy2th.*y2.*cotb-y1./yyas.*(nu+a./yy2q)./yy2q.*y2-y2./yya.*a./yy2th.*y1)-(omnunu).*cotb./yyycb.*(1+a./yy2q./cosb)+(omnunu).*y22.*cotb./yyycb2.*(1+a./yy2q./cosb)./yy2q+(omnunu).*y22.*cotb./yyycb.*a./yy2th./cosb-a.*(y3+a).*cotb./yy2th+3.*a.*y22.*(y3+a).*cotb./yy2fh+(y3+a)./yy2q./yya.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya))-y22.*(y3+a)./yy2th./yya.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya))-y22.*(y3+a)./yy2./yyas.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya))+y2.*(y3+a)./yy2q./yya.*(nunu.*y1./yyas./yy2q.*y2+a.*y1./yy2th.*(iyy2q+1./yya).*y2-a.*y1./yy2q.*(-1./yy2th.*y2-1./yyas./yy2q.*y2))+(y3+a).*cotb./yy2q./yyycb.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb)-y22.*(y3+a).*cotb./yy2th./yyycb.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb)-y22.*(y3+a).*cotb./yy2./yyycb2.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb)+y2.*(y3+a).*cotb./yy2q./yyycb.*(iyy2q.*cosb.*y2./yyycb.*(1+a./yy2q./cosb)-yCyY2.*(1+a./yy2q./cosb)./yy2q.*y2-yCyY.*a./yy2th./cosb.*y2-aa.*y3aa./yy22./cosb.*y2))./pi./(1-nu));
e22 = e22 + B3.*(oe.*((omnunu).*sinb.*(isysq.*y2./smymy+iyy2q.*y2./yyycb)-2.*y2.*sinb.*(isysq./smymy+iyy2q./yyycb)-y22.*sinb.*(-1./systh./smymy.*y2-1./(sys)./syy2.*y2-1./yy2th./yyycb.*y2-iyy2./yyycb2.*y2))./pi./(1-nu)+1./4.*((omnunu).*(-sinb./yy2q.*y2./yyycb+y2./yyas.*oay./yy2q.*y1+y2./yya.*a./yy2th.*y1-yysb./yyycb2.*cbay./yy2q.*y2-yysb./yyycb.*a./yy2th.*y2)-y2.*(y3+a)./yy2th.*(a./yy2+1./yya).*y1+y1.*(y3+a)./yy2q.*(-aa./yy22.*y2-1./yyas./yy2q.*y2)+(y3+a)./yyycb2.*(sinb.*(cosb-a./yy2q)+yysb./yy2q.*(1+a.*y3aa./yy2)-iyy2q./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya))./yy2q.*y2-(y3+a)./yyycb.*(sinb.*a./yy2th.*y2-yysb./yy2th.*(1+a.*y3aa./yy2).*y2-2.*yysb./yy2fh.*a.*y3aa.*y2+1./yy2th./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya).*y2+iyy2./yyycb2.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya).*y2-iyy2q./yyycb.*(2.*y2.*cosb.*sinb+a.*yysb./yy2th.*ycbya.*y2-a.*yysb./yy2.*cosb.*y2)))./pi./(1-nu));

e33 = B1.*(oe.*y2.*(-1./systh.*y3+oh./yy2th.*ty3fa-cosb.*((isysq.*cosb.*y3-1)./sysq./smymy-scby./systh./smymy.*y3-scby./sysq./syy2.*(isysq.*y3-cosb)-(oh./yy2q.*cosb.*ty3fa+1)./yy2q./yyycb+oh.*ycbya./yy2th./yyycb.*ty3fa+ycbya./yy2q./yyycb2.*(hytcb)))./pi./(1-nu)+1./4.*((tmnunu).*((omnunu).*(-y2./yysb2.*sinb./(1+y22./yysb2)+(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby).*cotb-y2./yyas.*nay.*hyto-oh.*y2./yya.*a./yy2th.*ty3fa+y2.*cosb./yyycb2.*cbay.*(hytcb)+oh.*y2.*cosb./yyycb.*a./yy2th.*ty3fa)+y2./yy2q.*(nunu./yya+a./yy2)-oh.*y2.*(y3+a)./yy2th.*(nunu./yya+a./yy2).*ty3fa+y2.*(y3+a)./yy2q.*(-nunu./yyas.*hyto-a./yy22.*ty3fa)+y2.*cosb./yy2q./yyycb.*(omnunu-yCyY.*cbay-a.*y3aa./yy2)-oh.*y2.*(y3+a).*cosb./yy2th./yyycb.*(omnunu-yCyY.*cbay-a.*y3aa./yy2).*ty3fa-y2.*(y3+a).*cosb./yy2q./yyycb2.*(omnunu-yCyY.*cbay-a.*y3aa./yy2).*(hytcb)+y2.*(y3+a).*cosb./yy2q./yyycb.*(-(oh./yy2q.*cosb.*ty3fa+1)./yyycb.*cbay+yCyY2.*cbay.*(hytcb)+oh.*yCyY.*a./yy2th.*ty3fa-a./yy2+a.*y3aa./yy22.*ty3fa))./pi./(1-nu));
e33 = e33 + B2.*(oe.*((-1+nunu).*sinb.*((isysq.*y3-cosb)./smymy-(hytcb)./yyycb)-y1.*(-1./systh.*y3+oh./yy2th.*ty3fa)-sinb.*scby./sysq./smymy+(y1cb-y3sb).*(isysq.*cosb.*y3-1)./sysq./smymy-(y1cb-y3sb).*scby./systh./smymy.*y3-(y1cb-y3sb).*scby./sysq./syy2.*(isysq.*y3-cosb)-sinb.*ycbya./yy2q./yyycb-yysb.*(oh./yy2q.*cosb.*ty3fa+1)./yy2q./yyycb+oh.*yysb.*ycbya./yy2th./yyycb.*ty3fa+yysb.*ycbya./yy2q./yyycb2.*(hytcb))./pi./(1-nu)+1./4.*((-2+nunu).*(omnunu).*cotb.*(hyto./yya-cosb.*(hytcb)./yyycb)+(tmnunu).*y1./yyas.*nay.*hyto+oh.*(tmnunu).*y1./yya.*a./yy2th.*ty3fa+(tmnunu).*sinb./yyycb.*cbay-(tmnunu).*yysb./yyycb2.*cbay.*(hytcb)-oh.*(tmnunu).*yysb./yyycb.*a./yy2th.*ty3fa+iyy2q.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2)-oh.*(y3+a)./yy2th.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2).*ty3fa+(y3+a)./yy2q.*(nunu.*y1./yyas.*hyto+a.*y1y22.*ty3fa)-1./yyycb.*(cosb.*sinb+ycbya.*cotb./yy2q.*((tmnunu).*cosb-yCyY)+a./yy2q.*sby7)+(y3+a)./yyycb2.*(cosb.*sinb+ycbya.*cotb./yy2q.*((tmnunu).*cosb-yCyY)+a./yy2q.*sby7).*(hytcb)-(y3+a)./yyycb.*((oh./yy2q.*cosb.*ty3fa+1).*cotb./yy2q.*((tmnunu).*cosb-yCyY)-oh.*ycbya.*cotb./yy2th.*((tmnunu).*cosb-yCyY).*ty3fa+ycbya.*cotb./yy2q.*(-(oh./yy2q.*cosb.*ty3fa+1)./yyycb+yCyY2.*(hytcb))-oh.*a./yy2th.*sby7.*ty3fa+a./yy2q.*(-yysb./yy2-y3aa.*sinb./yy2+y3aa.*yysb./yy22.*ty3fa-sinb.*ycbya./yy2q./yyycb-yysb.*(oh./yy2q.*cosb.*ty3fa+1)./yy2q./yyycb+oh.*yysb.*ycbya./yy2th./yyycb.*ty3fa+yysb.*ycbya./yy2q./yyycb2.*(hytcb))))./pi./(1-nu));
e33 = e33 + B3.*(oe.*((tmnunu).*(y2./ycys2.*sinb./(1+y22./ycys2)+(y2./sysq.*sinb./yyyy.*y3+y2.*sysq.*sinb2./yyyy2.*y1)./(1+y22.*(sys).*sinb2./yyyy2)+y2./yysb2.*sinb./(1+y22./yysb2)-(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby)+y2.*sinb.*((isysq.*cosb.*y3-1)./sysq./smymy-scby./systh./smymy.*y3-scby./sysq./syy2.*(isysq.*y3-cosb)-(oh./yy2q.*cosb.*ty3fa+1)./yy2q./yyycb+oh.*ycbya./yy2th./yyycb.*ty3fa+ycbya./yy2q./yyycb2.*(hytcb)))./pi./(1-nu)+1./4.*((tmnunu).*(-y2./yysb2.*sinb./(1+y22./yysb2)+(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby)-(tmnunu).*y2.*sinb./yyycb2.*cbay.*(hytcb)-oh.*(tmnunu).*y2.*sinb./yyycb.*a./yy2th.*ty3fa+y2.*sinb./yy2q./yyycb.*(1+yCyY.*cbay+a.*y3aa./yy2)-oh.*y2.*(y3+a).*sinb./yy2th./yyycb.*(1+yCyY.*cbay+a.*y3aa./yy2).*ty3fa-y2.*(y3+a).*sinb./yy2q./yyycb2.*(1+yCyY.*cbay+a.*y3aa./yy2).*(hytcb)+y2.*(y3+a).*sinb./yy2q./yyycb.*((oh./yy2q.*cosb.*ty3fa+1)./yyycb.*cbay-yCyY2.*cbay.*(hytcb)-oh.*yCyY.*a./yy2th.*ty3fa+a./yy2-a.*y3aa./yy22.*ty3fa))./pi./(1-nu));

e12 = oh.*B1.*(oe.*((tmnunu).*(-2./y1./(1+y22./y12)+1./(y1cb-y3sb)./(1+y22./ycys2)+(sysq.*sinb./yyyy+y22./sysq.*sinb./yyyy-2.*y22.*sysq.*sinb./yyyy2.*cosb)./(1+y22.*(sys).*sinb2./yyyy2)+1./yysb./(1+y22./yysb2)+(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby)-y1.*(isysq./(sysq-y3)+iyy2q./yya)-y1.*y2.*(-1./systh./(sysq-y3).*y2-1./(sys)./sy2.*y2-1./yy2th./yya.*y2-iyy2./yyas.*y2)-cosb.*(ssby./sysq./smymy+ysby./yy2q./yyycb)-y2.*cosb.*(1./(sys).*sinb.*y2./smymy-ssby./systh./smymy.*y2-ssby./(sys)./syy2.*y2+iyy2.*sinb.*y2./yyycb-ysby./yy2th./yyycb.*y2-ysby./yy2./yyycb2.*y2))./pi./(1-nu)+1./4.*((-2+nunu).*(omnunu).*(-1./y1./(1+y22./y12)+1./yysb./(1+y22./yysb2)+(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby).*cotb2+(omnunu)./yya.*((omnunu-a./yy2q).*cotb-y1./yya.*(nu+a./yy2q))-(omnunu).*y22./yyas.*((omnunu-a./yy2q).*cotb-y1./yya.*(nu+a./yy2q))./yy2q+(omnunu).*y2./yya.*(a./yy2th.*y2.*cotb+y1./yyas.*(nu+a./yy2q)./yy2q.*y2+y2./yya.*a./yy2th.*y1)+(omnunu).*cosb.*cotb./yyycb.*cbay-(omnunu).*y22cb.*cotb./yyycb2.*cbay./yy2q-(omnunu).*y22cb.*cotb./yyycb.*a./yy2th+a.*(y3+a).*cotb./yy2th-3.*a.*y22.*(y3+a).*cotb./yy2fh+(y3+a)./yy2q./yya.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2)-y22.*(y3+a)./yy2th./yya.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2)-y22.*(y3+a)./yy2./yyas.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2)+y2.*(y3+a)./yy2q./yya.*(-y1./yyas.*nay./yy2q.*y2-y2./yya.*a./yy2th.*y1-aa.*y1y22.*y2)+(y3+a)./yy2q./yyycb.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2)-y22.*(y3+a)./yy2th./yyycb.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2)-y22.*(y3+a)./yy2./yyycb2.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2)+y2.*(y3+a)./yy2q./yyycb.*(-cosb./yyycb2.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)./yy2q.*y2+cosb./yyycb.*(iyy2q.*cosb.*y2.*((omnunu).*cosb-a./yy2q).*cotb+ycbya.*a./yy2th.*y2.*cotb+(tmnunu)./yy2q.*sinb.*y2.*cosb)+aa.*y3aa.*cosb.*cotb./yy22.*y2))./pi./(1-nu));
e12 = e12 + oh.*B2.*(oe.*((-1+nunu).*(isysq.*y2./(sysq-y3)+iyy2q.*y2./yya-cosb.*(isysq.*y2./smymy+iyy2q.*y2./yyycb))+y12.*(-1./systh./(sysq-y3).*y2-1./(sys)./sy2.*y2-1./yy2th./yya.*y2-iyy2./yyas.*y2)+(y1cb-y3sb)./(sys).*sinb.*y2./smymy-(y1cb-y3sb).*ssby./systh./smymy.*y2-(y1cb-y3sb).*ssby./(sys)./syy2.*y2+yysb./yy2.*sinb.*y2./yyycb-yysb.*ysby./yy2th./yyycb.*y2-yysb.*ysby./yy2./yyycb2.*y2)./pi./(1-nu)+1./4.*((omnunu).*(((tmnunu).*cotb2+nu)./yy2q.*y2./yya-((tmnunu).*cotb2+1).*cosb./yy2q.*y2./yyycb)-(omnunu)./yyas.*((-1+nunu).*y1.*cotb+nu.*y3aa-a+a.*y1.*cotb./yy2q+y12./yya.*(nu+a./yy2q))./yy2q.*y2+(omnunu)./yya.*(-a.*y1.*cotb./yy2th.*y2-y12./yyas.*(nu+a./yy2q)./yy2q.*y2-y12./yya.*a./yy2th.*y2)+(omnunu).*cotb./yyycb2.*(yysb.*cosb-a.*ysby./yy2q./cosb)./yy2q.*y2-(omnunu).*cotb./yyycb.*(-a./yy2.*sinb.*y2./cosb+a.*ysby./yy2th./cosb.*y2)+3.*a.*y2.*(y3+a).*cotb./yy2fh.*y1-(y3+a)./yyas.*(nunu+iyy2q.*((omnunu).*y1.*cotb+a)-y12./yy2q./yya.*nay-a.*y12./yy2th)./yy2q.*y2+(y3+a)./yya.*(-1./yy2th.*((omnunu).*y1.*cotb+a).*y2+y12./yy2th./yya.*nay.*y2+y12./yy2./yyas.*nay.*y2+y12./yy22./yya.*a.*y2+3.*a.*y12./yy2fh.*y2)-(y3+a).*cotb./yyycb2.*(-cosb.*sinb+a.*y1.*y3aa./yy2th./cosb+ysby./yy2q.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb)))./yy2q.*y2+(y3+a).*cotb./yyycb.*(-3.*a.*y1.*y3aa./yy2fh./cosb.*y2+iyy2.*sinb.*y2.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb))-ysby./yy2th.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb)).*y2+ysby./yy2q.*(-iyy2q.*cosb.*y2./yyycb.*(1+a./yy2q./cosb)+yCyY2.*(1+a./yy2q./cosb)./yy2q.*y2+yCyY.*a./yy2th./cosb.*y2)))./pi./(1-nu));
e12 = e12 + oh.*B3.*(oe.*sinb.*(ssby./sysq./smymy+ysby./yy2q./yyycb)./pi./(1-nu)+oe.*y2.*sinb.*(1./(sys).*sinb.*y2./smymy-ssby./systh./smymy.*y2-ssby./(sys)./syy2.*y2+iyy2.*sinb.*y2./yyycb-ysby./yy2th./yyycb.*y2-ysby./yy2./yyycb2.*y2)./pi./(1-nu)+1./4.*((omnunu).*(1./yya.*oay-y22./yyas.*oay./yy2q-y22./yya.*a./yy2th-cosb./yyycb.*cbay+y22cb./yyycb2.*cbay./yy2q+y22cb./yyycb.*a./yy2th)-(y3+a)./yy2q.*(a./yy2+1./yya)+y22.*(y3+a)./yy2th.*(a./yy2+1./yya)-y2.*(y3+a)./yy2q.*(-aa./yy22.*y2-1./yyas./yy2q.*y2)+(y3+a).*cosb./yy2q./yyycb.*(yCyY.*cbay+a.*y3aa./yy2)-y22.*(y3+a).*cosb./yy2th./yyycb.*(yCyY.*cbay+a.*y3aa./yy2)-y22.*(y3+a).*cosb./yy2./yyycb2.*(yCyY.*cbay+a.*y3aa./yy2)+y2.*(y3+a).*cosb./yy2q./yyycb.*(iyy2q.*cosb.*y2./yyycb.*cbay-yCyY2.*cbay./yy2q.*y2-yCyY.*a./yy2th.*y2-aa.*y3aa./yy22.*y2))./pi./(1-nu))+oh.*B1.*(oe.*((omnunu).*(isysq.*y1./(sysq-y3)+iyy2q.*y1./yya-cosb.*((isysq.*y1-sinb)./smymy+iyysb./yyycb))-y22.*(-1./systh./(sysq-y3).*y1-1./(sys)./sy2.*y1-1./yy2th./yya.*y1-iyy2./yyas.*y1-cosb.*(-1./systh./smymy.*y1-isysq./syy2.*(isysq.*y1-sinb)-1./yy2th./yyycb.*y1-iyy2q./yyycb2.*iyysb)))./pi./(1-nu)+1./4.*((omnunu).*(((tmnunu).*cotb2-nu)./yy2q.*y1./yya-((tmnunu).*cotb2+omnunu).*cosb.*iyysb./yyycb)+(omnunu)./yyas.*(y1.*cotb.*(omnunu-a./yy2q)+nu.*y3aa-a+y22./yya.*(nu+a./yy2q))./yy2q.*y1-(omnunu)./yya.*((omnunu-a./yy2q).*cotb+a.*y12.*cotb./yy2th-y22./yyas.*(nu+a./yy2q)./yy2q.*y1-y22./yya.*a./yy2th.*y1)-(omnunu).*cosb.*cotb./yyycb.*cbay+(omnunu).*yysb.*cotb./yyycb2.*cbay.*iyysb+(omnunu).*yysb.*cotb./yyycb.*a./yy2th.*y1-a.*(y3+a).*cotb./yy2th+3.*a.*y12.*(y3+a).*cotb./yy2fh-(y3+a)./yyas.*(-nunu+iyy2q.*((omnunu).*y1.*cotb-a)+y22./yy2q./yya.*nay+a.*y22./yy2th)./yy2q.*y1+(y3+a)./yya.*(-1./yy2th.*((omnunu).*y1.*cotb-a).*y1+iyy2q.*(omnunu).*cotb-y22./yy2th./yya.*nay.*y1-y22./yy2./yyas.*nay.*y1-y22./yy22./yya.*a.*y1-3.*a.*y22./yy2fh.*y1)-(y3+a)./yyycb2.*(cosb2-iyy2q.*((omnunu).*yysb.*cotb+a.*cosb)+a.*y3aa.*yysb.*cotb./yy2th-iyy2q./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya)).*iyysb+(y3+a)./yyycb.*(1./yy2th.*((omnunu).*yysb.*cotb+a.*cosb).*y1-iyy2q.*(omnunu).*cosb.*cotb+a.*y3aa.*cosb.*cotb./yy2th-3.*a.*y3aa.*yysb.*cotb./yy2fh.*y1+1./yy2th./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya).*y1+iyy2q./yyycb2.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya).*iyysb-iyy2q./yyycb.*(-a.*cosb.*cotb./yy2q.*ycbya+a.*yysb.*cotb./yy2th.*ycbya.*y1-a.*yysb.*cotb./yy2.*cosb.*y1)))./pi./(1-nu))+oh.*B2.*(oe.*((tmnunu).*(2.*y2./y12./(1+y22./y12)-y2./ycys2.*cosb./(1+y22./ycys2)+(y2./sysq.*sinb./yyyy.*y1-y2.*sysq.*sinb./yyyy2.*(2.*y1cb-y3sb))./(1+y22.*(sys).*sinb2./yyyy2)-y2./yysb2.*cosb./(1+y22./yysb2)+(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby)+y2.*(isysq./(sysq-y3)+iyy2q./yya)+y1.*y2.*(-1./systh./(sysq-y3).*y1-1./(sys)./sy2.*y1-1./yy2th./yya.*y1-iyy2./yyas.*y1)-y2.*(cosb./sysq./smymy-(y1cb-y3sb)./systh./smymy.*y1-(y1cb-y3sb)./sysq./syy2.*(isysq.*y1-sinb)+cosb./yy2q./yyycb-yysb./yy2th./yyycb.*y1-yysb./yy2q./yyycb2.*iyysb))./pi./(1-nu)+1./4.*((tmnunu).*(omnunu).*(y2./y12./(1+y22./y12)-y2./yysb2.*cosb./(1+y22./yysb2)+(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby).*cotb2-(omnunu).*y2./yyas.*((-1+nunu+a./yy2q).*cotb+y1./yya.*(nu+a./yy2q))./yy2q.*y1+(omnunu).*y2./yya.*(-a./yy2th.*y1.*cotb+1./yya.*(nu+a./yy2q)-y12./yyas.*(nu+a./yy2q)./yy2q-y12./yya.*a./yy2th)+(omnunu).*y2.*cotb./yyycb2.*(1+a./yy2q./cosb).*iyysb+(omnunu).*y2.*cotb./yyycb.*a./yy2th./cosb.*y1+3.*a.*y2.*(y3+a).*cotb./yy2fh.*y1-y2.*(y3+a)./yy2th./yya.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya)).*y1-y2.*(y3+a)./yy2./yyas.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya)).*y1+y2.*(y3+a)./yy2q./yya.*(-nunu./yya+nunu.*y12./yyas./yy2q-a./yy2q.*(iyy2q+1./yya)+a.*y12./yy2th.*(iyy2q+1./yya)-a.*y1./yy2q.*(-1./yy2th.*y1-1./yyas./yy2q.*y1))-y2.*(y3+a).*cotb./yy2th./yyycb.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb).*y1-y2.*(y3+a).*cotb./yy2q./yyycb2.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb).*iyysb+y2.*(y3+a).*cotb./yy2q./yyycb.*(iyy2q.*cosb.*y1./yyycb.*(1+a./yy2q./cosb)-yCyY2.*(1+a./yy2q./cosb).*iyysb-yCyY.*a./yy2th./cosb.*y1-aa.*y3aa./yy22./cosb.*y1))./pi./(1-nu))+oh.*B3.*(oe.*((omnunu).*sinb.*((isysq.*y1-sinb)./smymy+iyysb./yyycb)-y22.*sinb.*(-1./systh./smymy.*y1-isysq./syy2.*(isysq.*y1-sinb)-1./yy2th./yyycb.*y1-iyy2q./yyycb2.*iyysb))./pi./(1-nu)+1./4.*((omnunu).*(-sinb.*iyysb./yyycb-1./yya.*oay+y12./yyas.*oay./yy2q+y12./yya.*a./yy2th+cosb./yyycb.*cbay-yysb./yyycb2.*cbay.*iyysb-yysb./yyycb.*a./yy2th.*y1)+(y3+a)./yy2q.*(a./yy2+1./yya)-y12.*(y3+a)./yy2th.*(a./yy2+1./yya)+y1.*(y3+a)./yy2q.*(-aa./yy22.*y1-1./yyas./yy2q.*y1)+(y3+a)./yyycb2.*(sinb.*(cosb-a./yy2q)+yysb./yy2q.*(1+a.*y3aa./yy2)-iyy2q./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya)).*iyysb-(y3+a)./yyycb.*(sinb.*a./yy2th.*y1+cosb./yy2q.*(1+a.*y3aa./yy2)-yysb./yy2th.*(1+a.*y3aa./yy2).*y1-2.*yysb./yy2fh.*a.*y3aa.*y1+1./yy2th./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya).*y1+iyy2q./yyycb2.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya).*iyysb-iyy2q./yyycb.*(-a.*cosb./yy2q.*ycbya+a.*yysb./yy2th.*ycbya.*y1-a.*yysb./yy2.*cosb.*y1)))./pi./(1-nu));

e13 = oh.*B1.*(oe.*((tmnunu).*(y2./ycys2.*sinb./(1+y22./ycys2)+(y2./sysq.*sinb./yyyy.*y3+y2.*sysq.*sinb2./yyyy2.*y1)./(1+y22.*(sys).*sinb2./yyyy2)-y2./yysb2.*sinb./(1+y22./yysb2)+(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby)-y1.*y2.*(-1./systh./(sysq-y3).*y3-isysq./sy2.*(isysq.*y3-1)-oh./yy2th./yya.*ty3fa-iyy2q./yyas.*hyto)-y2.*cosb.*(1./(sys).*sinb.*y3./smymy-ssby./systh./smymy.*y3-ssby./sysq./syy2.*(isysq.*y3-cosb)+oh./yy2.*sinb.*ty3fa./yyycb-oh.*ysby./yy2th./yyycb.*ty3fa-ysby./yy2q./yyycb2.*(hytcb)))./pi./(1-nu)+1./4.*((-2+nunu).*(omnunu).*(-y2./yysb2.*sinb./(1+y22./yysb2)+(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby).*cotb2-(omnunu).*y2./yyas.*((omnunu-a./yy2q).*cotb-y1./yya.*(nu+a./yy2q)).*hyto+(omnunu).*y2./yya.*(oh.*a./yy2th.*ty3fa.*cotb+y1./yyas.*(nu+a./yy2q).*hyto+oh.*y1./yya.*a./yy2th.*ty3fa)-(omnunu).*y2.*cosb.*cotb./yyycb2.*cbay.*(hytcb)-oh.*(omnunu).*y2.*cosb.*cotb./yyycb.*a./yy2th.*ty3fa+a./yy2th.*y2.*cotb-th.*a.*y2.*(y3+a).*cotb./yy2fh.*ty3fa+y2./yy2q./yya.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2)-oh.*y2.*(y3+a)./yy2th./yya.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2).*ty3fa-y2.*(y3+a)./yy2q./yyas.*((-1+nunu).*cotb+y1./yya.*nay+a.*y1./yy2).*hyto+y2.*(y3+a)./yy2q./yya.*(-y1./yyas.*nay.*hyto-oh.*y1./yya.*a./yy2th.*ty3fa-a.*y1y22.*ty3fa)+y2./yy2q./yyycb.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2)-oh.*y2.*(y3+a)./yy2th./yyycb.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2).*ty3fa-y2.*(y3+a)./yy2q./yyycb2.*(cosb./yyycb.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb)-a.*y3aa.*cosb.*cotb./yy2).*(hytcb)+y2.*(y3+a)./yy2q./yyycb.*(-cosb./yyycb2.*(ycbya.*((omnunu).*cosb-a./yy2q).*cotb+(tmnunu).*ysby.*cosb).*(hytcb)+cosb./yyycb.*((oh./yy2q.*cosb.*ty3fa+1).*((omnunu).*cosb-a./yy2q).*cotb+oh.*ycbya.*a./yy2th.*ty3fa.*cotb+oh.*(tmnunu)./yy2q.*sinb.*ty3fa.*cosb)-a.*cosb.*cotb./yy2+a.*y3aa.*cosb.*cotb./yy22.*ty3fa))./pi./(1-nu));
e13 = e13 + oh.*B2.*(oe.*((-1+nunu).*((isysq.*y3-1)./(sysq-y3)+hyto./yya-cosb.*((isysq.*y3-cosb)./smymy+(hytcb)./yyycb))+y12.*(-1./systh./(sysq-y3).*y3-isysq./sy2.*(isysq.*y3-1)-oh./yy2th./yya.*ty3fa-iyy2q./yyas.*hyto)-sinb.*ssby./sysq./smymy+(y1cb-y3sb)./(sys).*sinb.*y3./smymy-(y1cb-y3sb).*ssby./systh./smymy.*y3-(y1cb-y3sb).*ssby./sysq./syy2.*(isysq.*y3-cosb)+sinb.*ysby./yy2q./yyycb+oh.*yysb./yy2.*sinb.*ty3fa./yyycb-oh.*yysb.*ysby./yy2th./yyycb.*ty3fa-yysb.*ysby./yy2q./yyycb2.*(hytcb))./pi./(1-nu)+1./4.*((omnunu).*(((tmnunu).*cotb2+nu).*hyto./yya-((tmnunu).*cotb2+1).*cosb.*(hytcb)./yyycb)-(omnunu)./yyas.*((-1+nunu).*y1.*cotb+nu.*y3aa-a+a.*y1.*cotb./yy2q+y12./yya.*(nu+a./yy2q)).*hyto+(omnunu)./yya.*(nu-oh.*a.*y1.*cotb./yy2th.*ty3fa-y12./yyas.*(nu+a./yy2q).*hyto-oh.*y12./yya.*a./yy2th.*ty3fa)+(omnunu).*cotb./yyycb2.*(yysb.*cosb-a.*ysby./yy2q./cosb).*(hytcb)-(omnunu).*cotb./yyycb.*(cosb.*sinb-oh.*a./yy2.*sinb.*ty3fa./cosb+oh.*a.*ysby./yy2th./cosb.*ty3fa)-a./yy2th.*y1.*cotb+th.*a.*y1.*(y3+a).*cotb./yy2fh.*ty3fa+1./yya.*(nunu+iyy2q.*((omnunu).*y1.*cotb+a)-y12./yy2q./yya.*nay-a.*y12./yy2th)-(y3+a)./yyas.*(nunu+iyy2q.*((omnunu).*y1.*cotb+a)-y12./yy2q./yya.*nay-a.*y12./yy2th).*hyto+(y3+a)./yya.*(-oh./yy2th.*((omnunu).*y1.*cotb+a).*ty3fa+oh.*y12./yy2th./yya.*nay.*ty3fa+y12./yy2q./yyas.*nay.*hyto+oh.*y12./yy22./yya.*a.*ty3fa+th.*a.*y12./yy2fh.*ty3fa)+cotb./yyycb.*(-cosb.*sinb+a.*y1.*y3aa./yy2th./cosb+ysby./yy2q.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb)))-(y3+a).*cotb./yyycb2.*(-cosb.*sinb+a.*y1.*y3aa./yy2th./cosb+ysby./yy2q.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb))).*(hytcb)+(y3+a).*cotb./yyycb.*(a./yy2th./cosb.*y1-th.*a.*y1.*y3aa./yy2fh./cosb.*ty3fa+oh./yy2.*sinb.*ty3fa.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb))-oh.*ysby./yy2th.*((tmnunu).*cosb-yCyY.*(1+a./yy2q./cosb)).*ty3fa+ysby./yy2q.*(-(oh./yy2q.*cosb.*ty3fa+1)./yyycb.*(1+a./yy2q./cosb)+yCyY2.*(1+a./yy2q./cosb).*(hytcb)+oh.*yCyY.*a./yy2th./cosb.*ty3fa)))./pi./(1-nu));
e13 = e13 + oh.*B3.*(oe.*y2.*sinb.*(1./(sys).*sinb.*y3./smymy-ssby./systh./smymy.*y3-ssby./sysq./syy2.*(isysq.*y3-cosb)+oh./yy2.*sinb.*ty3fa./yyycb-oh.*ysby./yy2th./yyycb.*ty3fa-ysby./yy2q./yyycb2.*(hytcb))./pi./(1-nu)+1./4.*((omnunu).*(-y2./yyas.*oay.*hyto-oh.*y2./yya.*a./yy2th.*ty3fa+y2.*cosb./yyycb2.*cbay.*(hytcb)+oh.*y2.*cosb./yyycb.*a./yy2th.*ty3fa)-y2./yy2q.*(a./yy2+1./yya)+oh.*y2.*(y3+a)./yy2th.*(a./yy2+1./yya).*ty3fa-y2.*(y3+a)./yy2q.*(-a./yy22.*ty3fa-1./yyas.*hyto)+y2.*cosb./yy2q./yyycb.*(yCyY.*cbay+a.*y3aa./yy2)-oh.*y2.*(y3+a).*cosb./yy2th./yyycb.*(yCyY.*cbay+a.*y3aa./yy2).*ty3fa-y2.*(y3+a).*cosb./yy2q./yyycb2.*(yCyY.*cbay+a.*y3aa./yy2).*(hytcb)+y2.*(y3+a).*cosb./yy2q./yyycb.*((oh./yy2q.*cosb.*ty3fa+1)./yyycb.*cbay-yCyY2.*cbay.*(hytcb)-oh.*yCyY.*a./yy2th.*ty3fa+a./yy2-a.*y3aa./yy22.*ty3fa))./pi./(1-nu))+oh.*B1.*(oe.*y2.*(-1./systh.*y1+1./yy2th.*y1-cosb.*(1./(sys).*cosb.*y1./smymy-scby./systh./smymy.*y1-scby./sysq./syy2.*(isysq.*y1-sinb)-iyy2.*cosb.*y1./yyycb+ycbya./yy2th./yyycb.*y1+ycbya./yy2q./yyycb2.*iyysb))./pi./(1-nu)+1./4.*((tmnunu).*((omnunu).*(y2./y12./(1+y22./y12)-y2./yysb2.*cosb./(1+y22./yysb2)+(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby).*cotb-y1./yyas.*nay./yy2q.*y2-y2./yya.*a./yy2th.*y1+y2.*cosb./yyycb2.*cbay.*iyysb+y2.*cosb./yyycb.*a./yy2th.*y1)-y2.*(y3+a)./yy2th.*(nunu./yya+a./yy2).*y1+y2.*(y3+a)./yy2q.*(-nunu./yyas./yy2q.*y1-aa./yy22.*y1)-y2.*(y3+a).*cosb./yy2th./yyycb.*(omnunu-yCyY.*cbay-a.*y3aa./yy2).*y1-y2.*(y3+a).*cosb./yy2q./yyycb2.*(omnunu-yCyY.*cbay-a.*y3aa./yy2).*iyysb+y2.*(y3+a).*cosb./yy2q./yyycb.*(-iyy2q.*cosb.*y1./yyycb.*cbay+yCyY2.*cbay.*iyysb+yCyY.*a./yy2th.*y1+aa.*y3aa./yy22.*y1))./pi./(1-nu))+oh.*B2.*(oe.*((-1+nunu).*sinb.*((isysq.*y1-sinb)./smymy-iyysb./yyycb)-isysq+iyy2q-y1.*(-1./systh.*y1+1./yy2th.*y1)+cosb.*scby./sysq./smymy+(y1cb-y3sb)./(sys).*cosb.*y1./smymy-(y1cb-y3sb).*scby./systh./smymy.*y1-(y1cb-y3sb).*scby./sysq./syy2.*(isysq.*y1-sinb)-cosb.*ycbya./yy2q./yyycb-yysb./yy2.*cosb.*y1./yyycb+yysb.*ycbya./yy2th./yyycb.*y1+yysb.*ycbya./yy2q./yyycb2.*iyysb)./pi./(1-nu)+1./4.*((-2+nunu).*(omnunu).*cotb.*(iyy2q.*y1./yya-cosb.*iyysb./yyycb)-(tmnunu)./yya.*nay+(tmnunu).*y12./yyas.*nay./yy2q+(tmnunu).*y12./yya.*a./yy2th+(tmnunu).*cosb./yyycb.*cbay-(tmnunu).*yysb./yyycb2.*cbay.*iyysb-(tmnunu).*yysb./yyycb.*a./yy2th.*y1-(y3+a)./yy2th.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2).*y1+(y3+a)./yy2q.*(-nunu./yya+nunu.*y12./yyas./yy2q-a./yy2+aa.*y12./yy22)+(y3+a)./yyycb2.*(cosb.*sinb+ycbya.*cotb./yy2q.*((tmnunu).*cosb-yCyY)+a./yy2q.*sby7).*iyysb-(y3+a)./yyycb.*(iyy2.*cosb.*y1.*cotb.*((tmnunu).*cosb-yCyY)-ycbya.*cotb./yy2th.*((tmnunu).*cosb-yCyY).*y1+ycbya.*cotb./yy2q.*(-iyy2q.*cosb.*y1./yyycb+yCyY2.*iyysb)-a./yy2th.*sby7.*y1+a./yy2q.*(-y3aa.*cosb./yy2+2.*y3aa.*yysb./yy22.*y1-cosb.*ycbya./yy2q./yyycb-yysb./yy2.*cosb.*y1./yyycb+yysb.*ycbya./yy2th./yyycb.*y1+yysb.*ycbya./yy2q./yyycb2.*iyysb)))./pi./(1-nu))+oh.*B3.*(oe.*((tmnunu).*(-y2./ycys2.*cosb./(1+y22./ycys2)+(y2./sysq.*sinb./yyyy.*y1-y2.*sysq.*sinb./yyyy2.*(2.*y1cb-y3sb))./(1+y22.*(sys).*sinb2./yyyy2)+y2./yysb2.*cosb./(1+y22./yysb2)-(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby)+y2.*sinb.*(1./(sys).*cosb.*y1./smymy-scby./systh./smymy.*y1-scby./sysq./syy2.*(isysq.*y1-sinb)-iyy2.*cosb.*y1./yyycb+ycbya./yy2th./yyycb.*y1+ycbya./yy2q./yyycb2.*iyysb))./pi./(1-nu)+1./4.*((tmnunu).*(y2./y12./(1+y22./y12)-y2./yysb2.*cosb./(1+y22./yysb2)+(y2./yy2q.*sinb./yyysby.*y1-y2.*yy2q.*sinb./yyysby2.*(2.*y1cb+y3aa.*sinb))./oyysby)-(tmnunu).*y2.*sinb./yyycb2.*cbay.*iyysb-(tmnunu).*y2.*sinb./yyycb.*a./yy2th.*y1-y2.*(y3+a).*sinb./yy2th./yyycb.*(1+yCyY.*cbay+a.*y3aa./yy2).*y1-y2.*(y3+a).*sinb./yy2q./yyycb2.*(1+yCyY.*cbay+a.*y3aa./yy2).*iyysb+y2.*(y3+a).*sinb./yy2q./yyycb.*(iyy2q.*cosb.*y1./yyycb.*cbay-yCyY2.*cbay.*iyysb-yCyY.*a./yy2th.*y1-aa.*y3aa./yy22.*y1))./pi./(1-nu));

e23 = oh.*B1.*(oe.*((omnunu).*((isysq.*y3-1)./(sysq-y3)+hyto./yya-cosb.*((isysq.*y3-cosb)./smymy+(hytcb)./yyycb))-y22.*(-1./systh./(sysq-y3).*y3-isysq./sy2.*(isysq.*y3-1)-oh./yy2th./yya.*ty3fa-iyy2q./yyas.*hyto-cosb.*(-1./systh./smymy.*y3-isysq./syy2.*(isysq.*y3-cosb)-oh./yy2th./yyycb.*ty3fa-iyy2q./yyycb2.*(hytcb))))./pi./(1-nu)+1./4.*((omnunu).*(((tmnunu).*cotb2-nu).*hyto./yya-((tmnunu).*cotb2+omnunu).*cosb.*(hytcb)./yyycb)+(omnunu)./yyas.*(y1.*cotb.*(omnunu-a./yy2q)+nu.*y3aa-a+y22./yya.*(nu+a./yy2q)).*hyto-(omnunu)./yya.*(oh.*a.*y1.*cotb./yy2th.*ty3fa+nu-y22./yyas.*(nu+a./yy2q).*hyto-oh.*y22./yya.*a./yy2th.*ty3fa)-(omnunu).*sinb.*cotb./yyycb.*cbay+(omnunu).*yysb.*cotb./yyycb2.*cbay.*(hytcb)+oh.*(omnunu).*yysb.*cotb./yyycb.*a./yy2th.*ty3fa-a./yy2th.*y1.*cotb+th.*a.*y1.*(y3+a).*cotb./yy2fh.*ty3fa+1./yya.*(-nunu+iyy2q.*((omnunu).*y1.*cotb-a)+y22./yy2q./yya.*nay+a.*y22./yy2th)-(y3+a)./yyas.*(-nunu+iyy2q.*((omnunu).*y1.*cotb-a)+y22./yy2q./yya.*nay+a.*y22./yy2th).*hyto+(y3+a)./yya.*(-oh./yy2th.*((omnunu).*y1.*cotb-a).*ty3fa-oh.*y22./yy2th./yya.*nay.*ty3fa-y22./yy2q./yyas.*nay.*hyto-oh.*y22./yy22./yya.*a.*ty3fa-th.*a.*y22./yy2fh.*ty3fa)+1./yyycb.*(cosb2-iyy2q.*((omnunu).*yysb.*cotb+a.*cosb)+a.*y3aa.*yysb.*cotb./yy2th-iyy2q./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya))-(y3+a)./yyycb2.*(cosb2-iyy2q.*((omnunu).*yysb.*cotb+a.*cosb)+a.*y3aa.*yysb.*cotb./yy2th-iyy2q./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya)).*(hytcb)+(y3+a)./yyycb.*(oh./yy2th.*((omnunu).*yysb.*cotb+a.*cosb).*ty3fa-iyy2q.*(omnunu).*sinb.*cotb+a.*yysb.*cotb./yy2th+a.*y3aa.*sinb.*cotb./yy2th-th.*a.*y3aa.*yysb.*cotb./yy2fh.*ty3fa+oh./yy2th./yyycb.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya).*ty3fa+iyy2q./yyycb2.*(y22cb2-a.*yysb.*cotb./yy2q.*ycbya).*(hytcb)-iyy2q./yyycb.*(-a.*sinb.*cotb./yy2q.*ycbya+oh.*a.*yysb.*cotb./yy2th.*ycbya.*ty3fa-a.*yysb.*cotb./yy2q.*(oh./yy2q.*cosb.*ty3fa+1))))./pi./(1-nu));
e23 = e23 + oh.*B2.*(oe.*((tmnunu).*(y2./ycys2.*sinb./(1+y22./ycys2)+(y2./sysq.*sinb./yyyy.*y3+y2.*sysq.*sinb2./yyyy2.*y1)./(1+y22.*(sys).*sinb2./yyyy2)-y2./yysb2.*sinb./(1+y22./yysb2)+(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby)+y1.*y2.*(-1./systh./(sysq-y3).*y3-isysq./sy2.*(isysq.*y3-1)-oh./yy2th./yya.*ty3fa-iyy2q./yyas.*hyto)-y2.*(-sinb./sysq./smymy-(y1cb-y3sb)./systh./smymy.*y3-(y1cb-y3sb)./sysq./syy2.*(isysq.*y3-cosb)+sinb./yy2q./yyycb-oh.*yysb./yy2th./yyycb.*ty3fa-yysb./yy2q./yyycb2.*(hytcb)))./pi./(1-nu)+1./4.*((tmnunu).*(omnunu).*(-y2./yysb2.*sinb./(1+y22./yysb2)+(oh.*y2./yy2q.*sinb./yyysby.*ty3fa-y2.*yy2q.*sinb2./yyysby2.*y1)./oyysby).*cotb2-(omnunu).*y2./yyas.*((-1+nunu+a./yy2q).*cotb+y1./yya.*(nu+a./yy2q)).*hyto+(omnunu).*y2./yya.*(-oh.*a./yy2th.*ty3fa.*cotb-y1./yyas.*(nu+a./yy2q).*hyto-oh.*y1./yya.*a./yy2th.*ty3fa)+(omnunu).*y2.*cotb./yyycb2.*(1+a./yy2q./cosb).*(hytcb)+oh.*(omnunu).*y2.*cotb./yyycb.*a./yy2th./cosb.*ty3fa-a./yy2th.*y2.*cotb+th.*a.*y2.*(y3+a).*cotb./yy2fh.*ty3fa+y2./yy2q./yya.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya))-oh.*y2.*(y3+a)./yy2th./yya.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya)).*ty3fa-y2.*(y3+a)./yy2q./yyas.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2q.*(iyy2q+1./yya)).*hyto+y2.*(y3+a)./yy2q./yya.*(nunu.*y1./yyas.*hyto+oh.*a.*y1./yy2th.*(iyy2q+1./yya).*ty3fa-a.*y1./yy2q.*(-oh./yy2th.*ty3fa-1./yyas.*hyto))+y2.*cotb./yy2q./yyycb.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb)-oh.*y2.*(y3+a).*cotb./yy2th./yyycb.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb).*ty3fa-y2.*(y3+a).*cotb./yy2q./yyycb2.*((-2+nunu).*cosb+yCyY.*(1+a./yy2q./cosb)+a.*y3aa./yy2./cosb).*(hytcb)+y2.*(y3+a).*cotb./yy2q./yyycb.*((oh./yy2q.*cosb.*ty3fa+1)./yyycb.*(1+a./yy2q./cosb)-yCyY2.*(1+a./yy2q./cosb).*(hytcb)-oh.*yCyY.*a./yy2th./cosb.*ty3fa+a./yy2./cosb-a.*y3aa./yy22./cosb.*ty3fa))./pi./(1-nu));
e23 = e23 + oh.*B3.*(oe.*((omnunu).*sinb.*((isysq.*y3-cosb)./smymy+(hytcb)./yyycb)-y22.*sinb.*(-1./systh./smymy.*y3-isysq./syy2.*(isysq.*y3-cosb)-oh./yy2th./yyycb.*ty3fa-iyy2q./yyycb2.*(hytcb)))./pi./(1-nu)+1./4.*((omnunu).*(-sinb.*(hytcb)./yyycb+y1./yyas.*oay.*hyto+oh.*y1./yya.*a./yy2th.*ty3fa+sinb./yyycb.*cbay-yysb./yyycb2.*cbay.*(hytcb)-oh.*yysb./yyycb.*a./yy2th.*ty3fa)+y1./yy2q.*(a./yy2+1./yya)-oh.*y1.*(y3+a)./yy2th.*(a./yy2+1./yya).*ty3fa+y1.*(y3+a)./yy2q.*(-a./yy22.*ty3fa-1./yyas.*hyto)-1./yyycb.*(sinb.*(cosb-a./yy2q)+yysb./yy2q.*(1+a.*y3aa./yy2)-iyy2q./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya))+(y3+a)./yyycb2.*(sinb.*(cosb-a./yy2q)+yysb./yy2q.*(1+a.*y3aa./yy2)-iyy2q./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya)).*(hytcb)-(y3+a)./yyycb.*(oh.*sinb.*a./yy2th.*ty3fa+sinb./yy2q.*(1+a.*y3aa./yy2)-oh.*yysb./yy2th.*(1+a.*y3aa./yy2).*ty3fa+yysb./yy2q.*(a./yy2-a.*y3aa./yy22.*ty3fa)+oh./yy2th./yyycb.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya).*ty3fa+iyy2q./yyycb2.*(y22cb.*sinb-a.*yysb./yy2q.*ycbya).*(hytcb)-iyy2q./yyycb.*(-a.*sinb./yy2q.*ycbya+oh.*a.*yysb./yy2th.*ycbya.*ty3fa-a.*yysb./yy2q.*(oh./yy2q.*cosb.*ty3fa+1))))./pi./(1-nu))+oh.*B1.*(oe.*(isysq-iyy2q-cosb.*(scby./sysq./smymy-ycbya./yy2q./yyycb))./pi./(1-nu)+oe.*y2.*(-1./systh.*y2+1./yy2th.*y2-cosb.*(1./(sys).*cosb.*y2./smymy-scby./systh./smymy.*y2-scby./(sys)./syy2.*y2-iyy2.*cosb.*y2./yyycb+ycbya./yy2th./yyycb.*y2+ycbya./yy2./yyycb2.*y2))./pi./(1-nu)+1./4.*((tmnunu).*((omnunu).*(-1./y1./(1+y22./y12)+1./yysb./(1+y22./yysb2)+(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby).*cotb+1./yya.*nay-y22./yyas.*nay./yy2q-y22./yya.*a./yy2th-cosb./yyycb.*cbay+y22cb./yyycb2.*cbay./yy2q+y22cb./yyycb.*a./yy2th)+(y3+a)./yy2q.*(nunu./yya+a./yy2)-y22.*(y3+a)./yy2th.*(nunu./yya+a./yy2)+y2.*(y3+a)./yy2q.*(-nunu./yyas./yy2q.*y2-aa./yy22.*y2)+(y3+a).*cosb./yy2q./yyycb.*(omnunu-yCyY.*cbay-a.*y3aa./yy2)-y22.*(y3+a).*cosb./yy2th./yyycb.*(omnunu-yCyY.*cbay-a.*y3aa./yy2)-y22.*(y3+a).*cosb./yy2./yyycb2.*(omnunu-yCyY.*cbay-a.*y3aa./yy2)+y2.*(y3+a).*cosb./yy2q./yyycb.*(-iyy2q.*cosb.*y2./yyycb.*cbay+yCyY2.*cbay./yy2q.*y2+yCyY.*a./yy2th.*y2+aa.*y3aa./yy22.*y2))./pi./(1-nu))+oh.*B2.*(oe.*((-1+nunu).*sinb.*(isysq.*y2./smymy-iyy2q.*y2./yyycb)-y1.*(-1./systh.*y2+1./yy2th.*y2)+(y1cb-y3sb)./(sys).*cosb.*y2./smymy-(y1cb-y3sb).*scby./systh./smymy.*y2-(y1cb-y3sb).*scby./(sys)./syy2.*y2-yysb./yy2.*cosb.*y2./yyycb+yysb.*ycbya./yy2th./yyycb.*y2+yysb.*ycbya./yy2./yyycb2.*y2)./pi./(1-nu)+1./4.*((-2+nunu).*(omnunu).*cotb.*(iyy2q.*y2./yya-cosb./yy2q.*y2./yyycb)+(tmnunu).*y1./yyas.*nay./yy2q.*y2+(tmnunu).*y1./yya.*a./yy2th.*y2-(tmnunu).*yysb./yyycb2.*cbay./yy2q.*y2-(tmnunu).*yysb./yyycb.*a./yy2th.*y2-(y3+a)./yy2th.*((omnunu).*cotb-nunu.*y1./yya-a.*y1./yy2).*y2+(y3+a)./yy2q.*(nunu.*y1./yyas./yy2q.*y2+aa.*y1y22.*y2)+(y3+a)./yyycb2.*(cosb.*sinb+ycbya.*cotb./yy2q.*((tmnunu).*cosb-yCyY)+a./yy2q.*sby7)./yy2q.*y2-(y3+a)./yyycb.*(iyy2.*cosb.*y2.*cotb.*((tmnunu).*cosb-yCyY)-ycbya.*cotb./yy2th.*((tmnunu).*cosb-yCyY).*y2+ycbya.*cotb./yy2q.*(-cosb./yy2q.*y2./yyycb+yCyY2./yy2q.*y2)-a./yy2th.*sby7.*y2+a./yy2q.*(2.*y3aa.*yysb./yy22.*y2-yysb./yy2.*cosb.*y2./yyycb+yysb.*ycbya./yy2th./yyycb.*y2+yysb.*ycbya./yy2./yyycb2.*y2)))./pi./(1-nu))+oh.*B3.*(oe.*((tmnunu).*(1./(y1cb-y3sb)./(1+y22./ycys2)+(sysq.*sinb./yyyy+y22./sysq.*sinb./yyyy-2.*y22.*sysq.*sinb./yyyy2.*cosb)./(1+y22.*(sys).*sinb2./yyyy2)-1./yysb./(1+y22./yysb2)-(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby)+sinb.*(scby./sysq./smymy-ycbya./yy2q./yyycb)+y2.*sinb.*(1./(sys).*cosb.*y2./smymy-scby./systh./smymy.*y2-scby./(sys)./syy2.*y2-iyy2.*cosb.*y2./yyycb+ycbya./yy2th./yyycb.*y2+ycbya./yy2./yyycb2.*y2))./pi./(1-nu)+1./4.*((tmnunu).*(-1./y1./(1+y22./y12)+1./yysb./(1+y22./yysb2)+(yy2q.*sinb./yyysby+y22./yy2q.*sinb./yyysby-2.*y22.*yy2q.*sinb./yyysby2.*cosb)./oyysby)+(tmnunu).*sinb./yyycb.*cbay-(tmnunu).*y22.*sinb./yyycb2.*cbay./yy2q-(tmnunu).*y22.*sinb./yyycb.*a./yy2th+(y3+a).*sinb./yy2q./yyycb.*(1+yCyY.*cbay+a.*y3aa./yy2)-y22.*(y3+a).*sinb./yy2th./yyycb.*(1+yCyY.*cbay+a.*y3aa./yy2)-y22.*(y3+a).*sinb./yy2./yyycb2.*(1+yCyY.*cbay+a.*y3aa./yy2)+y2.*(y3+a).*sinb./yy2q./yyycb.*(iyy2q.*cosb.*y2./yyycb.*cbay-yCyY2.*cbay./yy2q.*y2-yCyY.*a./yy2th.*y2-aa.*y3aa./yy22.*y2))./pi./(1-nu));
