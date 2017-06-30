function R = GetCrossPartials(b)
% Returns a linear operator R that when multiplied by 
% vector a gives the cross product a cross b
R = [0 b(3) -b(2) ; -b(3) 0 b(1) ; b(2) -b(1) 0];