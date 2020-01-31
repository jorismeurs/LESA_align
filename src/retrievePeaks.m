function [peakList,processVal] = retrievePeaks(files,threshold)

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
      msStruct = mzxmlread(files{j},'Levels',1);
      
      % Get indices for scans to process
      if processVal == 1
         posIdx = [];
         for n = 1:length(msStruct.scan)
            if msStruct.scan(n).polarity == '+' 
                posIdx = [posIdx;n];
            end
         end
      elseif processVal == 2
         negIdx = [];
         for n = 1:length(msStruct.scan)
            if msStruct.scan(n).polarity == '-' 
                negIdx = [negIdx;n];
            end
         end
      elseif processVal == 3
         posIdx = [];
         for n = 1:length(msStruct.scan)
            if msStruct.scan(n).polarity == '+' 
                posIdx = [posIdx;n];
            end
         end
         negIdx = [];
         for n = 1:length(msStruct.scan)
            if msStruct.scan(n).polarity == '-' 
                negIdx = [negIdx;n];
            end
         end
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
         includedData = [];
         for n = 1:length(includedScans)
            scanData = msStruct.scan(includedScans(n)).peaks.mz;
            mz = scanData(1:2:end);
            int = scanData(2:2:end);
            includedData{n,1} = [mz,int]; 
         end
         [MZ,Y] = msppresample(includedData,5e6);
         averageY = nanmean(Y,2);
      else
         includedData  = [];
         for n = 1:length(includedScansPos)
            scanData = msStruct.scan(includedScansPos(n)).peaks.mz;
            mz = scanData(1:2:end);
            int = scanData(2:2:end);
            includedData{n,1} = [mz,int]; 
         end
         [MZPos,Y] = msppresample(includedData,5e6);
         averageYPos = nanmean(Y,2);
         includedData = [];
         for n = 1:length(includedScansNeg)
            scanData = msStruct.scan(includedScansNeg(n)).peaks.mz;
            mz = scanData(1:2:end);
            int = scanData(2:2:end);
            includedData{n,1} = [mz,int]; 
         end
         [MZNeg,Y] = msppresample(includedData,5e6);
         averageYNeg = nanmean(Y,2);
      end
      
      % Perform peak picking
      if processVal == 1 || processVal == 2
         for n = 1:size(averageY,2)
            peakList{j,1} = mspeaks(MZ,averageY,'HeightFilter',threshold);
         end
      else
         for n = 1:size(averageYPos,2)
            peaksPos{j,1} = mspeaks(MZPos,averageYPos,'HeightFilter',threshold);
         end
         for n = 1:size(averageYNeg,2)
            peaksNeg{j,1} = mspeaks(MZNeg,averageYNeg,'HeightFilter',threshold);
         end
         peakList = [peaksPos;peaksNeg]; % Store as 2 x 1 cell array for positive and negative data
      end
   end
end
