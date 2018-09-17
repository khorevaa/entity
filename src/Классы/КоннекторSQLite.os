#Использовать asserts
#Использовать reflector
#Использовать strings
#Использовать sql

Перем Соединение;

Процедура Открыть() Экспорт
	Соединение = Новый Соединение();
	Соединение.ТипСУБД = Соединение.ТипыСУБД.sqlite;
	Соединение.ИмяБазы = ":memory:";
	Соединение.Открыть();
КонецПроцедуры

Процедура Закрыть() Экспорт
	Соединение.Закрыть();
КонецПроцедуры

Процедура НачатьТранзакцию() Экспорт
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = "BEGIN TRANSACTION;";
	Запрос.ВыполнитьКоманду();
КонецПроцедуры

Процедура ЗафиксироватьТранзакцию() Экспорт
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = "COMMIT;";
	Запрос.ВыполнитьКоманду();
КонецПроцедуры

Процедура ИнициализироватьТаблицу(ОбъектМодели) Экспорт
	
	КартаТипов = СоответствиеТиповМоделиИТиповКолонок();

	ИмяТаблицы = ОбъектМодели.ИмяТаблицы();
		
	ТекстЗапроса = "CREATE TABLE IF NOT EXISTS %1 (
	|	%2
	|);";
	КолонкиТаблицы = ОбъектМодели.Колонки();
	Идентификатор = ОбъектМодели.Идентификатор();
	СтрокаОпределенийКолонок = "";
	Для Каждого Колонка Из КолонкиТаблицы Цикл
		СтрокаКолонка = СтрШаблон("%1 %2", Колонка.ИмяКолонки, КартаТипов.Получить(Колонка.ТипКолонки));
		Если Колонка.ИмяПоля = Идентификатор.ИмяПоля Тогда
			СтрокаКолонка = СтрокаКолонка + " PRIMARY KEY";
		КонецЕсли;
		Если Колонка.ГенерируемоеЗначение Тогда
			СтрокаКолонка = СтрокаКолонка + " AUTOINCREMENT";
		КонецЕсли;
		СтрокаКолонка = СтрокаКолонка + "," + Символы.ПС;

		СтрокаОпределенийКолонок = СтрокаОпределенийКолонок + СтрокаКолонка;
	КонецЦикла;
	СтроковыеФункции.УдалитьПоследнийСимволВСтроке(СтрокаОпределенийКолонок, 2);

	ТекстЗапроса = СтрШаблон(ТекстЗапроса, ИмяТаблицы, СтрокаОпределенийКолонок);
	
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = ТекстЗапроса;

	Запрос.ВыполнитьКоманду();
КонецПроцедуры

Процедура Создать(ОбъектМодели, Сущность) Экспорт
	// TODO: см. выше
	
	// TODO: Таблица с единственным автополем - INSERT INTO first (id) VALUES (null);
	ИмяТаблицы = ОбъектМодели.ИмяТаблицы();
	КолонкиТаблицы = ОбъектМодели.Колонки();
	
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	
	ТекстЗапроса = "INSERT INTO %1 (
	|%2
	|) VALUES (
	|%3
	|);";
	
	ИменаКолонок = "";
	ЗначенияКолонок = "";
	// TODO: преобразования типов? Дата в число и тому подобное
	Для Каждого ДанныеОКолонке Из КолонкиТаблицы Цикл
		Если ДанныеОКолонке.ГенерируемоеЗначение Тогда
			// TODO: Поддержка чего-то кроме автоинкремента
			Продолжить;
		КонецЕсли;
		ИменаКолонок = ИменаКолонок + Символы.Таб + ДанныеОКолонке.ИмяКолонки + "," + Символы.ПС;
		ЗначенияКолонок = ЗначенияКолонок + Символы.Таб + "@" + ДанныеОКолонке.ИмяКолонки + "," + Символы.ПС;
		
		ЗначениеПараметра = Вычислить("Сущность." + ДанныеОКолонке.ИмяПоля);
		Запрос.УстановитьПараметр(ДанныеОКолонке.ИмяКолонки, ЗначениеПараметра);
	КонецЦикла;
	
	СтроковыеФункции.УдалитьПоследнийСимволВСтроке(ИменаКолонок, 2);
	СтроковыеФункции.УдалитьПоследнийСимволВСтроке(ЗначенияКолонок, 2);
	
	ТекстЗапроса = СтрШаблон(ТекстЗапроса, ИмяТаблицы, ИменаКолонок, ЗначенияКолонок);
	Запрос.Текст = ТекстЗапроса;
	
	Запрос.ВыполнитьКоманду();
	
	// TODO: Для полей с автоинкрементом - получить значения из базы.
	// по факту - просто переинициализировать класс значениями полей из СУБД.

КонецПроцедуры

// TODO: Стоит вынести в сам менеджер?
Функция ВыполнитьЗапрос(ТекстЗапроса) Экспорт

	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = ТекстЗапроса;
	Результат = Запрос.Выполнить().Выгрузить();
	
	Возврат Результат;

КонецФункции

Функция СоответствиеТиповМоделиИТиповКолонок()
	
	Карта = Новый Соответствие;
	Карта.Вставить(ТипыКолонок.Целое, "INTEGER");
	Карта.Вставить(ТипыКолонок.Строка, "TEXT");
	Карта.Вставить(ТипыКолонок.Дата, "DATE");
	Карта.Вставить(ТипыКолонок.Время, "TIME");
	Карта.Вставить(ТипыКолонок.ДатаВремя, "DATETIME");
	
	Возврат Карта;
	
КонецФункции
