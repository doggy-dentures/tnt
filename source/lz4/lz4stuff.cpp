#include "lz4.h"

uint8_t* decompressRaw(const uint8_t* input, int compressedSize, int decompressedSize)
{
    char *output = new char[decompressedSize];
    LZ4_decompress_safe((char*)input, output, compressedSize, decompressedSize);
    return (uint8_t*)output;
}

uint8_t* allocateArrayRaw(int size)
{
    return new uint8_t[size];
}