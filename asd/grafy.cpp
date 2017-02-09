//DWUKOLOROWANIE GRAFU z macierz¹ s¹siedztwa
bool isBipartite(int G[][V], int src)
{
    int colorArr[V];
    for (int i = 0; i < V; ++i)
        colorArr[i] = -1;

    colorArr[src] = 1;
    queue <int> q;
    q.push(src);
    while (!q.empty())
    {
        int u = q.front();
        q.pop();
        for (int v = 0; v < V; ++v)
        {
            if (G[u][v] && colorArr[v] == -1)
            {
                colorArr[v] = 1 - colorArr[u];
                q.push(v);
            }
            else if (G[u][v] && colorArr[v] == colorArr[u])
                return false;
        }
    }
return true;
}

// SPOJNA SKALDOWA
  int cn=0;
  for(i = 0; i < n; i++)
    if(!C[i])                // Szukamy nieodwiedzonego jeszcze wierzcho³ka
    {
      cn++;                  // Zwiêkszamy licznik sk³adowych
      S.push(i);             // Na stosie umieszczamy numer bie¿¹cego wierzcho³ka
      C[i] = cn;             // i oznaczamy go jako odwiedzonego i ponumerowanego
      while(!S.empty())      // Przechodzimy graf algorytmem DFS
      {
        v = S.top();         // Pobieramy wierzcho³ek
        S.pop();             // Usuwamy go ze stosu

        // Przegl¹damy s¹siadów wierzcho³ka v

        for(p = A[v]; p; p = p->next)
        {
          u = p->v;          // Numer s¹siada do u
          if(!C[u])
          {
            S.push(u);       // Na stos id¹ s¹siedzi nieodwiedzeni
            C[u] = cn;       // i ponumerowani
          }
        }
      }
    }


==================== BELLMAN FORD ===============================================================================================
void BF(int s)
{
      ODL[s]=0;
//LICZ
      for (int i=0;i<v-1;i++)
      {
              for (int j=1;j<=v;j++)
              {
                      for (int q=0;q<G[j].size();q++)
                      {
                              if (ODL[j]!=INF)
                              {
                                      element x=G[j][q];
                                      if ((ODL[j]+x.waga)<ODL[x.cel])
                                      	ODL[x.cel]=ODL[j]+x.waga;
                              }
                      }
              }
      }
//SPRAWDZ
      for (int t=1;t<=v;t++)
      {
              for (int r=0;r<G[t].size();r++)
              {
                      if (ODL[t]!=INF)
                      {
                             element u=G[t][r];
                              if (ODL[t]+u.waga<ODL[u.cel])
                              {
                                      cykl=1;
                              }
                      }
              }
      }
}
=================================== DIJ LISTA SASIEDZTWA + KOLEJKA ========================================================
bool ZATW[MAXN];
int ODL[MAXN];
priority_queue<element> Q;
vector <element> G[50005]; //struct element -> int cel, int waga
void DIJ()
{
      while (!Q.empty())
      {
              element x=Q.top(); Q.pop();
              ZATW[x.cel]=1;
              for (int i=0;i<G[x.cel].size();i++)
              {
                      element y=G[x.cel][i];
                      if (ZATW[y.cel]==0)
                      {
                              if ((ODL[x.cel]+y.waga)<ODL[y.cel])
                              {
                                      ODL[y.cel]=ODL[x.cel]+y.waga;
                              //      y.waga=ODL[y.cel];
                              element k;
                              k.cel=y.cel;
                              k.waga=ODL[y.cel];
                              Q.push(k);
                              }

                      }
              }
      }
}

===================================== KRUSKAL =============================================================
int find(int x)
{
      if(P[x]!=x)
        P[x] = find(P[x]);
      return P[x];
}

void unia(int x, int y)
{
      int a = find(x);
      int b = find(y);
      if(R[a]<R[b])
        P[a]=b;
    else if (R[a]>R[b])
        P[b]=a;
    else if (R[a]==R[b])
    {
        P[a]=b; R[b]++;
    }
}

void kruskal()
{
    while (!Q.empty())
    {
        element x=Q.top(); Q.pop();
        if (find(x.w1)!=find(x.w2))
            koszt+=x.waga;
        unia(x.w1,x.w2);
    }
}
