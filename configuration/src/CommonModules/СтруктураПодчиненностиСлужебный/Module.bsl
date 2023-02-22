///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПереименованийОбъектовМетаданных.
Процедура ПриДобавленииПереименованийОбъектовМетаданных(Итог) Экспорт
	
	Библиотека = "СтандартныеПодсистемы";
	
	СтароеИмя = "Роль.ИспользованиеСтруктурыПодчиненности";
	НовоеИмя  = "Роль.ПросмотрСвязанныеДокументы";
	ОбщегоНазначения.ДобавитьПереименование(Итог, "2.3.3.5", СтароеИмя, НовоеИмя, Библиотека);
	
КонецПроцедуры

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииКомандПодключенныхКОбъекту
//
// Параметры:
//   ВидыПодключаемыхКоманд - см. ПодключаемыеКомандыПереопределяемый.ПриОпределенииВидовПодключаемыхКоманд.ВидыПодключаемыхКоманд
//
Процедура ПриОпределенииВидовПодключаемыхКоманд(ВидыПодключаемыхКоманд) Экспорт
	
	Вид = ВидыПодключаемыхКоманд.Добавить();
	Вид.Имя         = "СвязанныеДокументы";
	Вид.ИмяПодменю  = "ПодменюОтчеты";
	Вид.Заголовок   = НСтр("ru = 'Отчеты'");
	Вид.Порядок     = 50;
	Вид.Картинка    = БиблиотекаКартинок.Отчет;
	Вид.Отображение = ОтображениеКнопки.КартинкаИТекст;
	
КонецПроцедуры

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииКомандПодключенныхКОбъекту
Процедура ПриОпределенииКомандПодключенныхКОбъекту(НастройкиФормы, Источники, ПодключенныеОтчетыИОбработки, Команды) Экспорт
	
	МетаданныеФормы = Метаданные.ОбщиеФормы.СвязанныеДокументы;
	Если Не ПравоДоступа("Просмотр", МетаданныеФормы) Тогда
		Возврат;
	КонецЕсли;
	
	ТипПараметраКоманды = ТипПараметраКоманды(Источники);
	Если ТипПараметраКоманды = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Команда = Команды.Добавить();
	Команда.Представление      = НСтр("ru = 'Связанные документы'");
	Команда.Вид                = "СвязанныеДокументы";
	Команда.МножественныйВыбор = Ложь;
	Команда.ИмяПараметраФормы  = "ОбъектОтбора";
	Команда.ИмяФормы           = МетаданныеФормы.ПолноеИмя();
	Команда.Важность           = "СмТакже";
	Команда.ТипПараметра       = ТипПараметраКоманды;
	Команда.СочетаниеКлавиш    = Новый СочетаниеКлавиш(Клавиша.S, Ложь, Истина, Истина);
	Команда.Картинка           = БиблиотекаКартинок.СтруктураПодчиненности;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ТипПараметраКоманды(Источники)
	
	ТипыИсточников = Новый Массив;
	ЗаполнитьТипыИсточников(ТипыИсточников, Источники.Строки);
	ТипыИсточников = ОбщегоНазначенияКлиентСервер.СвернутьМассив(ТипыИсточников);
	
	ИндексТиповСвязанныхОбъектов = ИндексТиповСвязанныхОбъектов();
	
	Индекс = ТипыИсточников.ВГраница();
	Пока Индекс >= 0 Цикл
		
		ТипИсточника = ТипыИсточников[Индекс];
		Если ИндексТиповСвязанныхОбъектов[ТипИсточника] = Неопределено Тогда 
			ТипыИсточников.Удалить(Индекс);
		КонецЕсли;
		
		Индекс = Индекс - 1;
		
	КонецЦикла;
	
	Возврат ?(ТипыИсточников.Количество() > 0, Новый ОписаниеТипов(ТипыИсточников), Неопределено);
	
КонецФункции

Процедура ЗаполнитьТипыИсточников(ТипыИсточников, Источники)
	
	Для Каждого Источник Из Источники Цикл 
		
		Если ТипЗнч(Источник.ТипСсылкиДанных) = Тип("Тип") Тогда
			
			ТипыИсточников.Добавить(Источник.ТипСсылкиДанных);
			
		ИначеЕсли ТипЗнч(Источник.ТипСсылкиДанных) = Тип("ОписаниеТипов") Тогда
			
			ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ТипыИсточников, Источник.ТипСсылкиДанных.Типы());
			
		КонецЕсли;
		
		ЗаполнитьТипыИсточников(ТипыИсточников, Источник.Строки);
		
	КонецЦикла;
	
КонецПроцедуры

Функция ИндексТиповСвязанныхОбъектов()
	
	Индекс = Новый Соответствие;
	
	МетаданныеСвязанныхОбъектов = Метаданные.КритерииОтбора.СвязанныеДокументы;
	ТипыСвязанныхОбъектов = МетаданныеСвязанныхОбъектов.Тип.Типы();
	ТипПараметраКоманды = Метаданные.ОбщиеКоманды.СвязанныеДокументы.ТипПараметраКоманды;
	
	Для Каждого ТипСвязанногоОбъекта Из ТипыСвязанныхОбъектов Цикл 
		
		Если Не ТипПараметраКоманды.СодержитТип(ТипСвязанногоОбъекта) Тогда 
			Индекс.Вставить(ТипСвязанногоОбъекта, Истина);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Индекс;
	
КонецФункции

#КонецОбласти
