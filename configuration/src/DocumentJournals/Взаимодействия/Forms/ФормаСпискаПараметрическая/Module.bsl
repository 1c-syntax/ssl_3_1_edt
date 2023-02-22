///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем КонтекстВыбора;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	УстановитьУсловноеОформление();
	
	Взаимодействия.ИнициализироватьФормуСпискаВзаимодействий(ЭтотОбъект, Параметры);
	Элементы.СписокСоздатьЭлектронноеПисьмоОтдельнаяКнопкаДерево.Видимость = ТолькоПочта;
	Элементы.ГруппаСоздатьДерево.Видимость = НЕ ТолькоПочта;
	Если ТолькоПочта Тогда
		ЗаголовокУчастникиПочта =  НСтр("ru = 'Кому, от'");
		Элементы.ДеревоВзаимодействийУчастники.Заголовок = ЗаголовокУчастникиПочта;
		Элементы.Участники.Заголовок = ЗаголовокУчастникиПочта;
	КонецЕсли;
	
	
	
	Если ТипЗнч(Параметры.Отбор) = Тип("Структура") Тогда
		
		ШаблонЗаголовка = НСтр("ru = 'Взаимодействия по %1'");
		
		Если Параметры.Отбор.Свойство("Предмет") Тогда
			
			Если ТипЗнч(Параметры.ДополнительныеПараметры) = Тип("Структура") 
				И Параметры.ДополнительныеПараметры.Свойство("ТипВзаимодействия") Тогда
				
				Если Параметры.ДополнительныеПараметры.ТипВзаимодействия = "Взаимодействие" Тогда
					ПредметДляОтбора = Взаимодействия.ПолучитьЗначениеПредмета(Параметры.Отбор.Предмет);
					Параметры.Отбор.Предмет = ПредметДляОтбора ;
				ИначеЕсли Параметры.ДополнительныеПараметры.ТипВзаимодействия = "Предмет" Тогда
					ПредметДляОтбора = Параметры.Отбор.Предмет;
				КонецЕсли;
			КонецЕсли;
			
			Параметры.Отбор.Удалить("Предмет");
			УстановитьОтборПоПредмету();
			
			Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, ОбщегоНазначения.ПредметСтрокой(ПредметДляОтбора));
			
		ИначеЕсли Параметры.Отбор.Свойство("Контакт") Тогда
			
			Контакт = Параметры.Отбор.Контакт;
			Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, ОбщегоНазначения.ПредметСтрокой(Контакт));
			Параметры.Отбор.Удалить("Контакт");
			УстановитьОтборПоКонтакту();
			
		КонецЕсли;
	КонецЕсли;
	
	Взаимодействия.ЗаполнитьСписокДоступныхДляСозданияДокументов(ДокументыДоступныеДляСоздания);
	Взаимодействия.ЗаполнитьПодменюПоТипуВзаимодействия(Элементы.ДеревоТипВзаимодействия, ЭтотОбъект);
	Взаимодействия.ЗаполнитьПодменюПоТипуВзаимодействия(Элементы.СписокТипВзаимодействия, ЭтотОбъект);
	
	ТипВзаимодействия = ?(ТолькоПочта,"ВсеПисьма","Все");
	Статус = "Все";
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	Статус = Настройки.Получить("Статус");
	Если Статус <> Неопределено Тогда
		Настройки.Удалить("Статус");
	КонецЕсли;
	Если Не ИспользоватьПризнакРассмотрено Или НЕ ЗначениеЗаполнено(Статус) Тогда
		Статус = "Все";
	КонецЕсли;
	Ответственный = Настройки.Получить("Ответственный");
	Если Ответственный <> Неопределено Тогда
		Настройки.Удалить("Ответственный");
	КонецЕсли;
	ВВидеДерева = Настройки.Получить("ВВидеДерева");
	Если ВВидеДерева <> Неопределено Тогда
		Настройки.Удалить("ВВидеДерева");
	КонецЕсли;
	
	Взаимодействия.ПриЗагрузкеТипаВзаимодействийИзНастроек(ЭтотОбъект, Настройки);
	
	УправлениеСтраницамиСервер();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ВзаимодействияКлиентСервер.ЯвляетсяВзаимодействием(Источник) Тогда
		Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаДерево Тогда
			ЗаполнитьДеревоВзаимодействийКлиент();
		Иначе
			Если ОтборПоПредмету Тогда
				УстановитьОтборПоПредмету();
			Иначе
				УстановитьОтборПоКонтакту();
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("Справочник.Пользователи.Форма.ФормаСписка") Тогда
		
		Если ВыбранноеЗначение <> Неопределено Тогда
			
			МассивИзмененныхДокументов = Новый Массив;
			ВыполненаЗамена = Ложь;
			УстановитьОтветственного(ВыбранноеЗначение, МассивИзмененныхДокументов);
			
			Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
				Если МассивИзмененныхДокументов.Количество() > 0 Тогда
					Элементы.Список.Обновить();
				КонецЕсли;
			Иначе
				Если МассивИзмененныхДокументов.Количество() > 0  Тогда
					РазвернутьВсеСтрокиДерева();
				КонецЕсли;
			КонецЕсли;
			
			Для Каждого ИзмененныйДокумент Из МассивИзмененныхДокументов Цикл
				
				Оповестить("ЗаписьВзаимодействия", ИзмененныйДокумент);
				
			КонецЦикла;
			
		КонецЕсли;
		
	ИначеЕсли КонтекстВыбора = "ПредметВыполнитьТипПредмета" Тогда
		
		Если ВыбранноеЗначение = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		КонтекстВыбора = "ПредметВыполнить";
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("РежимВыбора", Истина);
		
		ОткрытьФорму(ВыбранноеЗначение + ".ФормаВыбора", ПараметрыФормы, ЭтотОбъект);
		
		Возврат;
		
	ИначеЕсли КонтекстВыбора = "ПредметВыполнить" Тогда
		
		Если ВыбранноеЗначение <> Неопределено Тогда
			
			Если ОтборПоПредмету И ПредметДляОтбора = ВыбранноеЗначение Тогда
				Возврат;
			КонецЕсли;
			
			ВыполненаЗамена = Ложь;
			УстановитьПредмет(ВыбранноеЗначение, ВыполненаЗамена);
			
			Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
				Если ВыполненаЗамена Тогда
					Элементы.Список.Обновить();
				КонецЕсли;
			Иначе
				Если ВыполненаЗамена Тогда
					РазвернутьВсеСтрокиДерева();
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОтветственныйПриИзменении(Элемент)
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		ВзаимодействияКлиентСервер.БыстрыйОтборСписокПриИзменении(ЭтотОбъект, Элемент.Имя,, ОтборПоПредмету);
		
	Иначе
		
		ЗаполнитьДеревоВзаимодействийКлиент();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СтатусПриИзменении(Элемент)
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		ДатаДляОтбора = ОбщегоНазначенияКлиент.ДатаСеанса();
		ВзаимодействияКлиентСервер.БыстрыйОтборСписокПриИзменении(ЭтотОбъект,Элемент.Имя, ДатаДляОтбора, ОтборПоПредмету);
		
	Иначе
		
		ЗаполнитьДеревоВзаимодействийКлиент();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ЗначенияЗаполнения = Новый Структура("Предмет,Контакт",ПредметДляОтбора,Контакт);
	
	ВзаимодействияКлиент.СписокПередНачаломДобавления(
		Элемент,Отказ,Копирование,ТолькоПочта,ДокументыДоступныеДляСоздания,
		Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения));
	
