///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ОбщиеВнутренниеДанные;

&НаКлиенте
Перем ВременноеХранилищеКонтекстовОпераций;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбщиеВнутренниеДанные = Новый Соответствие;
	Отказ = Истина;
	
	ВременноеХранилищеКонтекстовОпераций = Новый Соответствие;
	ПодключитьОбработчикОжидания("УдалитьУстаревшиеКонтекстыОпераций", 300);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// АПК:78-выкл: для безопасной передачи данных на клиенте между формами, не отправляя их на сервер.
&НаКлиенте
Процедура ОткрытьНовуюФорму(ВидФормы, СерверныеПараметры, КлиентскиеПараметры = Неопределено,
			ОбработкаЗавершения = Неопределено, Знач ВладелецНовойФормы = Неопределено) Экспорт
// АПК:78-вкл: для безопасной передачи данных на клиенте между формами, не отправляя их на сервер.
	
	ВидыФорм =
		",ПодписаниеДанных,ШифрованиеДанных,РасшифровкаДанных,
		|,ВыборСертификатаДляПодписанияИлиРасшифровки,ПроверкаСертификата,";
	
	Если СтрНайти(ВидыФорм, "," + ВидФормы + ",") = 0 Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка в процедуре ОткрытьНовуюФорму. ВидФормы ""%1"" не поддерживается.'"),
			ВидФормы);
	КонецЕсли;
	
	Если ВладелецНовойФормы = Неопределено Тогда
		ВладелецНовойФормы = Новый УникальныйИдентификатор;
	КонецЕсли;
	
	ИмяНовойФормы = "Справочник.СертификатыКлючейЭлектроннойПодписиИШифрования.Форма." + ВидФормы;
	
	Контекст = Новый Структура;
	Форма = ОткрытьФорму(ИмяНовойФормы, СерверныеПараметры, ВладелецНовойФормы,,,,
		Новый ОписаниеОповещения("ОткрытьНовуюФормуОповещениеОЗакрытии", ЭтотОбъект, Контекст));
	
	Если Форма = Неопределено Тогда
		Если ТипЗнч(ОбработкаЗавершения) = Тип("ОписаниеОповещения") Тогда
			ВыполнитьОбработкуОповещения(ОбработкаЗавершения, Неопределено);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	СтандартныеПодсистемыКлиент.УстановитьХранениеФормы(Форма, Истина);
	
	Контекст.Вставить("Форма", Форма);
	Контекст.Вставить("ОбработкаЗавершения", ОбработкаЗавершения);
	Контекст.Вставить("КлиентскиеПараметры", КлиентскиеПараметры);
	Контекст.Вставить("Оповещение", Новый ОписаниеОповещения("ПродлитьХранениеКонтекстаОперации", ЭтотОбъект));
	
	Оповещение = Новый ОписаниеОповещения("ОткрытьНовуюФормуПродолжение", ЭтотОбъект, Контекст);
	
	Если КлиентскиеПараметры = Неопределено Тогда
		Форма.ПродолжитьОткрытие(Оповещение, ОбщиеВнутренниеДанные);
	Иначе
		Форма.ПродолжитьОткрытие(Оповещение, ОбщиеВнутренниеДанные, КлиентскиеПараметры);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ОткрытьНовуюФорму.
&НаКлиенте
Процедура ОткрытьНовуюФормуПродолжение(Результат, Контекст) Экспорт
	
	Если Контекст.Форма.Открыта() Тогда
		Возврат;
	КонецЕсли;
	
	ОбновитьХранениеФормы(Контекст);
	
	Если ТипЗнч(Контекст.ОбработкаЗавершения) = Тип("ОписаниеОповещения") Тогда
		ВыполнитьОбработкуОповещения(Контекст.ОбработкаЗавершения, Результат);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ОткрытьНовуюФорму.
