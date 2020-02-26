clc
clear
[FileName,PathName] = uigetfile('.tif',...
    'MultiSelect','on');
fileLocation = fullfile(PathName,FileName);
%%
j = 9;
I_org = imread(fileLocation{j});
I_org = uint8(I_org); 
bg = mean(mean(I_org(1:100,1:100)));
I_org(I_org(:,:)<bg) = uint8(bg);
imshow(I_org);
I = imadjust(I_org,[0.1 0.4]);
I = imgaussfilt(I,10);
I = imfill(I,'holes');
I = imbinarize(I);
I = bwareaopen(I,200);
imshow(I);
%%
stats = regionprops('table', I, 'Centroid', 'Eccentricity', 'EquivDiameter',...
        'Centroid','MajorAxisLength','MinorAxisLength','PixelList','PixelIdxList');
    %stats(stats.Eccentricity>0.3,:) = [];
%%
stats = sortrows(stats,2,'descend');
stats([2:1:size(stats,1)],:) = []; % Keep largest area
diameter = stats.EquivDiameter;
centers = stats.Centroid;
diameters = min([stats.MajorAxisLength stats.MinorAxisLength]);
radii = diameters/2;
f = figure;
imshow(I_org);
hold on
viscircles(centers,radii);
hold off