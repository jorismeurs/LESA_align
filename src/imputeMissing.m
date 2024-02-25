function [mz,intensity_data] = imputeMissing(mz,intensity_data);
    % Function for filtering and imputing missing data according to the 80% rule
    % Imputation according to the kNN algorithm. Parameter k is set to 10
    
    % Samples are in columns
    r = [];
    for j = 1:size(intensity_data,1)
        idx = find(isnan(intensity_data(j,:)));
        if numel(idx) > 0.2*size(intensity_data,2)
            r = [r;j]; % Collect rows to remove
        end
    end

    if ~isempty(r)
        mz(r,:) = [];
        intensity_data(r,:) = [];
    end

    % Impute remaining 
    intensity_data = knnimpute(intensity_data,10);
end
