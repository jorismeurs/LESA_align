% Code here
function alignMS() 

[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on')
if isequal(FileName, 0)
   return
end 

end

function mzxmlFiles = convertRaw(rawFiles)

end

function peakList = uniquePeaks(allPeaks)

end
