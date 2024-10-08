﻿// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииОбработчиковУстановкиПараметровСеанса.
Процедура УстановкаПараметровСеанса(Знач ИмяПараметра, УстановленныеПараметры) Экспорт
	
	Если ИмяПараметра <> "ТекущийПользователь"
	   И ИмяПараметра <> "АвторизованныйПользователь" Тогда
		
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Попытка
		Значения = ЗначенияПараметровСеансаТекущийПользователь();
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось установить параметр сеанса ТекущийПользователь по причине:
			           |""%1"".
			           |
			           |Обратитесь к администратору.'"),
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
	Если ТипЗнч(Значения) = Тип("Строка") Тогда
		ВызватьИсключение Значения;
	КонецЕсли;
	
	ПараметрыСеанса.ТекущийПользователь        = Значения.ТекущийПользователь;
	
	Если ЗначениеЗаполнено(Значения.ТекущийПользователь) Тогда
		ПараметрыСеанса.АвторизованныйПользователь = Значения.ТекущийПользователь;
	КонецЕсли;
	
	УстановленныеПараметры.Добавить("ТекущийПользователь");
	УстановленныеПараметры.Добавить("АвторизованныйПользователь");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

Функция ЗначенияПараметровСеансаТекущийПользователь()
	ЗаголовокОшибки = НСтр("ru = 'Не удалось установить параметр сеанса ТекущийПользователь.'") + Символы.ПС;
	
	НачатьТранзакцию();
	Попытка
		СведенияОПользователе = НайтиТекущегоПользователяВСправочнике();
		
		Если СведенияОПользователе.СоздатьПользователя Тогда
			СоздатьТекущегоПользователяВСправочнике(СведенияОПользователе);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если Не СведенияОПользователе.СоздатьПользователя
	   И Не СведенияОПользователе.ПользовательНайден Тогда
		
		Возврат ЗаголовокОшибки + ТекстСообщенияПользовательНеНайденВСправочнике(
			СведенияОПользователе.ИмяПользователя);
	КонецЕсли;
	
	Если СведенияОПользователе.ТекущийПользователь        = Неопределено Тогда
		
		Возврат ЗаголовокОшибки + ТекстСообщенияПользовательНеНайденВСправочнике(
				СведенияОПользователе.ИмяПользователя) + Символы.ПС
			+ НСтр("ru = 'Возникла внутренняя ошибка при поиске пользователя.'");
	КонецЕсли;
	
	Значения = Новый Структура;
	Значения.Вставить("ТекущийПользователь",        СведенияОПользователе.ТекущийПользователь);
	
	Возврат Значения;
	
КонецФункции

