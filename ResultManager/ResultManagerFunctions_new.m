function ResultManagerFunctions(option)
% ResultManagerFunctions
%
% Functions called by ResultManagerGUI


% Declare variables
global GLOBAL ul cul st Segment plotsegs Obs Mod Res Rot Def Str Tri cSegment cplotsegs cObs cMod cRes cRot cDef cStr cTri vecScale
translateScale                     = 0.2;
vecScale						   = get(findobj(gcf, 'tag', 'Rst.velSlider'), 'value');

% Parse callbacks
switch(option)
   
   %%%   Start File I/O commands   %%%
% Load segment file
   case 'Rst.loadPush'
      % Delete all the childrean of the current axes
      fprintf(GLOBAL.filestream, '%s\n', option);
      
      % Get the name of the segment file
      ha                          = findobj(gcf, 'Tag', 'Rst.loadEdit');
      dirname                     = get(ha, 'string');
      if exist(dirname, 'dir')
         dirname              = strcat(pwd, filesep, dirname);
      else
         dirname      = uigetdir(pwd, 'Choose results directory');
         if dirname == 0
            return;
            set(ha, 'string', '');
         else
            set(ha, 'string', dirname);
         end
      end
      
      % Read in the results files
      if exist([dirname filesep 'Mod.segment']);
	      Segment                      = ReadSegmentStruct([dirname filesep 'Mod.segment']);
			set(findobj(gcf, '-regexp', 'tag', 'Rst.SlipText'), 'enable', 'on');
	      set(findobj(gcf, '-regexp', 'tag', 'Rst.SlipNumCheck'), 'enable', 'on');
	      set(findobj(gcf, '-regexp', 'tag', 'Rst.SlipColCheck'), 'enable', 'on');	      
	      setappdata(gcf, 'Segment', Segment);
         % Plot segments
      	plotsegs = DrawSegment(Segment, 'color', 'b', 'tag', 'Segs');
	  end
	  
	  if exist([dirname filesep 'Obs.sta.data']);
	  	Obs 						= ReadStation([dirname filesep 'Obs.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Obsv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Mod.sta.data']);
	  	Mod						= ReadStation([dirname filesep 'Mod.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Modv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Res.sta.data']);
	  	Res						= ReadStation([dirname filesep 'Res.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Resv'), 'enable', 'on');
      set(findobj(gcf, '-regexp', 'tag', 'Rst.Resm'), 'enable', 'on');
	    if ~isempty(strmatch(get(findobj(gcf, 'tag', 'Rst.cResvCheck'), 'enable'), 'on', 'exact'))
	    	set(findobj(gcf, '-regexp', 'tag', 'Rst.ResidImpCheck'), 'enable', 'on');
	    end
	  end
	  
	  if exist([dirname filesep 'Rot.sta.data']);
	  	Rot						= ReadStation([dirname filesep 'Rot.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Rotv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Def.sta.data']);
	  	Def						= ReadStation([dirname filesep 'Def.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Defv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Strain.sta.data']);
	  	Str						= ReadStation([dirname filesep 'Strain.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Strv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Tri.sta.data']);
	  	Tri						= ReadStation([dirname filesep 'Tri.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Sta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.Triv'), 'enable', 'on');
	  end
	  s = whos('Obs', 'Mod', 'Res', 'Rot', 'Def', 'Str', 'Tri'); % at least one of these exists, or else the button would be inactive
     PlotSta(eval(s(round(find([s.size], 1)/2)).name), '.k', 'tag', 'Sta', 'visible', 'off')
     LabelSta(eval(s(round(find([s.size], 1)/2)).name), 'color', 'k', 'tag', 'Stan', 'visible', 'off');
     quiver(0, 0, vecScale*10, 0, 0, 'k', 'tag', 'scav', 'visible', 'off', 'userdata', vecScale)
	  text(0, 0, '10 mm/yr', 'tag', 'tscav', 'visible', 'off')
     MoveLegend
     
     % check for optional files
     if exist([dirname filesep 'Strain.block']);
     	StrBlock					= ReadBlock([dirname filesep 'Strain.block']);
     	setappdata(gcf, 'StrBlock', StrBlock)
     	set(findobj(gcf, '-regexp', 'tag', 'Rst.Strain'), 'enable', 'on');
     	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
     end
     
     if exist([dirname filesep 'Mod.patch']);
     	[C, V, tSlip]			= PatchData([dirname filesep 'Mod.patch']);
     	setappdata(gcf, 'C', C); setappdata(gcf, 'V', V); setappdata(gcf, 'tSlip', tSlip);
     	set(findobj(gcf, '-regexp', 'tag', 'Rst.TriCheck'), 'enable', 'on');
     end
	  	  
   % Clear directory
   case 'Rst.clearPush'
      fprintf(GLOBAL.filestream, '%s\n', option);
      setappdata(gcf, 'Segment', []);
      ha                          = findobj(gcf, 'Tag', 'Rst.loadEdit');
      set(ha, 'string', '');
      set(findobj(gcf, '-regexp', 'tag', 'Rst.SlipNumCh'), 'enable', 'off', 'value', 0);
      set(findobj(gcf, '-regexp', 'tag', 'Rst.SlipColCh'), 'enable', 'off', 'value', 0);
      set(findobj(gcf, '-regexp', 'tag', 'Rst.SlipText'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Stav'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Stat'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Stan'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Obsv'), 'enable', 'off', 'value', 0); 	   
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Modv'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Resv'), 'enable', 'off', 'value', 0);
 	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Resm'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Rotv'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Defv'), 'enable', 'off', 'value', 0);	   
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Str'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Tri'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.srate'), 'enable', 'off', 'value', 1);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.drate'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.Resid'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, 'tag', 'Rst.ResidRadioW'), 'value', 1);
     	set(findobj(gcf, 'tag', 'Rst.TriSRadio'), 'value', 1);
	   delete(findobj(gcf, '-regexp', 'tag', '^Sta')); % delete stations and names
	   delete(findobj(gcf, 'tag', 'Segs')); % delete segments
		delete(findobj(gcf, '-regexp', 'tag', '^\w{3,3}[v]')); % delete main vectors
		delete(findobj(gcf, 'tag', 'Resm')); % delete residual magnitudes
      delete(findobj(gcf, '-regexp', 'tag', '^Slip\w{4,4}')); % delete main slip rate object
      delete(findobj(gcf, '-regexp', 'tag', '^diffres')); % delete residual comparisons
      delete(findobj(gcf, '-regexp', 'tag', '^TriSlips\d')); % delete triangular slips
      delete(findobj(gcf, '-regexp', 'tag', '^StrainAxes')); % delete strain axes
      clear -regexp '[A-Z]\w+'
      rmappdata(gcf, 'StrBlock'); rmappdata(gcf, 'C'); rmappdata(gcf, 'V'); rmappdata(gcf, 'tSlip');
      colorbar off
      
   % Plot stations
   case 'Rst.StatCheck'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Sta');
      hb                           = findobj(gcf, 'Tag', 'Rst.StatCheck');
      if get(hb, 'Value') == 0;
      	set(ha, 'Visible', 'off');
      else
         set(ha, 'Visible', 'on');
      end
      
   % Label stations
   case 'Rst.StanCheck'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Stan');
      hb                           = findobj(gcf, 'Tag', 'Rst.StanCheck');
      if get(hb, 'Value') == 0;
      	set(ha, 'Visible', 'off');
      else
         set(ha, 'Visible', 'on');
      end
      
	case 'Rst.ObsvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Obsv');
      hb                           = findobj(gcf, 'Tag', 'Rst.ObsvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Obs, vecScale, 'color', 'b', 'tag', 'Obsv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
      
	case 'Rst.ModvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Modv');
      hb                           = findobj(gcf, 'Tag', 'Rst.ModvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Mod, vecScale, 'color', 'r', 'tag', 'Modv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
      
	case 'Rst.ResvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Resv');
      hb                           = findobj(gcf, 'Tag', 'Rst.ResvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Res, vecScale, 'color', 'm', 'tag', 'Resv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
   
   case 'Rst.RotvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Rotv');
      hb                           = findobj(gcf, 'Tag', 'Rst.RotvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Rot, vecScale, 'color', 'g', 'tag', 'Rotv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
	
	case 'Rst.DefvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Defv');
      hb                           = findobj(gcf, 'Tag', 'Rst.DefvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Def, vecScale, 'color', 'c', 'tag', 'Defv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
   
   case 'Rst.StrvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Strv');
      hb                           = findobj(gcf, 'Tag', 'Rst.StrvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Str, vecScale, 'color', [0 0.5 0.5], 'tag', 'Strv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale

	case 'Rst.TrivCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Triv');
      hb                           = findobj(gcf, 'Tag', 'Rst.TrivCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(Tri, vecScale, 'color', [1 .65 0], 'tag', 'Triv', 'visible', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
      
	case 'Rst.ResmCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Resm');
      hac								  = findobj(gcf, 'Tag', 'cResm');
      hb                           = findobj(gcf, 'Tag', 'Rst.ResmCheck');
      hbc								  = findobj(gcf, 'Tag', 'Rst.cResmCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end
	      if ~isempty(cRes)
    	      set(hbc, 'value', 0, 'enable', 'on');
	         set(findobj(gcf, 'tag', 'Rst.cResmText'), 'enable', 'on');
	      end   
      else
      	if isempty(ha)
	      	PlotResMag(Res, vecScale, 'tag', 'Resm', 'visible', 'on', 'clipping', 'on');
	      else	
	         set(ha, 'Visible', 'on');
	      end
	      set(hbc, 'value', 0, 'enable', 'off');
	      set(findobj(gcf, 'tag', 'Rst.cResmText'), 'enable', 'off');
	      if ~isempty(hac)
	      	set(hac, 'visible', 'off');
	      end
      end

      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now load the comparison directory results %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'Rst.cloadPush'
      % Delete all the childrean of the current axes
      fprintf(GLOBAL.filestream, '%s\n', option);
      
      % Get the name of the segment file
      ha                          = findobj(gcf, 'Tag', 'Rst.cloadEdit');
      dirname                     = get(ha, 'string');
      if exist(dirname, 'dir')
         dirname              = strcat(pwd, filesep, dirname);
      else
         dirname      = uigetdir(pwd, 'Choose results directory');
         if dirname == 0
            return;
            set(ha, 'string', '');
         else
            set(ha, 'string', dirname);
         end
      end
      
      % Read in the results files
      if exist([dirname filesep 'Mod.segment']);
	      cSegment                      = ReadSegmentStruct([dirname filesep 'Mod.segment']);
			set(findobj(gcf, '-regexp', 'tag', 'Rst.cSlipText'), 'enable', 'on');
	      set(findobj(gcf, '-regexp', 'tag', 'Rst.cSlipNumCheck'), 'enable', 'on');
	      set(findobj(gcf, '-regexp', 'tag', 'Rst.cSlipColCheck'), 'enable', 'on');	      
%  	      set(findobj(gcf, '-regexp', 'tag', 'Rst.csrate'), 'enable', 'on');
%  	      set(findobj(gcf, '-regexp', 'tag', 'Rst.cdrate'), 'enable', 'on');
	      setappdata(gcf, 'cSegment', cSegment);
         % Plot segments
      	plotsegsc = DrawSegment(cSegment, 'color', 'b', 'linestyle', '--', 'tag', 'cSegs');
	  end
	  
	  if exist([dirname filesep 'Obs.sta.data']);
	  	cObs 						= ReadStation([dirname filesep 'Obs.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cObsv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Mod.sta.data']);
	  	cMod						= ReadStation([dirname filesep 'Mod.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cModv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Res.sta.data']);
	  	cRes						= ReadStation([dirname filesep 'Res.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cResv'), 'enable', 'on');
      set(findobj(gcf, '-regexp', 'tag', 'Rst.cResm'), 'enable', 'on');
	   if ~isempty(strmatch(get(findobj(gcf, 'tag', 'Rst.ResvCheck'), 'enable'), 'on', 'exact'))
	    	set(findobj(gcf, '-regexp', 'tag', 'Rst.ResidImpCheck'), 'enable', 'on');
	    	% make a bubble legend
			scatter(0, 0, vecScale*10001, 'k', 'tag', 'diffressca', 'userdata', 1, 'visible', 'off');
			text(0, 0, '1 mm/yr', 'tag', 'tdiffressca', 'visible', 'off');
			MoveLegend
	   end
	  end
	  
	  if exist([dirname filesep 'Rot.sta.data']);
	  	cRot						= ReadStation([dirname filesep 'Rot.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cRotv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Def.sta.data']);
	   cDef						= ReadStation([dirname filesep 'Def.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cDefv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Strain.sta.data']);
	  	cStr						= ReadStation([dirname filesep 'Strain.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cStrv'), 'enable', 'on');
	  end
	  
	  if exist([dirname filesep 'Tri.sta.data']);
	  	cTri						= ReadStation([dirname filesep 'Tri.sta.data']);
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cSta'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
	  	set(findobj(gcf, '-regexp', 'tag', 'Rst.cTriv'), 'enable', 'on');
	  end
	  s = who('cObs', 'cMod', 'cRes', 'cRot', 'cDef', 'cStr', 'cTri'); % at least one of these exists, or else the button would be inactive
     PlotSta(eval(s{1}), '.b', 'tag', 'cSta', 'visible', 'off')
     LabelSta(eval(s{1}), 'color', 'b', 'tag', 'cStan', 'visible', 'off');
     
     % check for optional files
     if exist([dirname filesep 'Strain.block']);
     	cStrBlock					= ReadBlock([dirname filesep 'Strain.block']);
     	setappdata(gcf, 'cStrBlock', cStrBlock);
     	set(findobj(gcf, '-regexp', 'tag', 'Rst.cStrain'), 'enable', 'on');
     	set(findobj(gcf, '-regexp', 'tag', 'Rst.velS'), 'enable', 'on');
     	set(findobj(gcf, 'tag', 'Rst.opText'), 'enable', 'on');
     end
     
     if exist([dirname filesep 'Mod.patch']);
     	[cC, cV, ctSlip]			= PatchData([dirname filesep 'Mod.patch']);
     	setappdata(gcf, 'cC', cC); setappdata(gcf, 'cV', cV); setappdata(gcf, 'ctSlip', ctSlip);
     	set(findobj(gcf, '-regexp', 'tag', 'Rst.cTriCheck'), 'enable', 'on');
     	set(findobj(gcf, 'tag', 'Rst.opText'), 'enable', 'on');
     end
	  	  
   % Clear directory
   case 'Rst.cclearPush'
      fprintf(GLOBAL.filestream, '%s\n', option);
      setappdata(gcf, 'cSegment', []);
      ha                          = findobj(gcf, 'Tag', 'Rst.cloadEdit');
      set(ha, 'string', '');
      set(findobj(gcf, '-regexp', 'tag', 'Rst.cSlipNumCh'), 'enable', 'off', 'value', 0);
      set(findobj(gcf, '-regexp', 'tag', 'Rst.cSlipColCh'), 'enable', 'off', 'value', 0);
      set(findobj(gcf, '-regexp', 'tag', 'Rst.cSlipText'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cStav'), 'enable', 'off', 'value', 0);
 	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cStat'), 'enable', 'off', 'value', 0);
  	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cStan'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cObsv'), 'enable', 'off', 'value', 0); 	   
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cModv'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cResv'), 'enable', 'off', 'value', 0);
      set(findobj(gcf, '-regexp', 'tag', 'Rst.cResm'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cRotv'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cDefv'), 'enable', 'off', 'value', 0);	   
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cStr'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cTri'), 'enable', 'off', 'value', 0);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.csrate'), 'enable', 'off', 'value', 1);
	   set(findobj(gcf, '-regexp', 'tag', 'Rst.cdrate'), 'enable', 'off', 'value', 0);
   	set(findobj(gcf, '-regexp', 'tag', 'Rst.Resid'), 'enable', 'off', 'value', 0);
   	set(findobj(gcf, 'tag', 'Rst.ResidRadioW'), 'value', 1);
   	set(findobj(gcf, 'tag', 'Rst.cTriSRadio'), 'value', 1);
	   delete(findobj(gcf, '-regexp', 'tag', '^cSta')); % delete compare stations and names
  	   delete(findobj(gcf, 'tag', 'cSegs')); % delete compare segments
		delete(findobj(gcf, '-regexp', 'tag', '^c\w{3,3}[v]')); % delete compare vectors
      delete(findobj(gcf, '-regexp', 'tag', '^cSlip\w{4,4}')); % delete compare slip rate object
      delete(findobj(gcf, '-regexp', 'tag', '^diffres')); % delete residual comparisons
      delete(findobj(gcf, '-regexp', 'tag', 'cTriSlips\d')); % delete triangular slips
      delete(findobj(gcf, '-regexp', 'tag', 'cStrainAxes')); % delete strain axes
      clear -regexp 'c[A-Z]\w+'
      rmappdata(gcf, 'cStrBlock'); rmappdata(gcf, 'cC'); rmappdata(gcf, 'cV'); rmappdata(gcf, 'ctSlip');
      colorbar off
   % Plot stations
   case 'Rst.cStatCheck'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cSta');
      hb                           = findobj(gcf, 'Tag', 'Rst.cStatCheck');
      if get(hb, 'Value') == 0;
      	set(ha, 'Visible', 'off');
      else
         set(ha, 'Visible', 'on');
      end

   % Label stations
   case 'Rst.cStanCheck'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cStan');
      hb                           = findobj(gcf, 'Tag', 'Rst.cStanCheck');
      if get(hb, 'Value') == 0;
      	set(ha, 'Visible', 'off');
      else
         set(ha, 'Visible', 'on');
      end

      
	case 'Rst.cObsvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cObsv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cObsvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cObs, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cObsv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cObs, vecScale, 'color', 0.8*[0 0 1], 'tag', 'cObsv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Obsv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
      
	case 'Rst.cModvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cModv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cModvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cMod, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cModv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cMod, vecScale, 'color', 0.8*[1 0 0], 'tag', 'cModv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Modv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
      
	case 'Rst.cResvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cResv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cResvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cRes, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cResv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cRes, vecScale, 'color', 0.8*[1 0 1], 'tag', 'cResv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Resv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	    else	
	        set(ha, 'Visible', 'on');
	    end  
      end
      CheckVecScale
   
   case 'Rst.cRotvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cRotv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cRotvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cRot, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cRotv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cRot, vecScale, 'color', 0.8*[0 1 0], 'tag', 'cRotv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Rotv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
	
	case 'Rst.cDefvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cDefv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cDefvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cDef, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cDefv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cDef, vecScale, 'color', 0.8*[0 1 1], 'tag', 'cDefv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Defv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
   
   case 'Rst.cStrvCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cStrv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cStrvCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cStr, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cStrv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cStr, vecScale, 'color', 0.8*[0 0.5 0.5], 'tag', 'cStrv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Strv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale

	case 'Rst.cTrivCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cTriv');
      hb                           = findobj(gcf, 'Tag', 'Rst.cTrivCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	if isempty(ha)
	      	PlotStaVec(cTri, vecScale, 'color', 0.8*[1 1 1], 'tag', 'cTriv', 'visible', 'on', 'linewidth', 2);
	      	PlotStaVec(cTri, vecScale, 'color', 0.8*[1 .65 0], 'tag', 'cTriv', 'visible', 'on', 'linewidth', 1);
	      	% make sure the main vectors are on top
	      	m = findobj(gcf, 'tag', 'Triv');
	      	if ~isempty(m)
	      		a = get(gca, 'children');
	      		i = find(a == m);
	      		set(gca, 'children', [m; a(setdiff(1:length(a), i))]);
	      	end
	      else	
	         set(ha, 'Visible', 'on');
	      end   
      end
      CheckVecScale
      
   case 'Rst.cResmCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Resm');
      hac								  = findobj(gcf, 'Tag', 'cResm');
      hb                           = findobj(gcf, 'Tag', 'Rst.ResmCheck');
      hbc								  = findobj(gcf, 'Tag', 'Rst.cResmCheck');
      if get(hbc, 'Value') == 0;
      	if isempty(hac)
      		return
      	else	
	      	set(hac, 'Visible', 'off');
	      end
	      if ~isempty(Res)
	         set(hb, 'value', 0, 'enable', 'on');
	         set(findobj(gcf, 'tag', 'Rst.ResmText'), 'enable', 'on');
	      end   
      else
      	if isempty(hac)
	      	PlotResMag(cRes, vecScale, 'tag', 'cResm', 'visible', 'on', 'clipping', 'on');
	      else	
	         set(hac, 'Visible', 'on');
	      end
	      set(hb, 'value', 0, 'enable', 'off');
	      set(findobj(gcf, 'tag', 'Rst.ResmText'), 'enable', 'off');
	      if ~isempty(ha)
	      	set(ha, 'visible', 'off');
	      end
      end
      
