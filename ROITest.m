addpath('.\');

function image = cutImage(im, ROI)
    image = imcrop(im, ROI);
end

% function corners = getCorners(im)
%     if size(im, 3) == 3
%         im = rgb2gray(im);
%     end
% 
%     im = imadjust(im);
%     bw = edge(im, 'sobel');
%     EE1 = strel('rectangle', [3 15]);
%     EE2 = strel('rectangle', [2 2]);
%     bw = imclose(bw, EE1);
%     bw = imfill(bw, 'holes');
%     bw = imopen(bw, EE2);
%     figure, imshow(bw), title('bw');
%     corners = [];
% end

showSteps = false;
showResult = true;
showRois = true;
loadDataset = false;        % true para cargar todo el contenido de la carpeta Dataset, false para usar el vector images

%images = ["eu1.jpg","eu2.jpg","eu3.jpg","eu4.jpg","eu5.jpg","eu8.jpg","eu9.jpg","eu11.jpg","test_097.jpg","test_012.jpg","test_013.jpg","test_044.jpg","test_045.jpg","test_049.jpg","test_066.jpg"];
%Imagenes que no acotan bien
%images = ["test_092.jpg","test_090.jpg","test_066.jpg","test_061.jpg","test_058.jpg","test_042.jpg","test_033.jpg","test_097.jpg"];
%Imagenes donde no se detecta la matrícula
%images = ["test_049.jpg","test_041.jpg","test_019.jpg","test_018.jpg","test_015.jpg","eu8.jpg","eu4.jpg"];
%images = ["test_073.jpg",];
images = ["test_049.jpg","test_019.jpg","test_015.jpg","eu8.jpg","eu4.jpg"];
%images = ["test_091.jpg","test_096.jpg","test_079.jpg","test_078.jpg","test_063.jpg","test_071.jpg","test_056.jpg","test_044.jpg","test_029.jpg"];
%images = ["test_092.jpg","test_071.jpg","test_073.jpg","test_061.jpg","test_057.jpg","test_060.jpg","test_048.jpg","test_046.jpg","test_023.jpg","test_017.jpg","test_015.jpg","test_010.jpg","eu8.jpg","eu4.jpg","eu11.jpg",];

if loadDataset
    images = [];
    data = dir(fullfile(pwd, 'Dataset', '*.jpg'));
    images = string({data.name});
end

for k = 1:numel(images)
    im = imread(images(k));
    candidates = getCandidates(im, showSteps);
    candidates = joinDuplicates(candidates, 0.70);

    [~, name] = fileparts(images(k));
    figure, imshow(im), title(name);
    hold on;
    
    if showResult
        for i = 1:size(candidates, 1)
            rectangle('Position', candidates(i, :), 'EdgeColor', 'g', 'LineWidth', 2);
        end
    end
    
    hold off;
    
    %ROIs = []
    for i = 1:size(candidates, 1)
        crop = cutImage(im, candidates(i, :));
        aligned = alignPlate(crop);
        blobs = segm(aligned);
        if size(blobs,1) <= 3
            aligned = alignPlate(255-crop);
            blobs = segm(aligned);
        end
        if showRois && size(blobs, 1) > 3
            figure, imshow(aligned), title('cropped image');
            hold on;
            for j = 1:size(blobs, 1)
                bb = blobs(j, :);
                rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);
                text(bb(1), bb(2), num2str(j),"FontSize",14, "FontWeight", "bold", "Color","r","HorizontalAlignment","center", "VerticalAlignment","bottom");
            end
            hold off;
           % getCorners(crop);
        end
        %ROIs = [ROIs; crop]
    end
end