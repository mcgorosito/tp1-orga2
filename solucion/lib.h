#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>

/* String */

char* strClone(char* a);
uint32_t strLen(char* a);
int32_t strCmp(char* a, char* b);
char* strConcat(char* a, char* b);
void strDelete(char* a);
void strPrint(char* a, FILE *pFile);
void hexPrint(char* a, FILE *pFile);

/* List */

typedef struct s_list{
    struct s_listElem *first;
    struct s_listElem *last;
} list_t;

typedef struct s_listElem{
    void *data;
    struct s_listElem *next;
    struct s_listElem *prev;
} listElem_t;

typedef void (funcDelete_t)(void*);
typedef void (funcPrint_t)(void*, FILE *pFile);
typedef int32_t (funcCmp_t)(void*, void*);
typedef void* (funcDup_t)(void*);
typedef int32_t (funcSorter_t)(void*);

list_t* listNew();
void listAddFirst(list_t* l, void* data);
void listAddLast(list_t* l, void* data);
void listAdd(list_t* l, void* data, funcCmp_t* fc);
void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd);
void listRemoveFirst(list_t* l, funcDelete_t* fd);
void listRemoveLast(list_t* l, funcDelete_t* fd);
list_t* listClone(list_t* l, funcDup_t* fn);
void listDelete(list_t* l, funcDelete_t* fd);
void listPrint(list_t* l, FILE *pFile, funcPrint_t* fp);

/** sorter **/

typedef struct s_sorter{
    uint16_t size;
    funcSorter_t *sorterFunction;
    funcCmp_t *compareFunction;
    list_t **slots;
} sorter_t;

sorter_t* sorterNew(uint16_t slots, funcSorter_t* fs, funcCmp_t* fc);
void sorterAdd(sorter_t* sorter, void* data);
void sorterRemove(sorter_t* sorter, void* data, funcDelete_t* fd);
list_t* sorterGetSlot(sorter_t* sorter, uint16_t slot, funcDup_t* fn);
char* sorterGetConcatSlot(sorter_t* sorter, uint16_t slot);
void sorterCleanSlot(sorter_t* sorter, uint16_t slot, funcDelete_t* fd);
void sorterDelete(sorter_t* sorter, funcDelete_t* fd);
void sorterPrint(sorter_t* sorter, FILE *pFile, funcPrint_t* fp);

/** sorterFunctions **/

uint16_t fs_sizeModFive(char* s);
uint16_t fs_firstChar(char* s);
uint16_t fs_bitSplit(char* s);