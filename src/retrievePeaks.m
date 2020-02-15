function [peakList,processVal] = retrievePeaks(files,parameters)

   % Get threshold value for peak intensity
   threshold = parameters.threshold;
   processVal = parameters.polarity;
   
   wb = waitbar(0,sprintf('Peak picking'));
   set(findall(wb),'Units', 'normalized');
    % Change the size of the figure
    set(wb,'Position', [0.5 0.5 0.2 0.2]);   

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
      % Base peak should be larger than 1e5
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Filter scans',j,length(files)));
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
      
      % Generate CMZ vector (Race et al., Anal Chem.)
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Interpolation CMZ',j,length(files)));
      binSize = -8e-8; % Empirical value
      minMZ = parameters.minMZ;
      maxMZ = parameters.maxMZ;
      mzChannels = 1/sqrt(minMZ):binSize:1/sqrt(maxMZ)+binSize;
      mzChannels = ones(size(mzChannels))./(mzChannels.^2);
      
      % Generate average spectrum for chosen polarity/polarities
      if processVal == 1 || processVal == 2
         includedData = [];
         for n = 1:length(includedScans)
            scanData = msStruct.scan(includedScans(n)).peaks.mz;
            mz = scanData(1:2:end);
            int = scanData(2:2:end);
            [mz,idx] = unique(mz);
            int = int(idx,1);
            includedData = [includedData;interp1(mz,int,mzChannels,'linear')];
         end
         averageY = nanmean(includedData,1);
      else
         includedDataPos  = [];
         for n = 1:length(includedScansPos)
            scanData = msStruct.scan(includedScansPos(n)).peaks.mz;
            mz = scanData(1:2:end);
            int = scanData(2:2:end);
            [mz,idx] = unique(mz);
            int = int(idx,1);
            includedDataPos = [includedDataPos;interp1(mz,int,mzChannels,'linear')];
         end
         averageYPos = nanmean(includedDataPos,1);
         includedDataNeg = [];
         for n = 1:length(includedScansNeg)
            scanData = msStruct.scan(includedScansNeg(n)).peaks.mz;
            mz = scanData(1:2:end);
            int = scanData(2:2:end);
            [mz,idx] = unique(mz);
            int = int(idx,1);
            includedDataNeg = [includedDataNeg;interp1(mz,int,mzChannels,'linear')]; 
         end
         averageYNeg = nanmean(includedDataNeg,1);
      end
      
      wb = waitbar(j/length(files),wb,sprintf('Peak picking \n File %d/%d \n Peak picking',j,length(files)));
      % Perform peak picking
      if processVal == 1 || processVal == 2
          peakList{j,1} = mspeaks(mzChannels',averageY','HeightFilter',threshold);
      else
          peakListPos{j,1} = mspeaks(mzChannels',averageYPos','HeightFilter',threshold);
          peakListNeg{j,1} = mspeaks(mzChannels',averageYNeg','HeightFilter',threshold);
          peakList = [peakListPos;peakListNeg]; % Store as 2 x 1 cell array for positive and negative data
      end
   end
   delete(wb);
end
