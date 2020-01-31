function mzXMLFiles = convertRaw(rawFiles)
   if exist('mzXML','dir') == 0 
      cd(userpath);
      mkdir('mzXML');
   else
      cd([userpath '\mzXML']);
      delete *.mzXML
   end
   for j = 1:length(rawFiles)
      system('cd C:\ProteoWizard\');
      system(['msconvert ' rawFiles{j} ' --mzXML --32 -o ' [userpath '/mzXML']]);
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
