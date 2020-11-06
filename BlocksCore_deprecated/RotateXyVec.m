function [xp yp] = RotateXyVec(x, y, alpha)
alpha                         = alpha*pi/180;
xp                            = cos(alpha).*x - sin(alpha).*y;
yp                            = sin(alpha).*x + cos(alpha).*y;