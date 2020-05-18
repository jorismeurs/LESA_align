function [peakList,processVal] = retrieveSIMSPeaks(textFiles,parameters)

 % Get parameters
threshold = parameters.threshold;
processVal = parameters.polarity;
intVal = parameters.intensityVal;
if processVal == 3
    return
end
minMZ = parameters.minMZ;
maxMZ = parameters.maxMZ;

% Generate CMZ vector (Race et al., Anal Chem.)
 binSize = -8e-8; % Empirical value
 mzChannels = 1/sqrt(minMZ):binSize:1/sqrt(maxMZ)+binSize;
 mzChannels = ones(size(mzChannels))./(mzChannels.^2);
 
%  [FileName,PathName] = uigetfile('.txt','MultiSelect','on');
%  textFiles = fullfile(PathName,FileName);
 
 % Retrieve peaks per file
 for j = 1:length(textFiles)
    fileID = fopen(textFiles{j},'r'); 
    msData = textscan(fileID,'%f','Delimiter','\t','HeaderLines',3); 
    msData = cell2mat(msData);
    fclose(fileID);
    fclose('all');
   
    % Reconstruct cell
    mz = msData(2:3:end,1);
    int = msData(3:3:end,1);
    interp1MS = interp1(mz,int,mzChannels);
    if intVal == 2
       thresholdVal = (threshold/100)*max(interp1MS);
    else
       thresholdVal = threshold; 
    end
    peakList{j,1} = mspeaks(mzChannels',interp1MS','HeightFilter',thresholdVal,'Denoising',false);    
 end
 