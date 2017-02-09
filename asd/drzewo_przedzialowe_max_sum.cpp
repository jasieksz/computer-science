#include <iostream>
#include <algorithm>
int const N=10000000;

using namespace std;

int TAB[N];

int PotegaDwa(int x)
{
    int i=2;
    while (x>i)
        i*=2;
return i;
}

void ZerujTab(int T[], int n)
{
    for (int i=0;i<n;i++)
        T[i]=0;
}
//--------------------------------------------MAX----------------------------------------------------\\

void MakeTreeMax(int T[],int n)
{
    int r = PotegaDwa(n);
    T[0]=0;
//WCZYTAJ
    for (int i=r;i<r+n;i++)
        cin >> T[i];
    for (int i=r+n;i<2*r;i++)
        T[i]=-1000; // ELEMENT NEUTRALNY
//SUMA
    for (int i=2*r-1;i>1;i=i-2)
        T[i/2] = max(T[i],T[i-1]);
//WYPISZ
    cout << "TABLICA drzewa: ";
    for (int i=0;i<2*r;i++)
        cout << T[i] << " ";
    cout << endl;

}

void FixTreeMax(int T[],int ind)
{
      if (ind<1)
              return;
      TAB[ind]=max(TAB[2*ind], TAB[2*ind+1]);
      FixTreeMax(T,ind/2);
}

void UpdateElementMax(int T[],int sz,int ind, int val)//tablica, rozmiar (uzupelniony zerami), indeks [1;n], wartosc
{
    ind=sz+ind-1;
    T[ind]=val;
    FixTreeMax(T,ind/2);
}

int MaxInterval(int p, int q, int T[], int sz) //[p,q] tablica, rozmiar (uzupelniony -INF)
{
    p = p+sz-1;
    q = q+sz-1;
    int w=-100; //element neurtalny
    while(p<=q)
    {
        if(p%2==1)
        {
            w=max(w, TAB[p]);
            p++;
        }
        if(q%2==0)
        {
            w=max(w, TAB[q]);
            q--;
        }
        p=p/2;
        q=q/2;
    }
return w;
}

//---------------------------------SUMA----------------------------------------\\

void MakeTreeSum(int T[],int n) //IND 0 nie uzywany .... ELEMENTY WLASCIWE NA INDEKSACH [r;r+n-1]
{
    int r = PotegaDwa(n);
    //int T[2*r+1]; T[0]=0;
    T[0]=0;
//WCZYTAJ
    for (int i=r;i<r+n;i++)
        cin >> T[i];
    for (int i=r+n;i<2*r;i++)
        T[i]=0; // ELEMENT NEUTRALNY
//SUMA
    for (int i=2*r-1;i>1;i=i-2)
        T[i/2] = (T[i]+T[i-1]);
//WYPISZ
    cout << "TABLICA drzewa2: ";
    for (int i=0;i<2*r;i++)
        cout << T[i] << " ";
    cout << endl;

}

void FixTreeSum(int T[],int ind) //O(log n)
{
      if (ind<1)
              return;
      TAB[ind] = (TAB[2*ind] + TAB[2*ind+1]);
      FixTreeSum(T,ind/2);
}

void UpdateElementSum(int T[],int sz,int ind, int val)//tablica, rozmiar (uzupelniony zerami), indeks [1;n], wartosc
{
    ind=sz+ind-1;
    T[ind]=val;
    FixTreeSum(T,ind/2);
}

int SumInterval(int a, int b, int T[],int sz)
{
    a = a+sz-1; b = b+sz-1;
    //graniczne liscie
    int wynik = T[a];
    if (a!=b)
        wynik+=T[b];

   // Spacer a¿ do momentu spotkania.
    while (a/2 != b/2)
    {
        if (a%2==0) wynik+=T[a+1]; // prawa bombka na lewej œcie¿ce
        if (b%2==1) wynik+=T[b-1]; // lewa bombka na prawej œcie¿ce
        a/=2; b/=2;
    }
return wynik;
}

int SumIntervalRec(int p, int q, int TAB[], int w)
{
    p+=7; q+=7;
    int ps = 0; int ls=0;
    if(p==q)
        return TAB[w];
    else
    {
        int sr=(p+q)/2;
        if(p<=sr)
            ps=SumIntervalRec(p,min(sr,q),TAB,2*w);
        if(q > sr)
            ls=SumIntervalRec(max(p,sr + 1),q,TAB,2*w+1);
        return ps + ls;
    }
}
//---------------------------------MAIN------------------------------\\

int main()
{

    cout << "Podaj rozmiar i tablice sum"<<endl;
    int n1; cin >> n1;
    MakeTreeSum(TAB,n1);
    int p1 = PotegaDwa(n1);
    cout <<"Metoda 1: "<< SumInterval(2,3,TAB,p1)<<endl;
    int w=SumIntervalRec(2,3,TAB,1);
    cout << "Metoda 2: "<< w << endl;

    ZerujTab(TAB,N);
/*
    cout << "Podaj rozmiar i tablice maks"<<endl;
    int n2; cin >> n2;
    MakeTreeMax(TAB,n2);
    int p2=PotegaDwa(n2);
    cout << MaxInterval(2,4,TAB,p2) <<endl;
*/

return 0;
}
