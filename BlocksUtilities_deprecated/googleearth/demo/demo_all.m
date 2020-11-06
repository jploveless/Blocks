%% Demonstrate All functions
% runs all demonstrations

% clear
% close all
% clc

dir_struct = dir(fullfile(googleearthroot,'demo'));
Success = [];

for k=3:length(dir_struct)
    if length(dir_struct(k).name)>=5&&...
       strcmp(dir_struct(k).name(1:5),'demo_')&&...
       strcmp(dir_struct(k).name(end-1:end),'.m')&&...
       ~isequal(dir_struct(k).name,[mfilename,'.m'])
   
        %  eval(['edit ',dir_struct(k).name])
   
        disp(['demo: ' 39 dir_struct(k).name 39 ' started...'])   
        eval(dir_struct(k).name(1:end-2))
        disp(['demo: ' 39 dir_struct(k).name 39 ' completed successfully.'])
        Success=[Success;k];
        
    else
       % disp(['Skipping file: ' 39 dir_struct(k).name 39 '. Not a demo.'])
    end
end

disp([10,'Successfully ran ' num2str(length(Success)) ' demos:'])

for j=1:length(Success)
    disp([ '(',num2str(j,'%02d'),') : ' ,dir_struct(Success(j)).name])
end

clear j k 