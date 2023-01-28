#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <iostream>

#define LEFTROTATE(x, c) (((x) << (c)) | ((x) >> (32 - (c))))

uint32_t r[] = {
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

uint32_t k[] = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};

void md5(uint8_t *initial_msg, size_t initial_len, uint8_t *hash)
{
    static uint8_t msg[56 + 64];
    uint8_t *p;
    uint64_t bits_len;

    uint32_t h0 = 0x67452301;
    uint32_t h1 = 0xefcdab89;
    uint32_t h2 = 0x98badcfe;
    uint32_t h3 = 0x10325476;

    memset(msg, 0, sizeof(msg));
    memcpy(msg, initial_msg, 8);

    msg[8] = 128;

    bits_len = 64;
    memcpy(msg + 56, &bits_len, 8);

    uint32_t *w = (uint32_t *)(msg);

    uint32_t a = h0;
    uint32_t b = h1;
    uint32_t c = h2;
    uint32_t d = h3;

    uint32_t i;
    for (i = 0; i < 64; i++)
    {
        uint32_t f, g;

        if (i < 16)
        {
            f = (b & c) | ((~b) & d);
            g = i;
        }
        else if (i < 32)
        {
            f = (d & b) | ((~d) & c);
            g = (5 * i + 1) % 16;
        }
        else if (i < 48)
        {
            f = b ^ c ^ d;
            g = (3 * i + 5) % 16;
        }
        else
        {
            f = c ^ (b | (~d));
            g = (7 * i) % 16;
        }

        uint32_t temp = d;
        d = c;
        c = b;
        b = b + LEFTROTATE((a + f + k[i] + w[g]), r[i]);
        a = temp;
    }

    h0 += a;
    h1 += b;
    h2 += c;
    h3 += d;

    p = (uint8_t *)&h0;
    hash[0] = p[0], hash[1] = p[1], hash[2] = p[2], hash[3] = p[3];
    p = (uint8_t *)&h1;
    hash[4] = p[0], hash[5] = p[1], hash[6] = p[2], hash[7] = p[3];
    p = (uint8_t *)&h2;
    hash[8] = p[0], hash[9] = p[1], hash[10] = p[2], hash[11] = p[3];
    p = (uint8_t *)&h3;
    hash[12] = p[0], hash[13] = p[1], hash[14] = p[2], hash[15] = p[3];
}

int main(int argc, char **argv)
{
    size_t len;
    uint8_t hash[16];

    len = (argc == 2) ? strlen(argv[1]) : 0;
    if (argc != 2 || len != 8)
    {
        printf("\nUsage: %s 'string'\n", argv[0]);
        printf("Note: the string length must be 8.\n");
        return 1;
    }

    uint8_t *p = reinterpret_cast<uint8_t *>(argv[1]);
    md5(p, len, hash);

    printf("\nThe hash code of %s is: ", argv[1]);
    printf("%02x%02x%02x%02x", hash[0], hash[1], hash[2], hash[3]);
    printf("%02x%02x%02x%02x", hash[4], hash[5], hash[6], hash[7]);
    printf("%02x%02x%02x%02x", hash[8], hash[9], hash[10], hash[11]);
    printf("%02x%02x%02x%02x\n", hash[12], hash[13], hash[14], hash[15]);

    return 0;
}
