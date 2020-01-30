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
allPeaks = uniquePeaks(peakData);

% Retrieve intensities per peak for each file
intensityMatrix = generateIntensityMatrix(allPeaks,peakData);

% Filter variables below threshold abundance and impute remaining missing values
allowedMissing = 0.2;
c = [];
for j = 1:size(intensityMatrix,2) 
    idx = find(intensityMatrix(:,j)==0);
    if numel(idx) > allowedMissing*size(intensityMatrix,1) 
        c = [c;j];
    end
end 
intensityMatrix(:,c) = [];
intensityMatrix(intensityMatrix==0) = NaN;
intensityMatrix = knnimpute(intensityMatrix,10);

% Export matrix to an Excel file
if isempty(parameters.name)

else
   exportName = parameters.name;
end

xlswrite([exportName '.xlsx'],intensityMatrix,'Sheet1',B2);
xlswrite([exportName '.xlsx'],FileName','Sheet1'

end


