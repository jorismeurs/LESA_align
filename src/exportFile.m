function exportFile(mzList,intensityMatrix,file_names,j)
% Function to export stored peak lists and corresponding intensities to a .csv file
    
    % Deal with export of both positive and negative mode data
    if nargin < 4
      j = 0;
    end

    if j == 0 % Single file
        intensityMatrix = intensityMatrix'; % Transpose matrix to have data files in rows
        mzList = num2str(mzList');
        T = table(file_names);
        T.Properties.VariableNames = {'File_name'};
        T = [T,array2table(intensityMatrix)];
        T.Properties.VariableNames(2:end) = mzList;
        exportName = [datestr(now,'yymmdd-HHMMSS') '.csv'];
        writetable(T,exportName);
    else
        if j == 1
            intensityMatrix = intensityMatrix'; % Transpose matrix to have data files in rows
            mzList = num2str(mzList');
            T = table(file_names);
            T.Properties.VariableNames = {'File_name'};
            T = [T,array2table(intensityMatrix)];
            T.Properties.VariableNames(2:end) = mzList;
            exportName = [datestr(now,'yymmdd-HHMMSS') '_pos.csv'];
            writetable(T,exportName);    
        elseif j == 2
            intensityMatrix = intensityMatrix'; % Transpose matrix to have data files in rows
            mzList = num2str(mzList');
            T = table(file_names);
            T.Properties.VariableNames = {'File_name'};
            T = [T,array2table(intensityMatrix)];
            T.Properties.VariableNames(2:end) = mzList;
            exportName = [datestr(now,'yymmdd-HHMMSS') '_neg.csv'];
            writetable(T,exportName);
        end
    end
end
