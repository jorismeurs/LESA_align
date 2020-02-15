function mzXMLFiles = convertRaw(Path,Files)

   % Determine file type
   fileExtLoc = find(Files{1}=='.');
   fileExt = Files{1}(fileExtLoc+1:end);
   
   % No conversion needed when files are mzXML
   if isequal(fileExt,'mzXML')
       cd(Path);
       mzXMLList = dir('*.mzXML');
       for j = 1:size(mzXMLList,1)
           tempName = fullfile(mzXMLList(j).folder,mzXMLList(j).name);
           mzXMLFiles = [mzXMLFiles;{tempName}];
       end
       cd([userpath '\LESA_align-master\src']);
   
   % Convert RAW to mzXML
   elseif isequal(fileExt,'raw')
       rawFiles = fullfile(Path,Files);
       for j = 1:length(rawFiles)
          system('cd C:\ProteoWizard\');
          system(['msconvert ' rawFiles{j} ' --mzXML --32 -o ' [userpath '\mzXML']]);
       end
       cd([userpath '\mzXML']);
       mzXMLList = dir('*.mzXML');
       mzXMLFiles = [];
       for j = 1:size(mzXMLList,1)
           tempName = fullfile(mzXMLList(j).folder,mzXMLList(j).name);
           mzXMLFiles = [mzXMLFiles;{tempName}];
       end
       cd([userpath '\LESA_align-master\src']);
   end
end
