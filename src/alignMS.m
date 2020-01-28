% Code here
function alignMS() 

[FileName, PathName] = uigetfile('.raw',...
'MultiSelect','on')
if isequal(FileName, 0)
   return
end 
