% Functionality behind LESA_align GUI for processing .RAW files
%
% (c) Joris Meurs, MSc (2020)

function alignMS(parameters) 

% Check validity of input parameters from GUI
% parameters.tolerance = 5;
% parameters.threshold = 10000;
% parameters.name = [];
% parameters.polarity = 3;
% parameters.minMZ = 70;
% parameters.maxMZ = 1050;

validateInput(parameters);
cd([userpath '\LESA_align-master']);
addpath([userpath '\LESA_align-master\src']);

% Browse for files
% mzXML not supported yet
[FileName, PathName] = uigetfile({'*.raw','Thermo RAW Files (.raw)';'*.mzXML','mzXML Files (.mzXML)'},...
'MultiSelect','on');
if isequal(FileName, 0)
   return
end 
%fileLocation = fullfile(PathName, FileName);

% Retrieve peaklist per file
try
   mzxmlFiles = convertRaw(PathName,FileName);
   [peakData,val] = retrievePeaks(mzxmlFiles,parameters);
catch
   errordlg('Error during peak processing','Something went wrong with files');
   return
end

% Generate unique peak matrix
if val ~=3
    allPeaks = uniquePeaks(peakData,parameters);
else
    for j = 1:2
        posIDX = 1:length(peakData)/2;
        negIDX = (length(peakData)/2)+1:length(peakData);
        if j == 1
            allPeaks{j} = uniquePeaks(peakData(posIDX,1),parameters);
        else
            allPeaks{j} = uniquePeaks(peakData(negIDX,1),parameters);
        end
    end
end

if val~=3
    allPeaks = deisotope(allPeaks);
else
    for j = 1:2
       allPeaks{j} = deisotope(cell2mat(allPeaks(j)));
    end
end

% Retrieve intensities per peak for each file
intensityMatrix = [];
if val ~= 3
    [intensityMatrix,emptyIDX] = generateIntensityMatrix(allPeaks,peakData,parameters);
else
    posIDX = 1:length(peakData)/2;
    negIDX = (length(peakData)/2)+1:length(peakData);
    for j = 1:2
        if j == 1
            [intensityMatrix{j},emptyIDX{j}] = generateIntensityMatrix(cell2mat(allPeaks(j)),peakData(posIDX),parameters);
        else
            [intensityMatrix{j},emptyIDX{j}] = generateIntensityMatrix(cell2mat(allPeaks(j)),peakData(negIDX),parameters);
        end
    end
end

% Filter variables below threshold abundance and impute remaining missing values
allowedMissing = 0.2;
if val ~= 3
    c = [];
    for j = 1:size(intensityMatrix,2) 
        idx = find(intensityMatrix(:,j)==0);
        if numel(idx) > ceil(allowedMissing*size(intensityMatrix,1)) 
            c = [c;j];
        end
    end 
    intensityMatrix(:,c) = [];
    allPeaks(c,:) = [];
    intensityMatrix(intensityMatrix==0) = NaN;
    intensityMatrix = intensityMatrix';
    intensityMatrix = knnimpute(intensityMatrix,10);  
    intensityMatrix = intensityMatrix';
else
    peakOut = []; matOut = [];
    for j = 1:2
        c = [];
        tempMat = cell2mat(intensityMatrix(j));
        tempPeaks = cell2mat(allPeaks(j));
        for n = 1:size(tempMat,2) 
            idx = find(tempMat(:,j)==0);
            if numel(idx) > ceil(allowedMissing*size(tempMat,1)) 
                c = [c;j];
            end
        end 
        tempMat(:,c) = [];
        tempPeaks(c,:) = [];
        tempMat(tempMat==0) = NaN;
        tempMat = tempMat';
        tempMat = knnimpute(tempMat,10);
        tempMat = tempMat';
        peakOut{j} = tempPeaks;
        matOut{j} = tempMat;
    end
end

% Export matrix to an Excel file
try
    if isempty(parameters.name)
       exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_output'];
    else
       exportName = parameters.name;
    end
catch
    exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_output'];
end

if val ~= 3
    % Remove file names from spectra without peaks
    if ~isempty(emptyIDX)
       FileName(emptyIDX) = [];
    end
    xlswrite([exportName '.xlsx'],intensityMatrix,'Sheet1','B2');
    xlswrite([exportName '.xlsx'],FileName','Sheet1','A2');
    xlswrite([exportName '.xlsx'],allPeaks','Sheet1','B1');
else
    % Create separate file name cell arrays in case for one polarity peaks
    % are missing
    FileNamePos = FileName;
    FileNameNeg = FileName;
    for j = 1:2
        tempMat = cell2mat(matOut(j));
        tempPeaks = cell2mat(peakOut(j));
        if j == 1
            if ~isempty(emptyIDX)
               FileNamePos(emptyIDX) = [];
            end
            xlswrite([exportName '.xlsx'],tempMat,'pos','B2');
            xlswrite([exportName '.xlsx'],FileNamePos','pos','A2');
            xlswrite([exportName '.xlsx'],tempPeaks','pos','B1'); 
        else
            if ~isempty(emptyIDX)
               FileNameNeg(emptyIDX) = [];
            end
            xlswrite([exportName '.xlsx'],tempMat,'neg','B2');
            xlswrite([exportName '.xlsx'],FileNameNeg','neg','A2');
            xlswrite([exportName '.xlsx'],tempPeaks','neg','B1');
        end
    end
end

end


