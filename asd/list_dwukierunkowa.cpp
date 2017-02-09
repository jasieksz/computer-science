#include <iostream>
#include <cmath>
#include <algorithm>
#include <cstdio>


using namespace std;

struct Node{
    int v;
    Node *next;
    Node *prev;
};

struct DList{
    Node *head;
    Node *tail;
    int counter;
};

void DLInit(DList &L)
{
  L.head=L.tail=NULL;
  L.counter = 0;
}

void PushFront(DList &L, int x)
{
    Node *n = new Node;
    n->v = x;
    n->next = L.head;
    n->prev = NULL;
    L.head = n;
    if (n->next != NULL)
        n->next->prev = n;
    else
        L.tail = n;
    L.counter++;
}

void PushBack(DList &L, int x)
{
    Node *n = new Node;
    n->v = x;
    n->next = NULL;
    n->prev = L.tail;
    L.tail = n;
    if (n->prev != NULL)
        n->prev->next = n;
    else
        L.head = n;
    L.counter++;
}

void PushBefore(DList &L, Node *elem, int x)
{
    if (elem == L.head)
        PushFront(L,x);
    else
    {
        Node *n = new Node;
        n->v = x;
        n->next = elem;
        n->prev = elem->prev;
        elem->prev->next = n;
        elem->prev = n;
        L.counter++;
    }
}

void PushAfter(DList &L, Node *elem, int x)
{
    if (elem == L.tail)
        PushBack(L,x);
    else
    {
        Node *n = new Node;
        n->v = x;
        n->next = elem->next;
        n->prev = elem;
        elem->next->prev = n;
        elem->next = n;
        L.counter++;
    }
}

void PopElement(DList &L, Node *elem)
{
    L.counter--;

    if (elem->prev != NULL)
        elem->prev->next = elem->next;
    else
        L.head = elem->next;

    if (elem->next != NULL)
        elem->next->prev = elem->prev;
    else
        L.tail = elem->prev;

    delete elem;
}

void PopFront(DList &L)
{
    if (L.counter != 0)
        PopElement(L,L.head);
}

void PopBack(DList &L)
{
    if (L.counter != 0)
        PopElement(L,L.tail);
}

void CreateList(DList &L, int s)
{
    while(s--)
    {
        int x;
        scanf("%d", &x);
        PushBack(L,x);
    }
}

void PrintList(DList L)
{
    Node *n = L.head;
    printf("Lista %d elementowa : ", L.counter);
    while (n != NULL)
    {
        printf("%d ", n->v);
        n = n->next;
    }
    printf("\n");
}

void ReverseList(DList &L)
{

}

int main()
{
    DList Lista;
    DLInit(Lista);

    CreateList(Lista,4);
    PushBack(Lista,5);
    PopFront(Lista);
    PrintList(Lista);


return 0;
}
