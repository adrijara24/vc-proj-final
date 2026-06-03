

function features = extract_character_features(img, imageSize)

    % Grayscale
    
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    
    % Aspect and Area Ratio
    
    %[h, w] = size(img);
    %aspectRatio = w / h;
    %areaRatio = (h * w);
    
    % Connected components
    
    %bw = imbinarize(img);
    %cc = bwconncomp(bw);
    %numComponents = cc.NumObjects;
    
    % Resize
    
    img = imresize(img, imageSize);
    img = im2uint8(im2double(img));
    
    % HOG FEATURES
    
    hog_feature = extractHOGFeatures(img,'CellSize', [8 8]);
    
    features = [hog_feature];

end