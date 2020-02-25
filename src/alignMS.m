% Functionality behind LESA_align GUI for processing .RAW files
%
% (c) Joris Meurs, MSc (2020)

% Store FileNames for re-processing
% Hide axes numbers on start-up
% Check the use of spaces for ProteoWizard
% Log output
% Place waitbar next to GUI

function alignMS(parameters,handles) 
% parameters.minMZ = 70;
% parameters.maxMZ = 1050;
% parameters.tolerance = 5;
% parameters.threshold = 10000;
% parameters.polarity = 3;

% if isfile('log.txt')
%    delete('log.txt'); 
% end

% Initiate process
processVal = 0;
updateProcess(processVal,handles);

% Check validity of input parameters from GUI
processVal = processVal+1;
updateProcess(processVal,handles);
try
    validateInput(parameters);
catch
    failedProcess(handles);
    return
end

% Browse for files
processVal = processVal+1;
updateProcess(processVal,handles);
% try
    [FileName, PathName] = uigetfile({'*.raw','Thermo RAW Files (.raw)';'*.mzXML','mzXML Files (.mzXML)'},...
    'MultiSelect','on');
    if isequal(FileName, 0)
        failedProcess(handles);
        return
    end 
% catch
%    failedProcess(handles);
%    return
% end

diary([PathName '\log.txt']);

% Convert .RAW files
processVal = processVal+1;
updateProcess(processVal,handles);
% try
    mzxmlFiles = convertRaw(PathName,FileName,parameters);
% catch
%    failedProcess(handles);
%    return
% end

% Retrieve peaklist per file
processVal = processVal+1;
updateProcess(processVal,handles);
% try
    [peakData,val] = retrievePeaks(mzxmlFiles,parameters);
% catch
%     failedProcess(handles);
%     return
% end


% Generate unique peak matrix
processVal = processVal+1;
updateProcess(processVal,handles);


% Change processing value if polarity data is completely missing 
if val == 3
    negIDX = (length(peakData)/2)+1:length(peakData);
    posIDX = 1:length(peakData)/2;
    if isempty(cell2mat(peakData(posIDX,1)))
        val = 2;
        peakData = peakData(negIDX,1);
    end
    if isempty(cell2mat(peakData(negIDX,1)))
        val = 1;
        peakData = peakData(posIDX,1);
    end
end

%try
    if val ~=3
        if isempty(cell2mat(peakData))
            failedProcess(handles)
            errordlg('No peaks detected at chosen polarity');
            return
        else
            allPeaks = uniquePeaks(peakData,parameters);
        end
    else
        for j = 1:2           
            if j == 1
                allPeaks{j} = uniquePeaks(peakData(posIDX,1),parameters);
            else
                allPeaks{j} = uniquePeaks(peakData(negIDX,1),parameters);
            end
        end
    end
% catch
%     failedProcess(handles);
% end

% Remove isotopes from peak list
processVal = processVal+1;
updateProcess(processVal,handles);
%try
    if val ~= 3
        allPeaks = deisotope(allPeaks);
    else
        for j = 1:2
           allPeaks{j} = deisotope(cell2mat(allPeaks(j)));
        end
    end
%catch
    %failedProcess(handles);
%end

% Remove background peaks if file provided
processVal = processVal+1;
updateProcess(processVal,handles);
if ~isempty(parameters.backgroundSpectrum)
    
    %try
       if val ~= 3
           allPeaks = subtractBackground(allPeaks,parameters);
       else
          for j = 1:2
             allPeaks{j} = subtractBackground(cell2mat(allPeaks(j)),parameters,j); 
          end
       end
    %catch 
%        failedProcess(handles);
%        return 
%     end
end

% Retrieve intensities per peak for each file
% Store original peak matrices separately
processVal = processVal+1;
updateProcess(processVal,handles);
%try
    intensityMatrix = []; originalMatrix = []; originalPeaks = [];
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
% catch
%    failedProcess(handles); 
%    return
% end

