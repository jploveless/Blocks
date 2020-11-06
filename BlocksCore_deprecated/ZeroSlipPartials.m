function slips = ZeroSlipPartials(patchfiles, patchtogs, slipm);
%
% ZeroSlipPartials sets the appropriate rows of the slip partial derivative 
% matrix equal to zero to account for some segments being replaced by triangular
% dislocation patches.
%
% Inputs:
%   patchfiles					= patch file indices (usually Segment.patchFile)
%	 patchtogs					= patch file toggle flags (usually Segment.patchTogs)
%	 slipm						= original matrix of slip partial derivatives
%			
% Returns:			
%	 slips						= updated matrix of slip partials
%

slips 												= slipm;
i 														= intersect(find(patchfiles), find(patchtogs));
i														= [3*i(:)-2; 3*i(:)-1; 3*i];
slips(i, :)											= 0;