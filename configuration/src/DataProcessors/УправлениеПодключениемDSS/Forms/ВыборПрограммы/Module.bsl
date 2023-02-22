///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ПрограммноеЗакрытие;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВидПрограммыЭлектроннойПодписи = "ПрограммаЭлектроннойПодписи";
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СервисКриптографииDSSСлужебныйКлиент.ПриОткрытииФормы(ЭтотОбъект, ПрограммноеЗакрытие);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если СервисКриптографииDSSСлужебныйКлиент.ПередЗакрытиемФормы(
			ЭтотОбъект,
			Отказ,
			ПрограммноеЗакрытие,
			ЗавершениеРаботы) Тогда
		ЗакрытьФорму();
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Добавить(Команда)
	
	РезультатВыбора = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию();
	РезультатВыбора.Вставить("Результат", ВидПрограммыЭлектроннойПодписи);
	
	ЗакрытьФорму(РезультатВыбора);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗакрытьФорму(ПараметрыОперации = Неопределено)
	
	ПрограммноеЗакрытие = Истина;
	Если ТипЗнч(ПараметрыОперации) <> Тип("Структура")
		ИЛИ ПараметрыОперации.Количество() = 0 Тогда
		ПараметрыОперации = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Ложь);
	КонецЕсли;
	
	Закрыть(ПараметрыОперации);
	
КонецПроцедуры

#КонецОбласти