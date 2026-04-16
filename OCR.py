def getPlate(data, ogImage):
    image, ROIs = data
    def getCharacter(ch):
        return 'A'
    
    plate = ''
    for c in ROIs:
        plate += getCharacter(c) + ' '
    return plate
