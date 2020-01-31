% Functionality behind LESA_align GUI for processing .RAW files
%
% (c) Joris Meurs, MSc (2020)

function alignMS(parameters) 

% Check validity of input parameters from GUI
validateInput(parameters);
cd([userpath '\LESA_align-master']);
addpath([userpath '\LESA_align-master\src']);

% Browse for
[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on');
if isequal(FileName, 0)
   return
end 
fileLocation = fullfile(PathName, FileName);
% Retrieve peaklist per file
try
   mzxmlFiles = convertRaw(fileLocation);
   [peakData,val] = retrievePeaks(mzxmlFiles,parameters.threshold);
catch
    errordlg('Error during peak processing','Something went wrong with files');
    return
end

% Generate unique peak matrix
if val ~=3
    allPeaks = uniquePeaks(peakData,parameters.tolerance);
else
    for j = 1:2
        allPeaks{j} = uniquePeaks(peakData(j,1),parameters.tolerance);
    end
end

% Retrieve intensities per peak for each file
if val ~= 3
    intensityMatrix = generateIntensityMatrix(allPeaks,peakData,parameters.tolerance);
else
    intensityMatrix{j} = generateIntensityMatrix(cell2mat(allPeaks(j)),peakData,parameters.tolerance); 
end

% Filter variables below threshold abundance and impute remaining missing values
allowedMissing = 0.2;
if val ~= 3
    c = [];
    for j = 1:size(intensityMatrix,2) 
        idx = find(intensityMatrix(:,j)==0);
        if numel(idx) > allowedMissing*size(intensityMatrix,1) 
            c = [c;j];
        end
    end 
    intensityMatrix(:,c) = [];
    allPeaks(c,:) = [];
    intensityMatrix(intensityMatrix==0) = NaN;
    intensityMatrix = knnimpute(intensityMatrix,10);  
else
    peakOut = []; matOut = [];
    for j = 1:2
        c = [];
        tempMat = cell2mat(intensityMatrix(j));
        tempPeaks = cell2mat(allPeaks(j));
        for n = 1:size(intensityMatrix,2) 
            idx = find(intensityMatrix(:,j)==0);
            if numel(idx) > allowedMissing*size(intensityMatrix,1) 
                c = [c;j];
            end
        end 
        tempMat(:,c) = [];
        tempPeaks(c,:) = [];
        tempMat(tempMat==0) = NaN;
        tempMat = knnimpute(tempMat,10);
        peakOut{j} = tempPeaks;
        matOut{j} = tempMat;
    end
end

% Export matrix to an Excel file
if isempty(parameters.name)
   exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_output'];
else
   exportName = parameters.name;
end

if val ~= 3
    xlswrite([exportName '.xlsx'],intensityMatrix,'Sheet1','B2');
    xlswrite([exportName '.xlsx'],FileName','Sheet1','A2');
    xlswrite([exportName '.xlsx'],allPeaks','Sheet1','B1');
else
    for j = 1:2
        tempMat = cell2mat(matOut(j));
        tempPeaks = cell2mat(peakOut(j));
        if j == 1            
            xlswrite([exportName '.xlsx'],tempMat,'pos','B2');
            xlswrite([exportName '.xlsx'],FileName','pos','A2');
            xlswrite([exportName '.xlsx'],tempPeaks','pos','B1'); 
        else
            xlswrite([exportName '.xlsx'],tempMat,'neg','B2');
            xlswrite([exportName '.xlsx'],FileName','neg','A2');
            xlswrite([exportName '.xlsx'],tempPeaks','neg','B1');
        end
    end
end

end


