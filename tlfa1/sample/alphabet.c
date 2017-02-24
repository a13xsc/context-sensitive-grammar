#include "alphabet.h"
#include <stdlib.h>
#include <stdio.h>

struct alphabet* alphabet_init()
{
    struct alphabet* result = (struct alphabet*)malloc(sizeof(*result));
    result->buffer = (unsigned int*)calloc(NUMBER_OF_BUCKETS,
                sizeof(*result->buffer));
    return result;
}

void alphabet_clean(struct alphabet* alpha)
{
    free(alpha->buffer);
    free(alpha);
}

void alphabet_add(struct alphabet* alpha, unsigned char c)
{
    int aindex = (int)c / NUMBER_OF_BITS, bindex = (int)c % NUMBER_OF_BITS;
    alpha->buffer[aindex] |= (1 << bindex);
}

void alphabet_remove(struct alphabet* alpha, unsigned char c)
{
    int aindex = (int)c / NUMBER_OF_BITS, bindex = (int)c % NUMBER_OF_BITS;
    alpha->buffer[aindex] &= ~(1 << bindex);
}

int alphabet_contains(struct alphabet* alpha, unsigned char c)
{
    int aindex = (int)c / NUMBER_OF_BITS, bindex = (int)c % NUMBER_OF_BITS;
    return (alpha->buffer[aindex] & (1 << bindex)) >> bindex;
}

void alphabet_print(struct alphabet* alphabet)
{
    char sep = '{';
    int i;
    for(i = 0; i < NUMBER_OF_SYMBOLS; ++i)
    {
        if(alphabet_contains(alphabet, (unsigned char)i))
        {
            printf("%c%c", sep, i);
            sep = ',';
        }
    }
    printf("%c\n", (sep == ',' ? '}' : 'O'));
}

int alphabet_is_empty(struct alphabet* alphabet)
{
    int i;
    for(i = 0; i < NUMBER_OF_BUCKETS; ++i) {
        if(alphabet->buffer[i]) {
            return 0;
        }
    }
    return 1;
}
