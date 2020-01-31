function intensityMatrix = generateIntensityMatrix(peakList,peakData,tolerance)

intensityMatrix = zeros(length(peakData),length(peakList));
for j = 1:length(peakList) 
   peakMZ = peakList(j,1);
   maxDev = ppmDeviation(peakMZ,tolerance);
   for n = 1:length(peakData) 
      tempData = cell2mat(peakData(n,1));
      peakMatch = find(tempData(:,1) >= peakMZ-maxDev & ... 
                       tempData(:,1) <= peakMZ+maxDev);
      if ~isempty(peakMatch) 
         intensityMatrix(n,j) = tempData(peakMatch(1),2);
      end
   end 
end
