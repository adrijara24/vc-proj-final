
function features = extract_character_features(img, imageSize)
    
    if size(img,3) == 3
                img = rgb2gray(img);
    end
    img = imresize(img, imageSize);
    img = im2single(img);

    bin = imbinarize(img);
    se = strel('disk', 1);
    bin = imclose(bin, se);
    bin = bwareaopen(bin, 5);
    
    % 1. HOG 
    hog_feature = extractHOGFeatures(img, 'CellSize', [4 4]);
    
    % 2. Density global
    density = sum(bin(:)) / numel(bin);
    
    % 3. Número de agujeros
    cc = bwconncomp(~bin);
    numHoles = cc.NumObjects;
    
    % 4. Perfiles de proyección completos (16+16)
    targetLen = 16;
    hProfile = sum(bin, 1);
    vProfile = sum(bin, 2);
    hProf_norm = imresize(hProfile / (max(hProfile) + eps), [1, targetLen]);
    vProf_norm = imresize(vProfile'/ (max(vProfile)  + eps), [1, targetLen]);
    projFeatures = [hProf_norm, vProf_norm];
    
    % 5. Zoning 4x4 (densidad por zona)
    zoningF = zoningFeatures(bin, 4, 4);

    % 6. Zoning asimétrico 6x3 
    zoningF2 = zoningFeatures(bin, 6, 3);

    % 7. Crossing numbers por fila
    crossings = zeros(1, targetLen);
    binResized = imresize(bin, [targetLen, targetLen]) > 0.5;
    for row = 1:targetLen
        line = binResized(row, :);
        crossings(row) = sum(diff(line) == 1);
    end
    crossings = crossings / (max(crossings) + eps);
    
    features = [
        hog_feature, ...
        density, ...
        numHoles, ...
        projFeatures, ...
        zoningF, ...
        zoningF2, ...
        crossings
        ];
end


function zf = zoningFeatures(bin, rows, cols)
    [H, W] = size(bin);
    zf = zeros(1, rows * cols);
    idx = 1;
    for r = 1:rows
        for c = 1:cols
            rStart = round((r-1)*H/rows) + 1;
            rEnd   = round(r*H/rows);
            cStart = round((c-1)*W/cols) + 1;
            cEnd   = round(c*W/cols);
            zone = bin(rStart:rEnd, cStart:cEnd);
            zf(idx) = sum(zone(:)) / numel(zone);
            idx = idx + 1;
        end
    end
end

















%function features = extract_character_features(img, imageSize)

    % Preprocess
 
    %if size(img,3) == 3
     %   img = rgb2gray(img);
    %end
    
   % img = imresize(img, imageSize);
   % img = im2single(img);
    
  
    % BINARIZATION (para shape features)
   % bin = imbinarize(img);
    
  
    % HOG FEATURES (base)
  %  hog_feature = extractHOGFeatures(img, 'CellSize', [8 8]);
    
 
    % 1. SHAPE FEATURES (muy importantes para 8 vs B, 1 vs I)
    %density = sum(bin(:)) / numel(bin);
    
    % agujeros (topología básica)
   % cc = bwconncomp(~bin);
   % numHoles = cc.NumObjects;
    
    % =========================================================
    % 2. PROJECTION FEATURES (OCR clásico potente)
    % =========================================================
    
   % hProfile = sum(bin, 1);
   % vProfile = sum(bin, 2);
    
   % projFeatures = [
   %     mean(hProfile), std(hProfile), ...
   %     mean(vProfile), std(vProfile)
    %    ];
    
    % =========================================================
    % 3. GRADIENT FEATURES (complemento a HOG)
    % =========================================================
    
   % [Gx, Gy] = imgradientxy(img);
   % [Gmag, Gdir] = imgradient(Gx, Gy);
    
   % gradFeatures = [
     %   mean(Gmag(:)), ...
     %   std(Gmag(:))
     %   ];
    
   % dirHist = histcounts(Gdir(:), 8);
   % dirHist = dirHist / (sum(dirHist) + eps);
    
    % =========================================================
    % FINAL FEATURE VECTOR
    % =========================================================
   % features = [
  %      hog_feature, ...
  %      density, ...
  %      numHoles, ...
  %      projFeatures, ...
   %     gradFeatures, ...
  %      dirHist
   %     ];

%end

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