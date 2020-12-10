#include <iostream>
//Без этого pthread не заработал
#define HAVE_STRUCT_TIMESPEC
#include <pthread.h>
#include <semaphore.h>
#include <windows.h>
#include <chrono>
#include <string>
#include <vector>

//Без этого pthread не заработал
#pragma comment(lib,"pthreadVC2.lib")    

using namespace std;

int foodLeft;
int cannibalNumber;
int foodNumber;
sem_t semaphore;
pthread_mutex_t allowEat;

/*
Метод для того, чтобы каннибалы ели
*/
void* Cannibal(void* eater)
{
	//Начало и конец по времени
	auto start = chrono::system_clock::now();
	auto end = std::chrono::system_clock::now();
	//Номер каннибала
	int num = *((int*)eater);
	srand(time(0) + num);
	//Трапеза продолжается 10 секунд
	while ((std::chrono::duration_cast<std::chrono::seconds>(end - start).count() <= 10)) {
		//Уменьшаем значение семафора
		sem_wait(&semaphore);
		pthread_mutex_lock(&allowEat);
		if (foodLeft > 0)
		{
			//Блокируем вывод, чтобы текст не бегал
			cout << "Cannibal " << num << " is eating!";
			foodLeft--;
			cout << "Food left: " << foodLeft << endl;
			//Разблокируем обратно
		}
		pthread_mutex_unlock(&allowEat);
		//Семафор прибавляется
		sem_post(&semaphore);
		//Каннибал засыпает на рандомное время
		int delay = 1000 + (rand() % 10) * 100;
		Sleep(delay);
		end = std::chrono::system_clock::now();
	}
	return NULL;
}

//Метод в котором шеф готовит еду
void* Chief(void* args)
{
	//Шеф работает столько же сколько и едят каннибалы
	auto start = chrono::system_clock::now();
	auto end = std::chrono::system_clock::now();
	int meatAmount = *((int*)args);
	while ((std::chrono::duration_cast<std::chrono::seconds>(end - start).count() <= 10)) {
		//Проходим по семафору и ждем пока еды не останется
		if (foodLeft == 0)
		{
			pthread_mutex_lock(&allowEat);
			//Заполняем еду
			foodLeft = meatAmount;
			cout << "Food cooked!" << endl;
			pthread_mutex_unlock(&allowEat);
		}
		Sleep(1000);
		end = std::chrono::system_clock::now();
	}
	return NULL;
}

int main(int argc, char* argv[])
{
	//Проверка входных аргументов
	if (argc != 3)
	{
		cout << "Incorrect amount of parametrs, please enter amount of cannibals and food amount" << endl;
		return -1;
	}
	try {
		foodNumber = stoi(argv[1]);
		if (foodNumber <= 0) { foodNumber = 1; }
		foodLeft = foodNumber;
		cannibalNumber = stoi(argv[2]);
		if (cannibalNumber <= 0) { cannibalNumber = 1; }
	}
	catch (exception e) {
		cout << "Incorrect data";
		return -1;
	}
	//Инициализация мутексов и семафоров
	sem_init(&semaphore, 0, foodNumber);
	pthread_mutex_init(&allowEat, nullptr);
	int* arr = new int[cannibalNumber];
	vector<pthread_t> cannibals(cannibalNumber);
	pthread_t chief;
	//Создаем поток шефа
	pthread_create(&chief, NULL, Chief, &foodNumber);
	//Создаем каннибалов
	for (int t = 0; t < cannibalNumber; t++)
	{
		arr[t] = t;
		int rc = pthread_create(&cannibals[t], NULL, Cannibal, &arr[t]);
		if (rc)
		{
			printf("ERROR:return code from pthread_create() is %d\n", rc);
			exit(-1);
		}
	}
	//После завершения работы соединяем все потоки
	for (int t = 0; t < cannibalNumber; t++)
	{
		pthread_join(cannibals[t], NULL);
	}
	delete[] arr;
	pthread_join(chief, NULL);
	sem_destroy(&semaphore);
	pthread_exit(NULL);
}

