#include <vector>
#include <iostream>
#include <algorithm>
#include <cmath>
#include <queue>
#include <stack>

using namespace std;

void Kombinacje(vector<int> T,bool B[],int start,int wsk,int k) //Kombinacje(T,B,0,0,2)
{
    if (wsk == k)
    {
        for(int i=0;i<T.size();i++)
        {
            if (B[i])
                cout << T[i]<<" ";
        }
        cout << endl;
        return;
    }
    if (start==T.size())
        return;
    B[start]=true;
    Kombinacje(T,B,start+1,wsk+1,k);
    B[start]=false;
    Kombinacje(T,B,start+1,wsk,k);
}

void Permutacje(string s, int wsk) // Permutacje("kot",0);
{
    if (wsk==s.size()-1)
    {
        cout << s<<endl;
        return;
    }
    Permutacje(s,wsk+1);
    for (int i=wsk+1;i<s.size();i++)
    {
        swap(s[wsk],s[i]);
        Permutacje(s,wsk+1);
    }
}
//SORTOWANIE
void QSort(int l,int r,int T[]) // INDEKS TABLICY 0->N-1
{
    int m,p,wsk;
    m=(l+r)/2; p=T[m]; T[m]=T[r];
    for (m=wsk=l;m<r;m++)
    {
        if (T[m]<p)
        {
            swap(T[m],T[wsk]);
            wsk++;
        }
    }
    T[r]=T[wsk]; T[wsk]=p;
    if (l<wsk-1) {QSort(l,wsk-1,T);}
    if (r>wsk+1) {QSort(wsk+1,r,T);}

}
//ZAMIANA LICZBY DZIESIETNEJ NA DOWOLNY SYSTEM LICZBOWY
void DecToAny(int x,int p)
{
    stack<int> w;
    while (x!=0)
    {
        w.push(x%p);
        x = x/p;
    }
    while (!w.empty())
    {
        cout << w.top()<< " ";
        w.pop();
    }
}

int BinToDec (string b)
{
    int decimal=0;
    for (int i=0;i<b.size();i++)
    {
        if (b[i]=='1')
            decimal=decimal*2+1;
        else
            decimal=decimal*2;
    }
    return decimal;
}

void GenerujPierwsze(bool T[],int r)
{
    for (int i=2;i<=r;i++)
    {
        for (int j=i*i;j<=r;j+=i)
        {
            T[j]=false;
        }
    }
    for (int i=0;i<=r;i++)
        if(T[i])
            cout << i << " ";
}

int NWD(int a,int b)
{
    int c;
    while (b!=0)
    {
        c=a%b;
        a=b;
        b=c;
    }
return a;
}
//PALINDROM W DOWOLNYM SYSTEMIE LCIZBOWYM
bool Palindrom(int a,int b) // liczba , baza systemu
{
    int rev=0;
    int p=a;
    while (p!=0)
    {
        rev = rev*b + p%b;
        p = p/b;
    }
    cout << a << " " << rev<<endl;
    if (a==rev)
        return true;
return false;
}
//ROZKLAD LICZBY NA SUME SKLADNIKOW
void sum(int n, int T[], int pos) // sum(n,T,0);
{
   if (n == 0) // gdy rozlozylismy liczbe na podzial
   {
      for (int i = 0; i<pos; i++)  //wypisujemy podzia³
      {
         cout << T[i] << " ";
      }

      cout << endl;
   }
   else
   {
      int start;
      if (pos == 0) start = 1;            // trzeba odejmowaæ tylko liczby wiêksze od poprzedniego sk³adnika jeœli go nie ma zaczyna od 1
      else start = T[pos - 1];
      for (int i = start; i <= n; i++)
      {
         T[pos] = i; // Zapisujemy sk³adnik do tablicy
         sum(n - i, T, pos + 1); // rozkladamy liczbe pomniejszon¹ o i, i zaczynamy od nast komorki
      }
   }
}

void Faktoryzacja(int n)
{
    int pierwiastek=sqrt(n);
    int i=3;
    cout << n << " = ";
    while (n%2==0)
    {
        cout << "2  ";
        n=n/2;
    }
    while (n!=1 && i<=pierwiastek)
    {
        if(n%i==0)
        {
            cout << i <<"  ";
            n=n/i;
        }
        else
            i+=2;
    }
    if (i>pierwiastek && n!=1)
        cout << n;
    cout << endl;
}

void zamien(int *x,int *y) // SWAP
{
    int c=0;
    c=*x;
    *x=*y;
    *y=c;
}

bool CzyPierwsza(int x)
{
    int p;
    p=sqrt(x);
    if (x==2)
        return true;
    if (x%2==0)
        return false;
    for (int i=3;i<=p;i+=2)
    {
        if (x%i==0)
            return false;
    }
return true;
}

void Fibbonaci(int n) // wypisuje n liczb fibbonaciego
{
    int f1,f2,f3;
    f1=0; f2=1;
    while (n--)
    {
        f3=f2+f1;
        cout << f3 << endl;
        f1=f2;
        f2=f3;
    }
}
//Najmniejsza potega 2 wieksza od x
int PotegaDwojki(int x)
{
    int wynik=2;
    while (wynik<x)
        wynik*=2;
return wynik;
}

long long SzybkiePotegowanie(long long a, long long b)
{
    if (b==0)
        return 1;
    if (b%2==0)
    {
        long long w=SzybkiePotegowanie(a,b/2);
        return w*w;
    }
    else
    {
        long long w=SzybkiePotegowanie(a,(b-1)/2);
        return a*w*2;
    }
}

int main()
{
return 0;
}
