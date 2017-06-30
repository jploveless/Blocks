function [Command] = ReadCommand(baseFileName)
% ReadCommand.m
%
% Read in commands from *.command file

Command.fileName                                      = baseFileName;

% Set up input file stream
infile                  = fopen(baseFileName, 'r');

% Set default values
Command.reuseElastic                                  = 'no';
Command.reuseElasticFile                              = '';
Command.saveKernels                                   = 'no'; 
Command.poissonsRatio                                 = 0.25;
Command.unitSigmas                                    = 'no';
Command.ldTog2                                        = 0;
Command.ldTog3                                        = 0;
Command.ldTog4                                        = 0;
Command.ldTog5                                        = 0;
Command.ldOvTog                                       = 'no';
Command.ldOvValue                                     = 0;
Command.aprioriBlockName                              = '';
Command.patchFileNames                                = '';
Command.triSmooth                                     = 1;
Command.pmagTriSmooth                                 = 0;
Command.smoothType                                    = 1;
Command.nIter                                         = 1;
Command.triEdge                                       = [0 0 0];
Command.triDepthTol                                   = 0; 
Command.triConWgt                                     = 1;
Command.strainMethod                                  = 1; 
Command.sarFileName                                   = '';
Command.sarRamp                                       = 0;
Command.sarWgt                                        = 1;
Command.triSlipConstraintType                         = 0;
Command.inversionType                                 = 'standard';
Command.inversionParam01                              = 0;
Command.inversionParam02                              = 0;
Command.inversionParam03                              = 0;
Command.inversionParam04                              = 0;
Command.inversionParam05                              = 0;
Command.dumpall                                       = 'no';
Command.mogiFileName                                  = '';
Command.solutionMethod                                = 'backslash';
Command.ridgeParam                                    = 0;

% Read in commands one line at a time
while 1

   line                                               = fgetl(infile);
   if ~isstr(line), break, end
   colon_index                                        = find(line == ':');
   command                                            = lower(line(1:colon_index - 1));
   value                                              = line(colon_index + 2 : end);

   % Parse the string and pull out the values
   switch command

      case('segment file name')
         Command.segFileName                          = strtrim(value);

      case('station file name')
         Command.staFileName                          = strtrim(value);
         
      case('sar file name')
         Command.sarFileName                          = strtrim(value);

      case('block file name')
         Command.blockFileName                        = strtrim(value);

      case('reuse old elastic kernel')
         Command.reuseElastic                         = strtrim(value);

      case('old elastic kernel file')
         Command.reuseElasticFile                     = strtrim(value);
      
      case('save current elastic kernels')
         Command.saveKernels                          = lower(value);
    
      case('fault resolution')
         Command.faultRes                             = str2double(value);

      case('poissons ratio')
         Command.poissonsRatio                        = str2double(value);
      
      case('set all uncertainties to 1')
         Command.unitSigmas                           = lower(value);
         
      case('station data weight')
         Command.stationDataWgt                       = str2double(value);

      case('station data weight minimum')
         Command.stationDataWgtMin                    = str2double(value);

      case('station data weight maximum')
         Command.stationDataWgtMax                    = str2double(value);

      case('station data weight steps')
         Command.stationDataWgtSteps                  = str2double(value);
         
      case('sar data weight')
         Command.sarWgt                               = str2double(value);
         
      case('order of estimated sar ramp')
         Command.sarRamp                              = str2double(value);

      case('slip constraint weight')
         Command.slipConWgt                           = str2double(value);

      case('slip constraint weight minimum')
         Command.slipConWgtMin                        = str2double(value);

      case('slip constraint weight maximum')
         Command.slipConWgtMax                        = str2double(value);

      case('slip constraint weight steps')
         Command.slipConWgtSteps                      = str2double(value);
    
      case('block constraint weight')
         Command.blockConWgt                          = str2double(value);

      case('block constraint weight minimum')
         Command.blockConWgtMin                       = str2double(value);

      case('block constraint weight maximum')
         Command.blockConWgtMax                       = str2double(value);

      case('block constraint weight steps')
         Command.blockConWgtSteps                     = str2double(value);

      case('locking depth toggle 2')
         Command.ldTog2                               = str2double(value);
    
      case('locking depth toggle 3')
         Command.ldTog3                               = str2double(value);
    
      case('locking depth toggle 4')
         Command.ldTog4                               = str2double(value);
    
      case('locking depth toggle 5')
         Command.ldTog5                               = str2double(value);
    
      case('locking depth override toggle')
         Command.ldOvTog                              = lower(value);
      
      case('locking depth override value')
         Command.ldOvValue                            = str2double(value); 
    
      case('apriori block motions relative to')
         Command.aprioriBlockName                     = lower(value);
         
      case('mesh parameter file')
         Command.mshpFileName                         = lower(value);
      
      case('triangulated patch files')
         Command.patchFileNames                       = strtrim(value);

      case('type of a priori slip constraint (1 = slip values, 2 = coupling fraction)')
         Command.triSlipConstraintType                = str2num(value);
         
      case('patch slip distribution files')
         Command.slipFileNames                        = strtrim(value);
      
      case('mesh smoothing values')
         Command.triSmooth                            = str2num(value);
         
      case('mesh smoothing weight')
         Command.triSmooth                            = str2num(value);
         
      case('spatially variable smoothing weighted by resolution')
         Command.pmagTriSmooth                        = str2num(value);
         
      case('smooth slip components individually (1) or simultaneously (2)')
         Command.smoothType                           = str2num(value);
         
      case('set [updip downdip lateral] limits to zero slip')
         Command.triEdge                              = str2num(value); 

      case('constrain slip on [updip downdip lateral] limits')
         Command.triEdge                              = str2num(value);
         
      case('depth tolerance for finding updip and downdip limits (km)')
         Command.triDepthTol                          = str2num(value); 

      case('constrained triangular slip weight')
         Command.triConWgt                            = str2num(value);

      case('strain calculation method')
         Command.strainMethod                         = str2num(value); 
         
      case('number of monte carlo iterations')
         Command.nIter                                = str2double(value); 

      case('inversion type')
         Command.inversionType                        = lower(value);
         
      case('inversiontype')
         Command.inversionType                        = lower(value);

      case('inversionparam01')
         Command.inversionParam01                     = str2double(value); 

      case('inversionparam02')
         Command.inversionParam02                     = str2double(value); 

      case('inversionparam03')
         Command.inversionParam03                     = str2double(value); 

      case('inversionparam04')
         Command.inversionParam04                     = str2double(value); 

      case('inversionparam05')
         Command.inversionParam05                     = str2double(value); 

      case('save all outputs to .mat file')
         Command.dumpall                              = strtrim(value);
         
      case('dumpall')
         Command.dumpall                              = strtrim(value);   
         
      case('mogi source file')
         Command.mogiFileName                         = strtrim(value);

      case('solution method')
         Command.solutionMethod                       = strtrim(value);

      case('ridge regression parameter')
        Command.ridgeParam                            = str2double(value);
        
      case('ridge param')
        Command.ridgeParam                            = str2double(value);


   end   
end
fclose(infile);