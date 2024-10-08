﻿
Процедура ЗагрузкаПриказовНаОтпуск() Экспорт
	
	Если Константы.ИспользоватьRMQ.Получить() Тогда
		ДанныеПодключения =  РаботаСRMQ.ПолучитьДанныеПодключения(Справочники.ВидыПодключений.ВыгрузкаОтпуска);
	
		Попытка
			РаботаСRMQ.ПодключитьИПрочитатьСообщение(ДанныеПодключения);
		Исключение
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры


Процедура СоздатьПриказНаОтпуск(ЗапросПараметры) Экспорт
	
	Док = Документы.Отпуск.НайтиПоНомеру(СокрЛП(ЗапросПараметры.Номер), ЗапросПараметры.Дата);
	Сотрудник  = Справочники.Сотрудники.НайтиПоКоду(СокрЛП(ЗапросПараметры.СотрудникКод));  
	ВидОтпуска  = ПланыВидовРасчета.Начисления.НайтиПоНаименованию(СокрЛП(ЗапросПараметры.ВидОтпускаКод));
	
	Если Док.Ссылка = Документы.Отпуск.ПустаяСсылка() Тогда
		
		ДокОбъект = Документы.Отпуск.СоздатьДокумент();
		
	Иначе
		
		ДокОбъект = Док.ПолучитьОбъект();
		
		Если ДокОбъект.Проведен Тогда
			ДокОбъект.Записать(РежимЗаписиДокумента.ОтменаПроведения);
		КонецЕсли;	
	КонецЕсли;
	
	ДокОбъект.Номер = ЗапросПараметры.Номер;
	ДокОбъект.Дата = ЗапросПараметры.Дата;
	ДокОбъект.Сотрудник  = Сотрудник;    
	ДокОбъект.ФизическоеЛицо = 	ДокОбъект.Сотрудник.ФизическоеЛицо; 
	ДокОбъект.Организация = 	ДокОбъект.Сотрудник.ГоловнаяОрганизация;
	ДокОбъект.ВидРасчетаОсновногоОтпуска  = ВидОтпуска;    
	ДокОбъект.ПометкаУдаления = Ложь;     
	ДокОбъект.ДатаНачалаОсновногоОтпуска = ЗапросПараметры.ДатаНачала;
	ДокОбъект.ДатаОкончанияОсновногоОтпуска = ЗапросПараметры.ДатаОкончания;
	ДокОбъект.ПериодРегистрации = НачалоМесяца(ТекущаяДата());  
	ДокОбъект.ДатаНачалаСобытия =  ЗапросПараметры.ДатаНачала; 
	ДокОбъект.ПредоставитьОсновнойОтпуск =  Истина; 
	ДокОбъект.КоличествоДнейОсновногоОтпуска =  (НачалоДня(ЗапросПараметры.ДатаОкончания) - НачалоДня(ЗапросПараметры.ДатаНачала)) / (60 * 60 * 24)  + 1  ; 
	
	ДокОбъект.Комментарий = "Загружено из ЛК";
	ДокОбъект.Записать(РежимЗаписиДокумента.Запись);
	
КонецПроцедуры

Процедура СоздатьПриказНаОтпускИзJSON(Структура) Экспорт
	
	чтениеJSON = Новый ЧтениеJSON;
	чтениеJSON.УстановитьСтроку(Структура);
	ЗапросПараметры = ПрочитатьJSON(чтениеJSON,,,ФорматДатыJSON.ISO);
	чтениеJSON.Закрыть();  
	
	ЗапросПараметры.Дата = ПрочитатьДатуJSON(ЗапросПараметры.Дата, ФорматДатыJSON.ISO);
	ЗапросПараметры.ДатаНачала = ПрочитатьДатуJSON(ЗапросПараметры.ДатаНачала, ФорматДатыJSON.ISO);
	ЗапросПараметры.ДатаОкончания = ПрочитатьДатуJSON(ЗапросПараметры.ДатаОкончания, ФорматДатыJSON.ISO);

	СоздатьПриказНаОтпуск(ЗапросПараметры);
	
	
КонецПроцедуры
