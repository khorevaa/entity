Перем ИмяТаблицы;
Перем Колонки;
Перем Идентификатор;

Процедура ПриСозданииОбъекта(ТипСущности)
	
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");

	ИмяТаблицы = "";
	Колонки = Новый ТаблицаЗначений;
	Колонки.Колонки.Добавить("ИмяПоля", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ИмяКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ТипКолонки", ОписаниеТиповСтрока);
	Идентификатор = НовыйДанныеОКолонке();

	// TODO: Пока в рефлекторе нет поддержки работы с типами-сценариями, инициализируем dummy-объект
	ЭкземплярСущности = Новый(ТипСущности);
	
	РефлекторОбъекта = Новый РефлекторОбъекта(ЭкземплярСущности);
	МетодСущность = РефлекторОбъекта.ПолучитьТаблицуМетодов("Сущность")[0];
	
	АннотацияСущность = МетодСущность.Аннотации.Найти("сущность", "Имя");
	ПараметрИмяТаблицы = АннотацияСущность.Параметры.Найти("ИмяТаблицы", "Имя");
	ИмяТаблицы = ?(ПараметрИмяТаблицы = Неопределено, Строка(ТипСущности), ПараметрИмяТаблицы.Значение);
	
	// TODO: Работа с аннотациями через свойства
	//ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств("Идентификатор");
	
	Аннотации = МетодСущность.Аннотации;

	// TODO: Анализ экспортных свойств без аннотаций
	
	АннотацияИдентификатор = Аннотации.Найти("идентификатор", "Имя");
	ИмяПоляИдентификатор = АннотацияИдентификатор.Параметры.Найти("ИмяПоля", "Имя").Значение;

	АннотацииКолонка = Аннотации.НайтиСтроки(Новый Структура("Имя", "колонка"));
	Для Каждого АннотацияКолонка Из АннотацииКолонка Цикл
		ДанныеОКолонке = НовыйДанныеОКолонке();
		ЗаполнитьИмяПоля(ДанныеОКолонке, АннотацияКолонка);
		ЗаполнитьИмяКолонки(ДанныеОКолонке, АннотацияКолонка);
		ЗаполнитьТипКолонки(ДанныеОКолонке, АннотацияКолонка);
		
		Если ИмяПоляИдентификатор = ДанныеОКолонке.ИмяПоля Тогда
			Идентификатор = ДанныеОКолонке;
		КонецЕсли;

		ЗаполнитьЗначенияСвойств(Колонки.Добавить(), ДанныеОКолонке);
	КонецЦикла;
	
КонецПроцедуры

Функция ИмяТаблицы() Экспорт
	Возврат ИмяТаблицы;
КонецФункции

Функция Колонки() Экспорт
	Возврат Колонки.Скопировать();
КонецФункции

Функция Идентификатор() Экспорт
	Возврат Новый ФиксированнаяСтруктура(Идентификатор);
КонецФункции

Функция НовыйДанныеОКолонке()
	ДанныеОКолонке = Новый Структура("ИмяПоля, ИмяКолонки, ТипКолонки");
	Возврат ДанныеОКолонке;
КонецФункции

Процедура ЗаполнитьИмяПоля(ДанныеОКолонке, АннотацияКолонка)
	// TODO: Определение имени поля из имени свойства
	ПараметрИмяПоля = АннотацияКолонка.Параметры.Найти("ИмяПоля", "Имя");
	Если ПараметрИмяПоля = Неопределено Тогда
		ВызватьИсключение "Ошибка определения имени поля колонки";
	КонецЕсли;
	
	ДанныеОКолонке.ИмяПоля = ПараметрИмяПоля.Значение;
КонецПроцедуры

Процедура ЗаполнитьИмяКолонки(ДанныеОКолонке, АннотацияКолонка)
	ПараметрИмяКолонки = АннотацияКолонка.Параметры.Найти("Имя", "Имя");
	Если ПараметрИмяКолонки = Неопределено Тогда
		ИмяКолонки = ДанныеОКолонке.ИмяПоля;
	Иначе
		ИмяКолонки = ПараметрИмяКолонки.Значение;	
	КонецЕсли;
	
	ДанныеОКолонке.ИмяКолонки = ИмяКолонки;
КонецПроцедуры

Процедура ЗаполнитьТипКолонки(ДанныеОКолонке, АннотацияКолонка)
	ПараметрТипКолонки = АннотацияКолонка.Параметры.Найти("Тип", "Имя");
	Если ПараметрТипКолонки = Неопределено Тогда
		ТипКолонки = ТипыКолонок.Строка;
	Иначе
		ТипКолонки = ПараметрТипКолонки.Значение;	
	КонецЕсли;
	
	ДанныеОКолонке.ТипКолонки = ТипКолонки;
КонецПроцедуры
