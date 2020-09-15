
#include <stdlib.h> 
#include "declarations.h"
#include <stdio.h>

/* Free memory in the cluster lists
* param `size_t k`: The number of clusters
* param `struct node *PTR_CLUSTER_HEADS[k]`: The array of pointers to 
*     cluster HEADS
*/
void free_cluster_list(size_t k, struct node *PTR_CLUSTER_HEADS[k]) {
        struct node *ptr;
        struct node *prev; // using temp pointer for freeing
        for (size_t i = 0; i < k; i++) {
                ptr = PTR_CLUSTER_HEADS[i];
                while (ptr->next != NULL)
                {  
                        prev = ptr;
                        ptr = ptr->next;
                        free(prev);
                }
                free(ptr);
        }
        
}

/* Free index array for categories */
void free_category_indices(size_t c, size_t *CATEGORY_HEADS[c]) {
    for (size_t i = 0; i < c; i++) {
        free(CATEGORY_HEADS[i]);
    }
}

void free_distances(size_t n, double *DISTANCES[n]) {
        for (size_t i = 0; i < n; i++) {
            free(DISTANCES[i]);
        }
}

/* Free memory in the data points
 * param `size_t n`: length of array `POINTS`
 * param `struct element POINTS[n]`: Array containing data points
 * param `size_t i`: The index up to which data points are freed
 */
void free_points(size_t n, struct element POINTS[n], size_t i) {
        for (size_t j = 0; j < i; j++) {
                free(POINTS[j].values);
        }
}
