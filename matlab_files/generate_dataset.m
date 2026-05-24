clear;
clc;
close all;

%% Configuration

imagesDir = 'images';
annotationsDir = 'annotations';

positiveDir = 'dataset/positive';
negativeDir = 'dataset/negative';

mkdir(positiveDir);
mkdir(negativeDir);

padding = 0.05; % 5%

negativePerImage = 5;

%% Read Images

imageFiles = dir(fullfile(imagesDir, '*.png'));

positiveCount = 1;
negativeCount = 1;

%% Processing

for i = 1:length(imageFiles)

    fprintf('Processing image %d / %d\n', i, length(imageFiles));

    % Read Image

    imageName = imageFiles(i).name;

    imgPath = fullfile(imagesDir, imageName);

    img = imread(imgPath);

    [imgH, imgW, ~] = size(img);

    % Read XML

    xmlName = replace(imageName, '.png', '.xml');

    xmlPath = fullfile(annotationsDir, xmlName);

    xmlDoc = xmlread(xmlPath);

    objects = xmlDoc.getElementsByTagName('object');

    if objects.getLength == 0
        continue;
    end

    % Read only license plate

    obj = objects.item(0);

    bbox = obj.getElementsByTagName('bndbox').item(0);

    xmin = str2double(bbox.getElementsByTagName('xmin').item(0).getTextContent);

    ymin = str2double(bbox.getElementsByTagName('ymin').item(0).getTextContent);

    xmax = str2double(bbox.getElementsByTagName('xmax').item(0).getTextContent);

    ymax = str2double(bbox.getElementsByTagName('ymax').item(0).getTextContent);

    % Add padding

    bw = xmax - xmin;
    bh = ymax - ymin;

    padX = round(bw * padding);
    padY = round(bh * padding);

    xminP = max(1, xmin - padX);
    yminP = max(1, ymin - padY);

    xmaxP = min(imgW, xmax + padX);
    ymaxP = min(imgH, ymax + padY);

    % Positive crop

    positiveCrop = img(yminP:ymaxP, xminP:xmaxP, :);

    positiveName = sprintf('pos_%05d.jpg', positiveCount);

    positiveCrop = im2uint8(mat2gray(positiveCrop));

    imwrite(positiveCrop, fullfile(positiveDir, positiveName));

    positiveCount = positiveCount + 1;

    % Generate negatives (no plate)

    for n = 1:negativePerImage

        validCrop = false;

        attempts = 0;

        while ~validCrop && attempts < 100

            attempts = attempts + 1;

            % Similar size to the license plate

            cropW = bw;
            cropH = bh;

            rx = randi([1, imgW - cropW]);
            ry = randi([1, imgH - cropH]);

            % IOU

            iou = compute_iou([rx ry cropW cropH], [xmin ymin bw bh]);

            if iou < 0.1

                negativeCrop = img(ry:ry+cropH, rx:rx+cropW, :);

                negativeName = sprintf('neg_%05d.jpg', negativeCount);

                negativeCrop = im2uint8(mat2gray(negativeCrop));

                imwrite(negativeCrop, fullfile(negativeDir, negativeName));

                negativeCount = negativeCount + 1;

                validCrop = true;

            end

        end

    end

end

fprintf('Dataset successfully generated\n');