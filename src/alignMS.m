% Code here
function alignMS() 

[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on');
if isequal(FileName, 0);
   return
end 
fileLocation = fullfile(PathName, FileName);
mzxmlFiles = convertRaw(fileLocation);

end

function mzxmlFiles = convertRaw(rawFiles)

end

function peakList = uniquePeaks(allPeaks)

end
