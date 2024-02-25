function [mzList,intensityMatrix] = imputeMissing(mzList,intensityMatrix)
	% This function filters based on the 80% abundance rule for metabolomics data [1]. Remaining features are then 
 	% imputed using the kNN algorithm in which k is set to 10 [2].
  	%
   	% References
	% [1] Smilde et al., Analytical Chemistry (2005), 77 (20), DOI: 10.1021/ac051080y
 	% [2] Di Guida et al., Metabolomics 2016, 12, 93,  DOI: 10.1007/s11306-016-1030-9

  	for j = 1:size(intensityMatrix,1)
		idx = find(isnan(intensityMatrix(j,:)));
  		if numel(idx) > 0.2*size(intensityMatrix,2)
			r = [r;j]; % Collect rows of features to be removed
 		end
   	end

 	% Remove features 
  	if ~isempty(r)
		mzList(r,:) = [];
  		intensityMatrix(r,:) = [];
   	end

 	% Impute remaining missing values
  	intensityMatrix = intensityMatrix';
   	intensityMatrix = knnimpute(intensityMatrix,10)
	intensityMatrix = intensityMatrix';
end