Функция ТекстСообщенияТекущийПользовательНедоступенВСеансеБезРазделителей()
	
	Возврат
		НСтр("ru = 'Недопустимое получение параметра сеанса ТекущийПользователь
		           |в сеансе без указания всех разделителей.'");
	
КонецФункции

Функция НайтиТекущегоПользователяВСправочнике()
	
	Результат = Новый Структура;
	Результат.Вставить("ИмяПользователя",             Неопределено);
	Результат.Вставить("ПолноеИмяПользователя",       Неопределено);
	Результат.Вставить("ИдентификаторПользователяИБ", Неопределено);
	Результат.Вставить("ПользовательНайден",          Ложь);
	Результат.Вставить("СоздатьПользователя",         Ложь);
	Результат.Вставить("СсылкаНового",                Неопределено);
	Результат.Вставить("Служебный",                   Ложь);
	Результат.Вставить("ТекущийПользователь",         Неопределено);
	Результат.Вставить("ТекущийВнешнийПользователь",  Неопределено);
	
	ТекущийПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
	
	Если ПустаяСтрока(ТекущийПользовательИБ.Имя) Тогда
		СвойстваНеуказанногоПользователя = СвойстваНеуказанногоПользователя();
		
		Результат.ИмяПользователя       = СвойстваНеуказанногоПользователя.ПолноеИмя;
		Результат.ПолноеИмяПользователя = СвойстваНеуказанногоПользователя.ПолноеИмя;
		Результат.СсылкаНового          = СвойстваНеуказанногоПользователя.СтандартнаяСсылка;
		
		Если СвойстваНеуказанногоПользователя.Ссылка = Неопределено Тогда
			Результат.СоздатьПользователя = Истина;
			Результат.Служебный = Истина;
			Результат.ИдентификаторПользователяИБ = "";
		Иначе
			Результат.ПользовательНайден = Истина;
			Результат.ТекущийПользователь = СвойстваНеуказанногоПользователя.Ссылка;
		КонецЕсли;
		
		Возврат Результат;
	КонецЕсли;

	Результат.ИмяПользователя             = ТекущийПользовательИБ.Имя;
	Результат.ИдентификаторПользователяИБ = ТекущийПользовательИБ.УникальныйИдентификатор;
	
	Пользователи.НайтиНеоднозначныхПользователейИБ(Неопределено, Результат.ИдентификаторПользователяИБ);
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ИдентификаторПользователяИБ", Результат.ИдентификаторПользователяИБ);

	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Пользователи.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Результат.ТекущийПользователь = Выборка.Ссылка;
		Результат.ПользовательНайден = Истина;
		Возврат Результат;
	КонецЕсли;
	
	Результат.ИдентификаторПользователяИБ = ТекущийПользовательИБ.УникальныйИдентификатор;
	Результат.ПолноеИмяПользователя       = ТекущийПользовательИБ.ПолноеИмя;
	
	Если Результат.СоздатьПользователя Тогда
		Возврат Результат;
	КонецЕсли;
	
	ПользовательПоНаименованию = СсылкаПользователяПоПолномуНаименованию(
		Результат.ПолноеИмяПользователя);
	
	Если ПользовательПоНаименованию <> Неопределено Тогда
		Результат.ПользовательНайден  = Истина;
		Результат.ТекущийПользователь = ПользовательПоНаименованию;
	Иначе
		Результат.СоздатьПользователя = Истина;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура СоздатьТекущегоПользователяВСправочнике(СведенияОПользователе)
	
	НачатьТранзакцию();
	Попытка
		Если СведенияОПользователе.СсылкаНового = Неопределено Тогда
			СведенияОПользователе.СсылкаНового = Справочники.Пользователи.ПолучитьСсылку();
		КонецЕсли;
		
		СведенияОПользователе.ТекущийПользователь = СведенияОПользователе.СсылкаНового;
		
		ПараметрыСеанса.ТекущийПользователь        = СведенияОПользователе.ТекущийПользователь;
		ПараметрыСеанса.АвторизованныйПользователь = СведенияОПользователе.ТекущийПользователь;
		
		НовыйПользователь = Справочники.Пользователи.СоздатьЭлемент();
		НовыйПользователь.Служебный    = СведенияОПользователе.Служебный;
		НовыйПользователь.Наименование = СведенияОПользователе.ПолноеИмяПользователя;
		НовыйПользователь.УстановитьСсылкуНового(СведенияОПользователе.СсылкаНового);  
		НовыйПользователь.ИдентификаторПользователяИБ = СведенияОПользователе.ИдентификаторПользователяИБ;
		
		
		НовыйПользователь.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ОчищаемыеПараметры = Новый Массив;
		ОчищаемыеПараметры.Добавить("ТекущийПользователь");
		ОчищаемыеПараметры.Добавить("АвторизованныйПользователь");
		ПараметрыСеанса.Очистить(ОчищаемыеПараметры);
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Функция ТекстСообщенияПользовательНеНайденВСправочнике(ИмяПользователя)
	
	ШаблонСообщенияОбОшибке =
			НСтр("ru = 'Пользователь ""%1"" не найден в справочнике ""Пользователи"".
			           |
			           |Обратитесь к администратору.'");
	
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщенияОбОшибке, ИмяПользователя);
	
КонецФункции

Функция СсылкаПользователяПоПолномуНаименованию(ПолноеИмя)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Ссылка,
	|	Пользователи.ИдентификаторПользователяИБ
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Наименование = &ПолноеИмя";
	
	Запрос.УстановитьПараметр("ПолноеИмя", ПолноеИмя);
	
	Результат = Неопределено;
	
	НачатьТранзакцию();
	Попытка
		РезультатЗапроса = Запрос.Выполнить();
		Если НЕ РезультатЗапроса.Пустой() Тогда
			
			Выборка = РезультатЗапроса.Выбрать();
			Выборка.Следующий();
			
			Если НЕ Пользователи.ПользовательИБЗанят(Выборка.ИдентификаторПользователяИБ) Тогда
				Результат = Выборка.Ссылка;
			КонецЕсли;
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Функция РезультатУстановкиПараметровСеанса(РегистрироватьВЖурнале)
	
	Попытка
		Пользователи.АвторизованныйПользователь();
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Возврат КраткоеПредставлениеОшибкиАвторизацииПослеРегистрацииВЖурнале(ИнформацияОбОшибке,
			, РегистрироватьВЖурнале);
	КонецПопытки;
	
	Возврат "";
	
КонецФункции


Функция КраткоеПредставлениеОшибкиАвторизацииПослеРегистрацииВЖурнале(ИнформацияОбОшибке, ШаблонОшибки = "", РегистрироватьВЖурнале = Истина)
	
	Если ТипЗнч(ИнформацияОбОшибке) = Тип("ИнформацияОбОшибке") Тогда
		КраткоеПредставление   = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
		ПодробноеПредставление = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
	Иначе
		КраткоеПредставление   = ИнформацияОбОшибке;
		ПодробноеПредставление = ИнформацияОбОшибке;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ШаблонОшибки) Тогда
		КраткоеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ШаблонОшибки, КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		
		ПодробноеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ШаблонОшибки, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецЕсли;
	
	КраткоеПредставление   = ЗаголовокСообщенияАвторизацияНеВыполненаСПереводомСтроки() + КраткоеПредставление;
	ПодробноеПредставление = ЗаголовокСообщенияАвторизацияНеВыполненаСПереводомСтроки() + ПодробноеПредставление;
	
	Если РегистрироватьВЖурнале Тогда
		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Пользователи.Ошибка входа в программу'"),
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставление);
	КонецЕсли;
	
	Возврат КраткоеПредставление;
	