% Export orginal peaks and m/z to Excel file
processVal = processVal+1;
updateProcess(processVal,handles);
size(originalMatrix)
%try
    warning off
    try
        if isempty(parameters.name)
           exportName = [datestr(datetime('now'),'yyyymmddHHMMSS') '_allPeaks'];
        else
           exportName = parameters.name;
        end
    catch
        exportName = [datestr(datetime('now'),'yyyymmddHHMMSS') '_allPeaks'];
    end
    if val ~= 3
        % Remove file names from spectra without peaks
        if ~isempty(emptyIDX)
           FileName(emptyIDX) = [];
        end
        tempData = [];
        tempData = [FileName',num2cell(originalMatrix)];
        tempData = [num2cell([NaN,originalPeaks']);tempData];
        save([PathName '\' exportName '.mat'],'tempData');
        %xlswrite([PathName '\' exportName '.xlsx'],originalMatrix,'Sheet1','B2');
        %xlswrite([PathName '\' exportName '.xlsx'],FileName','Sheet1','A2');
        %xlswrite([PathName '\' exportName '.xlsx'],originalPeaks','Sheet1','B1');
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
                tempData = [];
                tempData = [FileNamePos',num2cell(tempMat)];
                tempData = [num2cell([NaN,tempPeaks']);tempData];
                save([PathName '\' exportName '_pos.mat'],'tempData');
                %xlswrite([PathName '\' exportName '.xlsx'],tempMat,'pos','B2');
                %xlswrite([PathName '\' exportName '.xlsx'],FileNamePos','pos','A2');
                %xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','pos','B1'); 
            else
                if ~isempty(emptyIDX)
                   emptyIDXNeg = cell2mat(emptyIDX(j)); 
                   FileNameNeg(emptyIDXNeg) = [];
                end
                tempData = [];
                tempData = [FileNameNeg',num2cell(tempMat)];
                tempData = [num2cell([NaN,tempPeaks']);tempData];
                save([PathName '\' exportName '_neg.mat'],'tempData');
                %xlswrite([PathName '\' exportName '.xlsx'],tempMat,'neg','B2');
                %xlswrite([PathName '\' exportName '.xlsx'],FileNameNeg','neg','A2');
                %xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','neg','B1');
            end
        end
    end
% catch
%     failedProcess(handles);
%     return
% end

% Filter variables below threshold abundance and impute remaining missing values
processVal = processVal+1;
updateProcess(processVal,handles);
%try
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
% catch
%    failedProcess(handles); 
%    return
% end

% Export matrix to an Excel file
processVal = processVal+1;
updateProcess(processVal,handles);
%try
    %try
        if isempty(parameters.name)
           exportName = [datestr(datetime('now'),'yyyymmddHHMMSS') '_MVA'];
        else
           exportName = parameters.name;
        end
    %catch
    %    exportName = [datestr(datetime('now'),'yyyymmddHHMMSS') '_MVA'];
    %end

    if val ~= 3
        % Remove file names from spectra without peaks
        if ~isempty(emptyIDX)
           FileName(emptyIDX) = [];
        end
        tempData = [];
        tempData = [FileName',num2cell(intensityMatrix)];
        tempData = [num2cell([NaN,allPeaks']);tempData];
        save([PathName '\' exportName '.mat'],'tempData');
        %xlswrite([PathName '\' exportName '.xlsx'],intensityMatrix,'Sheet1','B2');
        %xlswrite([PathName '\' exportName '.xlsx'],FileName','Sheet1','A2');
        %xlswrite([PathName '\' exportName '.xlsx'],allPeaks','Sheet1','B1');
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
                tempData = [];
                tempData = [FileNamePos',num2cell(tempMat)];
                tempData = [num2cell([NaN,tempPeaks']);tempData];
                save([PathName '\' exportName '_pos.mat'],'tempData');
                %xlswrite([PathName '\' exportName '.xlsx'],tempMat,'pos','B2');
                %xlswrite([PathName '\' exportName '.xlsx'],FileNamePos','pos','A2');
                %xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','pos','B1'); 
            else
                if ~isempty(emptyIDX)
                   emptyIDXNeg = cell2mat(emptyIDX(j)); 
                   FileNameNeg(emptyIDXNeg) = [];
                end
                tempData = [];
                tempData = [FileNameNeg',num2cell(tempMat)];
                tempData = [num2cell([NaN,tempPeaks']);tempData];
                save([PathName '\' exportName '_neg.mat'],'tempData');
                %xlswrite([PathName '\' exportName '.xlsx'],tempMat,'neg','B2');
                %xlswrite([PathName '\' exportName '.xlsx'],FileNameNeg','neg','A2');
                %xlswrite([PathName '\' exportName '.xlsx'],tempPeaks','neg','B1');
            end
        end
    end
% catch
%     failedProcess(handles);
%     return
% end

processVal = processVal+1;
updateProcess(processVal,handles);

end


