function [peakList,processVal] = retrievePeaks(files,parameters)

   % Get parameters
   threshold = parameters.threshold;
   intVal = parameters.intensityVal;
   processVal = parameters.polarity;
   minMZ = parameters.minMZ;
   maxMZ = parameters.maxMZ;
   
   
   minTIC = inputdlg('Enter minimum TIC:','Minimum TIC',...
       [1 35],{'1000'});
   minTIC = cell2mat(minTIC);
   
   peakList = []; peakListPos = []; peakListNeg = [];
   wb = waitbar(0,sprintf('Peak picking'));
   %set(findall(wb),'Units', 'normalized');
   %set(wb,'Position', [0.215 0.55 0.2 0.2]);   
   
   % Parse files
   for j = 1:length(files)
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Parsing mzXML',j,length(files))); 
      msStruct = mzxmlread(files{j},'Levels',1);
      
      % Get indices for scans to process
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Retrieve scan indices',j,length(files)));
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
      % Base peak should be larger than a user-defined threshold
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Filter scans',j,length(files)));
      if processVal == 1
         includedScans = [];
         for n = 1:length(posIdx)
            if msStruct.scan(posIdx(n)).basePeakIntensity > minTIC
               includedScans = [includedScans;posIdx(n)];
            end
         end
      elseif processVal == 2
         includedScans = [];
         for n = 1:length(negIdx)
            if msStruct.scan(negIdx(n)).basePeakIntensity > minTIC
               includedScans = [includedScans;negIdx(n)];
            end
         end
      elseif processVal == 3
         includedScansNeg = [];
         for n = 1:length(negIdx)
            if msStruct.scan(negIdx(n)).basePeakIntensity > minTIC
               includedScansNeg = [includedScansNeg;negIdx(n)];
            end
         end
         includedScansPos = [];
         for n = 1:length(posIdx)
            if msStruct.scan(posIdx(n)).basePeakIntensity > minTIC
               includedScansPos = [includedScansPos;posIdx(n)];
            end
         end
      end
      
      % Generate CMZ vector (Race et al., Anal Chem.)
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Interpolation CMZ',j,length(files)));
      binSize = -8e-8; % Empirical value
      mzChannels = 1/sqrt(minMZ):binSize:1/sqrt(maxMZ)+binSize;
      mzChannels = ones(size(mzChannels))./(mzChannels.^2);
      
      % Generate average spectrum for chosen polarity/polarities
      if processVal == 1 || processVal == 2
         if ~isempty(includedScans) 
             includedData = []; mzData = []; intData = []; interpolatedSpectra = [];
             if length(includedScans) > 1
                includedScans(1:10) = [];
             end
             for n = 1:length(includedScans)
                scanData = msStruct.scan(includedScans(n)).peaks.mz;
                mz = scanData(1:2:end);
                int = scanData(2:2:end);
                [mz,idx] = unique(mz);
                int = int(idx,1);
                mzData{n,1} = mz;
                intData{n,1} = int;
             end
             interpolatedSpectra = fastInterp1(mzData,intData,mzChannels);
             interpolatedSpectra = cell2mat(interpolatedSpectra);
             averageY = nanmean(interpolatedSpectra,1);
         else
             averageY = [];
         end
      else
         includedDataPos  = []; mzData = []; intData = []; interpolatedSpectra = [];
         if ~isempty(includedScansPos) 
             if length(includedScans) > 1
                includedScans(1:10) = [];
             end
             for n = 1:length(includedScansPos)
                scanData = msStruct.scan(includedScansPos(n)).peaks.mz;
                mz = scanData(1:2:end);
                int = scanData(2:2:end);
                [mz,idx] = unique(mz);
                int = int(idx,1);
                mzData{n,1} = mz;
                intData{n,1} = int;
             end
             interpolatedSpectra = fastInterp1(mzData,intData,mzChannels);
             interpolatedSpectra = cell2mat(interpolatedSpectra);
             averageYPos = nanmean(interpolatedSpectra,1);
         else
             averageYPos = [];
         end

         if ~isempty(includedScansNeg) 
             if length(includedScans) > 1
                includedScans(1:10) = [];
             end
             includedDataNeg = []; mzData = []; intData = []; interpolatedSpectra = [];
             for n = 1:length(includedScansNeg)
                scanData = msStruct.scan(includedScansNeg(n)).peaks.mz;
                mz = scanData(1:2:end);
                int = scanData(2:2:end);
                [mz,idx] = unique(mz);
                int = int(idx,1);
                mzData{n,1} = mz;
                intData{n,1} = int;
             end
             interpolatedSpectra = fastInterp1(mzData,intData,mzChannels);
             interpolatedSpectra = cell2mat(interpolatedSpectra);
             averageYNeg = nanmean(interpolatedSpectra,1);
         else
            averageYNeg = [];
         end
      end
      
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Peak picking',j,length(files)));
      % Perform peak picking
      if processVal == 1 || processVal == 2
          if ~isempty(averageY)
              if intVal == 2
                 thresholdVal = (theshold/100)*max(averageY); 
              else
                 thresholdVal = threshold; 
              end
              peakList{j,1} = mspeaks(mzChannels',averageY','HeightFilter',thresholdVal,'Denoising',false);
          else
              peakList{j,1} = [];
          end
      else
          if ~isempty(averageYPos)
              peakListPos{j,1} = mspeaks(mzChannels',averageYPos','HeightFilter',threshold,'Denoising',false);
          else
              peakListPos{j,1} = [];
          end
          if ~isempty(averageYNeg)
              peakListNeg{j,1} = mspeaks(mzChannels',averageYNeg','HeightFilter',threshold,'Denoising',false);
          else
              peakListNeg{j,1} = [];
          end
          peakList = [peakListPos;peakListNeg]; % Store as 2 x 1 cell array for positive and negative data
      end
   end
   delete(wb);
%end
