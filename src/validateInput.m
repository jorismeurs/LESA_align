function validateInput(params)
    if ~isempty(params.tolerance)
        if ~isnumeric(params.tolerance) || params.tolerance <= 0
            errordlg('Invalid input | Choose different value for tolerance');
            return
        end
    else
        params.tolerance = 5; % Default value
    end
    if ~isempty(params.threshold)
        if ~isnumeric(params.threshold) || params.threshold <= 0
            errordlg('Invalid input | Choose different value for threshold');
            return
        end
    else
        params.threshold = 10000; % Default value
    end
    if ~isempty(params.minMZ)
        if ~isnumeric(params.minMZ) || params.minMZ <= 0
           errordlg('Invalid input | Choose different value for minimum m/z');
           return
        end
    end
    if ~isempty(params.maxMZ)
        if ~isnumeric(params.maxMZ) || params.maxMZ <= 0
           errordlg('Invalid input | Choose different value for maximum m/z'); 
           return
        end
    end
    if params.maxMZ <= params.minMZ
       errordlg('Invalid scan range'); 
       return
    end
    fprintf('******************** \n');
    fprintf('m/z tolerance: %d ppm \n',params.tolerance);
    fprintf('Height filter: %d \n',params.threshold);
    fprintf('Scan range: m/z %d - %d \n',params.minMZ,params.maxMZ);
    if params.polarity == 1
        fprintf('Polarity: + \n');
    elseif params.polarity == 2
        fprintf('Polarity: - \n');
    elseif params.polarity == 3
        fprintf('Polarity: +/- \n');
    end
    fprintf('******************** \n');
end
