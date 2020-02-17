function intensityMatrix = generateIntensityMatrix(peakList,peakData,parameters)
    tolerance = parameters.tolerance;
    emptyIDX = cellfun(@(data) isempty(data),peakData,'UniformOutput',false);
    fileCount = length(peakData)-length(emptyIDX);
    intensityMatrix = zeros(fileCount,length(peakList));
    for j = 1:length(peakList) 
       peakMZ = peakList(j,1);
       maxDev = ppmDeviation(peakMZ,tolerance);
       for n = 1:length(peakData) 
          if ~isempty(emptyIDX) 
             if ~isempty(find(emptyIDX(:,1)==n))
                continue 
             end
          end
          tempData = cell2mat(peakData(n,1));
          peakMatch = find(tempData(:,1) >= peakMZ-maxDev & ... 
                           tempData(:,1) <= peakMZ+maxDev);
          if ~isempty(peakMatch) 
             intensityMatrix(n,j) = tempData(peakMatch(1),2);
          end
       end 
    end
end
