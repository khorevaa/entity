#Использовать "../src"
#Использовать 1bdd
#Использовать 1testrunner
#Использовать fs

Функция ПрогнатьТесты()
	
	Тестер = Новый Тестер;

	ПутьКТестам = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "tests");
	ПутьКОтчетуJUnit = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "tests-reports");

	ФС.ОбеспечитьПустойКаталог(ПутьКОтчетуJUnit);

	КаталогТестов = Новый Файл(ПутьКТестам);
	Если Не КаталогТестов.Существует() Тогда
		Сообщить(СтрШаблон("Не найден каталог тестов %1", ПутьКТестам));
		Возврат Истина;
	КонецЕсли;

	РезультатТестирования = Тестер.ТестироватьКаталог(
		КаталогТестов,
		Новый Файл(ПутьКОтчетуJUnit)
	);

	Успешно = РезультатТестирования = 0;
	
	Возврат Успешно;
КонецФункции // ПрогнатьТесты()

Функция ПрогнатьФичи()
	
	ПутьОтчетаJUnit = "./bdd-log.xml";

	КаталогФич = ОбъединитьПути(".", "features");

	Файл_КаталогФич = Новый Файл(КаталогФич);
	Если Не Файл_КаталогФич.Существует() Тогда
		Сообщить(СтрШаблон("Не найден каталог фич %1", КаталогФич));
		Возврат Истина;
	КонецЕсли;

	ИсполнительБДД = Новый ИсполнительБДД;
	РезультатыВыполнения = ИсполнительБДД.ВыполнитьФичу(Файл_КаталогФич, Файл_КаталогФич);
	ИтоговыйРезультатВыполнения = ИсполнительБДД.ПолучитьИтоговыйСтатусВыполнения(РезультатыВыполнения);

	СтатусВыполнения = ИсполнительБДД.ВозможныеСтатусыВыполнения().НеВыполнялся;
	Если РезультатыВыполнения.Строки.Количество() > 0 Тогда
		
		СтатусВыполнения = ИсполнительБДД.ПолучитьИтоговыйСтатусВыполнения(РезультатыВыполнения);
		
	КонецЕсли;

	ГенераторОтчетаJUnit = Новый ГенераторОтчетаJUnit;
	ГенераторОтчетаJUnit.Сформировать(РезультатыВыполнения, СтатусВыполнения, ПутьОтчетаJUnit);

	Сообщить(СтрШаблон("Результат прогона фич <%1>
	|", ИтоговыйРезультатВыполнения));

	Возврат ИтоговыйРезультатВыполнения <> ИсполнительБДД.ВозможныеСтатусыВыполнения().Сломался;
КонецФункции // ПрогнатьФичи()

Попытка
	ТестыПрошли = ПрогнатьТесты();

Исключение
	ТестыПрошли = Ложь;
	Сообщить(СтрШаблон("Тесты через 1testrunner выполнены неудачно
	|%1", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
КонецПопытки;

ФичиПрошли = Истина;

// Попытка
// 	ФичиПрошли = ПрогнатьФичи();
// Исключение
// 	ФичиПрошли = Ложь;
// 	Сообщить(СтрШаблон("Тесты поведения через 1bdd выполнены неудачно
// 	|%1", ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
// КонецПопытки;

Если Не ТестыПрошли Или Не ФичиПрошли Тогда
	ВызватьИсключение "Тестирование завершилось неудачно!";
Иначе
	Сообщить(СтрШаблон("Результат прогона тестов <%1>
	|", ТестыПрошли));
КонецЕсли;