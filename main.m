
% PIPELINE COMPLETO DE DETECCIÓN Y RECONOCIMIENTO DE MATRÍCULAS

addpath(genpath(pwd));

function image = cutImage(im, ROI)
    image = imcrop(im, ROI);
end


% Flags para controlar la visualización y ejecución del sistema

showSteps = false;      % Muestra pasos intermedios del detector de ROIs
showSegments = true;        % Muestra segmentación de caracteres dentro de la ROI

loadDataset = false;
useTxtFiles = true;
fileFactor = 1;
showVisuals = false;

% Ruta del dataset
datasetPath = fullfile(pwd, 'Datasets', 'Dataset');


% Lista de imagenes a procesar
images = ["test_092.jpg","test_071.jpg","test_073.jpg","test_061.jpg","test_057.jpg","test_060.jpg","test_048.jpg","test_046.jpg","test_023.jpg","test_017.jpg","test_015.jpg","test_010.jpg","eu8.jpg","eu4.jpg","eu11.jpg",];

% Carga del dataset
if useTxtFiles
    disp('Using txt');
    files = dir(fullfile(datasetPath, '*.txt'));
    images = [];
    roisDataset = [];
    platesDataset = [];
    for f = 1:(numel(files) * fileFactor)
        file = fullfile(datasetPath, files(f).name);
        fid = fopen(file, 'r');
        data = textscan(fid, '%s %d %d %d %d %s');
        fclose(fid);

        if ~isempty(data{1})
            imgPath = fullfile(datasetPath, string(data(1)));
            x = data{2};
            y = data{3};
            w = data{4};
            h = data{5};
            pl = string(data{6});
            bb = [x, y, w, h];
            images = [images(:); imgPath(:)];
            roisDataset = [roisDataset; bb];
            platesDataset = [platesDataset; pl];
        end
    end
elseif loadDataset
    images = [];
    data = [
        dir(fullfile(datasetPath, '*.jpg'));
        dir(fullfile(datasetPath, '*.png'));
        dir(fullfile(datasetPath, '*.jpeg'))
    ];

    images = fullfile({data.folder}, {data.name});
    images = string(images);

else 
    images = fullfile(datasetPath, images);
    images = string(images);
end


% Bucle principal de procesamiento
exactas = 0;
parciales = 0;
errores = 0;

confusionLog = {};

