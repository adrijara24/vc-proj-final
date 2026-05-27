
% PIPELINE COMPLETO DE DETECCIÓN Y RECONOCIMIENTO DE MATRÍCULAS

addpath(genpath(pwd));

function image = cutImage(im, ROI)
    image = imcrop(im, ROI);
end


% Flags para controlar la visualización y ejecución del sistema

showSteps = false;      % Muestra pasos intermedios del detector de ROIs
%showResult = false;      % Activa visualización de resultados globales
showRois = true;        % Muestra segmentación de caracteres dentro de la ROI

loadDataset = false;    % true -> carga automáticamente dataset completo
                        % false -> usa lista manual de imágenes

% Ruta del dataset
datasetPath = fullfile(pwd, 'Datasets', 'Dataset');


% Lista de imagenes a procesar

%images = ["eu1.jpg","eu2.jpg","eu3.jpg","eu4.jpg","eu5.jpg","eu8.jpg","eu9.jpg","eu11.jpg","test_097.jpg","test_012.jpg","test_013.jpg","test_044.jpg","test_045.jpg","test_049.jpg","test_066.jpg"];
%Imagenes que no acotan bien
%images = ["test_092.jpg","test_090.jpg","test_066.jpg","test_061.jpg","test_058.jpg","test_042.jpg","test_033.jpg","test_097.jpg"];
%Imagenes donde no se detecta la matrícula
%images = ["test_049.jpg","test_041.jpg","test_019.jpg","test_018.jpg","test_015.jpg","eu8.jpg","eu4.jpg"];
%images = ["test_073.jpg",];
%images = ["test_049.jpg","test_019.jpg","test_015.jpg","eu8.jpg","eu4.jpg"];
%images = ["test_091.jpg","test_096.jpg","test_079.jpg","test_078.jpg","test_063.jpg","test_071.jpg","test_056.jpg","test_044.jpg","test_029.jpg"];
%images = ["test_092.jpg","test_071.jpg","test_073.jpg","test_061.jpg","test_057.jpg","test_060.jpg","test_048.jpg","test_046.jpg","test_023.jpg","test_017.jpg","test_015.jpg","test_010.jpg","eu8.jpg","eu4.jpg","eu11.jpg",];

images = ["test_071.jpg","test_070.jpg","test_062.jpg","test_061.jpg","test_058.jpg","test_043.jpg","test_042.jpg","test_039.jpg","test_034.jpg","test_013.jpg"];

%images = ["test_095.jpg"];

% Alternativa: dataset 2 de vehículos 
%images = ["Cars0.png", "Cars1.png", "Cars2.png"];



% Carga del dataset

if loadDataset
    images = [];
    data = [
        dir(fullfile(datasetPath, '*.jpg'));
        dir(fullfile(datasetPath, '*.png'));
        dir(fullfile(datasetPath, '*.jpeg'))
    ];

    images = fullfile({data.folder}, {data.name});
    images = string(images);

else 
    % Construcción de rutas completas para las imágenes seleccionadas
    images = fullfile(datasetPath, images);
    images = string(images);
end


% Bucle principal de procesamiento

for k = 1:numel(images)

    % Lectura de la imagen actual
    im = imread(images(k));


    % FASE 1: DETECCIÓN DE POSIBLES MATRÍCULAS (ROIs)
 
    candidates = getCandidates(im, showSteps);
    candidates = joinDuplicates(candidates, 0.70);

    [~, name] = fileparts(images(k));


    % Creación de figura principal para visualización
    og = figure('Name', name);
    imshow(im), title(name);
    hold on;

     if showSteps
         for i = 1:size(candidates, 1)
             rectangle('Position', candidates(i, :), 'EdgeColor', 'g', 'LineWidth', 2);
         end
     end

    %hold off;


    % Procesamiento de cada ROI detectada (candidatos)
  
    for i = 1:size(candidates, 1)

        % Recorte de la región candidata
        crop = cutImage(im, candidates(i, :));
        plate = [];

        
        % Filtro de clasificación (PLACA / NO PLACA)
       
        [isPlate, score] = classify_roi(crop);

        if isPlate
            plate = crop;
        else
            continue
        end

  
        % FASE 2: ALINEACIÓN Y SEGMENTACIÓN
    
        [aligned, BB] = alignPlate(plate, candidates(i, :));
        blobs = segm(aligned);

        % Caso alternativo si la segmentación falla
        if size(blobs,1) <= 3
            [aligned, BB] = alignPlate(255-plate, candidates(i, :));
            blobs = segm(aligned);
        end

        
        % Visualización

        if ~isempty(BB)

            % Visualización matrícula detectada
          
            figure(og);

            x_pl = [BB(:, 1); BB(1, 1)];
            y_pl = [BB(:, 2); BB(1, 2)];

            line(x_pl, y_pl, 'Color', 'r', 'LineWidth', 2.5);

        
            % Visualización de segmentación de caracteres

            if size(blobs, 1) > 3

                if showRois

                    figure, imshow(aligned), title('cropped image');
                    hold on;

                    for j = 1:size(blobs, 1)

                        bb = blobs(j, :);

                        rectangle('Position', bb, ...
                            'EdgeColor', 'r', ...
                            'LineWidth', 2);

                        text(bb(1), bb(2), num2str(j), ...
                            "FontSize", 14, ...
                            "FontWeight", "bold", ...
                            "Color", "r", ...
                            "HorizontalAlignment", "center", ...
                            "VerticalAlignment", "bottom");
                    end

                    hold off;
                end
            end
        end

        % ROIs procesadas (para futuras extensiones del sistema)
        % ROIs = [ROIs; crop]
    end

    % Finalización de visualización de la imagen actual
    figure(og);
    hold off;
    
end