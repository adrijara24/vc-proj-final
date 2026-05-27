
img = imread('roi.jpg');

[pred, score] = classify_roi(img);

if pred == 1

    fprintf('Is a plate\n');

else

    fprintf('Is not a plate\n');

end

fprintf('Score: %.4f\n', score);