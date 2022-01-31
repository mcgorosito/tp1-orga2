#include "lib.h"

/** STRING **/

void hexPrint(char* a, FILE *pFile) {
    int i = 0;
    while (a[i] != 0) {
        fprintf(pFile, "%02hhx", a[i]);
        i++;
    }
    fprintf(pFile, "00");
}

/** Lista **/

void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd) {
	// Lista vacía
	if (l->first == NULL) {
		return;
	}
	// Único elemento de la lista
	if (l->first == l->last) {
		if (fc(data, l->first->data) == 0) {
			fd(l->first->data);
			free(l->first);
			l->first = NULL;
			l->last = NULL;
		}
		return;
	}
	struct s_listElem* actual = l->first;
	while (actual != NULL) {
		if (fc(data, actual->data) == 0) {
			if (actual->prev == NULL) {				//Primer elemento de la lista
				struct s_listElem* siguiente = actual->next;
				l->first = actual->next;
				actual->next->prev = NULL;
				if (fd != 0) {
					fd(actual->data);
				}
				free(actual);
				actual = siguiente;
			} else if (actual->next == NULL) {		//Último elemento de la lista
				l->last = actual->prev;
				actual->prev->next = NULL;
				if (fd != 0) {
					fd(actual->data);
				}
				free(actual);
				actual = NULL;
			} else {								//Elemento del medio de la lista
				struct s_listElem* siguiente = actual->next;
				actual->prev->next = actual->next;
				actual->next->prev = actual->prev;
				if (fd != 0) {
					fd(actual->data);
				}
				free(actual);
				actual = siguiente;
			}
		} else {
			actual = actual->next;
		}
	}
}


void listRemoveFirst(list_t* l, funcDelete_t* fd){
	if(l->first != NULL) {
		struct s_listElem* primerElem = l->first;
		if(primerElem->next != NULL) {
			l->first = l->first->next;
			l->first->prev = NULL;
		}
		if(fd != NULL){
			fd(primerElem->data);
		}
		free(primerElem);
	}
}


void listRemoveLast(list_t* l, funcDelete_t* fd){
	if(l->first != NULL) {
		struct s_listElem* ultimoElem = l->last;
		void *dato = l->last->data;
		if(ultimoElem->prev != NULL) {
			l->last = l->last->prev;
			l->last->next = NULL;
		}
		if(fd != NULL) {
			fd(dato);
		}
		free(ultimoElem);
	}
}