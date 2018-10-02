Перем СтрокаУсловия;
Перем МассивУсловий;

Процедура Создать(Знач ДиалектЗапроса, БуферТекстаЗапроса) Экспорт
	
	
	БуферТекстаЗапроса.ДобавитьТекст(" ");
	БуферТекстаЗапроса.ДобавитьТекст(СтрокаУсловия);
	БуферТекстаЗапроса.ДобавитьТекст(" ");
		
		
		УсловиеМассива.Создать(ДиалектЗапроса, БуферТекстаЗапроса);

		БуферТекстаЗапроса.ДобавитьЗначение(")");

	
	unc buildCmp(d Dialect, buf Buffer, pred string, column string, value interface{}) error {
	buf.WriteString(d.QuoteIdent(column))
	buf.WriteString(" ")
	buf.WriteString(pred)
	buf.WriteString(" ")
	buf.WriteString(placeholder)

	buf.WriteValue(value)
	return nil
}

КонецПроцедуры


Процедура ПриСозданииОбъекта(Знач ЗначениеСтрокаУсловия, Знач ЗначениеУсловия)
	
	СтрокаУсловия = ЗначениеСтрокаУсловия;
	
	Если Условие Тогда
		
	КонецЕсли;

	МассивУсловий = ЗначениеМассивУсловий;

КонецПроцедуры


Функция Равно(Знач ИмяПоляЗапроса, Знач ЗначениеПоляЗапроса) Экспорт
	
	Отбор = Новый Соответствие;
	Отбор.Вставить(ИмяПоляЗапроса, ЗначениеПоляЗапроса);
	
	Возврат Новый Условие("OR", Отбор);

КонецФункции

Функция ВСписке(Знач МассивУсловий) Экспорт
	Возврат Новый Условие("OR", МассивУсловий);
КонецФункции

Процедура СоздатьЕстьNull(Знач ДиалектЗапроса, БуферТекстаЗапроса) Экспорт 
	
	БуферТекстаЗапроса.ДобавитьТекст(ИмяПоляЗапроса); // TODO: Доделать обработку экранирования для диалекта d.QuoteIdent(column)
	БуферТекстаЗапроса.ДобавитьТекст(" IS NULL");

КонецПроцедуры

Процедура СоздатьПустойСписок(Знач ДиалектЗапроса, БуферТекстаЗапроса)
	
	БуферТекстаЗапроса.ДобавитьТекст(Ложь); // TODO: Доделать обработку экранирования для диалекта d.QuoteIdent(column)

КонецПроцедуры

Процедура СоздатьЕстьNull(Знач ДиалектЗапроса, БуферТекстаЗапроса) Экспорт 
	
	БуферТекстаЗапроса.ДобавитьТекст(ИмяПоляЗапроса); // TODO: Доделать обработку экранирования для диалекта d.QuoteIdent(column)
	БуферТекстаЗапроса.ДобавитьТекст(" IS NULL");

КонецПроцедуры

func buildCmp(d Dialect, buf Buffer, pred string, column string, value interface{}) error {
	buf.WriteString(d.QuoteIdent(column))
	buf.WriteString(" ")
	buf.WriteString(pred)
	buf.WriteString(" ")
	buf.WriteString(placeholder)

	buf.WriteValue(value)
	return nil
}

// Eq is `=`.
// When value is nil, it will be translated to `IS NULL`.
// When value is a slice, it will be translated to `IN`.
// Otherwise it will be translated to `=`.
func Eq(column string, value interface{}) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		if value == nil {
			buf.WriteString(d.QuoteIdent(column))
			buf.WriteString(" IS NULL")
			return nil
		}
		v := reflect.ValueOf(value)
		if v.Kind() == reflect.Slice {
			if v.Len() == 0 {
				buf.WriteString(d.EncodeBool(false))
				return nil
			}
			return buildCmp(d, buf, "IN", column, value)
		}
		return buildCmp(d, buf, "=", column, value)
	})
}

// Neq is `!=`.
// When value is nil, it will be translated to `IS NOT NULL`.
// When value is a slice, it will be translated to `NOT IN`.
// Otherwise it will be translated to `!=`.
func Neq(column string, value interface{}) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		if value == nil {
			buf.WriteString(d.QuoteIdent(column))
			buf.WriteString(" IS NOT NULL")
			return nil
		}
		v := reflect.ValueOf(value)
		if v.Kind() == reflect.Slice {
			if v.Len() == 0 {
				buf.WriteString(d.EncodeBool(true))
				return nil
			}
			return buildCmp(d, buf, "NOT IN", column, value)
		}
		return buildCmp(d, buf, "!=", column, value)
	})
}

// Gt is `>`.
func Gt(column string, value interface{}) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		return buildCmp(d, buf, ">", column, value)
	})
}

// Gte is '>='.
func Gte(column string, value interface{}) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		return buildCmp(d, buf, ">=", column, value)
	})
}

// Lt is '<'.
func Lt(column string, value interface{}) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		return buildCmp(d, buf, "<", column, value)
	})
}

// Lte is `<=`.
func Lte(column string, value interface{}) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		return buildCmp(d, buf, "<=", column, value)
	})
}

func buildLike(d Dialect, buf Buffer, column, pattern string, isNot bool, escape []string) error {
	buf.WriteString(d.QuoteIdent(column))
	if isNot {
		buf.WriteString(" NOT LIKE ")
	} else {
		buf.WriteString(" LIKE ")
	}
	buf.WriteString(d.EncodeString(pattern))
	if len(escape) > 0 {
		buf.WriteString(" ESCAPE ")
		buf.WriteString(d.EncodeString(escape[0]))
	}
	return nil
}

// Like is `LIKE`, with an optional `ESCAPE` clause
func Like(column, value string, escape ...string) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		return buildLike(d, buf, column, value, false, escape)
	})
}

// NotLike is `NOT LIKE`, with an optional `ESCAPE` clause
func NotLike(column, value string, escape ...string) Builder {
	return BuildFunc(func(d Dialect, buf Buffer) error {
		return buildLike(d, buf, column, value, true, escape)
	})
}