КонецФункции


Функция ЗаголовокСообщенияАвторизацияНеВыполненаСПереводомСтроки()
	
	Возврат НСтр("ru = 'Авторизация не выполнена. Работа системы будет завершена.'")
		+ Символы.ПС + Символы.ПС;
	
КонецФункции

// Возвращает свойства пользователя для пользователя ИБ с пустым именем.
Функция СвойстваНеуказанногоПользователя() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Свойства = Новый Структура;
	
	// Ссылка на найденный элемент справочника
	// соответствующий неуказанному пользователю.
	Свойства.Вставить("Ссылка", Неопределено);
	
	// Ссылка, используемая для поиска и создания
	// неуказанного пользователя в справочнике Пользователи.
	Свойства.Вставить("СтандартнаяСсылка", Справочники.Пользователи.ПолучитьСсылку(
		Новый УникальныйИдентификатор("aa00559e-ad84-4494-88fd-f0826edc46f0")));
	
	// Полное имя, которое устанавливается в элемент справочника Пользователи
	// при создании несуществующего неуказанного пользователя.
	Свойства.Вставить("ПолноеИмя", Пользователи.ПолноеИмяНеуказанногоПользователя());
	
	// Полное имя, которое используется для поиска неуказанного пользователя
	// старым способом, необходимым для поддержки старых версий
	// неуказанного пользователя. Это имя не требуется изменять.
	Свойства.Вставить("ПолноеИмяДляПоиска", НСтр("ru = '<Не указан>'"));
	
	// Поиск по уникальному идентификатору.
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Свойства.СтандартнаяСсылка);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Ссылка = &Ссылка";
	
	НачатьТранзакцию();
	Попытка
		Если Запрос.Выполнить().Пустой() Тогда
			Запрос.УстановитьПараметр("ПолноеИмя", Свойства.ПолноеИмяДляПоиска);
			Запрос.Текст =
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Пользователи.Ссылка
			|ИЗ
			|	Справочник.Пользователи КАК Пользователи
			|ГДЕ
			|	Пользователи.Наименование = &ПолноеИмя";
			Результат = Запрос.Выполнить();
			
			Если НЕ Результат.Пустой() Тогда
				Выборка = Результат.Выбрать();
				Выборка.Следующий();
				Свойства.Ссылка = Выборка.Ссылка;
			КонецЕсли;
		Иначе
			Свойства.Ссылка = Свойства.СтандартнаяСсылка;
		КонецЕсли;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Свойства;
	
КонецФункции

// Только для внутреннего использования.
Функция АвторизованныйПользователь() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат ПараметрыСеанса.ТекущийПользователь;
	
КонецФункции   


// Определяет наличие элемента в справочнике Пользователи
// или справочнике ВнешниеПользователи по уникальному идентификатору
// пользователя информационной.
//  Функция используется для проверки наличия сопоставления пользователяИБ только
// с одним элементом справочников Пользователи и ВнешниеПользователи.
//
// Параметры:
//  УникальныйИдентификатор - идентификатор пользователя ИБ.
//
//  СсылкаНаТекущего - СправочникСсылка.Пользователи,
//                     СправочникСсылка.ВнешниеПользователи - исключить
//                       указанную ссылку из поиска.
//                     Неопределено - искать среди всех элементов справочников.
//
//  НайденныйПользователь (Возвращаемое значение):
//                     Неопределено - пользователь не существует.
//                     СправочникСсылка.Пользователи,
//                     СправочникСсылка.ВнешниеПользователи, если найден.
//
//  ИдентификаторПользователяСервиса - Булево.
//                     Ложь   - проверять ИдентификаторПользователяИБ.
//                     Истина - проверять ИдентификаторПользователяСервиса.
//
// Возвращаемое значение:
//  Булево.
//
Функция ПользовательПоИдентификаторуСуществует(УникальныйИдентификатор,
                                               СсылкаНаТекущего = Неопределено,
                                               НайденныйПользователь = Неопределено,
                                               ИдентификаторПользователяСервиса = Ложь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("СсылкаНаТекущего", СсылкаНаТекущего);
	Запрос.УстановитьПараметр("УникальныйИдентификатор", УникальныйИдентификатор);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Пользователь
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.ИдентификаторПользователяИБ = &УникальныйИдентификатор
	|	И Пользователи.Ссылка <> &СсылкаНаТекущего";
	
	Результат = Ложь;
	НайденныйПользователь = Неопределено;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		НайденныйПользователь = Выборка.Пользователь;
		Результат = Истина;
		Пользователи.НайтиНеоднозначныхПользователейИБ(Неопределено, УникальныйИдентификатор);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

