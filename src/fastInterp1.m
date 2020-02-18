function interpolatedSpectra = fastInterp1(x,y,v)

% Fast linear interpolation designed for LESA_align
% Twice as fast as interp1
% (c) 2020 Joris Meurs, MSc

if length(x) ~= length(y)
   error('X and Y should be same length'); 
end
if ~iscell(x) || ~iscell(y)
   error('Input should be a cell array for X and Y'); 
end

griddedCell = cellfun(@(mzs,int) griddedInterpolant(mzs,int),x,y,'UniformOutput',false);
for n = 1:length(griddedCell)
    interpolatedSpectra{n,1} = griddedCell{n}(v);
end

end