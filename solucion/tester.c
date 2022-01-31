#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>

#include "lib.h"

#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_1 =  "salida.caso.1.txt";
char *filename_2 =  "salida.caso.2.txt";
void test_1();
void test_2();

int main() {
    srand(12345);
    remove(filename_1);
    test_1();
    remove(filename_2);
    test_2();
    return 0;
}

char* randomString(uint32_t l) {
    // 32 a 126 = caracteres validos
    char* s = malloc(l+1);
    for(uint32_t i=0; i<(l+1); i++)
       s[i] = (char)(33+(rand()%(126-33)));
    s[l] = 0;
    return s;
}

char* randomHexString(uint32_t l) {
    char* s = malloc(l+1);
    for(uint32_t i=0; i<(l+1); i++) {
        do {
            s[i] = (char)(rand()%256);
        } while (s[i]==0);
    }
    s[l] = 0;
    return s;
}

char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};

/** Strings **/
void test_strings(FILE *pfile) {
    fprintf(pfile,"===== String\n");
    char *a, *b, *c;
    // clone
    fprintf(pfile,"==> Clone\n");
    a = strClone("casa");
    b = strClone("");
    strPrint(a,pfile);
    fprintf(pfile,"\n");
    strPrint(b,pfile);
    fprintf(pfile,"\n");
    strDelete(a);
    strDelete(b);
    // concat
    fprintf(pfile,"==> Concat\n");
    a = strClone("perro_");
    b = strClone("loco");
    fprintf(pfile,"%i\n",strLen(a));
    fprintf(pfile,"%i\n",strLen(b));
    c = strConcat(a,b);
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    c = strConcat(c,strClone(""));
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    c = strConcat(strClone(""),c);
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    c = strConcat(c,c);
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    free(c);    
    // cmp
    fprintf(pfile,"==> Cmp\n");
    char* texts[5] = {"sar","23","taaa","tbb","tix"};
    for(int i=0; i<5; i++) {
        for(int j=0; j<5; j++) {
            fprintf(pfile,"cmp(%s,%s) -> %i\n",texts[i],texts[j],strCmp(texts[i],texts[j]));
        }
    }
}