%%%%%%%%%%%%%%%%%%%%
% Set vector scale %
%%%%%%%%%%%%%%%%%%%%

	case 'Rst.velScale'
		ha 								= get(findobj(gcf, 'tag', 'Rst.velScale'), 'string');
		if isempty(ha)
			set(ha, 'string', num2str(get(findobj(gcf, 'tag', 'Rst.velSlider'), 'value'), '%0.2f'));
		else
			vecScale						= str2double(ha);
			set(findobj(gcf, 'tag', 'Rst.velSlider'), 'value', vecScale);
			ScaleAllVectors(vecScale)
		end
		
	case 'Rst.velSlider'
		vecScale							= get(findobj(gcf, 'tag', 'Rst.velSlider'), 'value');
		set(findobj(gcf, 'tag', 'Rst.velScale'), 'string', num2str(vecScale, '%0.2f'));
		ScaleAllVectors(vecScale)
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show residual improvement %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'Rst.ResidImpCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^diffres');
      hb                           = findobj(gcf, 'Tag', 'Rst.ResidImpCheck');
      if get(hb, 'Value') == 0; % unchecked
      	set(findobj(gcf, '-regexp', 'tag', 'Rst.ResidRadio'), 'enable', 'off');
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      	set(findobj(gcf, '-regexp', 'tag', 'diffressca'), 'visible', 'off');
	      end	
      else
     		set(findobj(gcf, '-regexp', 'tag', 'Rst.ResidRadio'), 'enable', 'on');
			rads 						  = [findobj(gcf, 'tag', 'Rst.ResidRadioNW') findobj(gcf, 'tag', 'Rst.ResidRadioW')];
     		weighted					  = cell2mat(get(rads, 'value'));
     		weighted					  = find(weighted==max(weighted)) - 1;
      	if numel(ha) < 2 % if the bubbles have not yet been plotted...
      		% ...plot them
      		ResidImprove(Res, cRes, vecScale, weighted)
	      else
	      	set(findobj(gcf, 'tag', ['diffres' num2str(weighted)]), 'Visible', 'on');
	        set(findobj(gcf, 'tag', ['diffres' num2str(setdiff([0 1], weighted))]), 'Visible', 'off');
	      end
	      set(findobj(gcf, '-regexp', 'tag', 'diffressca'), 'visible', 'on');
      end

	case 'Rst.ResidRadioNW'
		han								= findobj('tag', 'diffres0');
		haw								= findobj('tag', 'diffres1');
		if ~isempty(haw)
			set(haw, 'visible', 'off')				
		end				
		if isempty(han)
			ResidImprove(Res, cRes, vecScale, 0)
		else
			set(han, 'visible', 'on')
		end	

	case 'Rst.ResidRadioW'
		han								= findobj('tag', 'diffres0');
		haw								= findobj('tag', 'diffres1');
		if ~isempty(han)
			set(han, 'visible', 'off')				
		end				
		if isempty(haw)
			ResidImprove(Res, cRes, vecScale, 1)
		else
			set(haw, 'visible', 'on')
		end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slip rate plotting, main results %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
