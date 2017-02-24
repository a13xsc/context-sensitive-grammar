#ifndef __DLIST_H
#define __DLIST_H 1

struct cell {
    void* info;
    struct cell* next;
    struct cell* prev;
    void (*f)(void*);
};

struct cell* list_init(void (*f)(void*));
void list_clean(struct cell*);

void list_add_last(struct cell*, void*);
void list_remove_last(struct cell*);

void list_remove(struct cell*, void (*f)(void*));

int list_is_empty(struct cell*);

#endif