&НаКлиенте
Процедура ОткрытьНовуюФормуОповещениеОЗакрытии(Результат, Контекст) Экспорт
	
	ОбновитьХранениеФормы(Контекст);
	
	Если ТипЗнч(Контекст.ОбработкаЗавершения) = Тип("ОписаниеОповещения") Тогда
		ВыполнитьОбработкуОповещения(Контекст.ОбработкаЗавершения, Результат);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьХранениеФормы(Контекст)
	
	СтандартныеПодсистемыКлиент.УстановитьХранениеФормы(Контекст.Форма, Ложь);
	Контекст.Форма.ОписаниеОповещенияОЗакрытии = Неопределено;
	
	Если ТипЗнч(Контекст.КлиентскиеПараметры) = Тип("Структура")
	   И Контекст.КлиентскиеПараметры.Свойство("ОписаниеДанных")
	   И ТипЗнч(Контекст.КлиентскиеПараметры.ОписаниеДанных) = Тип("Структура")
	   И Контекст.КлиентскиеПараметры.ОписаниеДанных.Свойство("КонтекстОперации")
	   И ТипЗнч(Контекст.КлиентскиеПараметры.ОписаниеДанных.КонтекстОперации) = Тип("ФормаКлиентскогоПриложения") Тогда
	
	#Если ВебКлиент Тогда
		ПродлитьХранениеКонтекстаОперации(Контекст.КлиентскиеПараметры.ОписаниеДанных.КонтекстОперации);
	#КонецЕсли
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПродлитьХранениеКонтекстаОперации(Форма) Экспорт
	
	Если ТипЗнч(Форма) = Тип("ФормаКлиентскогоПриложения") Тогда
		ВременноеХранилищеКонтекстовОпераций.Вставить(Форма,
			Новый Структура("Форма, Время", Форма, ОбщегоНазначенияКлиент.ДатаСеанса()));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьУстаревшиеКонтекстыОпераций()
	
	УдаляемыеСсылкиНаФормы = Новый Массив;
	Для Каждого КлючИЗначение Из ВременноеХранилищеКонтекстовОпераций Цикл
		
		Если КлючИЗначение.Значение.Форма.Открыта() Тогда
			ВременноеХранилищеКонтекстовОпераций[КлючИЗначение.Ключ].Время = ОбщегоНазначенияКлиент.ДатаСеанса();
			
		ИначеЕсли КлючИЗначение.Значение.Время + 15*60 < ОбщегоНазначенияКлиент.ДатаСеанса() Тогда
			УдаляемыеСсылкиНаФормы.Добавить(КлючИЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Форма Из УдаляемыеСсылкиНаФормы Цикл
		ВременноеХранилищеКонтекстовОпераций.Удалить(Форма);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПарольСертификата(СертификатСсылка, Пароль, ПояснениеПароля) Экспорт // АПК:78 - исключение для безопасного хранения паролей.
	
	УстановленныеПароли = ОбщиеВнутренниеДанные.Получить("УстановленныеПароли");
	ПоясненияУстановленныхПаролей = ОбщиеВнутренниеДанные.Получить("ПоясненияУстановленныхПаролей");
	
	Если УстановленныеПароли = Неопределено Тогда
		УстановленныеПароли = Новый Соответствие;
		ОбщиеВнутренниеДанные.Вставить("УстановленныеПароли", УстановленныеПароли);
		ПоясненияУстановленныхПаролей = Новый Соответствие;
		ОбщиеВнутренниеДанные.Вставить("ПоясненияУстановленныхПаролей", ПоясненияУстановленныхПаролей);
	КонецЕсли;
	
	УстановленныеПароли.Вставить(СертификатСсылка, ?(Пароль = Неопределено, Пароль, Строка(Пароль)));
	
	НовоеПояснениеПароля = Новый Структура;
	НовоеПояснениеПароля.Вставить("ТекстПояснения", "");
	НовоеПояснениеПароля.Вставить("ПояснениеГиперссылка", Ложь);
	НовоеПояснениеПароля.Вставить("ТекстПодсказки", "");
	НовоеПояснениеПароля.Вставить("ОбработкаДействия", Неопределено);
	
	Если ТипЗнч(ПояснениеПароля) = Тип("Структура") Тогда
		ЗаполнитьЗначенияСвойств(НовоеПояснениеПароля, ПояснениеПароля);
	КонецЕсли;
	
	ПоясненияУстановленныхПаролей.Вставить(СертификатСсылка, НовоеПояснениеПароля);
	
КонецПроцедуры

&НаКлиенте
Процедура СброситьПарольСертификата(СертификатСсылка) Экспорт // АПК:78 - исключение для безопасного хранения паролей.
	
	ХранилищеПаролей = ОбщиеВнутренниеДанные.Получить("ХранилищеПаролей");
	Если ХранилищеПаролей <> Неопределено Тогда
		ХранилищеПаролей.Вставить(СертификатСсылка, Неопределено);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
