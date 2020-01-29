% Code here
function alignMS(parameters) 

validateInput(parameters);

[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on');
if isequal(FileName, 0);
   return
end 
fileLocation = fullfile(PathName, FileName);
mzxmlFiles = convertRaw(fileLocation);
for j = 1:length(mzxmlFiles)
    peakData{j} = retrievePeaks(mzxmlFiles{j});
end



end

function validateInput(params);

end

function mzxmlFiles = convertRaw(rawFiles)

end

function peakList = uniquePeaks(allPeaks)

end
