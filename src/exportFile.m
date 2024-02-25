function exportFile(mzList,intensityMatrix,file_names,j)
% Function to export stored peak lists and corresponding intensities to a .csv file
    
    % Deal with export of both positive and negative mode data
    if nargin < 4
      j = 0;
    end

    if j == 0 % Single file
        intensityMatrix = intensityMatrix'; % Transpose matrix to have data files in rows
        
        T = table(file_names'); % Transpose file names to have them in rows
        T.Properties.VariableNames = {'File_name'};
        T = [T,array2table(intensityMatrix)];
        mz_cell = [];
        for j = 1:length(mzList)
           mz_cell = [mz_cell,cellstr(num2str(mzList(j)))]; 
        end
        T.Properties.VariableNames(2:end) = mz_cell;
        exportName = [datestr(now,'yymmdd-HHMMSS') '.csv'];
        writetable(T,exportName);
    else
        if j == 1
            intensityMatrix = intensityMatrix'; % Transpose matrix to have data files in rows

            T = table(file_names'); % Transpose file names to have them in rows
            T.Properties.VariableNames = {'File_name'};
            T = [T,array2table(intensityMatrix)];
            mz_cell = [];
            for j = 1:length(mzList)
               mz_cell = [mz_cell,cellstr(num2str(mzList(j)))]; 
            end
            T.Properties.VariableNames(2:end) = mz_cell;
            exportName = [datestr(now,'yymmdd-HHMMSS') '_pos.csv'];
            writetable(T,exportName);    
        elseif j == 2
            intensityMatrix = intensityMatrix'; % Transpose matrix to have data files in rows

            T = table(file_names'); % Transpose file names to have them in rows
            T.Properties.VariableNames = {'File_name'};
            T = [T,array2table(intensityMatrix)];
            mz_cell = [];
            for j = 1:length(mzList)
               mz_cell = [mz_cell,cellstr(num2str(mzList(j)))]; 
            end
            T.Properties.VariableNames(2:end) = mz_cell;
            exportName = [datestr(now,'yymmdd-HHMMSS') '_neg.csv'];
            writetable(T,exportName);
        end
    end
end
