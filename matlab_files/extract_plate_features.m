
function features = extract_plate_features(img, imageSize)

    % Grayscale
    
    if size(img,3) == 3
        img = rgb2gray(img);
    end

    % Aspect Ratio

    %[h, w] = size(img);

    %aspectRatio = w / h;

    % Connected components

    %bw = imbinarize(img);
    %cc = bwconncomp(bw);
    %numComponents = cc.NumObjects;
    
    % Resize
    
    img = imresize(img, imageSize);
   
    % HOG FEATURES
    
    hog_feature = extractHOGFeatures(img,'CellSize', [8 8]);

    features = hog_feature;

end