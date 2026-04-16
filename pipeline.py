from clasificador import classify
from separador import separate
from OCR import getPlate

def main():
    # Carga de dataset
    test = ([([1, 0, 1], [0, 1, 0], [1, 0, 1])])
    dataset = (test)
    for im in dataset:
        plates, others = classify(im, {})
        for p in plates:
            subim = separate(p)
            plate = getPlate(subim, im)
            print('Detected plate: ' + plate)

if __name__ == '__main__':
    main()