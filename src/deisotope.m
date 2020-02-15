function deisotopedPeakList = deisotope(peakList)

    % Peaks are assumed to be singly or doubly charged
    z = [1 2];
    isotopeTolerance = 2; % 2 ppm mass tolerance for isotope peak matching 
    
    % Iterate through peak list find isotope
    removeVector = [];
    for j = 1:length(peakList)
       refMZ = peakList(j,1);
       maxDev = ppmDeviation(refMZ,isotopeTolerance);
       for n = 1:length(z)
           locIsotope = find(peakList(:,1) > refMZ+(1.03325/z(n))-maxDev & ...
               peakList(:,1) < refMZ+(1.03355/z(n))+maxDev);
           if ~isempty(locIsotope)
              removeVector = [removeVector;locIsotope]; 
              break
           end
       end
    end
    
    % Remove isotopes
    peakList(removeVector,:) = [];
    deisotopedPeakList = peakList;
end

