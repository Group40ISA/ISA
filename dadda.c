#include <stdio.h>
#define n 32 //numero bit

int main(char argc, char **argv){
int colonne[n*2]={2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,17,17,17,17,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2};
int d[8]={0,2,3,4,6,9,13,19};
int nfa=0;
int nfac=0;
int nhac=0;
int nha=0;
int max=17;
int j,cont,resto;

// /scelgo il piano da cui partire
for(j=0;j<7 && max>d[j];j++);
j=j-1;

while(d[j]!=0){
for(cont=0;cont<2*n;cont++){
    if(colonne[cont]>d[j] || d[j]==2 ){
        resto=colonne[cont]-d[j];
            while (resto>0){    
                resto=resto-1;
                nhac+=1;
                if(nhac==2){
                    nfac+=1;
                    nhac=0;
                }
            }
        colonne[cont]=d[j];
        colonne[cont+1]+=nfac;
        colonne[cont+1]+=nhac;
        nfa+=nfac;
        nha+=nhac;
        nhac=0;
        nfac=0;
    }
}
j=j-1;
}
printf("\t\t\tn di FA = %d n di HA = %d\n",nfa,nha);
return 0;

}
