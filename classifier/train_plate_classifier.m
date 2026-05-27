clear;
clc;
close all;

%% Configuration

positiveDir = 'dataset/positive';
negativeDir = 'dataset/negative';

imageSize = [64 128]; % height * width

%% Load dataset

positiveImages = dir(fullfile(positiveDir, '*.jpg'));
negativeImages = dir(fullfile(negativeDir, '*.jpg'));

numPos = length(positiveImages);
numNeg = length(negativeImages);

fprintf('Positives: %d\n', numPos);
fprintf('Negatives: %d\n', numNeg);

%% Features extraction

features = [];
labels = [];

% ---------------------------
% Positives
% ---------------------------

for i = 1:numPos

    imgPath = fullfile(positiveDir, positiveImages(i).name);

    img = imread(imgPath);

    feat = extract_plate_features(img, imageSize);

    features = [features; feat];

    labels = [labels; 1];

end

% ---------------------------
% Negatives
% ---------------------------

for i = 1:numNeg

    imgPath = fullfile(negativeDir, negativeImages(i).name);

    img = imread(imgPath);

    feat = extract_plate_features(img, imageSize);

    features = [features; feat];

    labels = [labels; 0];

end

fprintf('Features extracted\n');
size(features)

%% Train / Test division

rng(42);
cv = cvpartition(labels, 'HoldOut', 0.2);

Xtrain = features(training(cv), :);
Ytrain = labels(training(cv));

Xtest = features(test(cv), :);
Ytest = labels(test(cv));

%% Train classifier (SVM)

fprintf('Training SVM...\n');

model = fitcsvm(Xtrain, Ytrain, 'KernelFunction', 'linear', ...
    'Standardize', true, 'ClassNames', [0 1], 'KernelScale','auto');

fprintf('Model trained\n');

%% Evaluation

predictions = predict(model, Xtest);

accuracy = sum(predictions == Ytest) / length(Ytest);

fprintf('Accuracy: %.2f %%\n', accuracy * 100);

%% Confusion matrix

figure;
confusionchart(Ytest, predictions);

title('Confusion Matrix');

%% Save model

save('plate_classifier.mat', 'model');

fprintf('Model saved in plate_classifier_model.mat\n');