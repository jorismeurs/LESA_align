% Functionality behind LESA_align GUI for processing .RAW files
%
% (c) Joris Meurs, MSc (2020)

function alignMS(parameters) 

% Check validity of input parameters from GUI
validateInput(parameters);

% Browse for
[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on');
if isequal(FileName, 0);
   return
end 
fileLocation = fullfile(PathName, FileName);

% Retrieve peaklist per file
try
   mzxmlFiles = convertRaw(fileLocation);
   for j = 1:length(mzxmlFiles)
      peakData{j} = retrievePeaks(mzxmlFiles{j});
   end
catch
   errordlg('Error during peak processing','Something went wrong with files');
   return
end

% Generate unique peak matrix

% Retrieve intensities per peak for each file

% Filter variables below threshold abundance and impute remaining missing values

% Export matrix to an Excel file
if isempty(parameters.name)

else
   exportName = parameters.name;
end
xlswrite([exportName '.xlsx'],intensityMatrix,'Sheet1',B2);
xlswrite

end

%---------------------------------
function validateInput(params);

end
%---------------------------------
function mzxmlFiles = convertRaw(rawFiles)

end
%---------------------------------
function retrievePeaks(files)
   
end
%---------------------------------
function peakList = uniquePeaks(allPeaks)

end
%---------------------------------
function intensityMatrix = generateIntensityMatrix(peakList)

end
