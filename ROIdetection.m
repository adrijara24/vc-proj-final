function candidates = getCandidates(im)
    candidates = [];
    im = rgb2gray(im);
    figure, imshow(im), title('input image');
    
    thresh = graythresh(im);
    bw = im2bw(im, thresh);
    figure, imshow(bw), title('binarized image');

    % Esborrar soroll
    area = numel(im);
    bw = bwareaopen(bw, round(0.001 * area));
    figure, imshow(bw), title('binarized area open image');

    EE = strel('rectangle', [5, 30]);
    cl = imclose(bw, EE);
    figure, imshow(cl), title('close');
    
    CC = bwconncomp(cl);
    S = regionprops(CC, 'BoundingBox', 'Area', 'Extent'); % Solidity, Eccentricity, Perimeter
    for k = 1:numel(S)
        bb = S(k).BoundingBox;
        x = bb(1);
        y = bb(2);
        w = bb(3);
        h = bb(4);
        if w < 10 || h < 10
            continue;
        end

        ar = w / h;
        if ar < 1
            ar = 1 / ar;
        end

        areaRatio = S(k).Area / area;

        isWide = (ar > 1.4) && (ar <= 12);
        isRect = S(k).Extent >= 0.25;
        isReasonable = (areaRatio > 0.0005) & (areaRatio <= 0.25);
        if isWide && isRect && isReasonable
            candidates = [candidates; [x y w h]];
        end
    end
end

im = imread('test_013.jpg');
candidates = getCandidates(im);

figure, imshow(im), title('Candidates');
hold on;

for i = 1:size(candidates, 1)
    rectangle('Position', candidates(i, :), 'EdgeColor', 'g', 'LineWidth', 2);
end

hold off;