function mzXMLFiles = convertRaw(rawFiles)
   if ~exist('mzXML','dir')
      cd(userpath);
      mkdir('mzXML');
   else
      cd([userpath '\mzXML']);
      delete *.mzXML
   end
   for j = 1:length(rawFile)
      system('cd C:\ProteoWizard\');
      system(['msconvert ' rawFiles{j} ' --mzXML --32 -o ' [userpath '/mzXML']]);
   end
   cd([userpath '\mzXML']);
   mzXMLFiles = dir('*.mzXML');
   cd(userpath);
end
