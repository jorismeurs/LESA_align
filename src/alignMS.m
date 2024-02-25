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
			[mzList_pos,intensityMatrix_neg] = clusterAlign(peakData);
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
% Add new background subtraction functionality
if ~isempty(parameters.backgroundSpectrum)
    % Deal with processing both polarities
    if val == 3
		for j = 1:2
			if j == 1 % positive mode
   				backgroundPeaks_pos = getBackgroundPeaks(parameter);
       				intensityMatrix = subtractBackground(backgroundPeaks_pos);
   			elseif j == 2 % negative mode
				backgroundPeaks_neg = getBackgroundPeaks(parameters);
    				intensityMatrix = subtractBackground(backgroundPeaks_neg);
   			end
  		end
    else
        backgroundPeaks = getBackgroundPeaks(parameters);
		intensityMatrix = subtractBackground(backgroundPeaks);
    end
end
diary off
commandOutput = fileread(commandFile);
set(handles.commandWindow,'String',commandOutput);

% Impute missing values when 'kNN' is selected
diary on
if val == 3
	for j = 1:2
		if j == 1
			[CMZ_pos,intensityMatrix_pos] = imputeMissing(CMZ_pos,intensityMatrix_pos,parameters); 
  		elseif j == 2
			[CMZ_neg,intensityMatrix_neg] = imputeMissing(CMZ_neg,intensityMatrix_neg,parameters); 
 		end
 	end 
else

end
diary off

% Export aligned peak list(s)
dairy on
if val == 3
	for j = 1:2
 		if j == 1 % positive mode
			exportFile(CMZ_pos,intensityMatrix_pos);
  		elseif j == 2 % negative mode
			exportFile(CMZ_neg,intensityMatrix_neg);
 		end
   	end
else
	exportFile(CMZ,intensityMatrix);
end
dairy off


end


