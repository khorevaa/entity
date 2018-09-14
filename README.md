# entity - OneScript Persistence API

Библиотека `Entity` предназначена для работы с данными БД как с простыми OneScript объектами. Является реализацией концепцию ORM в OneScript. Вдохновение черпается из Java Persistence API.

Возможности:

* Описание таблиц БД в виде специальным образом аннотированных OneScript классов
* Сохранение объектов OneScript в связанных таблицах БД
* Поиск по таблицам с результом в виде коллекции заполненных данными объектов OneScript
* Абстрактный программный интерфейс (API), не зависящий от используемой СУБД
* Референсная реализация коннектора к SQLite

## Пример класса-сущности

> Для конечной реализации требуется ряд доработок со стороны движка OneScript

```bsl
// file: Автор.os

&Идентификатор                        // Колонка для хранения ID сущности
&ГенерируемоеЗначение                 // Заполняется автоматически при сохранении сущности
&Колонка(Тип = ТипыКолонок.Целое)     // Хранит целочисленные значения
Перем Идентификатор Экспорт;          // Имя колонки в базе - `Идентификатор`

Перем Имя Экспорт;                    // Колонка `Имя` будет создана в таблице, т.к. поле экспортное.
&Колонка(Имя = "Фамилия")             // Поле `ВтороеИмя` в таблице будет представлено колонкой `Фамилия`.
Перем ВтороеИмя Экспорт;

&Колонка(Тип = ТипыКолонок.Дата)      // Колонка `ДатаРождения` хранит значения в формате дата-без-времени
Перем ДатаРождения Экспорт;

&Сущность(ИмяТаблицы = "Авторы")      // Объект с типом `Автор` (по имени файла) будет представлен в СУБД в виде таблицы `Авторы`
Процедура ПриСозданииОбъекта() Экспорт

КонецПроцедуры
```

## Создание и сохранение сущностей

```bsl
// Инициализация менеджера сущностей. Коннектором к базе выступает референсная реализация КоннекторSQLite.
МенеджерСущностей = Новый МенеджерСущностей(Тип("КоннекторSQLite"));

// Создание или обновление таблиц в БД
МенеджерСущностей.ДобавитьСущностьВМодель(Тип("Автор"));

// Работа с обычным объектом OneScript
СохраняемыйАвтор = Новый Автор;
СохраняемыйАвтор.Имя = "Иван";
СохраняемыйАвтор.ВтороеИмя = "Иванов";
СохраняемыйАвтор.ДатаРождения = Дата(1990, 01, 01);

// Сохранение объекта в БД
МенеджерСущностей.Сохранить(СохраняемыйАвтор);
```

## Чтение и поиск объектов

TODO.

## Система аннотаций для сущностей

Для связями между классом на OneScript и таблицей в БД используется система аннотаций. При анализе типа сущности менеджер сущности формирует специальные объекты модели, передаваемые конкретным реализациям коннекторов. Коннекторы могут рассчитывать на наличие всех описанных параметров аннотаций в объекте модели.

### Сущность

> Применение: обязательно

Каждый класс, подключемый к менеджеру сущностей должен иметь аннотацию `Сущность`, расположенную над экспортным методом класса.

При отсутствии у класса необходимых экспортных методов рекомендуется навешивать аннотацию над методом `ПриСозданииОбъекта()`, объявив его экспортным.

Аннотация `Сущность` имеет следующие параметры:

* `ИмяТаблицы` - Строка - Имя таблицы, используемой коннектором к СУБД при работе с сущностью. Значение по умолчанию - строковое представление имени типа сценария. При подключении сценариев стандартным загрузчиком библиотек совпадает с именем файла.

### Идентификатор

> Применение: обязательно

Каждый класс, подключемый к менеджеру сущностей должен иметь поле для хранения идентификатора объекта в СУБД - первичного ключа. Для формирования автоинкрементного первичного ключа можно воспользоваться дополнительной аннотацией `ГенерируемоеЗначение`.

Аннотация `Идентификатор` не имеет параметров.

### Колонка

> Применение: необязательно

Все экспортные поля класса преобразуются в колонки таблицы в СУБД. Аннотация `Колонка` позволяет тонко настроить параметры колонки таблицы.

Аннотация `Колонка` имеет следующие параметры:

* `Имя` - Строка - Имя колонки, используемой коннектором к СУБД при работе с сущностью. Значение по умолчанию - имя свойства.
* `Тип` - ТипыКолонок - Тип колонки, используемой для хранения идентификатора. Значение по умолчанию - `ТипыКолонок.Строка`.

### ГенерируемоеЗначение

> Применение: необязательно

Для части полей допустимо высчитывать значение колонки при вставке записи в таблицу. Например, для первичных числовых ключей обычно не требуется явное управление назначемыми идентификаторами.

Референсная реализация коннектора на базе SQLite поддерживает единственный тип генератора значений - `AUTOINCREMENT`.

> Планируется расширение аннотации указанием параметров генератора.

Аннотация `ГенерируемоеЗначение` не имеет параметров.

> To be continued...
