
function features = extract_character_features(imds, imgSize)

    numImages = numel(imds.Files);
    features = [];

    for i = 1:numImages
        img = readimage(imds, i);
    
        if size(img,3) == 3
            img = rgb2gray(img);
        end
    
        img = imresize(img, imgSize);
    
        % HOG features
        feat = extractHOGFeatures(img);
    
        features = [features; feat];
    end
end