% Numerical slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%
	case 'Rst.SlipNumCheck'		
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^SlipNum');
      hb                           = findobj(gcf, 'Tag', 'Rst.SlipNumCheck');
      if get(hb, 'Value') == 0;
      	set([findobj(gcf, '-regexp', 'tag', 'Rst.srateNum') findobj(gcf, '-regexp', 'tag', 'Rst.drateNum')], 'enable', 'off');
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
     		set([findobj(gcf, '-regexp', 'tag', 'Rst.srateNum') findobj(gcf, '-regexp', 'tag', 'Rst.drateNum')], 'enable', 'on');
			rads 						  = [findobj(gcf, 'tag', 'Rst.srateNumRadio') findobj(gcf, 'tag', 'Rst.drateNumRadio')];
     		comp						  = cell2mat(get(rads, 'value'));
     		comp						  = find(comp==max(comp));
      	if isempty(ha)
	      	symb					  = ['cx'; 'bx'];
	      	tgs					  = ['SlipNums'; 'SlipNumd'];
%	      	SlipNumLabel(Segment, comp, symb(comp, :), 'tag', tgs(comp, :));
	      	SlipNumLabel(Segment, comp, 0, 0, 'color', 'k', 'tag', tgs(comp, :), 'horizontalalignment', 'right');	      	
	      else
	      	tgs					  = get(rads, 'tag');
	         set(findobj(gcf, 'tag', ['SlipNum' tgs{comp}(5)]), 'Visible', 'on');
	         set(findobj(gcf, 'tag', ['SlipNum' tgs{setdiff([1 2], comp)}(5)]), 'Visible', 'off');
	      end   
      end

	case 'Rst.srateNumRadio'
		has								= findobj('tag', 'SlipNums');
		had								= findobj('tag', 'SlipNumd');
		if ~isempty(had)
			set(had, 'visible', 'off')				
		end				
		if isempty(has)
%			SlipNumLabel(Segment, 1, 'cx', 'tag', 'SlipNums');
      	SlipNumLabel(Segment, 1, 0, 0, 'color', 'k', 'tag', 'SlipNums', 'horizontalalignment', 'right');
		else
			set(has, 'visible', 'on')
		end	

	case 'Rst.drateNumRadio'
		has								= findobj('tag', 'SlipNums');
		had								= findobj('tag', 'SlipNumd');
		if ~isempty(has)
			set(has, 'visible', 'off')				
		end				
		if isempty(had)
