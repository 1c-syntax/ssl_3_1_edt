///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.УправлениеДоступом

// Параметры:
//   Ограничение - см. УправлениеДоступомПереопределяемый.ПриЗаполненииОграниченияДоступа.Ограничение.
//
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЧтениеСпискаРазрешено(ПроблемныйОбъект)";
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ДополнительныеПараметры = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыОтметкиОбработки();
	ДополнительныеПараметры.ЭтоНезависимыйРегистрСведений = Истина;
	ДополнительныеПараметры.ПолноеИмяРегистра             = Метаданные.РегистрыСведений.РезультатыПроверкиУчета.ПолноеИмя();
	
	ОтработаныВсеПроблемы = Ложь;
	КлючУникальности      = ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор();
	Пока Не ОтработаныВсеПроблемы Цикл
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1000
			|	РезультатыПроверкиУчета.ПроблемныйОбъект КАК ПроблемныйОбъект,
			|	РезультатыПроверкиУчета.ПравилоПроверки КАК ПравилоПроверки,
			|	РезультатыПроверкиУчета.ВидПроверки КАК ВидПроверки,
			|	РезультатыПроверкиУчета.КлючУникальности КАК КлючУникальности
			|ИЗ
			|	РегистрСведений.РезультатыПроверкиУчета КАК РезультатыПроверкиУчета
			|ГДЕ
			|	РезультатыПроверкиУчета.КлючУникальности > &КлючУникальности
			|
			|УПОРЯДОЧИТЬ ПО
			|	КлючУникальности";
		
		Запрос.УстановитьПараметр("КлючУникальности", КлючУникальности);
		Результат = Запрос.Выполнить().Выгрузить();
	
		ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, Результат, ДополнительныеПараметры);
		
		КоличествоЗаписей = Результат.Количество();
		Если КоличествоЗаписей < 1000 Тогда
			ОтработаныВсеПроблемы = Истина;
		КонецЕсли;
		
		Если КоличествоЗаписей > 0 Тогда
			КлючУникальности = Результат[КоличествоЗаписей - 1].КлючУникальности;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ОбработкаЗавершена = Истина;
	
	МетаданныеРегистра    = Метаданные.РегистрыСведений.РезультатыПроверкиУчета;
	ПолноеИмяРегистра     = МетаданныеРегистра.ПолноеИмя();
	ПредставлениеРегистра = МетаданныеРегистра.Представление();
	ПредставлениеОтбора   = НСтр("ru = 'Проблемный объект = ""%1""
		|Правило проверки = ""%2""
		|Вид проверки = ""%3""
		|Ключ уникальности = ""%4""'");
	
	ДополнительныеПараметрыВыборкиДанныхДляОбработки = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыВыборкиДанныхДляОбработки();
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьИзмеренияНезависимогоРегистраСведенийДляОбработки(
		Параметры.Очередь, ПолноеИмяРегистра, ДополнительныеПараметрыВыборкиДанныхДляОбработки);
	
	ОбъектовОбработано = 0;
	ПроблемныхОбъектов = 0;
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		
		Попытка
			
			ПроблемныйОбъект = Выборка.ПроблемныйОбъект;
			ПравилоПроверки  = Выборка.ПравилоПроверки;
			ВидПроверки      = Выборка.ВидПроверки;
			КлючУникальности = Выборка.КлючУникальности;
			
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить(ПолноеИмяРегистра);
			ЭлементБлокировки.УстановитьЗначение("ПроблемныйОбъект", ПроблемныйОбъект);
			ЭлементБлокировки.УстановитьЗначение("ПравилоПроверки",  ПравилоПроверки);
			ЭлементБлокировки.УстановитьЗначение("ВидПроверки",      ВидПроверки);
			ЭлементБлокировки.УстановитьЗначение("КлючУникальности", КлючУникальности);
			Блокировка.Заблокировать();
			
			НаборЗаписей = СоздатьНаборЗаписей();
			Отбор = НаборЗаписей.Отбор;
			Отбор.КлючУникальности.Установить(КлючУникальности);
			Отбор.ПроблемныйОбъект.Установить(ПроблемныйОбъект);
			Отбор.ПравилоПроверки.Установить(ПравилоПроверки);
			Отбор.ВидПроверки.Установить(ВидПроверки);
			
			ПредставлениеОтбора = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ПредставлениеОтбора, ПроблемныйОбъект, ПравилоПроверки, ВидПроверки, КлючУникальности);
			
			НаборЗаписей.Прочитать();
			Для Каждого ТекущаяЗапись Из НаборЗаписей Цикл
				
				Если Не ЗначениеЗаполнено(ТекущаяЗапись.КонтрольнаяСумма) Тогда
					ТекущаяЗапись.КонтрольнаяСумма = КонтрольВеденияУчетаСлужебный.КонтрольнаяСуммаПроблемы(ТекущаяЗапись);
				КонецЕсли;
				
				Если ТекущаяЗапись.УдалитьИгнорироватьПроблему И Не ТекущаяЗапись.ИгнорироватьПроблему Тогда
					ТекущаяЗапись.ИгнорироватьПроблему = ТекущаяЗапись.УдалитьИгнорироватьПроблему;
				КонецЕсли;
				
			КонецЦикла;
			
			ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписей);
			
			ОбъектовОбработано = ОбъектовОбработано + 1;
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			ОтменитьТранзакцию();
			
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать набор записей регистра ""%1"" с отбором %2 по причине:
				|%3'"), ПредставлениеРегистра, ПредставлениеОтбора, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
				МетаданныеРегистра, , ТекстСообщения);
			
		КонецПопытки;
		
	КонецЦикла;
	
	Если Не ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "РегистрСведений.РезультатыПроверкиУчета") Тогда
		ОбработкаЗавершена = Ложь;
	КонецЕсли;
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедуре РегистрыСведений.РезультатыПроверкиУчета.ОбработатьДанныеДляПереходаНаНовуюВерсию не удалось обработать некоторые записи проблемных объектов (пропущены): %1'"), 
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			, ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедура РегистрыСведений.НаличиеФайлов.ОбработатьДанныеДляПереходаНаНовуюВерсию обработала очередную порцию проблемных объектов: %1'"),
			ОбъектовОбработано));
	КонецЕсли;
	
	Параметры.ОбработкаЗавершена = ОбработкаЗавершена;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли