function validateInput(params)
   for j = 1:length(params)
      if ~isempty(params.tolerance)
         if ~isnumeric(params.tolerance) || params.tolerance <= 0
            errordlg('Invalid input','Choose different value for tolerance');
            return
         end
      else
         params.tolerance = 5; % Default value
      end
      if ~isempty(params.threshold)
         if ~isnumeric(params.threshold) || params.threshold <= 0
            errordlg('Invalid input','Choose different value for threshold');
         end
      else
         params.threshold = 10000; % Default value
      end
   end
end
