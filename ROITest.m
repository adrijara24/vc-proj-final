function candidates = getCandidates(im, showSteps)
    im = rgb2gray(im);
    im = imadjust(im);
    if showSteps
        figure, imshow(im), title('input image');
    end
    candidates = [];
    
    %thresh = graythresh(im);
    %bw = im2bw(im, thresh);         % Buscando, me sale que es mejor usar imbinarize pq tiene un parámetro ('adaptive') que funciona mejor con escenas iluminadas/no iluminadas https://www.mathworks.com/help/images/ref/imbinarize.html
    area = numel(im);
    edges = edge(im,"sobel");
    if showSteps
        figure, imshow(edges), title('edges');
    end

    EE = strel('diamond', 2);
    EE2 = strel('diamond', 8);

    cl = imdilate(edges, EE);
    cl = imfill(cl, 'holes');
    cl = imerode(cl, EE2);

    if showSteps
        figure, imshow(cl), title('close');
    end

    CC = bwconncomp(cl);
    S = regionprops(CC, 'BoundingBox', 'Area', 'Extent'); % Solidity, Eccentricity, Perimeter
    [szy, szx] = size(im);
    for k = 1:numel(S)
        bb = S(k).BoundingBox;
        x = max(bb(1) - 10, 0);
        y = max(bb(2) - 10, 0);
        w = min(bb(3) + 20, szx);
        h = min(bb(4) + 20, szy);
        if w < 10 || h < 10
            continue;
        end

        ar = w / h;
        if ar < 1
            ar = 1 / ar;
        end

        areaRatio = S(k).Area / area;

        isWide = (ar > 1.7) && (ar <= 12);
        isRect = S(k).Extent >= 0.25;
        isReasonable = (areaRatio > 0.0005) & (areaRatio <= 0.25);
        if isWide && isRect && isReasonable
            candidates = [candidates; [x y w h]];
        end
    end
end

function image = cutImage(im, ROI)
    image = imcrop(im, ROI);
end

showSteps = false;
showResult = true;
showRois = false;
loadDataset = false;        % true para cargar todo el contenido de la carpeta Dataset, false para usar el vector images

images = ["eu1.jpg","eu2.jpg","eu3.jpg","eu4.jpg","eu5.jpg","eu8.jpg","eu9.jpg","eu11.jpg","test_097.jpg","test_012.jpg","test_013.jpg","test_044.jpg","test_045.jpg","test_049.jpg","test_066.jpg"];
%Imagenes que no acotan bien
%images = ["test_092.jpg","test_090.jpg","test_066.jpg","test_061.jpg","test_058.jpg","test_042.jpg","test_033.jpg","test_09.jpg"];
%Imagenes donde no se detecta la matrícula
%images = ["test_049.jpg","test_041.jpg","test_019.jpg","test_018.jpg","test_015.jpg","eu8.jpg","eu4.jpg"];
%images = [];

if loadDataset
    images = []
    data = dir(fullfile(pwd, 'Dataset', '*.jpg'));
    images = string({data.name});
end

for k = 1:numel(images)
    im = imread(images(k));
    candidates = getCandidates(im, showSteps);
    
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
        if showRois
            figure, imshow(crop), title('cropped image');
        end
        %ROIs = [ROIs; crop]
    end
end