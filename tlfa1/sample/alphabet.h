#ifndef __ALPHABET_H
#define __ALPHABET_H 1

#define NUMBER_OF_SYMBOLS 256

struct alphabet {
    unsigned int* buffer;
};

#define NUMBER_OF_BITS (sizeof(*((struct alphabet*)0)->buffer) * 8)
#define NUMBER_OF_BUCKETS ((NUMBER_OF_SYMBOLS - 1) / NUMBER_OF_BITS + 1)

struct alphabet* alphabet_init();
void alphabet_clean(struct alphabet*);

void alphabet_add(struct alphabet*, unsigned char);
void alphabet_remove(struct alphabet*, unsigned char);
int alphabet_contains(struct alphabet*, unsigned char);

void alphabet_print(struct alphabet*);
int alphabet_is_empty(struct alphabet*);

#endif
