﻿
#Область ОбработчикиКомандФормы

// Процедура выполняется при нажатии кнопки "Сформировать".
//
&НаКлиенте
Процедура СформироватьВыполнить(Команда)
	
	Если НЕ ПроверитьЗаполнение() Тогда 
		Возврат;
	КонецЕсли;
	
	ВывестиОтчет();
	
	Элементы.Результат.ОтображениеСостояния.ДополнительныйРежимОтображения = ДополнительныйРежимОтображения.НеИспользовать;
	Элементы.Результат.ОтображениеСостояния.Видимость = Ложь;
			
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
// Процедура формирует отчет
//
Процедура ВывестиОтчет()
	
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	Результат.Очистить();
	
#Область Настройки

	Для Каждого ЭлементПользовательскойНастройки Из ОтчетОбъект.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы Цикл
		Если ТипЗнч(ЭлементПользовательскойНастройки) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда
			Если ЭлементПользовательскойНастройки.Параметр = Новый ПараметрКомпоновкиДанных("ПериодОтчета") Тогда
				НачалоПериода = ЭлементПользовательскойНастройки.Значение.ДатаНачала;
				КонецПериода  = ЭлементПользовательскойНастройки.Значение.ДатаОкончания;		
			КонецЕсли;
	    КонецЕсли;
	КонецЦикла;
	
#КонецОбласти

#Область ФормированиеТаблицыРезультата	

	//ТаблицаРезультата = Запрос.МенеджерВременныхТаблиц.Таблицы["ВТ_РезультатОтчета"].ПолучитьДанные().Выгрузить();
	//Запрос.МенеджерВременныхТаблиц.Закрыть();
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	1234 КАК USERID,
		|	ДАТАВРЕМЯ(2016, 11, 1, 0, 0, 0) КАК ДАТА,
		|	1 КАК ВремяПрихода,
		|	1 КАК ВремяУхода,
		|	1 КАК ОтработанноеВремя,
		|	10 КАК КоличествоОтработанныхЧасов
		|ГДЕ
		|	ДАТАВРЕМЯ(2016, 11, 1, 0, 0, 0) МЕЖДУ &НачалоПериода И &КонецПериода";
	
	Запрос.УстановитьПараметр("НачалоПериода",	НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода",	КонецПериода);
	
	РезультатЗапроса = Запрос.Выполнить();
	
#КонецОбласти	

	ТаблицаРезультата = РезультатЗапроса.Выгрузить();
	
#Область ВыводРезультата

	СхемаКомпоновкиДанных = ОтчетОбъект.СхемаКомпоновкиДанных;
	НастройкиКомпоновкиДанных = ОтчетОбъект.КомпоновщикНастроек.ПолучитьНастройки();
				
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	ДанныеРасшифровкиКомпоновки = Новый ДанныеРасшифровкиКомпоновкиДанных;
		
	МакетКомпоновки = КомпоновщикМакета.Выполнить(
		СхемаКомпоновкиДанных,
		НастройкиКомпоновкиДанных,
		ДанныеРасшифровкиКомпоновки
	);
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	
	ВнешниеНаборыДанных = Новый Структура();
	ВнешниеНаборыДанных.Вставить("ТаблицаРезультата",				ТаблицаРезультата);
		
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровкиКомпоновки, Истина);
	
	Результат.Очистить();
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(Результат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных, Истина);
	
	Результат.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	Результат.ФиксацияСверху = 1;
	
	ДанныеРасшифровки = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновки, Новый УникальныйИдентификатор);
	СхемаКомпоновки   = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, Новый УникальныйИдентификатор);
	
#КонецОбласти	
	
КонецПроцедуры // ВывестиОтчет()	

#КонецОбласти
