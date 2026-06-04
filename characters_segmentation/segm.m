function chars = segm(im)
   
    if size(im, 3) == 3
        im = rgb2gray(im);
    end

    %im = imadjust(im)
    im = imgaussfilt(im, 0.5);
    bw = ~imbinarize(im, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);

    bw = imclearborder(bw); % Elimina objetos tocando los bordes
    bw = bwareaopen(bw, 30); 

    CC = bwconncomp(bw);

    % Close para conectar numeros como 3, etc
    se = strel('square', 2); 
    bw = imclose(bw, se);

    S = regionprops(CC, 'BoundingBox', 'Area', 'Extent');
    
    [imgHeight, ~] = size(bw);
    blobs = [];

    for k = 1:numel(S)
        bb = S(k).BoundingBox;
        x = bb(1); 
        y = bb(2); 
        w = bb(3); 
        h = bb(4);
        
        ar = w / h; % Aspect Ratio

        cond_ar = (ar > 0.05 && ar < 1.5);

        cond_h = (h > imgHeight * 0.35 && h < imgHeight * 0.95);

        % Extent (Area del objeto / Area del Bounding Box)
        cond_ext = (S(k).Extent > 0.12 && S(k).Extent < 1.0);

        if cond_ar && cond_h && cond_ext
            blobs = [blobs; bb];
        end
    end

    if ~isempty(blobs)
        chars = sortrows(blobs, 1);
    else
        chars = [];
    end
end

function chars = segmOLD(im)

    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    
    %im = imadjust(im)
    
    bw = ~imbinarize(im, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.5);
    
    bw = imclearborder(bw); % Elimina objetos tocando los bordes
    bw = bwareaopen(bw, 40); 
    
    CC = bwconncomp(bw);
    
    % Close para conectar numeros como 3, etc
    se = strel('square', 2); 
    bw = imclose(bw, se);
    
    S = regionprops(CC, 'BoundingBox', 'Area', 'Extent');
    
    [imgHeight, ~] = size(bw);
    blobs = [];
    
    for k = 1:numel(S)
        bb = S(k).BoundingBox;
        x = bb(1); 
        y = bb(2); 
        w = bb(3); 
        h = bb(4);
    
        ar = w / h; % Aspect Ratio
    
        cond_ar = (ar > 0.05 && ar < 0.95);
    
        cond_h = (h > imgHeight * 0.35 && h < imgHeight * 0.95);
    
        % Extent (Area del objeto / Area del Bounding Box)
        cond_ext = (S(k).Extent > 0.12 && S(k).Extent < 1.0);
    
        if cond_ar && cond_h && cond_ext
            blobs = [blobs; bb];
        end
    end
    
    if ~isempty(blobs)
        chars = sortrows(blobs, 1);
    else
        chars = [];
    end
end