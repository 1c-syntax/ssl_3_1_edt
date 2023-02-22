///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПрочитатьПараметрыПрописи();
	УстановитьСклоненияПараметровПрописи(ЭтотОбъект);
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.СклонениеЦелойЧасти.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
		Элементы.ГруппаПараметрыДробнойЧасти.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
		Элементы.ГруппаПримерПрописи.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
		Элементы.СуммаПрописью.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Верх;
		Элементы.СуммаПрописью.Высота = 2;
		Элементы.СуммаПрописью.МногострочныйРежим = Истина;
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СуммаЧисло = 123.45;
	УстановитьСуммуПрописью();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПолеВводаПриИзменении(Элемент)
	
	Если Элемент = Элементы.ЦелаяЧастьРод
		Или Элемент = Элементы.ДробнаяЧастьРод Тогда
		УстановитьСклоненияПараметровПрописи(ЭтотОбъект);
	КонецЕсли;
	
	Модифицированность = Истина;
	УстановитьСуммуПрописью();
	ОповеститьВладельца();
	
КонецПроцедуры

&НаКлиенте
Процедура ПолеВводаИзменениеТекстаРедактирования(Элемент, Текст, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	ОповеститьВладельца(Истина, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	
	ОповеститьВладельца(Истина);
	Модифицированность = ВладелецФормы.Модифицированность;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПараметрыПрописи(Форма)
	
	ПараметрыПрописи = Новый Массив;
	ПараметрыПрописи.Добавить(Форма.ЦелаяЧастьОдин);
	ПараметрыПрописи.Добавить(Форма.ЦелаяЧатьДва);
	ПараметрыПрописи.Добавить(Форма.ЦелаяЧастьПять);
	ПараметрыПрописи.Добавить(Форма.ЦелаяЧастьРод);
	ПараметрыПрописи.Добавить(Форма.ДробнаяЧастьОдин);
	ПараметрыПрописи.Добавить(Форма.ДробнаяЧастьДва);
	ПараметрыПрописи.Добавить(Форма.ДробнаяЧастьПять);
	ПараметрыПрописи.Добавить(Форма.ДробнаяЧастьРод);
	ПараметрыПрописи.Добавить(Форма.ДлинаДробнойЧасти);
	
	Возврат СтрСоединить(ПараметрыПрописи, ", ");;
	
КонецФункции

&НаКлиенте
Процедура УстановитьСуммуПрописью()
	
	Если ЗначениеЗаполнено(Параметры.КодЯзыка) Тогда
		СуммаПрописью = ЧислоПрописью(СуммаЧисло, "L=" + Параметры.КодЯзыка + ";ДП=Ложь", ПараметрыПрописи(ЭтотОбъект)); // АПК:1357
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьПараметрыПрописи()
	
	ПараметрыПрописи = СтрРазделить(Параметры.ПараметрыПрописи, ",", Истина);
	Если ПараметрыПрописи.Количество() <> 9 Тогда
		Возврат;
	КонецЕсли;
	
	ЦелаяЧастьОдин = СокрЛП(ПараметрыПрописи[0]);
	ЦелаяЧатьДва = СокрЛП(ПараметрыПрописи[1]);
	ЦелаяЧастьПять = СокрЛП(ПараметрыПрописи[2]);
	ЦелаяЧастьРод = СокрЛП(ПараметрыПрописи[3]);
	ДробнаяЧастьОдин = СокрЛП(ПараметрыПрописи[4]);
	ДробнаяЧастьДва = СокрЛП(ПараметрыПрописи[5]);
	ДробнаяЧастьПять = СокрЛП(ПараметрыПрописи[6]);
	ДробнаяЧастьРод = СокрЛП(ПараметрыПрописи[7]);
	ДлинаДробнойЧасти = ОчиститьСтрокуСЧисломОтПостороннихСимволов(ПараметрыПрописи[8]);
	
КонецПроцедуры

&НаСервере
Функция ОчиститьСтрокуСЧисломОтПостороннихСимволов(СтрокаСЧислом)
	
	ПосторонниеСимволы = СтрСоединить(СтрРазделить(СтрокаСЧислом, "0123456789", Ложь), "");
	Возврат СтрСоединить(СтрРазделить(СтрокаСЧислом, ПосторонниеСимволы, Ложь), "");
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСклоненияПараметровПрописи(Форма)
	
	// Склонение заголовков параметров прописи.
	
	Элементы = Форма.Элементы;
	
	Если Форма.ЦелаяЧастьРод = "ж" Тогда
		Элементы.ЦелаяЧастьОдин.Заголовок = НСтр("ru = 'Одна'");
		Элементы.ЦелаяЧатьДва.Заголовок = НСтр("ru = 'Две'");
	ИначеЕсли Форма.ЦелаяЧастьРод = "м" Тогда
		Элементы.ЦелаяЧастьОдин.Заголовок = НСтр("ru = 'Один'");
		Элементы.ЦелаяЧатьДва.Заголовок = НСтр("ru = 'Два'");
	Иначе
		Элементы.ЦелаяЧастьОдин.Заголовок = НСтр("ru = 'Одно'");
		Элементы.ЦелаяЧатьДва.Заголовок = НСтр("ru = 'Два'");
	КонецЕсли;
	
	Если Форма.ДробнаяЧастьРод = "ж" Тогда
		Элементы.ДробнаяЧастьОдин.Заголовок = НСтр("ru = 'Одна'");
		Элементы.ДробнаяЧастьДва.Заголовок = НСтр("ru = 'Две'");
	ИначеЕсли Форма.ДробнаяЧастьРод = "м" Тогда
		Элементы.ДробнаяЧастьОдин.Заголовок = НСтр("ru = 'Один'");
		Элементы.ДробнаяЧастьДва.Заголовок = НСтр("ru = 'Два'");
	Иначе
		Элементы.ДробнаяЧастьОдин.Заголовок = НСтр("ru = 'Одно'");
		Элементы.ДробнаяЧастьДва.Заголовок = НСтр("ru = 'Два'");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОповеститьВладельца(Записать = Ложь, Закрыть = Ложь)
	
	ПараметрыПрописи = Новый Структура;
	ПараметрыПрописи.Вставить("КодЯзыка", Параметры.КодЯзыка);
	ПараметрыПрописи.Вставить("ПараметрыПрописи", ПараметрыПрописи(ЭтотОбъект));
	ПараметрыПрописи.Вставить("Записать", Записать);
	ПараметрыПрописи.Вставить("Закрыть", Закрыть);
	
	Оповестить("ПараметрыПрописиВалюты", ПараметрыПрописи, ВладелецФормы);
	
КонецПроцедуры

#КонецОбласти

