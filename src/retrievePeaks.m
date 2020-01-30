function peakList = retrievePeaks(files)

   % Select polarity for processing
   processingType = questdlg('Choose polarity','Select polarity for processing data',...
      'Positive','Negative','Both','Positive');
   switch processingType
      case 'Positive'
         processVal = 1;
      case 'Negative'
         processVal = 2;
      case 'Both'
         processVal = 3;
      otherwise
         processVal = 1; % Default is positive when no parameter is chosen
   end
   
   % Parse files
   for j = 1:length(files)
      msStruct = mzxmlread(files{j});
      
      % Get indices for scans to process
      if processVal == 1
         posIdx = find(msStruct.scan.polarity=='+');
      elseif processVal == 2
         negIdx = find(msStruct.scan.polarity=='-');
      elseif processVal == 3
         posIdx = find(msStruct.scan.polarity=='+');
         negIdx = find(msStruct.scan.polarity=='-');
      end
      
      % Filter scans based on base peak value
      % Base peak should be larger than 1e5
      if processVal == 1
         includedScans = [];
         for n = 1:length(posIdx)
            if msStruct.scan(posIdx(n)).basePeakIntensity > 1e5
               includedScans = [includedScans;posIdx(n)];
            end
         end
      elseif processVal == 2
         includedScans = [];
         for n = 1:length(negIdx)
            if msStruct.scan(negIdx(n)).basePeakIntensity > 1e5
               includedScans = [includedScans;negIdx(n)];
            end
         end
      elseif processVal == 3
         includedScansNeg = [];
         for n = 1:length(negIdx)
            if msStruct.scan(negIdx(n)).basePeakIntensity > 1e5
               includedScansNeg = [includedScansNeg;negIdx(n)];
            end
         end
         includedScansPos = [];
         for n = 1:length(posIdx)
            if msStruct.scan(posIdx(n)).basePeakIntensity > 1e5
               includedScansPos = [includedScansPos;posIdx(n)];
            end
         end
      end
      
      % Generate average spectrum for chosen polarity/polarities
      if processVal == 1 || processVal == 2
         for n = 1:length(includedScans)
         
         end
      else
         for n = 1:length(includedScansPos)
         
         end
         for n = 1:length(includedScansNeg)
         
         end
      end
   end
end
