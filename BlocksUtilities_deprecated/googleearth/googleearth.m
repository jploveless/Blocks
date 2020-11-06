function googleearth(varargin)

if nargin==0
    if uimatlab
        disp(['% Correct usage is one of:',char(10),...
              '%  >> googleearth -docinstall',char(10),...
              '%  >> googleearth -setbrowser',char(10),...
              '%  >> googleearth -version',char(10)])
    elseif uioctave
        disp(['% Correct usage is one of:',char(10),...
              '%  >> googleearth(',char(39),'-docinstall',char(39),')',char(10),...
              '%  >> googleearth(',char(39),'-setbrowser',char(39),')',char(10),...
              '%  >> googleearth(',char(39),'-version',char(39),')'])
    else
        disp('Unknown development environment.')
    end
        
    return
end

switch varargin{1}
    case '-docinstall'
        
        googleearth('-withdemos')
        
        try
            googleearth -versionFileForceChange
        catch
            warning('Non-fatal error during version file update.')
        end
        
        try
            try

                fid=fopen(fullfile(googleearthroot,'info.xml.template'),'r');
                textInfoXML='';
                while true
                    tline = fgets(fid);
                    if ischar(tline)
                        textInfoXML = [textInfoXML,tline];
                    else
                        break
                    end
                end
                fclose(fid);

                fid=fopen(fullfile(googleearthroot,'info.xml'),'wt');
                fprintf(fid,textInfoXML,googleearthroot);
                fclose(fid);

            catch
                warning('GoogleEarth:writing_of_info_file',...
                    ['An error occurred during writing ',...
                    'of googleearth ',char(39),...
                    'info.xml',char(39),' file'])
            end

            % % % % % % % % % % % % info.xml is written

            try

                fid=fopen(fullfile(prefdir,'matlab.prf'),'r');
                C = textscan(fid, '%s','delimiter','\r');
                fclose(fid);

                Colors_M_CommentsStr = '228B22';
                Colors_M_StringsStr = 'A020F0';
                Colors_M_KeywordsStr = '0000FF';
                Colors_M_SystemCommandsStr = 'B28C00';

                for k=1:numel(C{1})
                    try
                        MatlabVarName = strread(C{1}{k},'%[^=]',1);
                        
                        switch MatlabVarName{1}
                            case 'Colors_M_Comments'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_CommentsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                            case 'Colors_M_Strings'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_StringsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                            case 'Colors_M_Keywords'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_KeywordsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                            case 'Colors_M_SystemCommands'
                                indColor = strread(C{1}{k},'%*[^=]%*[=]%s',1);
                                [r,g,b]=indexed2hexcolor(indColor{1});
                                Colors_M_SystemCommandsStr =...
                                    [dec2hex(r,2),dec2hex(g,2),dec2hex(b,2)];
                        end
                    catch
                        warning('Error while parsing matlab preferences file.')
                    end
                end

                disp('Adopting user-customized styles for documentation files...')
                
                fid=fopen(fullfile(googleearthroot,'html','styles',...
                    'ge_styles.css.template'),'r');
                textStylesCSS='';
                while true
                    tline = fgets(fid);
                    if ischar(tline)
                        textStylesCSS = [textStylesCSS,tline];
                    else
                        break
                    end
                end
                fclose(fid);

                fid=fopen(fullfile(googleearthroot,'html','styles',...
                    'ge_styles.css'),'wt');
                fprintf(fid,textStylesCSS,...
                    Colors_M_CommentsStr,...
                    Colors_M_StringsStr,...
                    Colors_M_KeywordsStr,...
                    Colors_M_SystemCommandsStr);
                fclose(fid);
                
                disp([char(8),'Done.'])                

            catch
                warning('googleearth:writing_of_styles_file',...
                    ['An error occurred during writing ',...
                    'of googleearth ',char(39),...
                    'ge_styles.css',char(39),' file...Proceeding.'])

            end
            
            if uimatlab
                msg1 = [char(10),'Click on the MATLAB ',...
                    'Start button->Desktop Tools->View Source Files...',...
                    char(10),'...and click Refresh Start Button.'];
                msg2 = ['Click on the MATLAB ',...
                    'Start button->Desktop Tools->View Start Button Configuration Files...',...
                    char(10),'...and click Refresh Start Button.'];
                try
                    versionNumber = strread(versionStr,'%3f',1);
                catch
                    versionNumber = 7.2;
                end
                if versionNumber<=7.2
                    disp(msg1)
                else
                    disp(msg2)                
                end
            end
        catch
        end
    case '-withdemos'
        disp('Adding ''demo'' folder to the path...')
        addpath(fullfile(googleearthroot,'demo'))
        disp([char(8),'Done.'])
        
    case '-setbrowser'
        
        fid = fopen(fullfile(googleearthroot,'browsercall.txt'),'r');
        callStr = fgetl(fid);
        fclose(fid);

        if isempty(callStr) 
            disp(['No browser call has been set yet.'])
        else
            disp(['The browser call is currently set to: ',char(10),callStr])
        end

        loop=true;
        while loop 
            strQ1 = ['Would you like to change the browser launch call?',char(10),...
                'yes : [y]  ',char(10),...
                'no  : [n] or [Enter]',char(10),'>> '];
            strA1 = input(strQ1, 's');
            if isempty(strA1)|strcmp(strA1,'n')
                strA1 = 'n';
                loop=false;
            elseif strcmp(strA1,'y')
                loop=false;
            else
                loop=true;
                disp(repmat(char(8),[1,numel(strQ1)+2+numel(strA1)]))
            end

        end

        if strcmp(strA1,'y')

            strQ2 = ['Type the call to launch your browser',char(10),...
                     '>> '];
            strA2 = input(strQ2, 's');
            fid = fopen(fullfile(googleearthroot,'browsercall.txt'),'wt');
            fprintf(fid,'%s',strA2);
            fclose(fid);

            disp('Browser launch call has been reset.')
        else
            disp('Browser launch call has not been reset.')
        end
        
    case '-version'
        fid=fopen(fullfile(googleearthroot,'version-info.txt'),'rt');
        s=fgetl(fid);
        s=fgetl(fid);
        s=fgetl(fid);
        C=textscan(s,'This the GoogleEarth Toolbox for MATLAB Revision $LastChangedRevision: %n');
        v=C{1}; 
        fclose(fid);
        disp([char(10),'GoogleEarth Toolbox for MATLAB (revision ',...
            num2str(v),').',char(10)])
        
    case '-versionFileForceChange'
        
        % this part is called whenever you run googleearth -docinstall, so
        % that the 'version-info.txt' file changes, which in turn triggers
        % the version number in that file to be updated by the SVN system.

        % disp('Updating version number...')
        fid=fopen(fullfile(googleearthroot,'version-info.txt'),'r');
        
        versionStr='';
        for k=1:4
            versionStr=[versionStr,fgetl(fid),char(10)];
        end
        fclose(fid);

        lowerChars = 'abcdefghijklmnopqrstuvwxyz';
        upperChars = upper(lowerChars);
        allChars = [lowerChars,upperChars];
        nChars = numel(allChars);
        allChars = allChars(round((nChars-1)*rand(1,100*50)+1));
        allChars(50:50:end)=char(10);
        randomCharsStr = allChars;
        
        
        fid=fopen(fullfile(googleearthroot,'version-info.txt'),'w');
        fprintf(fid,'%s%s',versionStr,randomCharsStr);
        fclose(fid);
        
        % disp([char(8),'Done.'])        
       
    otherwise
        disp('Unrecognized option.')
        return

end