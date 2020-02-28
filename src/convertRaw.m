function mzXMLFiles = convertRaw(Path,Files,parameters)
   
   % Determine if a background file is selected for exclusion
   backgroundSpectrum = parameters.name;
   
   % Determine file type
   fileExtLoc = find(Files{1}=='.');
   fileExt = Files{1}(fileExtLoc+1:end);

   % No conversion needed when files are mzXML
   if isequal(fileExt,'mzXML')
       %cd(Path);
       %mzXMLList = dir('*.mzXML');
       mzXMLFiles = fullfile(Path,Files);
       %cd([userpath '\LESA_align-master\src']);
   
   % Convert RAW to mzXML
   elseif isequal(fileExt,'raw')
       rawFiles = fullfile(Path,Files);
       currentFolder = cd('C:\ProteoWizard\'); 
       for j = 1:length(rawFiles)        
          system(['msconvert ' rawFiles{j} ' --mzXML --32 -o ' Path]);
       end
       cd(Path);
%        mzXMLList = dir('*.mzXML');
        mzXMLFiles = [];
%        for j = 1:length(mzXMLList)
%            mzXMLFiles{j} = fullfile(mzXMLList(j).folder,mzXMLList(j).name);
%        end
%        if ~isempty(backgroundSpectrum)
%            remove = find(contains(mzXMLFiles,backgroundSpectrum));
%            mzXMLFiles(remove) = [];
%        end
       for j = 1:length(rawFiles)
           fileExtLoc = find(Files{j}=='.');
           tempName = fullfile(Path,[Files{j}(1:fileExtLoc) 'mzXML']);
           disp(tempName);
           mzXMLFiles = [mzXMLFiles;{tempName}];
       end
       cd(currentFolder);
   elseif isequal(fileExt,'txt')
      mzXMLFiles = fullfile(Path,Files); 
   end
   cd(Path);
end
