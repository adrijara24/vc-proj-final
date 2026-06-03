function features = extract_character_features(img, imageSize)

    % Preprocess
 
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    
    img = imresize(img, imageSize);
    img = im2single(img);
    
  
    % BINARIZATION (para shape features)
    bin = imbinarize(img);
    
  
    % HOG FEATURES (base)
    hog_feature = extractHOGFeatures(img, 'CellSize', [8 8]);
    
 
    % 1. SHAPE FEATURES (muy importantes para 8 vs B, 1 vs I)
    density = sum(bin(:)) / numel(bin);
    
    % agujeros (topología básica)
    cc = bwconncomp(~bin);
    numHoles = cc.NumObjects;
    
    % =========================================================
    % 2. PROJECTION FEATURES (OCR clásico potente)
    % =========================================================
    
    hProfile = sum(bin, 1);
    vProfile = sum(bin, 2);
    
    projFeatures = [
        mean(hProfile), std(hProfile), ...
        mean(vProfile), std(vProfile)
        ];
    
    % =========================================================
    % 3. GRADIENT FEATURES (complemento a HOG)
    % =========================================================
    
    [Gx, Gy] = imgradientxy(img);
    [Gmag, Gdir] = imgradient(Gx, Gy);
    
    gradFeatures = [
        mean(Gmag(:)), ...
        std(Gmag(:))
        ];
    
    dirHist = histcounts(Gdir(:), 8);
    dirHist = dirHist / (sum(dirHist) + eps);
    
    % =========================================================
    % FINAL FEATURE VECTOR
    % =========================================================
    features = [
        hog_feature, ...
        density, ...
        numHoles, ...
        projFeatures, ...
        gradFeatures, ...
        dirHist
        ];

end

%function features = extract_character_features(img, imageSize)

    % Grayscale
    
    %if size(img,3) == 3
        %img = rgb2gray(img);
    %end
    
    % Aspect and Area Ratio
    
    %[h, w] = size(img);
    %aspectRatio = w / h;
    %areaRatio = (h * w);
    
    % Connected components
    
    %bw = imbinarize(img);
    %cc = bwconncomp(bw);
    %numComponents = cc.NumObjects;
    
    % Resize
    
    %img = imresize(img, imageSize);
    %img = im2uint8(im2double(img));
    
    % HOG FEATURES
    
    %hog_feature = extractHOGFeatures(img,'CellSize', [8 8]);
    
    %features = [hog_feature];

%end