for k = 1:numel(images)

    % Lectura de la imagen actual
    im = imread(images(k));
    if useTxtFiles
        expected = char(platesDataset(k));
        bestMatch = 0;
        bestPlate = "";
    end

    % FASE 1: DETECCIÓN DE POSIBLES MATRÍCULAS (ROIs)
    candidates = getCandidates(im, false);
    
    % Clasificar todas las ROIs y recoger scores ANTES del NMS
    scores = zeros(size(candidates, 1), 1);
    validMask = false(size(candidates, 1), 1);
    
    for i = 1:size(candidates, 1)
        crop = cutImage(im, candidates(i,:));
        [isPlate, scores(i)] = classify_roi(crop);
        validMask(i) = isPlate;
    end
    
    % Quedarse solo con las que el clasificador acepta
    candidates = candidates(validMask, :);
    scores = scores(validMask);
    
    % NMS sobre las candidatas válidas
    candidates = nms(candidates, scores, 0.45, 0.75);
    
    [~, name] = fileparts(images(k));
    if showVisuals
        og = figure('Name', name);
        imshow(im), title(name);
        hold on;
    end
    
    % FASE 2: ALINEACIÓN Y SEGMENTACIÓN
    for i = 1:size(candidates, 1)
        plate = cutImage(im, candidates(i,:));
        match = 0;
    
        [aligned, BB] = alignPlate(plate, candidates(i,:));
        aligned = imresize(aligned, 2);
        blobs = segm(aligned);

        [plateText, charLabels] = recognize_plate(aligned, blobs);
        %fprintf("Matrícula detectada: %s\n", plateText);

        if size(blobs,1) <= 3
            [aligned, BB] = alignPlate(255-plate, candidates(i,:));
            aligned = imresize(aligned, 2);
            blobs = segm(aligned);
            [plateText, charLabels] = recognize_plate(aligned, blobs);
            %fprintf("Matrícula detectada: %s\n", plateText);
        end
        %fprintf("Matrícula detectada: %s\n", plateText);
        detectedCh = char(plateText);

        if useTxtFiles
            if strcmp(detectedCh,expected)
                match = 2;
            else
                m = 0;
                tmp = expected;
                for c = 1:length(detectedCh)
                    idx = strfind(tmp, detectedCh(c));
                    if ~isempty(idx)
                        m = m + 1;
                        tmp(idx(1)) = [];
                    end
                end
                if m >= 3
                    match = 1;
                end
            end
    
            if match > bestMatch
                bestMatch = match;
                bestPlate = plateText;
            end
        end
    
        % Visualización

        if showVisuals
            figure(og);
            if useTxtFiles
                bbDataset = roisDataset(k, :);
                rectangle('Position',bbDataset, 'EdgeColor', 'g', 'LineWidth', 2.5);
            end

            if ~isempty(BB)
                x_pl = [BB(:,1); BB(1,1)];
                y_pl = [BB(:,2); BB(1,2)];
                line(x_pl, y_pl, 'Color', 'r', 'LineWidth', 2.5);
        
                if size(blobs,1) > 3 && showSegments
                    figure, imshow(aligned), title('cropped image');
                    hold on;
                    for j = 1:size(blobs,1)
                        bb = blobs(j,:);
                        rectangle('Position', bb, ...
                            'EdgeColor', 'r', ...
                            'LineWidth', 2);
                        text(bb(1)+bb(3)/2, ...
                             bb(2)-5, ...
                             char(charLabels(j)), ...
                             'FontSize', 16, ...
                             'FontWeight', 'bold', ...
                             'Color', 'r', ...
                             'HorizontalAlignment', 'center');
                    end
                    if showVisuals
                        hold off;
                    end
                end
            end
        end
    end

    if showVisuals
        figure(og);
        hold off;
    end

    if useTxtFiles
        if bestMatch == 2
            exactas = exactas + 1;
            ver = "Correcto";
        elseif bestMatch == 1
            parciales = parciales + 1;
            ver = "Parcialmente correcto";

            % Analisis de Confusiones
            det = char(bestPlate);
            exp = expected;
            tmpExp = exp;
            tmpDet = det;
            % Elimina los caracteres que coinciden para quedarse solo con errores
            for c = length(tmpDet):-1:1
                idx = strfind(tmpExp, tmpDet(c));
                if ~isempty(idx)
                    tmpExp(idx(1)) = [];
                    tmpDet(c) = [];
                end
            end
            % Empareja lo que faltaba con lo que se detectó de más
            nPairs = min(length(tmpExp), length(tmpDet));
            for c = 1:nPairs
                confusionLog{end+1} = {tmpExp(c), tmpDet(c)};
            end
        else
            errores = errores + 1;
            ver = "Error";
        end
        fprintf("Name: %s\n", name);
        fprintf("Matrícula detectada: %s\n", bestPlate);
        fprintf("Matrícula esperada:  %s\n", expected);
        fprintf("Veredicto: %s\n", ver);
        fprintf("=======================\n");
    end
    if ~showVisuals
        close all hidden;
    end
end

fprintf("\n===============================\n");
fprintf("     RESULTADOS FINALES      \n");
fprintf("Imagenes evaluadas: %d\n", numel(images));
fprintf("===============================\n");
fprintf("Iguales: %d\n", exactas);
fprintf("Parciales: %d\n", parciales);
fprintf("Errores: %d\n", errores);
fprintf("===============================\n");
precision = (exactas / numel(images));
precParcial = ((exactas + parciales) / numel(images));
fprintf("Tasa de acierto: %.0f%%\n", precision * 100);
fprintf("Tasa de acierto parcial: %.0f%%\n",  precParcial * 100);

% --- RESUMEN DE CONFUSIONES ---
if ~isempty(confusionLog)
    % Agrupa y cuenta cada par (real -> detectado)
    pares = cellfun(@(x) sprintf('%s->%s', x{1}, x{2}), confusionLog, 'UniformOutput', false);
    [paresSorted, ~, ic] = unique(pares);
    counts = accumarray(ic, 1);
    [countsSorted, sortIdx] = sort(counts, 'descend');

    fprintf("\n=== CONFUSIONES MÁS FRECUENTES ===\n");
    fprintf("  Real -> Detectado   Veces\n");
    fprintf("  --------------------------\n");
    for i = 1:length(paresSorted)
        fprintf("  %-18s  %d\n", paresSorted{sortIdx(i)}, countsSorted(i));
    end
    fprintf("===================================\n");
end