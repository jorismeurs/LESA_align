function peakList = uniquePeaks(allPeaks, tolerance)
   peakVector = cell2mat(allPeaks);
   r = [];
   peakList = [];
   for j = 1:length(allPeaks) 
      if ~isempty(r) 
         dup = find(r(:,1)==j)
         if ~isempty(dup) 
            continue
         end
      end
      maxDev = ppmDeviation(peakVector(j,1),tolerance);
      matchIons = find(peakVector(:,1) >= peakVector(j,1)-maxDev & ... 
                        peakVector(:,1) <= peakVector(j,1)+maxDev);
      if numel(matchIons) > 1
          r = [r;matchIons];
          peakList = [peakList;median(peakVector(matchIons,1))];
      else 
          r = [r;matchIons];
          peakList = [peakList;peakVector(matchIons,1)];
      end
   end
end
