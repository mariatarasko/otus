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
	
	Док = Документы.ПриказНаОтпуск.НайтиПоНомеру(СокрЛП(ЗапросПараметры.Номер), ЗапросПараметры.Дата);
	Сотрудник  = Справочники.Сотрудники.НайтиПоКоду(СокрЛП(ЗапросПараметры.СотрудникКод));  
	ВидОтпуска  = Справочники.ВидыОтпусков.НайтиПоНаименованию(СокрЛП(ЗапросПараметры.ВидОтпускаКод));
	
	Если Док.Ссылка = Документы.ПриказНаОтпуск.ПустаяСсылка() Тогда
		
		ДокОбъект = Документы.ПриказНаОтпуск.СоздатьДокумент();
		
	Иначе
		
		ДокОбъект = Док.ПолучитьОбъект();
		
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ДокОбъект,ЗапросПараметры);    
	
	ДокОбъект.Сотрудник  = Сотрудник;
	ДокОбъект.ВидОтпуска  = ВидОтпуска;    
	ДокОбъект.ПометкаУдаления = Ложь;
	
	ДокОбъект.Комментарий = "Загружено из ЛК";
	ДокОбъект.Статус = перечисления.СтатусыЗаявокСотрудников.Согласовано;
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
