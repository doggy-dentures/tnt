from io import *
import sys
import os
import lz4.block

if (len(sys.argv) <= 1):
    print("NO FILE")
    sys.exit()

inbytes = open(sys.argv[1], "rb")
outbytes = BytesIO()

magic = inbytes.read(3).decode("utf-8")

format = 0

match magic:
    case "PVR":
        inbytes.seek(8, 0)
        pvrFormatBytes = inbytes.read(8)
        pvrFormat = int.from_bytes(pvrFormatBytes, 'little', signed=False)
        match pvrFormat:
            case 7: #dxt1
                format = 1
            case 15: #bc7
                format = 0
            case 289360692918773618: #rgba4
                format = 2
            case 73470489588295538: #rgb5a1
                format = 3
            case 11 | 10: #dxt5
                format = 4
            case _:
                print("NOT SUPPORTED FORMAT")
                exit(-1)

        outbytes.write(format.to_bytes(4, 'little', signed=True))
        inbytes.seek(24, 0)
        outbytes.write(inbytes.read(4))
        outbytes.write(inbytes.read(4))
        inbytes.seek(48, 0)
        metaSize = int.from_bytes(inbytes.read(4), 'little')
        inbytes.seek(52 + metaSize, 0)
        outbytes.write(inbytes.read())
    case "DDS":
        outbytes.write(format.to_bytes(4, 'little', signed=True))
        inbytes.seek(12, 0)
        outbytes.write(inbytes.read(4))
        outbytes.write(inbytes.read(4))
        inbytes.seek(148, 0)
        outbytes.write(inbytes.read())

outbytes.flush()
inbytes.close()
datachunk = outbytes.getbuffer()

# with open(sys.argv[1].split(".")[0] + ".punk", "wb") as f:
#     f.write(datachunk)

compressedchunk = lz4.block.compress(datachunk, mode='high_compression',compression=12, store_size=False)

outbytes2 = BytesIO()
outbytes2.write(b"FUNK")
outbytes2.write(len(datachunk).to_bytes(4, 'little', signed=True))
outbytes2.write(compressedchunk)
outbytes2.flush()

with open(sys.argv[1].split(".")[0] + ".funk", "wb") as f:
    f.write(outbytes2.getbuffer())

outbytes2.close()
