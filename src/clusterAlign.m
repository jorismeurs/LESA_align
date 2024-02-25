function [CMZ,intensityMatrix] = clusterAlign(peakData)
    % Function for aligning peaks using clustering based on Euclidean distance
    peakList = cell2mat(peakData);

    % Clustering based on Euclidean distance
    tree = linkage(pdist(peakList(:,1)));
    clusters = cluster(tree,'CUTOFF',0.005,'CRITERION','Distance'); 

    CMZ = accumarray(clusters,prod(peakList,2))./accumarray(clusters,peakList(:,2));

    PR = accumarray(clusters,peakList(:,2),[],@median);

    [CMZ,h] = sort(CMZ);
    PR = PR(h);

    intensityMatrix = nan(numel(CMZ),length(peakData));
    for i = 1:length(peakData)
        [j,k] = samplealign([CMZ PR],peakData{i},'BAND',1,'WEIGHTS',[1 0]);
        intensityMatrix(j,i) = peakData{i}(k,2);
    end
end

