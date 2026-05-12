from classifier import classify
from OCR import getPlateString
from reducer import getPlate

def process_dataset(path : str) -> dict:
    dataset = []
    results = dict()
    candidates, discarded = classify(dataset, {})
    for c in candidates:
        [res, p] = getPlate(c)
        if res:
            identifier = getPlateString(p)
            results[c] = identifier
            print(f'Detected plate {identifier} on image {c}')

    return results

def main():
    process_dataset('')

if __name__ == '__main__':
    main()