function candidates = getCandidates(im, showSteps)
    im = rgb2gray(im);
    im = imadjust(im);
    [szy, szx] = size(im);
    if showSteps
        figure, imshow(im), title('input image');
    end
    candidates = [];
    
    %thresh = graythresh(im);
    %bw = im2bw(im, thresh);         % Buscando, me sale que es mejor usar imbinarize pq tiene un parámetro ('adaptive') que funciona mejor con escenas iluminadas/no iluminadas https://www.mathworks.com/help/images/ref/imbinarize.html
    area = numel(im);
    edges = edge(im,'sobel', 'vertical');
    if showSteps
        figure, imshow(edges), title('edges');
    end
    %sizes = [1, 2, 4];
    %sizes = [1, 5 ; 2, 10 ; 3, 15];
    %sizes = [ceil(0.003 * szy), ceil(0.009 * szx);];
    %sizes = [ceil(0.003 * szy), ceil(0.009 * szx);];
    %sizes = [ceil(0.010 * szy), ceil(0.030 * szx);];
    sizes = [
        1, 5;
        2, 12;
        5, 20;
        8, 30;
        12, 45;
        ceil(0.010 * szy), ceil(0.030 * szx);
        ];
    for si = 1:size(sizes, 1)
        %EE = strel('diamond', si);
        %EE2 = strel('diamond', si*4);
        he = sizes(si, 1);
        wi = sizes(si, 2);
        EE = strel('rectangle', [he, wi]);
        EE2 = strel('rectangle', [he, wi]);
    
        cl = imdilate(edges, EE);
        cl = imfill(cl, 'holes');
        cl = imerode(cl, EE2);
    
        if showSteps
            figure, imshow(cl), title('close');
        end
    
        CC = bwconncomp(cl);
        S = regionprops(CC, 'BoundingBox', 'Area', 'Extent'); % Solidity, Eccentricity, Perimeter

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
            isRect = S(k).Extent >= 0.15;
            isReasonable = (areaRatio > 0.0005) & (areaRatio <= 0.25);
            if isWide && isRect && isReasonable
                candidates = [candidates; [x y w h]];
            end
        end
    end
end

function merged = joinDuplicates(candidates, threshold)
    if isempty(candidates)
        merged = zeros(0, 4);
        return;
    end
    if size(candidates, 1) < 2
        merged = candidates;
        return;
    end

    boxes = double(candidates);
    changed = true;

    while changed
        changed = false;
        n = size(boxes, 1);

        for i = 1:n-1
            for j = i+1:n
                [r1, r2] = getOverlap(boxes(i, :), boxes(j, :));
                if  r1 >= threshold && r2 >= threshold
                    boxes(i, :) = mergeROIs([boxes(i, :); boxes(j, :)]);
                    boxes(j, :) = [];
                    changed = true;
                    break;
                end
            end
            if changed
                break;
            end
        end
        merged = boxes;
    end


end

function [r1, r2] = getOverlap(A, B)
    x1 = max(A(1), B(1));
    y1 = max(A(2), B(2));
    x2 = min(A(1) + A(3), B(1) + B(3));
    y2 = min(A(2) + A(4), B(2) + B(4));

    iw = max(0, x2 - x1);
    ih = max(0, y2 - y1);
    in = iw * ih;

    aA = A(3) * A(4);
    aB = B(3) * B(4);

    r1 = in / aA;
    r2 = in / aB;
end

function ROI = mergeROIs(ROIs)
    x1 = min(ROIs(:, 1));
    y1 = min(ROIs(:, 2));
    x2 = max(ROIs(:, 1) + ROIs(:, 3));
    y2 = max(ROIs(:, 2) + ROIs(:, 4));

    ROI = [x1, y1, x2 - x1, y2 - y1];
end

function image = cutImage(im, ROI)
    image = imcrop(im, ROI);
end

function corners = getCorners(im)
    if size(im, 3) == 3
        im = rgb2gray(im);
    end

    im = imadjust(im);
    bw = edge(im, 'sobel');
    EE1 = strel('rectangle', [3 15]);
    EE2 = strel('rectangle', [2 2]);
    bw = imclose(bw, EE1);
    bw = imfill(bw, 'holes');
    bw = imopen(bw, EE2);
    figure, imshow(bw), title('bw');
    corners = [];
end

showSteps = false;
showResult = true;
showRois = false;
loadDataset = true;        % true para cargar todo el contenido de la carpeta Dataset, false para usar el vector images

images = ["eu1.jpg","eu2.jpg","eu3.jpg","eu4.jpg","eu5.jpg","eu8.jpg","eu9.jpg","eu11.jpg","test_097.jpg","test_012.jpg","test_013.jpg","test_044.jpg","test_045.jpg","test_049.jpg","test_066.jpg"];
%Imagenes que no acotan bien
%images = ["test_092.jpg","test_090.jpg","test_066.jpg","test_061.jpg","test_058.jpg","test_042.jpg","test_033.jpg","test_097.jpg"];
%Imagenes donde no se detecta la matrícula
%images = ["test_049.jpg","test_041.jpg","test_019.jpg","test_018.jpg","test_015.jpg","eu8.jpg","eu4.jpg"];
%images = ["test_073.jpg",];
images = ["test_092.jpg","test_071.jpg","test_073.jpg","test_061.jpg","test_057.jpg","test_060.jpg","test_048.jpg","test_046.jpg","test_023.jpg","test_017.jpg","test_015.jpg","test_010.jpg","eu8.jpg","eu4.jpg","eu11.jpg",];

if loadDataset
    images = []
    data = dir(fullfile(pwd, 'Dataset', '*.jpg'));
    images = string({data.name});
end

for k = 1:numel(images)
    im = imread(images(k));
    candidates = getCandidates(im, showSteps);
    candidates = joinDuplicates(candidates, 0.80);

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
            getCorners(crop);
        end
        %ROIs = [ROIs; crop]
    end
end