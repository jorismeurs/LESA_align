% Functionality behind LESA_align GUI for processing .RAW files
%
% (c) Joris Meurs, MSc (2020)

function alignMS(parameters,handles) 
% Initiate process
processVal = 0;
updateProcess(processVal,handles);

% Check validity of input parameters from GUI

try
    validateInput(parameters);
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end


% Browse for files
% mzXML not supported yet
try
    [FileName, PathName] = uigetfile({'*.raw','Thermo RAW Files (.raw)';'*.mzXML','mzXML Files (.mzXML)'},...
    'MultiSelect','on');
    if isequal(FileName, 0)
        failedProcess(handles);
        return
    end 
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
   failedProcess(handles); 
end

% Retrieve peaklist per file
try
    mzxmlFiles = convertRaw(PathName,FileName);
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
   failedProcess(handles); 
end

try
    [peakData,val] = retrievePeaks(mzxmlFiles,parameters);
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end

% Generate unique peak matrix
try
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
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end

% Remove isotopes from peak list
try
    if val ~= 3
        allPeaks = deisotope(allPeaks);
    else
        for j = 1:2
           allPeaks{j} = deisotope(cell2mat(allPeaks(j)));
        end
    end
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end

% Subtract background peaks if file provided
try
    if ~isempty(parameters.backgroundSpectrum)
       if val ~= 3
           allPeaks = subtractBackground(allPeaks,parameters);
       else
          for j = 1:2
             allPeaks{j} = subtractBackground(cell2mat(allPeaks(j)),parameters,j); 
          end
       end
    end
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end

% Retrieve intensities per peak for each file
% Store original peak matrices separately
try
    intensityMatrix = []; orginalMatrix = []; originalPeaks = [];
    if val ~= 3
        [intensityMatrix,emptyIDX] = generateIntensityMatrix(allPeaks,peakData,parameters);
        originalMatrix = intensityMatrix;
        originalPeaks = allPeaks;
    else
        posIDX = 1:length(peakData)/2;
        negIDX = (length(peakData)/2)+1:length(peakData);
        for j = 1:2
            if j == 1
                [intensityMatrix{j},emptyIDX{j}] = generateIntensityMatrix(cell2mat(allPeaks(j)),peakData(posIDX),parameters);
                originalMatrix{j} = cell2mat(intensityMatrix(j));
                originalPeaks{j} = cell2mat(allPeaks(j));
            else
                [intensityMatrix{j},emptyIDX{j}] = generateIntensityMatrix(cell2mat(allPeaks(j)),peakData(negIDX),parameters);
                originalMatrix{j} = cell2mat(intensityMatrix(j));
                originalPeaks{j} = cell2mat(allPeaks(j));
            end
        end
    end
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
   failedProcess(handles); 
end

% Export orginal peaks and m/z to Excel file
try
    warning off
    try
        if isempty(parameters.name)
           exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_allPeaks'];
        else
           exportName = parameters.name;
        end
    catch
        exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_allPeaks'];
    end
    if val ~= 3
        % Remove file names from spectra without peaks
        if ~isempty(emptyIDX)
           FileName(emptyIDX) = [];
        end
        xlswrite([PathName '\' exportName '.xlsx'],originalMatrix,'Sheet1','B2');
        xlswrite([PathName '\' exportName '.xlsx'],FileName','Sheet1','A2');
        xlswrite([PathName '\' exportName '.xlsx'],originalPeaks','Sheet1','B1');
    else
        % Create separate file name cell arrays in case for one polarity peaks
        % are missing
        FileNamePos = FileName;
        FileNameNeg = FileName;
        for j = 1:2
            tempMat = cell2mat(originalMatrix(j));
            tempPeaks = cell2mat(originalPeaks(j));
            if j == 1
                if ~isempty(emptyIDX)
                   emptyIDXPos = cell2mat(emptyIDX(j)); 
                   FileNamePos(emptyIDXPos) = [];
                end
                xlswrite([PathName '\' exportName '.xlsx'],tempMat,'pos','B2');
                xlswrite([PathName '\' exportName '.xlsx'],FileNamePos','pos','A2');
                xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','pos','B1'); 
            else
                if ~isempty(emptyIDX)
                   emptyIDXNeg = cell2mat(emptyIDX(j)); 
                   FileNameNeg(emptyIDXNeg) = [];
                end
                xlswrite([PathName '\' exportName '.xlsx'],tempMat,'neg','B2');
                xlswrite([PathName '\' exportName '.xlsx'],FileNameNeg','neg','A2');
                xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','neg','B1');
            end
        end
    end
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end

% Filter variables below threshold abundance and impute remaining missing values
try
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
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
   failedProcess(handles); 
end

% Export matrix to an Excel file
try
    try
        if isempty(parameters.name)
           exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_output'];
        else
           exportName = parameters.name;
        end
    catch
        exportName = [datestr(datetime,'YYYYMMDDhhmmss') '_output'];
    end
    processVal = processVal+1;
    updateProcess(processVal,handles);

    if val ~= 3
        % Remove file names from spectra without peaks
        if ~isempty(emptyIDX)
           FileName(emptyIDX) = [];
        end
        xlswrite([PathName '\' exportName '.xlsx'],intensityMatrix,'Sheet1','B2');
        xlswrite([PathName '\' exportName '.xlsx'],FileName','Sheet1','A2');
        xlswrite([PathName '\' exportName '.xlsx'],allPeaks','Sheet1','B1');
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
                   emptyIDXPos = cell2mat(emptyIDX(j)); 
                   FileNamePos(emptyIDXPos) = [];
                end
                xlswrite([PathName '\' exportName '.xlsx'],tempMat,'pos','B2');
                xlswrite([PathName '\' exportName '.xlsx'],FileNamePos','pos','A2');
                xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','pos','B1'); 
            else
                if ~isempty(emptyIDX)
                   emptyIDXNeg = cell2mat(emptyIDX(j)); 
                   FileNameNeg(emptyIDXNeg) = [];
                end
                xlswrite([PathName '\' exportName '.xlsx'],tempMat,'neg','B2');
                xlswrite([PathName '\' exportName '.xlsx'],FileNameNeg','neg','A2');
                xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','neg','B1');
            end
        end
    end
    processVal = processVal+1;
    updateProcess(processVal,handles);
catch
    failedProcess(handles);
end

end


