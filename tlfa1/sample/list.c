#include "list.h"
#include <stdlib.h>

struct cell* list_init(void (*f)(void*))
{
    struct cell* result = (struct cell*)malloc(sizeof(*result));
    result->info = NULL;
    result->next = result->prev = result;
    result->f = f;
    return result;
}

void list_add_last(struct cell* list, void* elem)
{
    struct cell* container = (struct cell*)malloc(sizeof(*container));
    container->info = elem;
    container->next = list;
    container->prev = list->prev;
    list->prev->next = container;
    list->prev = container;
}

void list_remove_last(struct cell* list)
{
    if(list_is_empty(list))
    {
        return;
    }
    list->prev = list->prev->prev;
    list->f(list->prev->next->info);
    free(list->prev->next);
    list->prev->next = list;
}

void list_remove(struct cell* list, void (*f)(void*)) {
    if(list->info == NULL) {
        return;
    }
    list->prev->next = list->next;
    list->next->prev = list->prev;
    f(list->info);
    free(list);
}

int list_is_empty(struct cell* list)
{
    return (list->next == list && list->info == NULL);
}

void list_clean(struct cell* list)
{
    while(!list_is_empty(list))
    {
        list_remove_last(list);
    }
    free(list);
}