КонецПроцедуры 

&НаКлиенте
Процедура ДеревоВзаимодействийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(, ТекущиеДанные.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоВзаимодействийПередУдалением(Элемент, Отказ)
	
	Отказ = Истина;
	Если Элементы.ДеревоВзаимодействий.ВыделенныеСтроки.Количество() > 0 Тогда
		
		ЕстьПомеченныеНаУдаление = Ложь;
		Для каждого ВыделеннаяСтрока Из Элементы.ДеревоВзаимодействий.ВыделенныеСтроки Цикл
			Если Элементы.ДеревоВзаимодействий.ДанныеСтроки(ВыделеннаяСтрока).ПометкаУдаления Тогда
				ЕстьПомеченныеНаУдаление = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ЕстьПомеченныеНаУдаление Тогда
			ТекстВопроса = НСтр("ru = 'Снять с выделенных элементов пометку на удаление?'");
		Иначе
			ТекстВопроса = НСтр("ru = 'Пометить выделенные строки на удаление?'");
		КонецЕсли;
		
		ДополнительныеПараметры = Новый Структура("ЕстьПомеченныеНаУдаление", ЕстьПомеченныеНаУдаление);
		ОбработчикОповещенияОЗакрытии = Новый ОписаниеОповещения("ВопросОПометкеНаУдалениеПослеЗавершения", ЭтотОбъект, ДополнительныеПараметры);
		ПоказатьВопрос(ОбработчикОповещенияОЗакрытии,
		               ТекстВопроса,РежимДиалогаВопрос.ДаНет);
		
	КонецЕсли;
	
КонецПроцедуры 

&НаКлиенте
Процедура ДеревоВзаимодействийПередНачаломИзменения(Элемент, Отказ)
	
	Отказ = Истина;
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено Тогда
		ПоказатьЗначение(, ТекущиеДанные.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоВзаимодействийПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Отказ = Истина;
	Если Копирование Тогда
		ТекущиеДанные = Элемент.ТекущиеДанные;
		Если ТекущиеДанные <> Неопределено Тогда
			Если ТипЗнч(ТекущиеДанные.Ссылка) = Тип("ДокументСсылка.ЭлектронноеПисьмоВходящее") 
				ИЛИ ТипЗнч(ТекущиеДанные.Ссылка) = Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее") Тогда
				
				ПоказатьПредупреждение(, НСтр("ru = 'Копирование электронных писем запрещено'"));
				
			ИначеЕсли ТипЗнч(ТекущиеДанные.Ссылка) = Тип("ДокументСсылка.Встреча") Тогда
				
				ОткрытьФорму("Документ.Встреча.ФормаОбъекта",
					Новый Структура("ЗначениеКопирования", ТекущиеДанные.Ссылка), ЭтотОбъект);
				
			ИначеЕсли ТипЗнч(ТекущиеДанные.Ссылка) = Тип("ДокументСсылка.ЗапланированноеВзаимодействие") Тогда
				
				ОткрытьФорму("Документ.ЗапланированноеВзаимодействие.ФормаОбъекта",
					Новый Структура("ЗначениеКопирования", ТекущиеДанные.Ссылка), ЭтотОбъект);
				
			ИначеЕсли ТипЗнч(ТекущиеДанные.Ссылка) = Тип("ДокументСсылка.ТелефонныйЗвонок") Тогда
				
				ОткрытьФорму("Документ.ТелефонныйЗвонок.ФормаОбъекта", 
					Новый Структура("ЗначениеКопирования",ТекущиеДанные.Ссылка), ЭтотОбъект);
				
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТипВзаимодействияПриИзменении(Элемент)
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		ВзаимодействияКлиентСервер.ПриИзмененииОтбораТипВзаимодействий(ЭтотОбъект, ТипВзаимодействия);
	Иначе
		ЗаполнитьДеревоВзаимодействийКлиент();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТипВзаимодействияСтатусОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// Изменяет отбор по типу взаимодействия в списке.
// 
// Параметры:
//  Команда - КомандаФормы - выполняемая команда.
//
&НаКлиенте
Процедура Подключаемый_ИзменитьОтборТипВзаимодействия(Команда)

	ИзменитьОтборТипВзаимодействияСервер(Команда.Имя);
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница <> Элементы.СтраницаСписок Тогда
		ЗаполнитьДеревоВзаимодействийКлиент();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура РассмотреноВыполнить(Команда)
	
	Если НЕ ВыборКорректен() Тогда
		Возврат;
	КонецЕсли;
	
	ФлагРассмотрено = (Не Команда.Имя = "НеРассмотрено");
	
	ВыполненаЗамена = Ложь;
	МассивВзаимодействий = Новый Массив;
	УстановитьФлагРассмотрено(ВыполненаЗамена, ФлагРассмотрено, МассивВзаимодействий);
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		Если ВыполненаЗамена Тогда
			Элементы.Список.Обновить();
		КонецЕсли;
		
	Иначе
		
		Если ВыполненаЗамена Тогда
			РазвернутьВсеСтрокиДерева();
		КонецЕсли;
		
	КонецЕсли;
	
	Если ВыполненаЗамена Тогда
		
		Для Каждого Взаимодействие Из МассивВзаимодействий Цикл
			Оповестить("ЗаписьВзаимодействия", Взаимодействие);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтветственныйВыполнить()
	
	Если НЕ ВыборКорректен() Тогда
		Возврат;
	КонецЕсли;
	
	КонтекстВыбора = Неопределено;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("РежимВыбора", Истина);
	
	ОткрытьФорму("Справочник.Пользователи.Форма.ФормаСписка", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредметВыполнить()
	
	Если НЕ ВыборКорректен() Тогда
		Возврат;
	КонецЕсли;
	
	КонтекстВыбора = "ПредметВыполнитьТипПредмета";
	ОткрытьФорму("ЖурналДокументов.Взаимодействия.Форма.ВыборТипаПредмета",,ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьИнтервал(Команда)
	
	Диалог = Новый ДиалогРедактированияСтандартногоПериода();
	Диалог.Период = Интервал;
	ОбработчикОповещенияЗакрытия = Новый ОписаниеОповещения("ВыборИнтервалаЗакрытие", ЭтотОбъект);
	Диалог.Показать(ОбработчикОповещенияЗакрытия);
	
КонецПроцедуры 

&НаКлиенте
Процедура ОтложитьРассмотрениеВыполнить(Команда)
	
	Если НЕ ВыборКорректен() Тогда
		Возврат;
	КонецЕсли;
	
	ДатаОтработки = ОбщегоНазначенияКлиент.ДатаСеанса();
	ОбработчикОповещенияОЗакрытии = Новый ОписаниеОповещения("ВводДатыОтложитьРассмотрениеПослеЗавершения", ЭтотОбъект);
	ПоказатьВводДаты(ОбработчикОповещенияОЗакрытии, ДатаОтработки, НСтр("ru = 'Отработать после'"));
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьВстречу(Команда)
	
	СоздатьНовоеВзаимодействие("Встреча");
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьЗапланированноеВзаимодействие(Команда)
	
	СоздатьНовоеВзаимодействие("ЗапланированноеВзаимодействие");
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьТелефонныйЗвонок(Команда)
	
	СоздатьНовоеВзаимодействие("ТелефонныйЗвонок");
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьЭлектронноеПисьмо(Команда)
	
	СоздатьНовоеВзаимодействие("ЭлектронноеПисьмоИсходящее");
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьНовоеВзаимодействие(ТипОбъекта)

	ЗначенияЗаполнения = Новый Структура("Предмет,Контакт",ПредметДляОтбора,Контакт);
	
	ВзаимодействияКлиент.СоздатьНовоеВзаимодействие(
	          ТипОбъекта,
	          Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения),
	          ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура СоздатьСообщениеSMS(Команда)
	
	СоздатьНовоеВзаимодействие("СообщениеSMS");
	
КонецПроцедуры

&НаКлиенте
Процедура ПереключитьРежимПросмотра(Команда)
	
	ПереключитьРежимПросмотраСервер();
	
КонецПроцедуры 

&НаКлиенте
Процедура ОбновитьДерево(Команда)
	
	ЗаполнитьДеревоВзаимодействийКлиент();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	СтандартныеПодсистемыСервер.УстановитьУсловноеОформлениеПоляДата(ЭтотОбъект, "ДеревоВзаимодействий.Дата", Элементы.ДеревоВзаимодействийДата.Имя);
	СтандартныеПодсистемыСервер.УстановитьУсловноеОформлениеПоляДата(ЭтотОбъект, "Список.Дата", Элементы.Список.Имя);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Список.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Список.Рассмотрено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ИспользоватьПризнакРассмотрено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("Шрифт", Метаданные.ЭлементыСтиля.ОсновнойЭлементСписка.Значение);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ДеревоВзаимодействий.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДеревоВзаимодействий.Рассмотрено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ИспользоватьПризнакРассмотрено");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("Шрифт", Метаданные.ЭлементыСтиля.ОсновнойЭлементСписка.Значение);

КонецПроцедуры

&НаСервере
Процедура ИзменитьОтборТипВзаимодействияСервер(ИмяКоманды)

	ТипВзаимодействия = Взаимодействия.ТипВзаимодействияПоИмениКоманды(ИмяКоманды, ТолькоПочта);
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		ПриИзмененииТипаСервер();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура УстановитьФлагРассмотрено(ВыполненаЗамена, ФлагРассмотрено, МассивВзаимодействий)
	
	ВыполненаЗамена = Ложь;
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
		ТипГруппировка = Тип("СтрокаГруппировкиДинамическогоСписка");
		
		Для Каждого Взаимодействие Из ВыделенныеСтроки Цикл
			Если ЗначениеЗаполнено(Взаимодействие)
				И ТипЗнч(Взаимодействие) <> ТипГруппировка Тогда
					МассивВзаимодействий.Добавить(Взаимодействие);
			КонецЕсли;
		КонецЦикла;
		
		Взаимодействия.УстановитьПризнакРассмотрено(МассивВзаимодействий,ФлагРассмотрено, ВыполненаЗамена);
		
	Иначе
		
		ВыделенныеСтроки = Элементы.ДеревоВзаимодействий.ВыделенныеСтроки;
		
		Для каждого Взаимодействие Из ВыделенныеСтроки Цикл
		
			ЭлементДерева = ДеревоВзаимодействий.НайтиПоИдентификатору(Взаимодействие);
			Если ЭлементДерева <> Неопределено И (НЕ ЭлементДерева.Рассмотрено = ФлагРассмотрено) Тогда
				МассивВзаимодействий.Добавить(ЭлементДерева.Ссылка);
			КонецЕсли;
			
		КонецЦикла;
		
		Взаимодействия.УстановитьПризнакРассмотрено(МассивВзаимодействий,ФлагРассмотрено, ВыполненаЗамена);
		
		Если ВыполненаЗамена Тогда
			ЗаполнитьДеревоВзаимодействий();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьОтветственного(Ответственный, МассивИзмененныхДокументов)
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
		
		ТипГруппировка = Тип("СтрокаГруппировкиДинамическогоСписка");
		Для Каждого Взаимодействие Из ВыделенныеСтроки Цикл
			Если ЗначениеЗаполнено(Взаимодействие)
				И ТипЗнч(Взаимодействие) <> ТипГруппировка
				И Взаимодействие.Ответственный <> Ответственный Тогда
					Взаимодействия.ЗаменитьОтветственногоВДокументе(Взаимодействие, Ответственный);
					МассивИзмененныхДокументов.Добавить(Взаимодействие);
			КонецЕсли;
		КонецЦикла;
		
	Иначе
		
		ВыделенныеСтроки = Элементы.ДеревоВзаимодействий.ВыделенныеСтроки;
		
		Для каждого Взаимодействие Из ВыделенныеСтроки Цикл
		
			ЭлементДерева = ДеревоВзаимодействий.НайтиПоИдентификатору(Взаимодействие);
			Если ЭлементДерева <> Неопределено И ЭлементДерева.Ответственный <> Ответственный Тогда
				Взаимодействия.ЗаменитьОтветственногоВДокументе(ЭлементДерева.Ссылка, Ответственный);
				
				МассивИзмененныхДокументов.Добавить(ЭлементДерева.Ссылка);
			КонецЕсли;
			
		КонецЦикла;
		
		Если МассивИзмененныхДокументов.Количество() > 0 Тогда
			ЗаполнитьДеревоВзаимодействий();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПредмет(Предмет,ВыполненаЗамена)
	
	МассивВзаимодействий = Новый Массив;
		
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
		
		ТипГруппировка = Тип("СтрокаГруппировкиДинамическогоСписка");
		Для Каждого Взаимодействие Из ВыделенныеСтроки Цикл
			Если ЗначениеЗаполнено(Взаимодействие)
				И ТипЗнч(Взаимодействие) <> ТипГруппировка Тогда
					МассивВзаимодействий.Добавить(Взаимодействие)
			КонецЕсли;
		КонецЦикла;
		
		Если МассивВзаимодействий.Количество() > 0 Тогда
			ВзаимодействияВызовСервера.УстановитьПредметДляМассиваВзаимодействий(МассивВзаимодействий, Предмет, Истина);
			ВыполненаЗамена = Истина;
		КонецЕсли;
		
	Иначе
		
		ВыделенныеСтроки = Элементы.ДеревоВзаимодействий.ВыделенныеСтроки;
		
		Для каждого Взаимодействие Из ВыделенныеСтроки Цикл
		
			ЭлементДерева = ДеревоВзаимодействий.НайтиПоИдентификатору(Взаимодействие);
			Если ЭлементДерева <> Неопределено И ЭлементДерева.Предмет <> Предмет Тогда
				МассивВзаимодействий.Добавить(ЭлементДерева.Ссылка);
			КонецЕсли;
			
		КонецЦикла;
		
		Если МассивВзаимодействий.Количество() > 0 Тогда
			ВзаимодействияВызовСервера.УстановитьПредметДляМассиваВзаимодействий(МассивВзаимодействий, Предмет, Истина);
			ВыполненаЗамена = Истина;
			ЗаполнитьДеревоВзаимодействий();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОтложитьРассмотрение(ДатаРассмотрения, ВыполненаЗамена = Ложь)
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
		МассивВзаимодействий = Новый Массив;
		
		ТипГруппировка = Тип("СтрокаГруппировкиДинамическогоСписка");
		Для Каждого Взаимодействие Из ВыделенныеСтроки Цикл
			Если ЗначениеЗаполнено(Взаимодействие)
				И ТипЗнч(Взаимодействие) <> ТипГруппировка Тогда
					МассивВзаимодействий.Добавить(Взаимодействие);
			КонецЕсли;
		КонецЦикла;
		
		МассивВзаимодействий = Взаимодействия.МассивВзаимодействийДляИзмененияДатыРассмотрения(МассивВзаимодействий, ДатаРассмотрения);
		
		Для Каждого Взаимодействие Из МассивВзаимодействий Цикл
			
			Реквизиты = РегистрыСведений.ПредметыПапкиВзаимодействий.РеквизитыВзаимодействия();
			Реквизиты.РассмотретьПосле        = ДатаРассмотрения;
			Реквизиты.РассчитыватьРассмотрено = Ложь;
			
			РегистрыСведений.ПредметыПапкиВзаимодействий.ЗаписатьПредметыПапкиВзаимодействий(Взаимодействие, Реквизиты);
			ВыполненаЗамена = Истина;
			
		КонецЦикла;
		
	Иначе
		
		ВыделенныеСтроки = Элементы.ДеревоВзаимодействий.ВыделенныеСтроки;
		МассивВзаимодействий = Новый Массив;
		
		Для каждого Взаимодействие Из ВыделенныеСтроки Цикл
		
			ЭлементДерева = ДеревоВзаимодействий.НайтиПоИдентификатору(Взаимодействие);
			Если ЭлементДерева <> Неопределено И НЕ ЭлементДерева.Рассмотрено Тогда
				
				Реквизиты = РегистрыСведений.ПредметыПапкиВзаимодействий.РеквизитыВзаимодействия();
				Реквизиты.РассмотретьПосле        = ДатаРассмотрения;
				Реквизиты.РассчитыватьРассмотрено = Ложь;

				РегистрыСведений.ПредметыПапкиВзаимодействий.ЗаписатьПредметыПапкиВзаимодействий(ЭлементДерева.Ссылка, Реквизиты);
				ВыполненаЗамена = Истина;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если ВыполненаЗамена Тогда
			ЗаполнитьДеревоВзаимодействий();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ВыборКорректен()
	
	Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
		
		Если Элементы.Список.ВыделенныеСтроки.Количество() = 0 Тогда
			Возврат Ложь;
		КонецЕсли;
		
		Для Каждого Элемент Из Элементы.Список.ВыделенныеСтроки Цикл
			Если ТипЗнч(Элемент) <> Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
				Возврат Истина;
			КонецЕсли;
		КонецЦикла;
		
		Возврат Ложь;
		
	Иначе
		
		Если Элементы.ДеревоВзаимодействий.ВыделенныеСтроки.Количество() = 0 Тогда
			Возврат Ложь;
		Иначе
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура ПереключитьРежимПросмотраСервер()
	
	ВВидеДерева = НЕ ВВидеДерева;
	
	УправлениеСтраницамиСервер();
	
КонецПроцедуры

&НаСервере
Процедура УправлениеСтраницамиСервер()

	Если ВВидеДерева Тогда
		Интервал = Элементы.Список.Период;
		Команды.ПереключитьРежимПросмотра.Подсказка = НСтр("ru = 'Установить режим просмотра в виде списка'");
		Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаДерево;
		ЗаполнитьДеревоВзаимодействий();
	Иначе
		
		ДатаДляОтбора = ТекущаяДатаСеанса();
		Элементы.Список.Период = Интервал;
		Команды.ПереключитьРежимПросмотра.Подсказка = НСтр("ru = 'Установить режим просмотра в виде дерева'");
		Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок;
		ВзаимодействияКлиентСервер.БыстрыйОтборСписокПриИзменении(ЭтотОбъект,"Статус", ДатаДляОтбора, ОтборПоПредмету);
		ВзаимодействияКлиентСервер.БыстрыйОтборСписокПриИзменении(ЭтотОбъект,"Ответственный", ДатаДляОтбора, ОтборПоПредмету);
		ПриИзмененииТипаСервер();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДеревоВзаимодействий()
	
	Если ОтборПоПредмету Тогда
		СхемаОтбора = ЖурналыДокументов.Взаимодействия.ПолучитьМакет("ИерархияВзаимодействийПредмет");
	Иначе
		СхемаОтбора = ЖурналыДокументов.Взаимодействия.ПолучитьМакет("ИерархияВзаимодействийКонтакт");
	КонецЕсли;
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных();
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаОтбора));
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаОтбора.НастройкиПоУмолчанию);
	
	Если ОтборПоПредмету Тогда
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(КомпоновщикНастроек.Настройки.Отбор,
			"Предмет", ВидСравненияКомпоновкиДанных.Равно, ПредметДляОтбора);
	Иначе
		КомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Контакт",Контакт);
	КонецЕсли;
	
	КомпоновщикНастроек.Настройки.ПараметрыДанных.УстановитьЗначениеПараметра("Интервал",Интервал);
	
	ОтборНастройщикаКомпоновок = КомпоновщикНастроек.Настройки.Отбор;
	
	Если ТолькоПочта Тогда
		
		СписокТипыПрочиеВзаимодействия = Новый СписокЗначений;
		СписокТипыПрочиеВзаимодействия.Добавить(Тип("ДокументСсылка.Встреча"));
		СписокТипыПрочиеВзаимодействия.Добавить(Тип("ДокументСсылка.ЗапланированноеВзаимодействие"));
		СписокТипыПрочиеВзаимодействия.Добавить(Тип("ДокументСсылка.ТелефонныйЗвонок"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"Тип", ВидСравненияКомпоновкиДанных.НеВСписке, СписокТипыПрочиеВзаимодействия);
		
	КонецЕсли;
	
	// Быстрый отбор "Ответственный".
	Если НЕ Ответственный.Пустая() Тогда
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,"Ответственный",
			ВидСравненияКомпоновкиДанных.Равно, Ответственный);
	КонецЕсли;
	
	// Быстрый отбор "Статус"
	Если Статус = "КРассмотрению" Тогда
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Рассмотрено", ВидСравненияКомпоновкиДанных.Равно, Ложь);
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"РассмотретьПосле", ВидСравненияКомпоновкиДанных.МеньшеИлиРавно, ТекущаяДатаСеанса());
	ИначеЕсли Статус = "Отложенные" Тогда
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Рассмотрено", ВидСравненияКомпоновкиДанных.Равно, Ложь);
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"РассмотретьПосле", ВидСравненияКомпоновкиДанных.Заполнено,);
	ИначеЕсли Статус = "Рассмотренные" Тогда
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"Рассмотрено" ,ВидСравненияКомпоновкиДанных.Равно, Истина);
	КонецЕсли;
	
	// Быстрый отбор "Тип взаимодействия".
	Если ТипВзаимодействия = "ВсеПисьма" Или ТолькоПочта Тогда
		
		СписокТипыПисьма = Новый СписокЗначений;
		СписокТипыПисьма.Добавить(Тип("ДокументСсылка.ЭлектронноеПисьмоВходящее"));
		СписокТипыПисьма.Добавить(Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип",ВидСравненияКомпоновкиДанных.ВСписке,СписокТипыПисьма);
		
	ИначеЕсли ТипВзаимодействия = "ВходящиеПисьма" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"Тип",ВидСравненияКомпоновкиДанных.Равно,Тип("ДокументСсылка.ЭлектронноеПисьмоВходящее"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"ПометкаУдаления", ВидСравненияКомпоновкиДанных.Равно, Ложь);
		
	ИначеЕсли ТипВзаимодействия = "ПисьмаЧерновики" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"Тип",ВидСравненияКомпоновкиДанных.Равно,Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"ПометкаУдаления",ВидСравненияКомпоновкиДанных.Равно,Ложь);
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"СтатусИсходящегоПисьма", ВидСравненияКомпоновкиДанных.Равно, 
			Перечисления.СтатусыИсходящегоЭлектронногоПисьма.Черновик);
		
	ИначеЕсли ТипВзаимодействия = "ИсходящиеПисьма" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"Тип",ВидСравненияКомпоновкиДанных.Равно,Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"ПометкаУдаления",ВидСравненияКомпоновкиДанных.Равно,Ложь);
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"СтатусИсходящегоПисьма", ВидСравненияКомпоновкиДанных.Равно, 
			Перечисления.СтатусыИсходящегоЭлектронногоПисьма.Исходящее);
		
	ИначеЕсли ТипВзаимодействия = "Отправленные" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип",ВидСравненияКомпоновкиДанных.Равно, Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"ПометкаУдаления", ВидСравненияКомпоновкиДанных.Равно, Ложь);
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, "СтатусИсходящегоПисьма",
			ВидСравненияКомпоновкиДанных.Равно, 
			Перечисления.СтатусыИсходящегоЭлектронногоПисьма.Отправлено);
		
	ИначеЕсли ТипВзаимодействия = "УдаленныеПисьма" Тогда
		
		СписокТипыПисьма = Новый СписокЗначений;
		СписокТипыПисьма.Добавить(Тип("ДокументСсылка.ЭлектронноеПисьмоВходящее"));
		СписокТипыПисьма.Добавить(Тип("ДокументСсылка.ЭлектронноеПисьмоИсходящее"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок, 
			"Тип", ВидСравненияКомпоновкиДанных.ВСписке, СписокТипыПисьма);
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"ПометкаУдаления", ВидСравненияКомпоновкиДанных.Равно, Истина);
		
	ИначеЕсли ТипВзаимодействия = "Встречи" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип", ВидСравненияКомпоновкиДанных.Равно, Тип("ДокументСсылка.Встреча"));
		
	ИначеЕсли ТипВзаимодействия = "ЗапланированныеВзаимодействия" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип", ВидСравненияКомпоновкиДанных.Равно, Тип("ДокументСсылка.ЗапланированноеВзаимодействие"));
		
	ИначеЕсли ТипВзаимодействия = "ТелефонныеЗвонки" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип",ВидСравненияКомпоновкиДанных.Равно, Тип("ДокументСсылка.ТелефонныйЗвонок"));
		
	ИначеЕсли ТипВзаимодействия = "ИсходящиеЗвонки" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип",ВидСравненияКомпоновкиДанных.Равно,Тип("ДокументСсылка.ТелефонныйЗвонок"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Входящий",ВидСравненияКомпоновкиДанных.Равно,Ложь);
		
	ИначеЕсли ТипВзаимодействия = "ВходящиеЗвонки" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип",ВидСравненияКомпоновкиДанных.Равно,Тип("ДокументСсылка.ТелефонныйЗвонок"));
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Входящий",ВидСравненияКомпоновкиДанных.Равно,Истина);
		
	ИначеЕсли ТипВзаимодействия = "СообщенияSMS" Тогда
		
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ОтборНастройщикаКомпоновок,
			"Тип",ВидСравненияКомпоновкиДанных.Равно,Тип("ДокументСсылка.СообщениеSMS"));
		
	КонецЕсли;
	
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаОтбора, КомпоновщикНастроек.ПолучитьНастройки(),,,
		Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	// Инициализация процессора компоновки.
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных);
	
	ДеревоОбъект = РеквизитФормыВЗначение("ДеревоВзаимодействий");
	ДеревоОбъект.Строки.Очистить();
	
	// Получение результата
	ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений =
		Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений.УстановитьОбъект(ДеревоОбъект);
	ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений.Вывести(ПроцессорКомпоновкиДанных);
	
	ЗначениеВРеквизитФормы(ДеревоОбъект,"ДеревоВзаимодействий");
	
	ШаблонЗаголовка = НСтр("ru = 'Тип взаимодействий: %1'");
	ПредставлениеТипа = Взаимодействия.СписокОтборовПоТипуВзаимодействий(ТолькоПочта).НайтиПоЗначению(ТипВзаимодействия).Представление;
	Элементы.ДеревоТипВзаимодействия.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, ПредставлениеТипа);
	Для Каждого ЭлементПодменю Из Элементы.ДеревоТипВзаимодействия.ПодчиненныеЭлементы Цикл
		Если ЭлементПодменю.Имя = ("УстановитьОтборТипВзаимодействия_ДеревоТипВзаимодействия_" + ТипВзаимодействия) Тогда
			ЭлементПодменю.Пометка = Истина;
		Иначе
			ЭлементПодменю.Пометка = Ложь;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДеревоВзаимодействийКлиент()

	ЗаполнитьДеревоВзаимодействий();
	РазвернутьВсеСтрокиДерева();
	
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьВсеСтрокиДерева()

	Для каждого СтрокаВерхнегоУровня Из ДеревоВзаимодействий.ПолучитьЭлементы() Цикл
		Элементы.ДеревоВзаимодействий.Развернуть(СтрокаВерхнегоУровня.ПолучитьИдентификатор(), Истина);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьИзменениеПометкиУдаленияВДереве(ЗНАЧ ВыделенныеСтроки,СниматьПометку);
	
	Для каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
		
		ДанныеСтроки =ДеревоВзаимодействий.НайтиПоИдентификатору(ВыделеннаяСтрока);
		Если ДанныеСтроки.ПометкаУдаления = СниматьПометку Тогда
			ВзаимодействиеОбъект = ДанныеСтроки.Ссылка.ПолучитьОбъект();
			ВзаимодействиеОбъект.УстановитьПометкуУдаления(Не СниматьПометку);
			ДанныеСтроки.ПометкаУдаления = НЕ ДанныеСтроки.ПометкаУдаления;
			ДанныеСтроки.НомерКартинки = ?(СниматьПометку,
			                               ДанныеСтроки.НомерКартинки - ?(ДанныеСтроки.Рассмотрено,5,10),
			                               ДанныеСтроки.НомерКартинки + ?(ДанныеСтроки.Рассмотрено,5,10));
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры 

