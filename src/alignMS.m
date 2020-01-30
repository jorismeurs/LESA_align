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
intensityMatrix = generateIntensityMatrix(allPeaks,peak Data);

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

%---------------------------------
function validateInput(params);
   for j = 1:length(params)
      if ~isempty(params.tolerance)
         if ~isnumeric(params.tolerance) || params.tolerance <= 0
            errordlg('Invalid input','Choose different value for tolerance');
            return
         end
      else
         params.tolerance = 5; % Default value
      end
      if ~isempty(params.threshold)
         if ~isnumeric(params.threshold) || params.threshold <= 0
            errordlg('Invalid input','Choose different value for threshold');
         end
      else
         params.threshold = 10000; % Default value
      end
   end
end
%---------------------------------
function mzXMLFiles = convertRaw(rawFiles)
   if ~exist('mzXML','dir')
      cd(userpath);
      mkdir('mzXML');
   else
      cd([userpath '\mzXML']);
      delete *.mzXML
   end
   for j = 1:length(rawFile)
      system('cd C:\ProteoWizard\');
      system(['msconvert ' rawFiles{j} ' --mzXML --32 -o ' [userpath '/mzXML']]);
   end
   cd([userpath '\mzXML']);
   mzXMLFiles = dir('*.mzXML');
   cd(userpath);
end
%---------------------------------
function peakList = retrievePeaks(files)
   
end
%---------------------------------
function peakList = uniquePeaks(allPeaks)

end
%---------------------------------
function intensityMatrix = generateIntensityMatrix(peakList)

end
