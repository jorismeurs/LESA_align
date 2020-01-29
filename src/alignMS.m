% Code here
function alignMS() 

[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on');
if isequal(FileName, 0);
   return
end 
fileLocation = fullfile(PathName, FileName);
mzxmlFiles = convertRaw(fileLocation);
for j = 1:length(mzxmlFiles)
    peakData = retrieve 
end



end

function mzxmlFiles = convertRaw(rawFiles)

end

function peakList = uniquePeaks(allPeaks)

end