// Получает массив, который передается в качестве параметра запроса при получении взаимодействий по контакту.
//
// Параметры:
//  Контакт  - ЛюбаяСсылка - контакт, для которого необходимо выполнить поиск связанных контактов.
//
// Возвращаемое значение:
//  Массив
//
&НаСервере
Функция ПараметрКонтактВЗависимостиОтТипа(Контакт)
	
	МассивОписанияКонтактов = ВзаимодействияКлиентСервер.ОписанияКонтактов();
	ЕстьДополнительныеТаблицы = Ложь;
	ТекстЗапроса = "";
	ИмяТаблицыКонтакта = Контакт.Метаданные().Имя;
	
	Для каждого ЭлементМассиваОписания Из МассивОписанияКонтактов Цикл
		
		Если ЭлементМассиваОписания.Имя = ИмяТаблицыКонтакта Тогда
			ТекстЗапроса = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
			|	СправочникКонтакт.Ссылка КАК Контакт
			|ИЗ
			|	&ИмяТаблицы КАК СправочникКонтакт
			|ГДЕ
			|	СправочникКонтакт.Ссылка = &Контакт";
			
			
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяТаблицы", "Справочник." + ЭлементМассиваОписания.Имя);
			Связь = ЭлементМассиваОписания.Связь;
			
			Если НЕ ПустаяСтрока(Связь) Тогда
				
				ТекстЗапроса = ТекстЗапроса + "
				|
				|ОБЪЕДИНИТЬ ВСЕ
				|";
				
				ТекстЗапроса = ТекстЗапроса + "
				|ВЫБРАТЬ
				|	СправочникКонтакт.Ссылка 
				|ИЗ
				|	&ИмяТаблицы КАК СправочникКонтакт
				|ГДЕ
				|	СправочникКонтакт." + Прав(Связь,СтрДлина(Связь) - СтрНайти(Связь,".")) + " = &Контакт"; 
				
				
				ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяТаблицы", "Справочник." + Лев(Связь,СтрНайти(Связь,".")-1));
				ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяРеквизитаСравнения", "СправочникКонтакт." + Прав(Связь,СтрДлина(Связь) - СтрНайти(Связь,".")));
				ЕстьДополнительныеТаблицы = Истина;
				
			КонецЕсли;
			
		ИначеЕсли ЭлементМассиваОписания.ИмяВладельца = ИмяТаблицыКонтакта Тогда
			
			ТекстЗапроса = ТекстЗапроса + "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|";
			
			ТекстЗапроса = ТекстЗапроса + "
			|ВЫБРАТЬ
			|	СправочникКонтакт.Ссылка
			|ИЗ
			|	&ИмяТаблицы КАК СправочникКонтакт
			|ГДЕ
			|	СправочникКонтакт.Владелец = &Контакт";
			
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ИмяТаблицы", "Справочник." + ЭлементМассиваОписания.Имя);
			
			ЕстьДополнительныеТаблицы = Истина;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ПустаяСтрока(ТекстЗапроса) ИЛИ (НЕ ЕстьДополнительныеТаблицы) Тогда
		Возврат Новый Массив;
	Иначе
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("Контакт",Контакт);
		РезультатЗапроса = Запрос.Выполнить();
		Если РезультатЗапроса.Пустой() Тогда
			Возврат Новый Массив;
		Иначе
			Возврат РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("Контакт");
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура УстановитьОтборПоКонтакту()

	Запрос = Новый Запрос(
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
			|	КонтактыВзаимодействий.Взаимодействие КАК Ссылка
			|ИЗ
			|	ЖурналДокументов.Взаимодействия КАК Взаимодействия
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.КонтактыВзаимодействий КАК КонтактыВзаимодействий
			|		ПО Взаимодействия.Ссылка = КонтактыВзаимодействий.Взаимодействие
			|ГДЕ
			|	КонтактыВзаимодействий.Контакт В(&Контакт)");
			
	МассивПараметрКонтакт = ПараметрКонтактВЗависимостиОтТипа(Контакт);
	Если МассивПараметрКонтакт.Количество() = 0 Тогда
		МассивПараметрКонтакт.Добавить(Контакт);
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Контакт",МассивПараметрКонтакт);
	
	СписокОтбора = Новый СписокЗначений;
	СписокОтбора.ЗагрузитьЗначения(
	Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка"));
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, 
		"Ссылка",СписокОтбора,ВидСравненияКомпоновкиДанных.ВСписке,,Истина);

КонецПроцедуры

&НаСервере
Процедура УстановитьОтборПоПредмету()

	ОтборПоПредмету = Истина;
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Предмет",
			ПредметДляОтбора,ВидСравненияКомпоновкиДанных.Равно,,Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросОПометкеНаУдалениеПослеЗавершения(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		ОбработатьИзменениеПометкиУдаленияВДереве(Элементы.ДеревоВзаимодействий.ВыделенныеСтроки, ДополнительныеПараметры.ЕстьПомеченныеНаУдаление);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВводДатыОтложитьРассмотрениеПослеЗавершения(ВведеннаяДата, ДополнительныеПараметры) Экспорт

	Если ВведеннаяДата <> Неопределено Тогда
		
		ВыполненаЗамена = Ложь;
		ОтложитьРассмотрение(ВведеннаяДата,ВыполненаЗамена);
		
		Если Элементы.СтраницыСписокДерево.ТекущаяСтраница = Элементы.СтраницаСписок Тогда
			
			Если ВыполненаЗамена Тогда
				Элементы.Список.Обновить();
			КонецЕсли;
			
		Иначе
			
			Если ВыполненаЗамена Тогда
				РазвернутьВсеСтрокиДерева();
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ВыборИнтервалаЗакрытие(ВыбранныйПериод, ДополнительныеПараметры) Экспорт

	Если ВыбранныйПериод <> Неопределено Тогда
		Интервал = ВыбранныйПериод;
		ЗаполнитьДеревоВзаимодействийКлиент();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененииТипаСервер()
	
	Взаимодействия.ОбработатьПодменюОтборПоТипуВзаимодействий(ЭтотОбъект);
	
	ВзаимодействияКлиентСервер.ПриИзмененииОтбораТипВзаимодействий(ЭтотОбъект, ТипВзаимодействия);
	
КонецПроцедуры


#КонецОбласти
