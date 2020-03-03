function writeOutput(data,peaks,labels,exportName,Path,processVal)
% Write peak matrix into .csv format for opening and further analysis in
% Excel

% Transpose labels
labels = labels';

if processVal == 1
    labels = [' ';labels];
    exportFile = [Path '\' exportName '.csv'];
    fileID = fopen(exportFile,'w');
    for j = 1:size(labels,1)
       fprintf(fileID,'%s, ',char(labels(j)));
       if j == 1
            fprintf(fileID,'%.4f, ',peaks);  
       else
            fprintf(fileID,'%.4f, ',data(j-1,:));
       end
       fprintf(fileID,'\n');
    end
fclose(fileID);
fclose('all');
elseif processVal == 2 % Pos
    labels = [' ';labels];
    exportFile = [Path '\' exportName '_pos.csv'];
    fileID = fopen(exportFile,'w');
    for j = 1:size(labels,1)
       fprintf(fileID,'%s, ',char(labels(j)));
       if j == 1
            fprintf(fileID,'%.4f, ',peaks);  
       else
            fprintf(fileID,'%.4f, ',data(j-1,:));
       end
       fprintf(fileID,'\n');
    end
    fclose(fileID);
    fclose('all');
elseif processVal == 3 % Neg
    labels = [' ';labels];
    exportFile = [Path '\' exportName '_neg.csv'];
    fileID = fopen(exportFile,'w');
    for j = 1:size(labels,1)
       fprintf(fileID,'%s, ',char(labels(j)));
       if j == 1
            fprintf(fileID,'%.4f, ',peaks);  
       else
            fprintf(fileID,'%.4f, ',data(j-1,:));
       end
       fprintf(fileID,'\n');
    end
    fclose(fileID);
    fclose('all');
end

end