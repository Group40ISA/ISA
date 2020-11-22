#include <stdio.h>
#define n 32 //numero bit

int main(char argc, char **argv){
int colonne[n*2]={2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,17,17,17,17,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2};
int stadiha[2*n]={0};
int stadifa[2*n]={0};
int max_ha=0;
int max_fa=0;
int d[8]={0,2,3,4,6,9,13,19};
int nfa=0;
int nfac=0;
int nhac=0;
int nha=0;
int max=17;
int j,cont,resto;

FILE *fd;
fd=fopen("albero.txt","w");

// /scelgo il piano da cui partire
for(j=0;j<7 && max>d[j];j++);
j=j-1;

for(int y=0;y<2*n;y++){
    if(colonne[y]-10<0){
        fprintf(fd,"%d-",colonne[y]);
    }else{
    fprintf(fd,"%d",colonne[y]);}
    }
fprintf(fd,"\n");

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
        
        stadiha[cont]=nhac;
        stadifa[cont]=nfac;
        if(cont==0){
            max_fa=nfac;
            max_ha=nhac;
        }else{
            if(nhac > stadiha[cont-1]){ max_ha=nhac;}
            if(nfac > stadifa[cont-1]){ max_fa=nfac;}
        }
        
        
        nhac=0;
        nfac=0;
    }
}
j=j-1;

    for (int y = 0; y < max_ha + max_fa ; y++)
    {   for (int z =0; z <2*n; z++)
        {   if(stadifa[z]==0){
                if(stadiha[z]==0){
                    fprintf(fd,"  ");
                 }else{
                    fprintf(fd,"HA");
                    stadiha[z]-=1;
                 }
            }else{
                 fprintf(fd,"FA");
                 stadifa[z]-=1;
            }
        }
        fprintf(fd,"\n");
    }
for(int y=0;y<2*n;y++){
    if(colonne[y]-10<0){
        fprintf(fd,"%d-",colonne[y]);
    }else{
    fprintf(fd,"%d",colonne[y]);}
    }fprintf(fd,"\n");
}
fclose(fd);
printf("\tn di FA = %d n di HA = %d\n",nfa,nha);
return 0;

}