/** List **/
void test_list(FILE *pfile) {
    fprintf(pfile,"===== List\n");
    char *a, *b, *c;
    list_t* l1;
    // listAddFirst
    fprintf(pfile,"==> listAddFirst\n");
    l1 = listNew();    
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listAddFirst(l1,strClone("PRIMERO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddFirst(l1,strClone("PRIMERO"));
    listAddFirst(l1,strClone("PRIMERO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddFirst(l1,strClone("PRIMERO"));
    listAddFirst(l1,strClone("PRIMERO"));
    listAddFirst(l1,strClone("PRIMERO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listAddLast
    fprintf(pfile,"==> listAddLast\n");
    l1 = listNew();
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddLast(l1,strClone("ULTIMO"));
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddLast(l1,strClone("ULTIMO"));
    listAddLast(l1,strClone("ULTIMO"));
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listAdd
    fprintf(pfile,"==> listAdd\n");
    l1 = listNew();
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listAddFirst(l1,strClone("PRIMERO"));
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddFirst(l1,strClone("PRIMERO"));
    listAddLast(l1,strClone("ULTIMO"));
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemove
    fprintf(pfile,"==> listRemove\n");
    l1 = listNew();
    listRemove(l1, strings[0], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    for(int i=0; i<5;i++) {
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
        listRemove(l1, strings[0], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    }
    listRemove(l1, strings[1], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listAddFirst(l1,strClone("PRIMERO"));
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listAddLast(l1,strClone("ULTIMO"));
    listRemove(l1, "PRIMERO", (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listRemove(l1, "ULTIMO", (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemoveFirst
    fprintf(pfile,"==> listRemoveFirst\n");
    l1 = listNew();
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listAddFirst(l1,strClone("PRIMERO"));
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listAddLast(l1,strClone("ULTIMO"));
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemoveLast
    fprintf(pfile,"==> listRemoveLast\n");
    l1 = listNew();
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listAddFirst(l1,strClone("PRIMERO"));
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listAddLast(l1,strClone("ULTIMO"));
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemove listRemoveFirst listRemoveLast
    fprintf(pfile,"==> listRemove listRemoveFirst listRemoveLast\n");
    l1 = listNew();
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listRemoveFirst(l1, 0);
    listRemoveLast(l1, 0);
    char* stringsLocal[10];
    for(int i=0; i<10;i++)
        stringsLocal[i] = strClone(strings[i]);
    for(int i=0; i<10;i++)
        listAdd(l1,stringsLocal[i],(funcCmp_t*)&strCmp);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveLast(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveFirst(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveLast(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveFirst(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveLast(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveFirst(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,0);
    for(int i=0; i<10;i++)
        free(stringsLocal[i]);
}

/** Sorter **/
void test_sorter(FILE *pfile) {
    fprintf(pfile,"===== Sorter\n");
    sorter_t* s = sorterNew(5, (funcSorter_t*)&fs_sizeModFive, (funcCmp_t*)&strCmp);
    fprintf(pfile,"==> sorterAdd\n");
    sorterAdd(s, strClone(""));
    sorterAdd(s, strClone("A"));
    sorterAdd(s, strClone("ET"));
    sorterAdd(s, strClone("Man"));
    sorterAdd(s, strClone("Iran"));
    sorterAdd(s, strClone("Iron"));
    sorterAdd(s, strClone("Irun"));
    sorterAdd(s, strClone("Laura"));
    sorterAdd(s, strClone("Nebula"));
    sorterAdd(s, strClone("Gamora"));
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    fprintf(pfile,"==> sorterRemove\n");
    sorterRemove(s, "Laura", (funcDelete_t*)&strDelete);
    sorterRemove(s, "A", (funcDelete_t*)&strDelete);
    sorterRemove(s, "Iron", (funcDelete_t*)&strDelete);
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    sorterAdd(s, strClone("Iron"));
    fprintf(pfile,"==> sorterGetSlot\n");
    for(int i=0;i<5;i++) {
        list_t* a = sorterGetSlot(s, i, (funcDup_t*)&strClone);
        listPrint(a, pfile, (funcPrint_t*)&strPrint); fprintf(pfile,"\n");
        listDelete(a, (funcDelete_t*)&strDelete);
    }
    fprintf(pfile,"==> sorterGetSlot\n");
    for(int i=0;i<5;i++) {
        char* a = sorterGetConcatSlot(s,i);
        char* b = sorterGetConcatSlot(s,i);
        strPrint(a, pfile); fprintf(pfile," - ");
        strPrint(b, pfile); fprintf(pfile,"\n");
        strDelete(a);
        strDelete(b);
    }
    fprintf(pfile,"==> sorterCleanSlot\n");
    for(int i=0;i<5;i++) {
        sorterCleanSlot(s, i, (funcDelete_t*)&strDelete);
        sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    }
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    fprintf(pfile,"==> sorterDelete\n");
    sorterDelete(s, (funcDelete_t*)&strDelete);
    fprintf(pfile,"==> sorter fs_sizeModFive\n");
    s = sorterNew(5, (funcSorter_t*)&fs_sizeModFive, (funcCmp_t*)&strCmp);
    char* a = strClone("");
    for(int i=0; i<100; i++) {
        sorterAdd(s, a);
        a = strConcat(strClone(a), strClone("-"));
    }
    sorterAdd(s, a);
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    sorterDelete(s, (funcDelete_t*)&strDelete);
    fprintf(pfile,"==> sorter fs_firstChar\n");
    s = sorterNew(256, (funcSorter_t*)&fs_firstChar, (funcCmp_t*)&strCmp);
    char aa[3] = {'a','a',0};
    for(int i=0; i<26; i++) {
        for(int j=0; j<26; j++) {
            aa[0] = 'a'+i;
            aa[1] = 'a'+j;
            sorterAdd(s, strClone(aa));
        }
    }
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    sorterDelete(s, (funcDelete_t*)&strDelete);
    s = sorterNew(256, (funcSorter_t*)&fs_firstChar, (funcCmp_t*)&strCmp);
    char xx[3] = {0,0,0};
    for(int i=0; i<256; i++) {
        for(int j=0; j<10; j++) {
            xx[0] = (uint8_t)i;
            xx[1] = (uint8_t)j;
            sorterAdd(s, strClone(xx));
        }
    }
    sorterPrint(s, pfile, (funcPrint_t*)&hexPrint);
    sorterDelete(s, (funcDelete_t*)&strDelete);
    fprintf(pfile,"==> sorter fs_bitSplit\n");
    s = sorterNew(10, (funcSorter_t*)&fs_bitSplit, (funcCmp_t*)&strCmp);
    char sx[3] = {0,0,0};
    for(int i=0; i<256; i++) {
        for(int j=0; j<10; j++) {
            sx[0] = (uint8_t)i;
            sx[1] = (uint8_t)j;
            sorterAdd(s, strClone(sx));
        }
    }
    sorterPrint(s, pfile, (funcPrint_t*)&hexPrint);
    sorterDelete(s, (funcDelete_t*)&strDelete);
}

void test_1(char* filename){
    FILE *pfile;
    RUN(filename,test_strings(pfile););
    RUN(filename,test_list(pfile););
    RUN(filename,test_sorter(pfile););
}

void test_2(char* filename){
    FILE *pfile;
    // 1
    sorter_t* s = sorterNew(5, (funcSorter_t*)&fs_sizeModFive, (funcCmp_t*)&strCmp);
    for(int i=0; i<15; i++) {
        for(int j=0; j<30; j++) {
            for(int l=0; l<10; l++) {
                sorterAdd(s, randomString(l));
            }
        }
        for(int i=0; i<5; i++) {
            char* concat = sorterGetConcatSlot(s,i);
            RUN(filename,strPrint(concat, pfile););NL(filename)
            free(concat);
            
        }
        sorterRemove(s, "a", (funcDelete_t*)&strDelete);
        sorterCleanSlot(s, (17*i)%5, (funcDelete_t*)&strDelete);
        RUN(filename,sorterPrint(s, pfile, (funcPrint_t*)&strPrint););NL(filename)
    }
    sorterDelete(s, (funcDelete_t*)&strDelete);
    // 2
    s = sorterNew(256, (funcSorter_t*)&fs_firstChar, (funcCmp_t*)&strCmp);
    for(int i=0; i<15; i++) {
        for(int j=0; j<30; j++) {
            for(int l=0; l<10; l++) {
                sorterAdd(s, randomHexString(l));
            }
        }
        for(int i=0; i<256; i++) {
            char* concat = sorterGetConcatSlot(s,i);
            RUN(filename,hexPrint(concat, pfile););NL(filename)
            free(concat);
        }
        sorterRemove(s, "a", (funcDelete_t*)&strDelete);
        sorterCleanSlot(s, (17*i)%256, (funcDelete_t*)&strDelete);
        RUN(filename,sorterPrint(s, pfile, (funcPrint_t*)&hexPrint););NL(filename)
    }
    sorterDelete(s, (funcDelete_t*)&strDelete);
    // 3
    s = sorterNew(10, (funcSorter_t*)&fs_bitSplit, (funcCmp_t*)&strCmp);
    for(int i=0; i<15; i++) {
        for(int j=0; j<30; j++) {
            for(int l=0; l<10; l++) {
                sorterAdd(s, randomHexString(l));
            }
        }
        for(int i=0; i<10; i++) {
            char* concat = sorterGetConcatSlot(s,i);
            RUN(filename,hexPrint(concat, pfile););NL(filename)
            free(concat);
        }
        sorterRemove(s, "a", (funcDelete_t*)&strDelete);
        sorterCleanSlot(s, (17*i)%10, (funcDelete_t*)&strDelete);
        RUN(filename,sorterPrint(s, pfile, (funcPrint_t*)&hexPrint););NL(filename)
    }
    sorterDelete(s, (funcDelete_t*)&strDelete);
}