﻿#language: ru

@tree

Функционал: Создание документа Заявки на отпуск

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий

Сценарий: Проверка копирования документа
И В командном интерфейсе я выбираю "HR Заявки" "Заявка на отпуск"
Тогда открылось окно "Заявка на отпуск"
И в таблице 'Список' я выбираю текущую строку
И я нажимаю на кнопку с именем 'ФормаСкопировать'
И я нажимаю на кнопку с именем 'ФормаПровестиИЗакрыть'
