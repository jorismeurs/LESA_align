function samplePeaks = subtractBackground(peakList,parameters,iteration)
    
    % Only required for processing both polarities
    % Value is dummy when not present, no impact on processing
    if nargin < 3
        iteration = 1;
    end
    
    % Retrieve relevant parameter values from structure
    processingVal = parameters.polarity;
    tolerance = parameters.tolerance;
    threshold = parameters.threshold;
    spectrumFile = parameters.backgroundSpectrum;
    
    % Determine file type spectrum
    fileExtLoc = find(spectrumFile=='.');
    fileExt = spectrumFile(fileExtLoc+1:end);
    PathLoc = find(spectrumFile=='\');
    OutputPath = spectrumFile(1:PathLoc(end)-1);
    % Convert if .RAW file
    if isequal(fileExt,'raw')
        system('cd C:\ProteoWizard\');
        system(['msconvert ' spectrumFile ' --mzXML --32 -o ' OutputPath]);
        spectrumFile = [spectrumFile(1:fileExtLoc) 'mzXML'];
    end
    
    % Generate CMZ
    binSize = -8e-8; % Empirical value
    minMZ = parameters.minMZ;
    maxMZ = parameters.maxMZ;
    mzChannels = 1/sqrt(minMZ):binSize:1/sqrt(maxMZ)+binSize;
    mzChannels = ones(size(mzChannels))./(mzChannels.^2);

    % Parse background file
    msStruct = mzxmlread(spectrumFile,'Levels',1);
    
    % Positive only
    if processingVal == 1
         posIdx = [];
         for n = 1:length(msStruct.scan)
            if msStruct.scan(n).polarity == '+' 
                posIdx = [posIdx;n];
            end
         end
         
         includedScans = [];
         for n = 1:length(posIdx)
            if msStruct.scan(posIdx(n)).basePeakIntensity > 1e5
               includedScans = [includedScans;posIdx(n)];
            end
         end
         totalPeaks = peakList;
    % Negative only
    elseif processingVal == 2
         negIdx = [];
         for n = 1:length(msStruct.scan)
            if msStruct.scan(n).polarity == '-' 
                negIdx = [negIdx;n];
            end
         end
         
         includedScans = [];
         for n = 1:length(negIdx)
            if msStruct.scan(negIdx(n)).basePeakIntensity > 1e5
               includedScans = [includedScans;negIdx(n)];
            end
         end
         totalPeaks = peakList;
    % Deal with both polarities
    elseif processingVal == 3        
        if iteration == 1
             posIdx = [];
             for n = 1:length(msStruct.scan)
                if msStruct.scan(n).polarity == '+' 
                    posIdx = [posIdx;n];
                end
             end    

             includedScans = [];
             for n = 1:length(posIdx)
                if msStruct.scan(posIdx(n)).basePeakIntensity > 1e5
                   includedScans = [includedScans;posIdx(n)];
                end
             end
             totalPeaks = cell2mat(peakList(iteration));
        elseif iteration == 2
             negIdx = [];
             for n = 1:length(msStruct.scan)
                if msStruct.scan(n).polarity == '-' 
                    negIdx = [negIdx;n];
                end
             end

             includedScans = [];
             for n = 1:length(negIdx)
                if msStruct.scan(negIdx(n)).basePeakIntensity > 1e5
                   includedScans = [includedScans;negIdx(n)];
                end
             end
             totalPeaks = cell2mat(peakList(iteration));
        end
    end
    
    % Average MS1 spectra for background file
    includedData = []; mzData = []; intData = []; interpolatedSpectra = [];
    for n = 1:length(includedScans)
        scanData = msStruct.scan(includedScans(n)).peaks.mz;
        mz = scanData(1:2:end);
        int = scanData(2:2:end);
        [mz,idx] = unique(mz);
        int = int(idx,1);
        mzData{n,1} = mz;
        intData{n,1} = int;
    end
    interpolatedSpectra = cellfun(@(mzs,int) interp1(mzs,int,mzChannels,'linear'),mzData,intData,'UniformOutput',false);
    interpolatedSpectra = cell2mat(interpolatedSpectra);
    averageY = nanmean(interpolatedSpectra,1);
    
    % Retrieve background peaks
    backgroundPeaks = mspeaks(mzChannels',averageY','HeightFilter',threshold,'Denoising',false);
    
    % Remove peaks within tolerance window
    removePeaks = [];
    for j = 1:length(backgroundPeaks)
        maxDev = ppmDeviation(backgroundPeaks(j,1),tolerance);
        locPeak = find(totalPeaks(:,1) > backgroundPeaks(j,1)-maxDev & ...
            totalPeaks(:,1) < backgroundPeaks(j,1)+maxDev);
        if ~isempty(locPeak)
            removePeaks = [removePeaks;locPeak];
        end
    end
    totalPeaks(locPeak,:) = [];
    samplePeaks = totalPeaks;
end