%			SlipNumLabel(Segment, 2, 'bx', 'tag', 'SlipNumd');
      	SlipNumLabel(Segment, 2, 0, 0, 'color', 'k', 'tag', 'SlipNumd', 'horizontalalignment', 'right');
		else
			set(had, 'visible', 'on')
		end
		
%%%%%%%%%%%%%%%%%%%%%%
% Colored slip rates %
%%%%%%%%%%%%%%%%%%%%%%		
	case 'Rst.SlipColCheck'		
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^SlipCol');
      hb                           = findobj(gcf, 'Tag', 'Rst.SlipColCheck');
      if get(hb, 'Value') == 0;
      	set([findobj(gcf, '-regexp', 'tag', 'Rst.srateCol') findobj(gcf, '-regexp', 'tag', 'Rst.drateCol')], 'enable', 'off');
      	if isempty(ha)
      		return
      	else
	      	set(ha, 'Visible', 'off');
	      	colorbar off
	      end	
      else
      	colorbar off
     		set([findobj(gcf, '-regexp', 'tag', 'Rst.srateCol') findobj(gcf, '-regexp', 'tag', 'Rst.drateCol')], 'enable', 'on');
			rads 						  = [findobj(gcf, 'tag', 'Rst.srateColRadio') findobj(gcf, 'tag', 'Rst.drateColRadio')];
     		comp						  = cell2mat(get(rads, 'value'));
     		comp						  = find(comp==max(comp));
     		cmaps						  = ['redwhiteblue(256)'; 'bluewhitered(256)'];
      	if isempty(ha)
	      	symb					  = ['ro'; 'mo'];
	      	tgs					  = ['SlipCols'; 'SlipCold'];
	      	lims = SlipColored(Segment, comp, 'tag', tgs(comp, :), [tgs(comp, :) 'Scale']);
				caxis(lims)
	      	ch = colorbar('east', 'tag', [tgs(comp, :) 'Scale']);
	      	colormap(cmaps(comp, :));
	      else
	      	tgs					  = get(rads, 'tag');
	      	on 					  = findobj(gcf, '-regexp', 'tag', ['^SlipCol' tgs{comp}(5)]);
	      	off					  = findobj(gcf, '-regexp', 'tag', ['^SlipCol' tgs{setdiff([1 2], comp)}(5)]);
	         set(on, 'Visible', 'on');
	         set(off, 'Visible', 'off');
				caxis(get(on(end), 'userdata'))
	      	ch = colorbar('east', 'tag', ['SlipCol' tgs{comp}(5) 'Scale']);
	      	colormap(cmaps(comp, :));
	      end   
      end

	case 'Rst.srateColRadio'
		has								= findobj(gcf, '-regexp', 'tag', '^SlipCols');
		had								= findobj(gcf, '-regexp', 'tag', '^SlipCold');
		if ~isempty(had)
			set(had, 'visible', 'off')				
		end				
		if isempty(has)
			colorbar off
			slims = SlipColored(Segment, 1, 'tag', 'SlipCols', 'SlipColsScale');
			caxis(slims)
			chs = colorbar('east', 'tag', 'SlipColsScale');
			colormap(redwhiteblue(256));
		else
			colorbar off
			set(has, 'visible', 'on')
			caxis(get(has(end), 'userdata'))
			chs = colorbar('east', 'tag', 'SlipColsScale');
			colormap(redwhiteblue(256));
		end	

	case 'Rst.drateColRadio'
		has								= findobj(gcf, '-regexp', 'tag', '^SlipCols');
		had								= findobj(gcf, '-regexp', 'tag', '^SlipCold');
		if ~isempty(has)
			set(has, 'visible', 'off')				
		end				
		if isempty(had)
			colorbar off
			dlims = SlipColored(Segment, 2, 'tag', 'SlipCold', 'SlipColdScale');
			caxis(dlims)
			chd = colorbar('east', 'tag', 'SlipColdScale');
			colormap(bluewhitered(256));
		else
		   colorbar off
			set(had, 'visible', 'on')
			caxis(get(had(end), 'userdata'))
			chd = colorbar('east', 'tag', 'SlipColdScale');
			colormap(bluewhitered(256));
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Slip rate plotting, compare results %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
% Numerical slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%
	case 'Rst.cSlipNumCheck'		
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^cSlipNum');
      hb                           = findobj(gcf, 'Tag', 'Rst.cSlipNumCheck');
      if get(hb, 'Value') == 0;
      	set([findobj(gcf, '-regexp', 'tag', 'Rst.csrateNum') findobj(gcf, '-regexp', 'tag', 'Rst.cdrateNum')], 'enable', 'off');
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
     		set([findobj(gcf, '-regexp', 'tag', 'Rst.csrateNum') findobj(gcf, '-regexp', 'tag', 'Rst.cdrateNum')], 'enable', 'on');
			rads 						  = [findobj(gcf, 'tag', 'Rst.csrateNumRadio') findobj(gcf, 'tag', 'Rst.cdrateNumRadio')];
     		comp						  = cell2mat(get(rads, 'value'));
     		comp						  = find(comp==max(comp));
      	if isempty(ha)
      		symb					  = ['rx'; 'mx'];
      		tgs					  = ['cSlipNums'; 'cSlipNumd'];
	      	SlipNumLabel(cSegment, comp, 0, 0, 'tag', tgs(comp, :), 'horizontalalignment', 'left', 'color', 'b');
	      else
	      	tgs					  = get(rads, 'tag');
	         set(findobj(gcf, 'tag', ['cSlipNum' tgs{comp}(5)]), 'Visible', 'on');
	         set(findobj(gcf, 'tag', ['cSlipNum' tgs{setdiff([1 2], comp)}(5)]), 'Visible', 'off');
	      end   
      end

	case 'Rst.csrateNumRadio'
		has								= findobj(gcf, 'tag', 'cSlipNums');
		had								= findobj(gcf, 'tag', 'cSlipNumd');
		if ~isempty(had)
			set(had, 'visible', 'off')				
		end				
		if isempty(has)
			SlipNumLabel(cSegment, 1, 0, 0, 'tag', 'cSlipNums', 'horizontalalignment', 'left', 'color', 'b');
		else
			set(has, 'visible', 'on')
		end	

	case 'Rst.cdrateNumRadio'
		has								= findobj(gcf, 'tag', 'cSlipNums');
		had								= findobj(gcf, 'tag', 'cSlipNumd');
		if ~isempty(has)
			set(has, 'visible', 'off')				
		end				
		if isempty(had)
			SlipNumLabel(cSegment, 2, 0, 0, 'tag', 'cSlipNumd', 'horizontalalignment', 'left', 'color', 'b');
		else
			set(had, 'visible', 'on')
		end
		
