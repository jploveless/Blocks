function [ek, tk, tz, ts] = CheckExistingKernels(c, s, st, p);
%
% CheckExistingKernels checks to see if the specified existing elastic kernels
% can be used given the current segment and patch geometries.
%
% Inputs:
%   c			= Command structure
%	 s			= Segment structure
%	 st      = Station structure
%	 p			= Patches structure
%
% Returns:
%   ek		= elastic kernel for segments
%   tk      = elastic kernel for triangular patches
%	 tz		= matrix denoting strike, dip, tensile partials for patches
%	 ts		= matrix defining strikes of elements
%   If a kernel can be used, it is loaded and returned to newBlocks.  If not, the size
%	 of the output kernel is zero and a new kernel will be calculated subsequently.
%

[ek, tk, tz, ts] 	= deal(zeros(3*numel(st.lon), 0));
[segc, tric] 		= deal(1);

if strcmp(c.reuseElastic, 'yes') == 1;
	% find the directory in which the existing kernel exists
	sepers = strfind(c.reuseElasticFile, filesep);
	% load the accompanying segment and patch file
	os = ReadSegmentTri(sprintf('%sMod.segment', c.reuseElasticFile(1:sepers(end))));
	ost = ReadStation(sprintf('%sMod.sta.data', c.reuseElasticFile(1:sepers(end))));
	% compare coordinates for segments...
	if numel(os.lon1) == numel(s.lon1) & numel(ost.lon) == numel(st.lon);
		segc = sum([sum(abs([os.lon1; os.lat1; os.lon2; os.lat2] - [s.lon1(:); s.lat1(:); s.lon2(:); s.lat2(:)])), ...
					   sum(abs(os.dip - s.dip)), sum(abs(os.lDep - s.lDep)), sum(abs(os.bDep - s.bDep))]);
	end
	if ~isempty(p.c) & exist(sprintf('%sMod.patch', c.reuseElasticFile(1:sepers(end))), 'file') > 0
		[co, ve, sl] = PatchData(sprintf('%sMod.patch', c.reuseElasticFile(1:sepers(end))));
		if numel(co) == numel(p.c) & numel(ost.lon) == numel(st.lon);
			% ... and triangles
			dc = abs(co - p.c);
			tric = max(dc(:)) > 1e-4;
		end
	else
		tric = 1;
	end	
	if segc + tric == max([segc, tric]); % if at least one of the two is identical to the stored kernel...
		Partials = load(c.reuseElasticFile); % load those kernels
		if segc == 0
			fprintf('\n  Using existing elastic kernel...');
			ek = Partials.elastic;
		end
		if tric == 0
			fprintf('\n  Using existing triangular kernel...');
			tk = Partials.tri;
			tz = Partials.trizeros;
			ts = Partials.tristrikes;
		end
	end
end	
			
