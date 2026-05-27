def getPlateString(image):
    image, ROIs = image
    def getCharacter(ch):
        return 'A'
    
    plate = ''
    for c in ROIs:
        plate += getCharacter(c) + ' '
    return plate

def separateCharacters(image) -> list:
    characters = []

    return characters