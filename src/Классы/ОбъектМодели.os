Перем ИмяТаблицы;
Перем Колонки;
Перем Идентификатор;

Процедура ПриСозданииОбъекта(ТипСущности)
	
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");

	ИмяТаблицы = "";
	Колонки = Новый ТаблицаЗначений;
	Колонки.Колонки.Добавить("ИмяПоля", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ИмяКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ТипКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ГенерируемоеЗначение", ОписаниеТиповБулево);
	Колонки.Колонки.Добавить("Идентификатор", ОписаниеТиповБулево);
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
	
	// TODO: Это временный расчета аннотаций на колонку. После доработки движка переписать на анализ свойств
	// Собираем аннотации над аннотаций Колонка и считаем их аннотациями этой колонки
	МассивАннотацийНадПолем = Новый Массив;
	Для Каждого Аннотация Из Аннотации Цикл
		Если НРег(Аннотация.Имя) = "сущность" Тогда
			Продолжить;
		КонецЕсли;
		Если НРег(Аннотация.Имя) <> "колонка" Тогда
			МассивАннотацийНадПолем.Добавить(Аннотация);
		Иначе

			ДанныеОКолонке = НовыйДанныеОКолонке();
			ЗаполнитьИмяПоля(ДанныеОКолонке, Аннотация);
			ЗаполнитьИмяКолонки(ДанныеОКолонке, Аннотация);
			ЗаполнитьТипКолонки(ДанныеОКолонке, Аннотация);

			// обработать аннотации над полем
			Для Каждого АннотацияНадПолем Из МассивАннотацийНадПолем Цикл
				Если НРег(АннотацияНадПолем.Имя) = "идентификатор" Тогда
					ДанныеОКолонке.Идентификатор = Истина;
					Идентификатор = ДанныеОКолонке;
				КонецЕсли;
				Если НРег(АннотацияНадПолем.Имя) = "генерируемоезначение" Тогда
					ДанныеОКолонке.ГенерируемоеЗначение = Истина;
				КонецЕсли;
			КонецЦикла;

			ЗаполнитьЗначенияСвойств(Колонки.Добавить(), ДанныеОКолонке);

			МассивАннотацийНадПолем.Очистить();
		КонецЕсли;
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
	ДанныеОКолонке = Новый Структура("ИмяПоля, ИмяКолонки, ТипКолонки, ГенерируемоеЗначение, Идентификатор");
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
