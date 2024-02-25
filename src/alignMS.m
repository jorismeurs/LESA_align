% Functionality behind LESA_align GUI for processing .RAW files
% Code takes .mzXML files and ensures peak picking and alignment. The output is an aligned feature list
% Joris Meurs, PhD (2023)

function alignMS(parameters,handles) 

% Initiate process
try
    delete('log.txt');
catch exception
    disp(exception.message);
end
processVal = 0;
updateProcess(processVal,handles);

% Check validity of input parameters from GUI
processVal = processVal+1;
updateProcess(processVal,handles);
try
    validateInput(parameters);
catch exception
    disp(exception.message);
    if size(exception,1) > 0
        fprintf('File: %s \n',exception.stack.name);
        fprintf('Line no.: %d \n',exception.stack.line);
    end
    return
end

% Browse for files
processVal = processVal+1;
updateProcess(processVal,handles);

[FileName, PathName] = uigetfile({'*.mzXML','LESA-MS Files (.mzXML)'},...
'MultiSelect','on');
if isequal(FileName, 0)
    failedProcess(handles);
    return
end 
if ~iscell(FileName)
   errordlg('Minimum file input is 2');
   failedProcess(handles);
   return
end
commandFile = [PathName '\log.txt'];
diary(commandFile);

diary on
processVal = processVal+1;
updateProcess(processVal,handles);
mzxmlFiles = fullfile(PathName,FileName);
try
   	[peakData,val] = retrievePeaks(mzxmlFiles,parameters);
catch exception
    disp(exception.message);
    if size(exception,1) > 0
        fprintf('File: %s \n',exception.stack.name);
        fprintf('Line no.: %d \n',exception.stack.line);
    end
    diary off
    commandOutput = fileread(commandFile);
    set(handles.commandWindow,'String',commandOutput);
    delete(commandFile);
    failedProcess(handles);
    return
end
diary off
commandOutput = fileread(commandFile);
set(handles.commandWindow,'String',commandOutput);

% Align peak lists
diary on
processVal = processVal+1;
% Deal with two peak lists when both polarities are chosen
if val == 3
    for j = 1:length(peakData)
        if j == 1 % Data from positive mode
			[mzList_pos,intensityMatrix_pos] = clusterAlign(peakData);
        elseif j == 2 % Data from negative mode
			[mzList_neg,intensityMatrix_neg] = clusterAlign(peakData);
        end
    end
else
	[mzList,intensityMatrix] = clusterAlign(peakData);
end
diary off
commandOutput = fileread(commandFile);
set(handles.commandWindow,'String',commandOutput);

% Remove background peaks if file provided
diary on
processVal = processVal+1;
updateProcess(processVal,handles);
if ~isempty(parameters.backgroundSpectrum)
    % Deal with processing both polarities
    if val == 3
        for j = 1:2
            if j == 1 % positive mode
                    [mzList_pos,intensityMatrix_pos] = subtractBackground(mzList_pos,intensityMatrix_pos,parameters);
            elseif j == 2 % negative mode
                [mzList_neg,intensityMatrix_neg] = subtractBackground(mzList_neg,intensityMatrix_neg,parameters);
            end
        end
    else
        [mzList,intensityMatrix] = subtractBackground(mzList,intensityMatrix,parameters);
    end
end
diary off
commandOutput = fileread(commandFile);
set(handles.commandWindow,'String',commandOutput);

% Impute missing values when 'kNN' is selected
diary on
processVal = processVal+1;
updateProcess(processVal,handles);
if parameters.imputationType == 2
	% Deal with polarities
	if val == 3
		for j = 1:2
			if j == 1
				[mzList_pos,intensityMatrix_pos] = imputeMissing(mzList_pos,intensityMatrix_pos); 
	  		elseif j == 2
				[mzList_neg,intensityMatrix_neg] = imputeMissing(mzList_neg,intensityMatrix_neg); 
	 		end
	 	end 
	else
		[mzList,intensityMatrix] = imputeMissing(mzList,intensityMatrix,parameters);
	end
end
diary off
commandOutput = fileread(commandFile);
set(handles.commandWindow,'String',commandOutput);

% Export aligned peak list(s)
diary on
processVal = processVal+1;
updateProcess(processVal,handles);
if val == 3
    for j = 1:2
        if j == 1 % positive mode
            exportFile(mzList_pos,intensityMatrix_pos,FileName,j);
        elseif j == 2 % negative mode
            exportFile(mzList_neg,intensityMatrix_neg,FileName,j);
        end
    end
else
	exportFile(mzList,intensityMatrix,FileName);
end
diary off
commandOutput = fileread(commandFile);
set(handles.commandWindow,'String',commandOutput);


end


