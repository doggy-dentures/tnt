@For %%A In (itemsRGB5A1/*.png) Do cuttlefish -i itemsRGB5A1/%%~nA.png --pre-multiply -f R5G5B5A1 --quality highest -o itemsRGB5A1/%%~nA.pvr && python bytes.py itemsRGB5A1/%%~nA.pvr