%%%%%%%%%%%%%%%%%%%%%%
% Colored slip rates %
%%%%%%%%%%%%%%%%%%%%%%		
	case 'Rst.cSlipColCheck'		
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^cSlipCol');
      hb                           = findobj(gcf, 'Tag', 'Rst.cSlipColCheck');
      if get(hb, 'Value') == 0;
      	set([findobj(gcf, '-regexp', 'tag', 'Rst.csrateCol') findobj(gcf, '-regexp', 'tag', 'Rst.cdrateCol')], 'enable', 'off');
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      	colorbar off
	      end	
      else
      	colorbar off
     		set([findobj(gcf, '-regexp', 'tag', 'Rst.csrateCol') findobj(gcf, '-regexp', 'tag', 'Rst.cdrateCol')], 'enable', 'on');
			rads 						  = [findobj(gcf, 'tag', 'Rst.csrateColRadio') findobj(gcf, 'tag', 'Rst.cdrateColRadio')];
     		comp						  = cell2mat(get(rads, 'value'));
     		comp						  = find(comp==max(comp));
     		cmaps						  = ['redwhiteblue(256)'; 'bluewhitered(256)'];
      	if isempty(ha)
	      	tgs					  = ['cSlipCols'; 'cSlipCold'];
	      	lims = SlipColored(cSegment, comp, 'tag', tgs(comp, :), [tgs(comp, :) 'Scale']);
				caxis(lims)
	      	ch = colorbar('east', 'tag', [tgs(comp, :) 'Scale']);
	      	colormap(cmaps(comp, :));
	      else
	      	tgs					  = get(rads, 'tag');
	      	on 					  = findobj(gcf, '-regexp', 'tag', ['^cSlipCol' tgs{comp}(6)]);
	      	off					  = findobj(gcf, '-regexp', 'tag', ['^cSlipCol' tgs{setdiff([1 2], comp)}(6)]);
	         set(on, 'Visible', 'on');
	         set(off, 'Visible', 'off');
				caxis(get(on(end), 'userdata'))
	      	ch = colorbar('east', 'tag', ['SlipCol' tgs{comp}(6) 'Scale']);
	      	colormap(cmaps(comp, :));
	      end   
      end

	case 'Rst.csrateColRadio'
		has								= findobj(gcf, '-regexp', 'tag', '^cSlipCols');
		had								= findobj(gcf, '-regexp', 'tag', '^cSlipCold');
		if ~isempty(had)
			set(had, 'visible', 'off')				
		end				
		if isempty(has)
			colorbar off
			slims = SlipColored(cSegment, 1, 'tag', 'cSlipCols', 'cSlipColsScale');
			caxis(slims)
			chs = colorbar('east', 'tag', 'cSlipColsScale');
			colormap(redwhiteblue(256));
		else
			colorbar off
			set(has, 'visible', 'on')
			caxis(get(has(end), 'userdata'))
			chs = colorbar('east', 'tag', 'cSlipColsScale');
			colormap(redwhiteblue(256));
		end		

	case 'Rst.cdrateColRadio'
		has								= findobj(gcf, '-regexp', 'tag', '^cSlipCols');
		had								= findobj(gcf, '-regexp', 'tag', '^cSlipCold');
		if ~isempty(has)
			set(has, 'visible', 'off')				
		end				
		if isempty(had)
			colorbar off
			dlims = SlipColored(cSegment, 2, 'tag', 'cSlipCold', 'cSlipColdScale');
			caxis(dlims)
			chd = colorbar('east', 'tag', 'cSlipColdScale');
			colormap(bluewhitered(256));
		else
		   colorbar off
			set(had, 'visible', 'on')
			caxis(get(had(end), 'userdata'))
			chd = colorbar('east', 'tag', 'cSlipColdScale');
			colormap(bluewhitered(256));
		end	
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional result plotting , main results %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	case 'Rst.StrainCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'StrainAxes');
      hb                           = findobj(gcf, 'Tag', 'Rst.StrainCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
     		if isempty(ha)
     			StrBlock 				  = getappdata(gcf, 'StrBlock'); 
      		PlotStrainAxes(StrBlock, vecScale, 'r', 'b', 'linewidth', 2, 'tag', 'StrainAxes', 'userdata', vecScale)
      	else
	      	set(ha, 'visible', 'on')
	      end   
      end
      
	case 'Rst.TriCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^TriSlips');
      hb                           = findobj(gcf, 'Tag', 'Rst.TriCheck');
      if get(hb, 'Value') == 0;
      	set(findobj(gcf, '-regexp', 'tag', 'Rst.Tri[A-Z]{2}'), 'enable', 'off');
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	set(findobj(gcf, '-regexp', 'tag', 'Rst.Tri[A-Z]{2}'), 'enable', 'on');
      	rads 						  = [findobj(gcf, 'tag', 'Rst.TriSRadio') findobj(gcf, 'tag', 'Rst.TriDRadio')];
     		comp						  = cell2mat(get(rads, 'value'));
     		comp						  = find(comp==max(comp));
      	if isempty(ha)
     			C			 				   = getappdata(gcf, 'C');
     			V							   = getappdata(gcf, 'V');
     			tSlip							= getappdata(gcf, 'tSlip');
      		PlotTriSlips(C, V, tSlip(:, comp), 'tag', ['TriSlips' num2str(comp)]);
	      else
	      	on 					  = findobj(gcf, '-regexp', 'tag', ['^TriSlips' num2str(comp)]);
	      	off					  = findobj(gcf, '-regexp', 'tag', ['^TriSlips' num2str(setdiff([1 2], comp))]);
	         set(on, 'Visible', 'on');
	         set(off, 'Visible', 'off');
	      end
		end	      
      
	case 'Rst.TriSRadio'
		has								= findobj(gcf, 'tag', 'TriSlips1');
		had								= findobj(gcf, 'tag', 'TriSlips2');
		if ~isempty(had)
			set(had, 'visible', 'off')				
		end				
		if isempty(has)
			C			 				   = getappdata(gcf, 'C');
     		V							   = getappdata(gcf, 'V');
     		tSlip							= getappdata(gcf, 'tSlip');
			PlotTriSlips(C, V, tSlip(:, 1), 'tag', 'TriSlips1');
		else
			set(has, 'visible', 'on')
		end
	case 'Rst.TriDRadio'
		has								= findobj(gcf, 'tag', 'TriSlips1');
		had								= findobj(gcf, 'tag', 'TriSlips2');
		if ~isempty(has)
			set(has, 'visible', 'off')				
		end				
		if isempty(had)
			C			 				   = getappdata(gcf, 'C');
     		V							   = getappdata(gcf, 'V');
     		tSlip							= getappdata(gcf, 'tSlip');
			PlotTriSlips(C, V, tSlip(:, 2), 'tag', 'TriSlips2');
		else
			set(had, 'visible', 'on')
		end	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional result plotting , compare results %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	case 'Rst.cStrainCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'cStrainAxes');
      hb                           = findobj(gcf, 'Tag', 'Rst.cStrainCheck');
      if get(hb, 'Value') == 0;
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
     		if isempty(ha)
     			cStrBlock 				  = getappdata(gcf, 'cStrBlock'); 
      		PlotStrainAxes(cStrBlock, vecScale, 'r', 'b', 'linewidth', 2, 'tag', 'cStrainAxes', 'userdata', vecScale)
      	else
	      	set(ha, 'visible', 'on')
	      end   
      end
      
	case 'Rst.cTriCheck'
		fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, '-regexp', 'Tag', '^cTriSlips');
      hb                           = findobj(gcf, 'Tag', 'Rst.cTriCheck');
      if get(hb, 'Value') == 0;
      	set(findobj(gcf, '-regexp', 'tag', 'Rst.cTri[A-Z]{2}'), 'enable', 'off');
      	if isempty(ha)
      		return
      	else	
	      	set(ha, 'Visible', 'off');
	      end	
      else
      	set(findobj(gcf, '-regexp', 'tag', 'Rst.cTri[A-Z]{2}'), 'enable', 'on');
      	rads 						  = [findobj(gcf, 'tag', 'Rst.cTriSRadio') findobj(gcf, 'tag', 'Rst.cTriDRadio')];
     		comp						  = cell2mat(get(rads, 'value'));
     		comp						  = find(comp==max(comp));
      	if isempty(ha)
     			cC			 				   = getappdata(gcf, 'cC');
     			cV							   = getappdata(gcf, 'cV');
     			ctSlip							= getappdata(gcf, 'ctSlip');
      		PlotTriSlips(cC, cV, ctSlip(:, comp), 'tag', ['cTriSlips' num2str(comp)]);
	      else
	      	on 					  = findobj(gcf, '-regexp', 'tag', ['^cTriSlips' num2str(comp)]);
	      	off					  = findobj(gcf, '-regexp', 'tag', ['^cTriSlips' num2str(setdiff([1 2], comp))]);
	         set(on, 'Visible', 'on');
	         set(off, 'Visible', 'off');
	      end
		end	      
      
	case 'Rst.cTriSRadio'
		has								= findobj(gcf, 'tag', 'cTriSlips1');
		had								= findobj(gcf, 'tag', 'cTriSlips2');
		if ~isempty(had)
			set(had, 'visible', 'off')				
		end				
		if isempty(has)
			cC			 				   = getappdata(gcf, 'cC');
     		cV							   = getappdata(gcf, 'cV');
     		ctSlip							= getappdata(gcf, 'ctSlip');
			PlotTriSlips(cC, cV, ctSlip(:, 1), 'tag', 'cTriSlips1');
		else
			set(has, 'visible', 'on')
		end
	case 'Rst.cTriDRadio'
		has								= findobj(gcf, 'tag', 'cTriSlips1');
		had								= findobj(gcf, 'tag', 'cTriSlips2');
		if ~isempty(has)
			set(has, 'visible', 'off')				
		end				
		if isempty(had)
			cC			 				   = getappdata(gcf, 'cC');
     		cV							   = getappdata(gcf, 'cV');
     		ctSlip							= getappdata(gcf, 'ctSlip');
			PlotTriSlips(cC, cV, ctSlip(:, 2), 'tag', 'cTriSlips2');
		else
			set(had, 'visible', 'on')
		end	

      
   %%%   Start Display Commands   %%%
   % Change topo settings
   case 'Rst.dispTopo'
      fprintf(GLOBAL.filestream, '%s\n', option);
      value                        = get(findobj(gcf, 'Tag', 'Rst.dispTopo'), 'Value');
      if value == 1
         set(findobj(gcf, 'Tag', 'topo'), 'visible', 'off');
         delete(findobj(gcf, 'Tag', 'topo'));
      elseif value == 2
         SocalTopo                 = load('SocalTopo.mat');
         surf(SocalTopo.lon_mat, SocalTopo.lat_mat, zeros(size(SocalTopo.map)), real(log10(SocalTopo.map)), 'EdgeColor', 'none', 'Tag', 'topo'); colormap(gray);
         set(findobj(gcf, 'Tag', 'topo'), 'visible', 'on');
      else
         return;
      end
   
      
      
   % Change grid settings  
   case 'Rst.dispGrid'
      fprintf(GLOBAL.filestream, '%s\n', option);
      value                        = get(findobj(gcf, 'Tag', 'Rst.dispGrid'), 'Value');
      if value == 1
         set(gca, 'XGrid', 'off', 'YGrid', 'off');
      elseif value == 2
         set(gca, 'XGrid', 'on', 'YGrid', 'on');
      else
         return;
      end
      
      
      
   %%  Change longitude labeling
   case 'Rst.dispMeridian'
      fprintf(GLOBAL.filestream, '%s\n', option);
      value                        = get(findobj(gcf, 'Tag', 'Rst.dispMeridian'), 'Value');
      if value == 1
         set(gca, 'XTickLabel', deblank(strjust(num2str(zero22pi(transpose(get(gca, 'XTick')))), 'center')));
      elseif value == 2
         set(gca, 'XTickLabel', deblank(strjust(num2str(npi2pi(transpose(get(gca, 'XTick')))), 'center')));
      else
         return;
      end


      
   %%  Load a line file
   case 'Rst.dispPushLine'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Rst.dispEditLine');
      filename                     = get(ha, 'String');
      if exist(filename, 'file')
         filenameFull              = strcat(pwd, '\', filename);
      else
         [filename, pathname]      = uigetfile({'*'}, 'Load line file');
         if filename == 0
            return;
            set(ha, 'string', '');
         else
            set(ha, 'string', filename);
            filenameFull           = strcat(pathname, filename);
         end
      end
      PlotLine(filenameFull);
      hb                           = findobj(gcf, 'Tag', 'Rst.dispCheckLine');
      set(hb, 'Value', 1);
   
      
      
   %%  Toggle the line file visibility
   case 'Rst.dispCheckLine'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'lineAll');
      hb                           = findobj(gcf, 'Tag', 'Rst.dispCheckLine');
      if isempty(ha)
         return;
      else
         if get(hb, 'Value') == 0
            set(ha, 'Visible', 'off');
         elseif get(hb, 'Value') == 1
            set(ha, 'Visible', 'on');
         end
      end
     
      
      
   %%  Load a xy file
   case 'Rst.dispPushXy'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'Rst.dispEditXy');
      filename                     = get(ha, 'String');
      if exist(filename, 'file')
         filenameFull              = strcat(pwd, '\', filename);
      else
         [filename, pathname]      = uigetfile({'*'}, 'Load xy file');
         if filename == 0
            return;
            set(ha, 'string', '');
         else
            set(ha, 'string', filename);
            filenameFull           = strcat(pathname, filename);
         end
      end
      PlotXy(filenameFull);
      hb                           = findobj(gcf, 'Tag', 'Rst.dispCheckXy');
      set(hb, 'Value', 1);
     
      
      
   %%  Toggle the xy file visibility
   case 'Rst.dispCheckXy'
      fprintf(GLOBAL.filestream, '%s\n', option);
      ha                           = findobj(gcf, 'Tag', 'xyAll');
      hb                           = findobj(gcf, 'Tag', 'Rst.dispCheckXy');
      if isempty(ha)
         return;
      else
         if get(hb, 'Value') == 0
            set(ha, 'Visible', 'off');
         elseif get(hb, 'Value') == 1
            set(ha, 'Visible', 'on');
         end
      end
     
    
      
   %%%   Start Navigation Commands   %%%
   case 'Rst.navZoomRange'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = GetRangeRbbox(getappdata(gcf, 'Range'));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      Range                        = getappdata(gcf, 'Range');
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      MoveLegend
      
      
   case 'Rst.navZoomIn'
      fprintf(GLOBAL.filestream, '%s\n', option);
      zoomFactor                   = 0.5;
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = (max(Range.lon) - min(Range.lon)) / 2;
      deltaLat                     = (max(Range.lat) - min(Range.lat)) / 2;
      centerLon                    = mean(Range.lon);
      centerLat                    = mean(Range.lat);
      Range.lon                    = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
      Range.lat                    = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
		MoveLegend
      
      
   case 'Rst.navZoomOut'
      fprintf(GLOBAL.filestream, '%s\n', option);
      zoomFactor                   = 2.0;
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = (max(Range.lon) - min(Range.lon)) / 2;
      deltaLat                     = (max(Range.lat) - min(Range.lat)) / 2;
      centerLon                    = mean(Range.lon);
      centerLat                    = mean(Range.lat);
      Range.lon                    = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
      Range.lat                    = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navUpdate'
      fprintf(GLOBAL.filestream, '%s\n', option);
      lonMax                       = str2num(get(findobj(gcf, 'Tag', 'Rst.navEditLonMax'), 'string'));
      lonMin                       = str2num(get(findobj(gcf, 'Tag', 'Rst.navEditLonMin'), 'string'));
      latMax                       = str2num(get(findobj(gcf, 'Tag', 'Rst.navEditLatMax'), 'string'));
      latMin                       = str2num(get(findobj(gcf, 'Tag', 'Rst.navEditLatMin'), 'string'));
      Range                        = getappdata(gcf, 'Range');
      Range.lon                    = [lonMin lonMax];
      Range.lat                    = [latMin latMax];
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navBack'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      RangeLev							  = max([1 cul]);
      Range.lon						  = Range.lonOld(RangeLev, :);
      Range.lat						  = Range.latOld(RangeLev, :);
      setappdata(gcf, 'Range', Range);
		SetAxes(Range);
      cul 								  = max([1 RangeLev - 1]);
		MoveLegend
      
   case 'Rst.navSW'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon - translateScale * deltaLon;
      Range.lat                    = Range.lat - translateScale * deltaLat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend

      
   case 'Rst.navS'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon;
      Range.lat                    = Range.lat - translateScale * deltaLat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navSE'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon + translateScale * deltaLon;
      Range.lat                    = Range.lat - translateScale * deltaLat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navW'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon - translateScale * deltaLon;
      Range.lat                    = Range.lat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navC'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
 		Range.lonOld                 = [Range.lonOld(2:end, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(2:end, :) ; Range.lat];
      k                            = waitforbuttonpress;
      point                        = get(gca, 'CurrentPoint');
      point                        = point(1, 1:2);
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navE'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon + translateScale * deltaLon;
      Range.lat                    = Range.lat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navNW'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon - translateScale * deltaLon;
      Range.lat                    = Range.lat + translateScale * deltaLat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navN'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon;
      Range.lat                    = Range.lat + translateScale * deltaLat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   case 'Rst.navNE'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Range                        = getappdata(gcf, 'Range');
      deltaLon                     = max(Range.lon) - min(Range.lon);
      deltaLat                     = max(Range.lat) - min(Range.lat);
      Range.lon                    = Range.lon + translateScale * deltaLon;
      Range.lat                    = Range.lat + translateScale * deltaLat;
      Range                        = CheckRange(Range);
 		Range.lonOld                 = [Range.lonOld(st:cul+1, :) ; Range.lon];
      Range.latOld                 = [Range.latOld(st:cul+1, :) ; Range.lat];
      cul								  = min([size(Range.lonOld, 1)-1 cul+1]);
      st									  = 1 + (cul==(ul-1));
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      MoveLegend
      
      
   %%  Draw the clean map
   case 'DrawClean'
      fprintf(GLOBAL.filestream, '%s\n', option);
      delete(gca);
      Rst.axHandle                 = axes('parent', gcf, 'units', 'pixels', 'position', [340 60 640 640],     'visible', 'on', 'Tag', 'Rst.axHandle', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'nextplot', 'add');
      WorldHiVectors               = load('WorldHiVectors');
      coast = plot(WorldHiVectors.lon, WorldHiVectors.lat, '-k', 'LineWidth', 0.25, 'visible', 'on', 'tag', 'Rst.coast', 'Color', 0.7 * [1 1 1]);
      box on;
      Range.lon                    = [0 360];
      Range.lat                    = [-90 90];
      Range.lonOld                 = repmat(Range.lon, ul, 1);
      Range.latOld                 = repmat(Range.lat, ul, 1);
      setappdata(gcf, 'Range', Range);
      SetAxes(Range);
      
   %%  Print the figure
   case 'Rst.pszPrint'
      fprintf(GLOBAL.filestream, '%s\n', option);
      printdlg(gcf);

      
      
   %%  Save the figure
   case 'Rst.pszSave'
      fprintf(GLOBAL.filestream, '%s\n', option);
      %%  Get filename
      filename                    = char(inputdlg('Please enter a base filename', 'Base filename', 1));
      if length(filename) > 0
         Zumax(gca);
         SaveCurrentFigure(filename);
         delete(gcf);
      else
         return;
      end
      
      
      
   %%  Zumax the figure
   case 'Rst.pszZumax'
      fprintf(GLOBAL.filestream, '%s\n', option);
      Zumax(gca);

end

%%%%%%%%%%%%%%%%%%%%%%%
% 							 %
%      FUNCTIONS      %
% 							 %
%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get range from drawn rubberband box %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Range = GetRangeRbbox(Range)
%%  GetRangeRbbox
k                            = waitforbuttonpress;
point1                       = get(gca, 'CurrentPoint');
finalRect                    = rbbox;
point2                       = get(gca, 'CurrentPoint');
point1                       = point1(1,1:2);
point2                       = point2(1,1:2);
Range.lon                    = sort([point1(1) point2(1)]);
Range.lat                    = sort([point1(2) point2(2)]);

%%%%%%%%%%%%%%%%%%%
% Set axis limits %
%%%%%%%%%%%%%%%%%%%
function SetAxes(Range)
%%  SetAxes
axis([min(Range.lon) max(Range.lon) min(Range.lat) max(Range.lat)]);
set(findobj(gcf, 'Tag', 'Rst.navEditLonMin'), 'string', sprintf('%7.3f', min(Range.lon)));
set(findobj(gcf, 'Tag', 'Rst.navEditLonMax'), 'string', sprintf('%7.3f', max(Range.lon)));
set(findobj(gcf, 'Tag', 'Rst.navEditLatMin'), 'string', sprintf('%7.3f', min(Range.lat)));
set(findobj(gcf, 'Tag', 'Rst.navEditLatMax'), 'string', sprintf('%7.3f', max(Range.lat)));
yAspect                        = cos(deg2rad(mean(Range.lat)));
daspect([1 yAspect 1]);

if max(Range.lon) == 360
   set(gca, 'XTick', [0 60 120 180 240 300 360]);
   set(gca, 'YTick', [-90 -45 0 45 90]);
else
   set(gca, 'XTickMode', 'auto');
   set(gca, 'YTickMode', 'auto');
end   
ResultManagerFunctions('Rst.dispMeridian');

%%%%%%%%%%%%%%%%%%%%%%
% Check window range %
%%%%%%%%%%%%%%%%%%%%%%
function Range = CheckRange(Range)
% CheckRange
Range.lon                    = sort(Range.lon);
Range.lat                    = sort(Range.lat);
Range.lon(Range.lon > 360)   = 360;
Range.lon(Range.lon < 0)     = 0;
Range.lat(Range.lat > 90)    = 90;
Range.lat(Range.lat < -90)   = -90;

%%%%%%%%%%%%%%%%%%%%%
% Plot the segments %
%%%%%%%%%%%%%%%%%%%%%
function plotsegs = DrawSegment(Segment, varargin)
plotsegs 								= line([Segment.lon1'; Segment.lon2'], [Segment.lat1'; Segment.lat2'], varargin{:});
  
%%%%%%%%%%%%%%%%%%%%
% Plot a line file %
%%%%%%%%%%%%%%%%%%%%
function PlotLine(filename)
	% PlotLine
	% open the file
fid1 = fopen(filename); frewind(fid1);

in = textscan(fid1, '%s', 'delimiter', '\n', 'whitespace', '');
in = in{1};
in = char(in);
szin = size(in);

fclose(fid1);

	% find line separators
in = strjust(in, 'left'); % shift all left
str = in(:, 1)';
pat = '[^-\d]';
blank = regexp(str, pat, 'start');
in(blank, 1:7) = repmat('NaN NaN', length(blank), 1);
in = str2num(in);
plot(zero22pi(in(:, 1)), in(:, 2), '-', 'LineWidth', 0.5, 'Color', 0.6 * [1 1 1], 'Tag', 'lineAll');


%%%%%%%%%%%%%%%%%%%%
% Plot an X-Y file %
%%%%%%%%%%%%%%%%%%%%
function PlotXy(filename)
% PlotXy
fileStream      = fopen(filename, 'r');
data            = fgetl(fileStream);
while (isstr(data));
   % Try a conversion to numeric
   vals         = str2num(data);
   if ~isempty(vals)
      plot(zero22pi(vals(1)), vals(2), '.k', 'Tag', 'xyAll');
   end
   
   % Get the next line
   data = fgetl(fileStream);
end
fclose(fileStream);

%%%%%%%%%%%%%%%%%%%%%
% Plot the stations %
%%%%%%%%%%%%%%%%%%%%%
function PlotSta(Station, varargin)
	% PlotSta
plot(Station.lon, Station.lat, varargin{:});

%%%%%%%%%%%%%%%%%%%%%
% Label the stations %
%%%%%%%%%%%%%%%%%%%%%
function LabelSta(Station, varargin)
	% LabelSta
text(Station.lon, Station.lat, [repmat(' ', numel(Station.lon), 1) Station.name], 'interpreter', 'none', 'clipping', 'on', 'fontname', 'fixedwidth', varargin{:});


%%%%%%%%%%%%%%%%%%%%%%%%
% Plot station vectors %
%%%%%%%%%%%%%%%%%%%%%%%%
function PlotStaVec(Station, vecScale, varargin)
	% PlotStaVec
quiver(Station.lon, Station.lat, vecScale*Station.eastVel, vecScale*Station.northVel, 0, 'userdata', vecScale, varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot residual magnitudes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotResMag(Res, vecScale, varargin)
% Determine residual magnitudes
rmag = sqrt(Res.eastVel.^2 + Res.northVel.^2);

% create scale of marker size
sc = 50;
cmap = jet(256);
cidx = ceil(255*((rmag - min(rmag))./(max(rmag) - min(rmag)))) + 1;
cidx = ceil(255*((rmag - min(rmag))./(5 - min(rmag)))) + 1;
cidx(cidx>256) = 256;

cvec = cmap(cidx, :);

% plotting commands
rmgc = scatter(Res.lon, Res.lat, sc, cvec, 'filled', varargin{:}); 

%%%%%%%%%%%%%%%%%%%%%%%%%
% Scale station vectors %
%%%%%%%%%%%%%%%%%%%%%%%%%
function ScaleAllVectors(vecScale)
	% ScaleAllVectors
global Obs Mod Res Rot Def Str Tri cObs cMod cRes cRot cDef cStr cTri
groups = findobj(gcf, 'type', 'hggroup');
vecs = findobj(groups, '-regexp', 'tag', '\w+v');
bubs = findobj(groups, '-regexp', 'tag', '^diffres');
saxs = findobj(groups, '-regexp', 'tag', 'StrainAxes$');
% scale the vectors
if ~isempty(vecs)
	if length(vecs) == 1
		ovs = get(vecs, 'userdata');
		ud = (get(vecs, 'udata')/ovs*vecScale);
		vd = (get(vecs, 'vdata')/ovs*vecScale);
		set(vecs, 'udata', ud);
		set(vecs, 'vdata', vd);
	else
		ovs = get(vecs(1), 'userdata');
		ud = cellfun(@(x) x/ovs*vecScale, get(vecs, 'udata'), 'uniformoutput', false);
		vd = cellfun(@(x) x/ovs*vecScale, get(vecs, 'vdata'), 'uniformoutput', false);
		set(vecs, {'udata'}, ud);
		set(vecs, {'vdata'}, vd);
	end
end
set(vecs, 'userdata', vecScale)
% scale the bubbles
if ~isempty(bubs)
	if length(bubs) > 1 % actual bubbles exist
		sc = vecScale*10000;
		ms = cellfun(@(x) ceil(sc*abs(x)) + 1, get(bubs, 'userdata'), 'uniformoutput', false);
		set(bubs, {'sizedata'}, ms);
	else
		set(bubs, 'sizedata', vecScale*10001);
	end
end
% scale the strain axes
if ~isempty(saxs)
	ovs = get(saxs(1), 'userdata');
	ud = cellfun(@(x) x/ovs*vecScale, get(saxs, 'udata'), 'uniformoutput', false);
	vd = cellfun(@(x) x/ovs*vecScale, get(saxs, 'vdata'), 'uniformoutput', false);
	set(saxs, {'udata'}, ud);
	set(saxs, {'vdata'}, vd);
	set(saxs, 'userdata', vecScale)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show residual improvement %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResidImprove(one, two, vecScale, weighted)
	% ResidImprove
	
% compare residual velocities
if weighted == 0
	oneVel = sqrt(one.eastVel.^2 + one.northVel.^2);
	twoVel = sqrt(two.eastVel.^2 + two.northVel.^2);
else
	oneVel = sqrt(one.eastVel.^2 + one.northVel.^2)./(sqrt(one.eastSig.^2 + one.northSig.^2));
	twoVel = sqrt(two.eastVel.^2 + two.northVel.^2)./(sqrt(two.eastSig.^2 + two.northSig.^2));
end

[noMatch1, noMatch2] = deal([]);
[ui1, ui2] = deal(1:length(oneVel));

if numel(oneVel) ~= numel(twoVel) % different numbers of stations, need to find common stations based on coordinates
	coords = [one.lon one.lat; two.lon two.lat];
	[uv, ui1] = unique(coords, 'rows', 'first');
	[uv, ui2] = unique(coords, 'rows', 'last');
	ui = [ui1 ui2];
	noMatchInd = find(diff(ui, 1, 2) == 0);
	noMatch = ui1(noMatchInd);
	noMatch1 = noMatch(find(noMatch <= numel(oneVel)));
	noMatch2 = noMatch(find(noMatch > numel(oneVel))) - numel(oneVel);
	matchInd = setdiff(1:size(ui, 1), noMatchInd);
	ui1 = ui(matchInd, 1);
	ui2 = ui(matchInd, 2) - numel(oneVel);
	corObj = 4;
else
	corObj = 3;
end

% take the difference
dVel = twoVel(ui2) - oneVel(ui1);

% create scale of marker size
sc = vecScale*10000;
ms = ceil(sc*abs(dVel))+1;

cmap = bluewhitered(256, [min(dVel) max(dVel)]);
if max(abs(dVel)) ~= 0
	cidx = ceil(255*((dVel - min(dVel))./(max(dVel) - min(dVel)))) + 1;
	cvec = cmap(cidx, :);
else
	cvec = [1 1 1];
end

% plotting commands
diffc = scatter(two.lon(ui2), two.lat(ui2), ms, cvec, 'filled', 'tag', ['diffres' num2str(weighted)], 'userdata', dVel, 'clipping', 'on'); 
ovrly = scatter(two.lon(ui2), two.lat(ui2), ms, 'k', 'tag', ['diffres' num2str(weighted)], 'userdata', dVel, 'clipping', 'on');
nmtch1 = plot(one.lon(noMatch1), one.lat(noMatch1), 'xk', 'tag', ['diffres' num2str(weighted)]);
nmtch2 = plot(two.lon(noMatch2), two.lat(noMatch2), 'xk', 'tag', ['diffres' num2str(weighted)]);

% make sure that bubbles lie beneath any vectors that are plotted
warning off all
allobj = get(gca, 'children');
allvec = findobj(gcf, '-regexp', 'tag', '\w{3,4}v$');
[otherObj, otherInd] = setdiff(allobj, allvec);
allobj = [allvec; allobj(sort(otherInd))];
set(gca, 'children', allobj);
warning on all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Label numerical slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SlipNumLabel(Sm, comp, xshift, yshift, varargin)
if comp == 1
%	plot(180, 0, varargin{:})
	text(xshift + (Sm.lon1+Sm.lon2)/2, xshift + (Sm.lat1+Sm.lat2)/2, [strjust(num2str(Sm.ssRate, '%4.1f'), 'right') repmat('\pm', numel(Sm.lon1), 1) strjust(num2str(Sm.ssRateSig, '%4.1f'), 'left')], 'clipping', 'on', 'FontSize', 10, 'HorizontalAlignment', 'center', varargin{:})
else
%	plot(180, 0, varargin{:})
	text(xshift + (Sm.lon1+Sm.lon2)/2, yshift + (Sm.lat1+Sm.lat2)/2, [strjust(num2str(Sm.dsRate-Sm.tsRate, '%4.1f'), 'right') repmat('\pm', numel(Sm.lon1), 1) strjust(num2str(Sm.dsRateSig+Sm.tsRateSig, '%4.1f'), 'left')], 'clipping', 'on',  'FontSize', 10, 'HorizontalAlignment', 'center', varargin{:})
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot colored slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lims = SlipColored(Sm, comp, varargin)
if comp == 1
	sSmaxRate                    = max(Sm.ssRate(:));
	sSminRate                    = min(Sm.ssRate(:));
	lw = abs(Sm.ssRate)/2 + eps;
	trate = Sm.ssRate;
	sw = abs(Sm.ssRateSig/2) + eps;
	colslips = mycline([Sm.lon1'; Sm.lon2'], [Sm.lat1'; Sm.lat2'], Sm.ssRate);
	colormap(redwhiteblue)
	set(colslips, varargin{1:end-1})
	set(colslips, {'linewidth'}, num2cell(lw), 'userdata', -[sSmaxRate sSminRate]);
	sigslips = line([Sm.lon1'; Sm.lon2'], [Sm.lat1'; Sm.lat2'], 'color', 'k', 'tag', [varargin{end-1} 'Wid']);
	set(sigslips, {'LineWidth'}, num2cell(sw));
	% make sure that the colored lines lie beneath all other objects
	allobj = get(gca, 'children');
	first = find(allobj == colslips(end));
	last = find(allobj == colslips(1));
	allobj = [allobj(1:first-1); allobj(last+1:end); colslips(:)];
	set(gca, 'children', allobj);

else
	dSmaxRate                    = max(Sm.dsRate(:) - Sm.tsRate(:));
	dSminRate                    = min(Sm.dsRate(:) - Sm.tsRate(:));
	conrates = Sm.dsRate-Sm.tsRate;
	consigs = Sm.dsRateSig+Sm.tsRateSig;
	lw = abs(conrates)/2 + eps;
	trate = conrates;
	sw = abs(consigs/2) + eps;	
	colslipd = line([Sm.lon1'; Sm.lon2'], [Sm.lat1'; Sm.lat2'], conrates);
	colormap(bluewhitered)
	set(colslipd, varargin{1:end-1})
	set(colslipd, {'linewidth'}, num2cell(lw), 'userdata', [dSminRate dSmaxRate]);
	sigslipd = line([Sm.lon1'; Sm.lon2'], [Sm.lat1'; Sm.lat2'], 'color', 'k', 'tag', [varargin{end-1} 'Wid']);
	set(sigslipd, {'LineWidth'}, num2cell(sw));
	% make sure that the colored lines lie beneath all other objects
	allobj = get(gca, 'children');
	first = find(allobj == colslipd(end));
	last = find(allobj == colslipd(1));
	allobj = [allobj(1:first-1); allobj(last+1:end); colslipd(:)];
	set(gca, 'children', allobj);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot principal strain rate axes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotStrainAxes(Block, vecScale, varargin)
a = gca;
BlockStrainAxes(Block, a, varargin{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot triangular slip rates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotTriSlips(c, v, bc, varargin)
h = patch('Vertices', c, 'faces', v, 'facevertexcdata', bc, 'facecolor', 'flat', 'edgecolor', 'black', 'parent', gca, varargin{:});
colormap(bluewhitered)

%%%%%%%%%%%%%%%%%%%
% Move the legend %
%%%%%%%%%%%%%%%%%%%
function MoveLegend

r = getappdata(gcf, 'Range');
legLon = r.lon(1) + 0.1*diff(r.lon);
legLat = r.lat(2) - 0.05*diff(r.lat);

scav = findobj(gcf, 'tag', 'scav');
diffressca = findobj(gcf, 'tag', 'diffressca');
set(scav, 'xdata', legLon, 'ydata', legLat);
set(diffressca, 'xdata', legLon + 0.03*diff(r.lon), 'ydata', (legLat - 0.05*diff(r.lat)));

tscav = findobj(gcf, 'tag', 'tscav');
tdiffressca = findobj(gcf, 'tag', 'tdiffressca');
set(tscav, 'position', [(legLon - 0.09*diff(r.lon)), legLat, 0]);
set(tdiffressca, 'position', [(legLon - 0.09*diff(r.lon)), (legLat - 0.05*diff(r.lat)), 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check to see whether or not the vector legend should be visible %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckVecScale
legTags = findobj(gcf, '-regexp', 'tag', 'scav$');
vecChecks = findobj(gcf, '-regexp', 'tag', 'vCheck');
on = sum(cell2mat(get(vecChecks, 'value')));
if on > 0
	set(legTags, 'visible', 'on');
else
	set(legTags, 'visible', 'off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call to plot colored line segments %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = mycline(x, y, varargin)
% MYCLINE  Modification of CLINE, using more line-line conventions.
%   MYCLINE(X, Y) draws one line segment per column of X and Y.
%   
%   MYCLINE(X, Y, Z) draws one three-dimensional line segment per 
%   columns of X, Y, and Z.
%
%   MYCLINE(X, Y, C) draws one line segment per column of X and Y, 
%   with segment color specified by vector C.
%
%   MYCLINE(X, Y, Z, C) draws one three-dimensional line segment
%   per column of X, Y, and Z, colored by vector C.
%

if nargin == 3
   if isequal(size(varargin{1}), size(x)) % Z has been specified
      z = varargin{1};
      c = zeros([size(z) 3]);
      c(:, :, 3) = 1;
   else
      c = varargin{1};
      c = repmat(c(:)', 2, 1); 
      z = zeros(size(x));
   end
elseif nargin == 4
      z = varargin{1};
      c = repmat(varargin{2}(:)', 2, 1);
elseif nargin == 2
   c = [0 0 1];
   z = zeros(size(x));
end

% Do the plotting, using the convention of CLINE but with more line-like notation
h = patch(x, y, z, c);
set(h, 'edgecolor', 'flat')


%%%%%%%%%%%%%%%%%%%
function BigTitle(label)
title(label, 'FontSize', 16);