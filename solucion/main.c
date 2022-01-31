#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_lista(FILE *pfile){
    //Crear una lista vacı́a.
    list_t* southParkTop10;
    southParkTop10 = listNew();
    //Agregar exactamente 10 strings cualquiera.
    listAdd(southParkTop10, strClone("Cartman"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Randy"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Stan"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Kenny"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Kyle"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Butters"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Towelie"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Mr. Garrison"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("City Wok Guy"), (funcCmp_t*)&strCmp);
    listAdd(southParkTop10, strClone("Mr. Mackey"), (funcCmp_t*)&strCmp);
    //Imprimir la lista.
    listPrint(southParkTop10, pfile, (funcPrint_t*)&strPrint);
    fprintf(pfile,"\n");
    //Borrar la lista.
    listDelete(southParkTop10,(funcDelete_t*)&strDelete);
}

void test_sorter(FILE *pfile){
	//Crear un sorter vacı́o utilizando la función fs_sizeModFive(char* s).
    sorter_t* s = sorterNew(5, (funcSorter_t*)&fs_sizeModFive, (funcCmp_t*)&strCmp);
    //Agregar un string en todos los slots.
    sorterAdd(s, strClone("Screw"));
    sorterAdd(s, strClone("you"));
    sorterAdd(s, strClone("guys"));
    sorterAdd(s, strClone("I"));
    sorterAdd(s, strClone("'m"));
    sorterAdd(s, strClone("going"));
    sorterAdd(s, strClone("home"));
    sorterAdd(s, strClone("."));
    sorterAdd(s, strClone(""));
    //Imprimir el sorter.
    sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    fprintf(pfile,"\n");
    sorterDelete(s, (funcDelete_t*)&strDelete);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_lista(pfile);
    test_sorter(pfile);
    fclose(pfile);
    return 0;
}


