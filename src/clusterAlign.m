function [intensityMatrix,emptyIDX] = clusterAlign(allPeaks,peakData)
    
    emptyIDX = find(cellfun(@isempty,peakData));
    fileCount = length(peakData)-length(emptyIDX);

    peakList = cell2mat(allPeaks);
    numPeaks = cellfun(@(x) length(x),allPeaks);

    % Clustering based on Euclidean distance
    tree = linkage(pdist(peakList(:,1)));
    clusters = cluster(tree,'CUTOFF',0.005,'CRITERION','Distance'); 
    clusters_sorted = sort(clusters);

    CRt = accumarray(clusters,prod(peakList,2))./accumarray(clusters,peakList(:,2));

    PR = accumarray(clusters,peakList(:,2),[],@median);

    [CRt,h] = sort(CRt);
    PR = PR(h);

    intensityMatrix = nan(numel(CRt),length(allPeaks));
    for i = 1:length(allPeaks)
        [j,k] = samplealign([CRt PR],allPeaks{i},'BAND',1,'WEIGHTS',[1 0]);
        intensityMatrix(j,i) = allPeaks{i}(k,2);
    end
end

