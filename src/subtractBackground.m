function [mz_list,intensity_data] = subtractBackground(mz_list,intensity_data,parameters)
           
    % Retrieve relevant parameter values from structure
    tolerance = parameters.tolerance;
    threshold = parameters.threshold;
    spectrumFile = parameters.backgroundSpectrum;
    
    % Generate CMZ
    binSize = -8e-8; % Empirical value
    minMZ = parameters.minMZ;
    maxMZ = parameters.maxMZ;
    mzChannels = 1/sqrt(minMZ):binSize:1/sqrt(maxMZ)+binSize;
    mzChannels = ones(size(mzChannels))./(mzChannels.^2);

    % Parse background file
    includedScans = [];
    msStruct = mzxmlread(spectrumFile,'Levels',1);
    for n = 1:length(msStruct.scan)
        if msStruct.scan(n).basePeakIntensity > 1e5
           includedScans = [includedScans;n];
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
        locPeak = find(mz_list(:,1) > backgroundPeaks(j,1)-maxDev & ...
            mz_list(:,1) < backgroundPeaks(j,1)+maxDev);
        if ~isempty(locPeak)
            removePeaks = [removePeaks;locPeak];
        end
    end

    if ~isempty(removePeaks)
        mz_list(removePeaks,:) = [];
        intensity_data(removePeaks,:) = [];
    end
end

