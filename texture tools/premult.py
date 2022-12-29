from PIL import Image
import numpy
import sys


def is_pma(matrix):
    if ((matrix[:,:,0] > matrix[:,:,3]).any() or (matrix[:,:,1] > matrix[:,:,3]).any() or (matrix[:,:,2] > matrix[:,:,3]).any()):
        return False
    return True

def premultiplyAlpha(img):
    matrix = numpy.array(img)
    print ("checking PMA")
    if is_pma(matrix):
        print ("Skipped: already Premultiplied Alpha image")
        img.save(sys.argv[1].split(".")[0] + "_tmp.png")
        exit(1)
    print ("premultiplying matrix...")
    matrix[:,:,0] = numpy.round(matrix[:,:,0] * (matrix[:,:,3] / 255.0))
    matrix[:,:,1] = numpy.round(matrix[:,:,1] * (matrix[:,:,3] / 255.0))
    matrix[:,:,2] = numpy.round(matrix[:,:,2] * (matrix[:,:,3] / 255.0))
    return Image.fromarray(matrix)


if (len(sys.argv) <= 1):
    print("NO FILE")
    sys.exit()

im = Image.open(sys.argv[1]).convert('RGBA')
img2 = premultiplyAlpha(im)
# save
img2.save(sys.argv[1].split(".")[0] + "_tmp.png")
