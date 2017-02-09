#include <cstdio>
#include <algorithm>

using namespace std;

//-----------------------BINsearch-----------------------------
int LowerBound(int T[],int n,int x)//tablica rozmiar wartosc
{
    int p, k, s;
    p=0; k=n-1;
    while (p<k)
    {
        s=(p+k)/2;
        if (A[s]<x)
            p=s+1;
        else
            k=s;
    }
    if (A[p]==x)
       lb=p;
    else
        lb=0;
return lb;
}

int UpperBound(int T[], int n, int x)
{
    int pu, ku, su;
    pu=0; ku=n-1;
    while (pu<ku)
    {
        su=(pu+ku+1)/2;
        if (A[su]<=x)
            pu=su;
        else
            ku=su-1;
    }

    if (A[pu]==x)
        ub=pu;

    else
        ub=(-1);
return ub;
}
/*
//----------------------MeRgE SORT---------------------------------------
void merge(table t,int lo, int m, int hi){
   int i=0,j=lo,k;
   cout << lo << " " << m << " " << hi << endl;
   int* b=new int[m-lo+1];
   while(j<=m) b[i++]=t[j++];	// przepisywanie

   i=0; k=lo;
   while(k<j && j<=hi)			// scalanie
      if(b[i]<=t[j]) t[k++]=b[i++];
      else t[k++]=t[j++];
   while(k<j) t[k++]=b[i++];	// przepisywanie reszty jesli trzeba
	delete [] b;
}

void merge_sort(table t,int lo,int hi)
{
    if(lo<hi)
    {
		int m=(lo+hi)/2;
		merge_sort(t,lo,m);
		merge_sort(t,m+1,hi);
		merge(t,lo,m,hi);
	}
}
*/
////////////////////////////////////////////////////////////
void Merge(int p,int q,int r)
{
int i=p, j=q, k=p;  //i->pierwsza polowka, j->druga polowka

    while(k<r)
    {
        if(j>= r || (i<q && A[i]>=A[j])) // >= sortuje malejaca || < sortuje rosnaco
        {
            B[k]=A[i]; k++; i++;
        }
        else
        {
            B[k]=A[j]; k++; j++;
            licznik=licznik+(q-i);
        }

    }
    for(int ii=p;ii<r;ii++)
        {A[ii]=B[ii];}
}

//Sortowanie pocz, koniec
void MergeSort(int p,int k)
{
 if(p==k)
    {return;}
 int sr=(p+k)/2;
 MergeSort(p,sr);
 MergeSort(sr+1,k);
 Merge(p,sr+1,k+1);
}


//--------------------QuickSORT----------------------------------
void QSort(int T[],int lt,int rt) //[0,n-1]
{
    int md,pi,wsk;
    md=(lt+rt)/2; pi=T[md]; T[md]=T[rt]; //piwot na srodku
    for (md=wsk=lt;md<rt;md++)
    {
        if (T[md]<pi)
        {
            swap(T[md],T[wsk]);
            wsk++;
        }
    }
    printf("WYPISZ TABLICE : ");
    for (int i=0;i<6;i++)
        printf("%i ",T[i]);
    printf("\n");

    T[rt]=T[wsk]; T[wsk]=pi;
    if (lt<wsk-1) QSort(T,lt,wsk-1);
    if (rt>wsk+1) QSort(T,wsk+1,rt);
}

int main()
{
    int TAB[6]={5,7,3,2,8,11};
    QSort(TAB,0,5);
    for (int i=0;i<6;i++)
        printf("%i ",TAB[i]);

return 0;
}
