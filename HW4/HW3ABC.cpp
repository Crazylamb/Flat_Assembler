﻿#include <iostream>
#include<vector>
#include<thread>
#include<mutex>
#include<string>
#include<ctime>
using namespace std;

//Создание матрицы рандомом с остатком деления на 10
double** createMatrix(int N) {
	double** Matrix = new double* [N];
	for (size_t i = 0; i < N; i++)
	{
		Matrix[i] = new double[N];
	}
	for (size_t i = 0; i < N; i++)
	{
		for (size_t j = 0; j < N; j++)
		{
			Matrix[i][j] = rand() % 10;
			cout << Matrix[i][j] << "\t";
		}
		cout << endl;
	}
	return Matrix;
}


void substract_el(int iThread, int thrNum, int N, double* A[], int j, int i, double EPS) {
    for (int k = iThread; k < N; k += thrNum) //Для каждого потока будет свой цикл
        if (k != j && A[k][i] != EPS) //Если это не j-ая строка и ведущий элемент ненулевой
            for (int p = i + 1; p < N; ++p) // отнимаем j-ую строку от остальных
                A[k][p] -= A[j][p] * A[k][i];
}

void rang_mat(int thrNum, vector<bool> line_used, double* A[], int N, int &rank)

{
    const double EPS = 0;
    int rang = N;
    for (int i = 0; i < N; ++i) {
        int j;
        for (j = 0; j < N; ++j) {
            if (!line_used[j] && A[j][i] != EPS) { //Проверка что текущая строка матрицы не использована и что элемент больше 0
                break;
            }
        }
        if (j == N)
            --rang;
        else{
            line_used[j] = true; //запонимнаем выбранную строку
            for (int p = i + 1; p < N; ++p)
                A[j][p] /= A[j][i]; //Делим все элементы строки на первый ненулевой элемент
            thread* thr = new thread[thrNum]; //разбиваем на потоки
            for (size_t k = 0; k < thrNum; ++k)
            {
                thr[k] = thread{ substract_el, k, thrNum, N, ref(A), j , i, EPS };
            }
            for (size_t k = 0; k < thrNum; ++k)
            {
                thr[k].join();
            }
            delete[] thr;
        }
    }
    rank = rang;
}


int main()
{
    //Делаем, чтобы при разных тестах были разные значения рандома
    srand(time(NULL));
	int N;
    do {
        cout << "Please enter the amount of rows and columns: " << endl;
        cin >> N;
    } while (N < 0);
	double** Matrix = createMatrix(N); //Создаем матрицу
	int threadNumber;
    do {
        cout << "Please enter the amount of threads" << endl;
        cin >> threadNumber; //Узнаем число потоков
    } while (threadNumber <= 0);
    thread* thr = new thread[threadNumber];
    vector<int> rang = vector<int>(threadNumber);
    vector<bool> line_used(N);
    int rank = N;
    rang_mat(threadNumber, ref(line_used), Matrix, N, ref(rank)); //Считаем ранг
    cout << "Rank: " << rank;
	for (size_t i = 0; i < N; i++)
	{
		delete[] Matrix[i];
	}
	delete[] Matrix; //Удаление матрицы из памяти
}