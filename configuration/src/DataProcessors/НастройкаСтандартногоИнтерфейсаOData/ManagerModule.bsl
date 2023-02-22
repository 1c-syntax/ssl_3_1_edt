///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// АПК:581-выкл - вызывается из инструментов разработчика.

// Помещает во временное хранилище подготовленную структуру для просмотра метаданных.
// Для вызова из длительной операции (фонового задания).
//
// Параметры:
//  Параметры		 - Структура - пустая структура. 
//  АдресХранилища	 - Строка - адрес временного хранилища, куда будут возвращены данные. 
//
Процедура ПодготовитьПараметрыНастройкиСоставаСтандартногоИнтерфейсаOData(Параметры, АдресХранилища) Экспорт
	
	ДанныеИнициализации = Обработки.НастройкаСтандартногоИнтерфейсаOData.ПараметрыНастройкиСоставаСтандартногоИнтерфейсаOData();
	ПоместитьВоВременноеХранилище(ДанныеИнициализации, АдресХранилища);
	
КонецПроцедуры

// Возвращает роль, предназначенную для назначения пользователю информационной базы,
// логин и пароль которого будет использоваться при подключении к стандартному интерфейсу OData.
//
// Возвращаемое значение:
//   ОбъектМетаданныхРоль
//
Функция РольДляСтандартногоИнтерфейсаOData() Экспорт
	
	Возврат Метаданные.Роли.УдаленныйДоступOData;
	
КонецФункции

// Возвращает настройки авторизации для стандартного интерфейса OData (в модели сервиса).
//
// Возвращаемое значение:
//   ФиксированнаяСтруктура:
//                        * Используется - Булево - флаг включения авторизации для доступа
//                                         к стандартному интерфейсу OData,
//                        * Логин - Строка - логин пользователя для авторизации при доступе
//                                         к стандартному интерфейсу OData.
//
Функция НастройкиАвторизацииДляСтандартногоИнтерфейсаOData() Экспорт
	
	Результат = Новый Структура("Используется, Логин");
	Результат.Используется = Ложь;
	
	СвойстваПользователя = СвойстваПользователяСтандартногоИнтерфейсаOData();
	Если ЗначениеЗаполнено(СвойстваПользователя.Пользователь) Тогда
		Результат.Логин = СвойстваПользователя.Имя;
		Результат.Используется = СвойстваПользователя.Аутентификация;
	КонецЕсли;
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
	
КонецФункции

// Записывает настройки авторизации для стандартного интерфейса OData (в модели сервиса).
//
// Параметры:
//  НастройкиАвторизации - Структура:
//                        * Используется - Булево - флаг включения авторизации для доступа
//                                         к стандартному интерфейсу OData,
//                        * Логин - Строка - логин пользователя для авторизации при доступе
//                                         к стандартному интерфейсу OData,
//                        * Пароль - Строка - пароль пользователя для авторизации при доступе
//                                         к стандартному интерфейсу OData. Значение передается
//                                         в составе структуры только в тех случаях, когда требуется
//                                         изменить пароль.
//
Процедура ЗаписатьНастройкиАвторизацииДляСтандартногоИнтерфейсаOData(Знач НастройкиАвторизации) Экспорт
	
	СвойстваПользователя = СвойстваПользователяСтандартногоИнтерфейсаOData();
	
	Если НастройкиАвторизации.Используется Тогда
		
		// Требуется создать или обновить пользователя ИБ
		
		ПроверитьВозможностьСозданияПользователяДляВызововСтандартногоИнтерфейсаOData();
		
		ОписаниеПользователяИБ = Новый Структура();
		ОписаниеПользователяИБ.Вставить("Действие", "Записать");
		ОписаниеПользователяИБ.Вставить("Имя", НастройкиАвторизации.Логин);
		ОписаниеПользователяИБ.Вставить("АутентификацияСтандартная", Истина);
		ОписаниеПользователяИБ.Вставить("АутентификацияОС", Ложь);
		ОписаниеПользователяИБ.Вставить("АутентификацияOpenID", Ложь);
		ОписаниеПользователяИБ.Вставить("ПоказыватьВСпискеВыбора", Ложь);
		Если НастройкиАвторизации.Свойство("Пароль") Тогда
			ОписаниеПользователяИБ.Вставить("Пароль", НастройкиАвторизации.Пароль);
		КонецЕсли;
		ОписаниеПользователяИБ.Вставить("ЗапрещеноИзменятьПароль", Истина);
		ОписаниеПользователяИБ.Вставить("Роли",
			ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(
			РольДляСтандартногоИнтерфейсаOData().Имя));
		
		НачатьТранзакцию();
		Попытка
			
			Если ЗначениеЗаполнено(СвойстваПользователя.Пользователь) Тогда
				
				Блокировка = Новый БлокировкаДанных;
				ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
				ЭлементБлокировки.УстановитьЗначение("Ссылка", СвойстваПользователя.Пользователь);
				Блокировка.Заблокировать();
				
				ПользовательСтандартногоИнтерфейсаOData = СвойстваПользователя.Пользователь.ПолучитьОбъект();
				
			Иначе
				ПользовательСтандартногоИнтерфейсаOData = Справочники.Пользователи.СоздатьЭлемент();
			КонецЕсли;
			
			ПользовательСтандартногоИнтерфейсаOData.Наименование = НСтр("ru = 'Автоматический REST-сервис'");
			ПользовательСтандартногоИнтерфейсаOData.Служебный = Истина;
			ПользовательСтандартногоИнтерфейсаOData.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
			ПользовательСтандартногоИнтерфейсаOData.Записать();
			
			Константы.ПользовательСтандартногоИнтерфейсаOData.Установить(
				ПользовательСтандартногоИнтерфейсаOData.Ссылка);
				
			Если ОписаниеПользователяИБ.Свойство("Пароль") Тогда
				ОписаниеПользователяИБ.Удалить("Пароль");
			КонецЕсли;
			
			СокращенноеОписание = Новый Структура;
			ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(СокращенноеОписание, ОписаниеПользователяИБ);
			СокращенноеОписание.Удалить("ПользовательИБ");
			
			Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Выполнена запись пользователя для стандартного интерфейса OData.
					|
					|Описание пользователя ИБ:
					|-------------------------------------------
					|%1
					|-------------------------------------------
					|
					|Результат:
					|-------------------------------------------
					|%2
					|-------------------------------------------'"),
				ОбщегоНазначения.ЗначениеВСтрокуXML(СокращенноеОписание),
				ПользовательСтандартногоИнтерфейсаOData.ДополнительныеСвойства.ОписаниеПользователяИБ.РезультатДействия);
			
			ЗаписьЖурналаРегистрации(
				ИмяСобытияЖурналаРегистрации(НСтр("ru = 'ЗаписьПользователя'", ОбщегоНазначения.КодОсновногоЯзыка())),
				УровеньЖурналаРегистрации.Информация,
				Метаданные.Справочники.Пользователи,
				,
				Комментарий);
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			ОтменитьТранзакцию();
			ОписаниеПользователяИБ.Удалить("Пароль");
			
			Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'При записи пользователя для стандартного интерфейса OData произошла ошибка.
					|
					|Описание пользователя ИБ:
					|-------------------------------------------
					|%1
					|-------------------------------------------
					|
					|Текст ошибки:
					|-------------------------------------------
					|%2
					|-------------------------------------------'"),
				ОбщегоНазначения.ЗначениеВСтрокуXML(ОписаниеПользователяИБ),
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
			ЗаписьЖурналаРегистрации(
				ИмяСобытияЖурналаРегистрации(НСтр("ru = 'ЗаписьПользователя'", ОбщегоНазначения.КодОсновногоЯзыка())),
				УровеньЖурналаРегистрации.Ошибка,
				Метаданные.Справочники.Пользователи,
				,
				Комментарий);
			
			ВызватьИсключение;
			
		КонецПопытки;
		
	Иначе
		
		Если ЗначениеЗаполнено(СвойстваПользователя.Пользователь) Тогда
			
			// Требуется заблокировать пользователя ИБ
			
			ОписаниеПользователяИБ = Новый Структура();
			ОписаниеПользователяИБ.Вставить("Действие", "Записать");
			
			ОписаниеПользователяИБ.Вставить("ВходВПрограммуРазрешен", Ложь);
			
			ПользовательСтандартногоИнтерфейсаOData = СвойстваПользователя.Пользователь.ПолучитьОбъект();
			ПользовательСтандартногоИнтерфейсаOData.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
			ПользовательСтандартногоИнтерфейсаOData.Служебный = Истина;
			ПользовательСтандартногоИнтерфейсаOData.Записать();
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Возвращает модель данных для объектов, которые могут быть включены в состава стандартного
// интерфейса OData (в модели сервиса).
//
// Возвращаемое значение:
//   ТаблицаЗначений:
//                         * ОбъектМетаданных - ОбъектМетаданных - объект метаданных, который может
//                                              включен в состав стандартного интерфейса OData,
//                         * Чтение - Булево -  через стандартный интерфейс OData может быть предоставлен
//                                              доступ к чтению объекта,
//                         * Запись - Булево -  через стандартный интерфейс OData может быть предоставлен
//                                              доступ к записи объекта,
//                         * Зависимости -      Массив из ОбъектМетаданных - массив объектов метаданных, которые
//                                              необходимо включить в состав стандартного интерфейса OData при
//                                              включении текущего объекта.
//
Функция МодельДанныхПредоставляемыхДляСтандартногоИнтерфейсаOData() Экспорт
	
	Исключаемые = Новый Соответствие();
	Для Каждого ИсключаемыйОбъект Из ОбъектыИсключаемыеИзСтандартногоИнтерфейсаOData() Цикл
		Исключаемые.Вставить(ИсключаемыйОбъект.ПолноеИмя(), Истина);
	КонецЦикла;
	
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить("ПолноеИмя", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Чтение", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("Изменение", Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("Зависимости", Новый ОписаниеТипов("Массив"));
	
	Модель = ИнтерфейсODataСлужебныйПовтИсп.ОписаниеМоделиДанныхКонфигурации();
	Для Каждого Элементы Из Модель Цикл
		
		Для Каждого КлючИЗначение Из Элементы.Значение Цикл
			
			ОписаниеОбъекта = КлючИЗначение.Значение;
			
			Если Исключаемые.Получить(ОписаниеОбъекта.ПолноеИмя) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			ЭтоРазделенныйОбъектМетаданных = Ложь;
			Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
				МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
				ЭтоРазделенныйОбъектМетаданных = ОписаниеОбъекта.РазделениеДанных.Свойство(МодульРаботаВМоделиСервиса.РазделительОсновныхДанных());
			КонецЕсли;
			
			Если ЭтоРазделенныйОбъектМетаданных Тогда
				ЗаполнитьМодельДанныхПредоставляемыхДляСтандартногоИнтерфейсаOData(Результат, ОписаниеОбъекта.ПолноеИмя, Исключаемые);
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает эталонный состав роли для назначения пользователю информационной базы,
// логин и пароль которого будет использоваться при подключении к стандартному интерфейсу
// OData (в модели сервиса).
//
// Возвращаемое значение:
//   Соответствие из КлючИЗначение:
//                        * Ключ - ОбъектМетаданных - объект метаданных,
//                        * Значение - Массив из Строка - массив названий прав доступа,
//                                     которые должны быть разрешены для данного объекта
//                                     метаданных в роли.
//
Функция ЭталонныйСоставРолиДляСтандартногоИнтерфейсаOData() Экспорт
	
	Результат = Новый Соответствие();
	
	ВидыПрав = ВидыПравДляСтандартногоИнтерфейсаOData(Метаданные, Ложь, Ложь);
	Если ВидыПрав.Количество() > 0 Тогда
		Результат.Вставить(Метаданные, ВидыПрав);
	КонецЕсли;
	
	Для Каждого ПараметрСеанса Из Метаданные.ПараметрыСеанса Цикл
		ВидыПрав = ВидыПравДляСтандартногоИнтерфейсаOData(ПараметрСеанса, Истина, Ложь);
		Если ВидыПрав.Количество() > 0 Тогда
			Результат.Вставить(ПараметрСеанса, ВидыПрав);
		КонецЕсли;
	КонецЦикла;
	
	Модель = МодельДанныхПредоставляемыхДляСтандартногоИнтерфейсаOData();
	Для Каждого ЭлементМодели Из Модель Цикл
		
		ВидыПрав = ВидыПравДляСтандартногоИнтерфейсаOData(
			ЭлементМодели.ПолноеИмя,
			ЭлементМодели.Чтение,
			ЭлементМодели.Изменение);
		
		Если ВидыПрав.Количество() > 0 Тогда
			Результат.Вставить(ЭлементМодели.ПолноеИмя, ВидыПрав);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает ошибки состава роли, предназначенной для назначения пользователю информационной базы,
// логин и пароль которого будет использоваться при подключении к стандартному интерфейсу
// OData (в модели сервиса).
//
// Возвращаемое значение:
//   Массив - ошибки, найденные в составе роли.
//
Функция ОшибкиСоставаРолиOData(ОшибкиПоОбъектам = Неопределено) Экспорт
	
	Роль = РольДляСтандартногоИнтерфейсаOData();
	
	ИзбыточныеПрава = Новый Соответствие();
	НедостающиеПрава = Новый Соответствие();
	
	ЭталонныйСостав = ЭталонныйСоставРолиДляСтандартногоИнтерфейсаOData();
	
	ПроверитьСоставРолиODataПоОбъектуМетаданных(Метаданные, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.ПараметрыСеанса, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.Константы, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.Справочники, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.Документы, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.ЖурналыДокументов, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.ПланыВидовХарактеристик, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.ПланыСчетов, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.ПланыВидовРасчета, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.ПланыОбмена, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.БизнесПроцессы, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.Задачи, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.Последовательности, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.РегистрыСведений, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.РегистрыНакопления, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.РегистрыБухгалтерии, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	ПроверитьСоставРолиODataПоКоллекцииМетаданных(Метаданные.РегистрыРасчета, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	Для Каждого РегистрРасчета Из Метаданные.РегистрыРасчета Цикл
		ПроверитьСоставРолиODataПоКоллекцииМетаданных(РегистрРасчета.Перерасчеты, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	КонецЦикла;
	
	Ошибки = Новый Массив();
	Если ИзбыточныеПрава.Количество() > 0 Тогда
		ТекстОшибки = Символы.НПП + НСтр("ru = 'Следующие права избыточно включены в состав роли:'") + Символы.ПС + Символы.ВК
			+ ПредставлениеИзбыточныхИлиНедостающихПрав(ИзбыточныеПрава, 2);
		Ошибки.Добавить(ТекстОшибки);
	КонецЕсли;
	
	Если НедостающиеПрава.Количество() > 0 Тогда
		ТекстОшибки = Символы.НПП + НСтр("ru = 'Следующие права должны быть включены в состав роли:'") + Символы.ПС + Символы.ВК
			+ ПредставлениеИзбыточныхИлиНедостающихПрав(НедостающиеПрава, 2);
		Ошибки.Добавить(ТекстОшибки);
	КонецЕсли;
	
	Если ТипЗнч(ОшибкиПоОбъектам) = Тип("Соответствие") Тогда
		Для Каждого КлючИЗначение Из ИзбыточныеПрава Цикл
			ПолноеИмя = КлючИЗначение.Ключ.ПолноеИмя();
			ОшибкиПоОбъектам.Вставить(ПолноеИмя, СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Следующие права на объект %1 избыточно включены в состав роли %2: %3'"),
				ПолноеИмя, Роль.Имя, СтрСоединить(КлючИЗначение.Значение, ", ")));
		КонецЦикла;
		Для Каждого КлючИЗначение Из НедостающиеПрава Цикл
			ПолноеИмя = КлючИЗначение.Ключ.ПолноеИмя();
			ТекстОшибок = ОшибкиПоОбъектам.Получить(ПолноеИмя);
			ТекстОшибок = ?(ТекстОшибок = Неопределено, "", ТекстОшибок + Символы.ПС);
			ТекстОшибок = ТекстОшибок + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Следующие права на объект %1 должны быть включены в состав роли %2: %3'"),
				ПолноеИмя, Роль.Имя, СтрСоединить(КлючИЗначение.Значение, ", "));
			ОшибкиПоОбъектам.Вставить(ПолноеИмя, ТекстОшибок);
		КонецЦикла;
	КонецЕсли;
	
	Возврат Ошибки;
	
КонецФункции

// АПК:581-вкл

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПараметрыНастройкиСоставаСтандартногоИнтерфейсаOData() Экспорт
	
	Объект = Создать();
	Возврат Объект.ИнициализироватьДанныеДляНастройкиСоставаСтандартногоИнтерфейсаOData();
	
КонецФункции

Процедура ПроверитьСоставРолиODataПоКоллекцииМетаданных(КоллекцияМетаданных, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава)
	
	Для Каждого ОбъектМетаданных Из КоллекцияМетаданных Цикл
		ПроверитьСоставРолиODataПоОбъектуМетаданных(ОбъектМетаданных, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава);
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьСоставРолиODataПоОбъектуМетаданных(ОбъектМетаданных, ЭталонныйСостав, ИзбыточныеПрава, НедостающиеПрава)
	
	ВидыПрав = ДопустимыеПраваДляОбъектаМетаданных(ОбъектМетаданных);
	
	ЭталонныеПрава = ЭталонныйСостав.Получить(ОбъектМетаданных.ПолноеИмя());
	Если ЭталонныеПрава = Неопределено Тогда
		ЭталонныеПрава = Новый Массив();
	КонецЕсли;
	
	ПредоставленныеПрава = Новый Массив();
	Для Каждого ВидПрава Из ВидыПрав Цикл
		Если ПравоДоступа(ВидПрава.Имя, ОбъектМетаданных, РольДляСтандартногоИнтерфейсаOData()) Тогда
			ПредоставленныеПрава.Добавить(ВидПрава.Имя);
		КонецЕсли;
	КонецЦикла;
	
	// Все права, которые есть в эталонных, но отсутствуют в предоставленных - недостающие.
	НедостающиеПраваПоОбъекту = Новый Массив();
	Для Каждого ВидПрава Из ЭталонныеПрава Цикл
		Если ПредоставленныеПрава.Найти(ВидПрава) = Неопределено Тогда
			НедостающиеПраваПоОбъекту.Добавить(ВидПрава);
		КонецЕсли;
	КонецЦикла;
	Если НедостающиеПраваПоОбъекту.Количество() > 0 Тогда
		НедостающиеПрава.Вставить(ОбъектМетаданных, НедостающиеПраваПоОбъекту);
	КонецЕсли;
	
	// Все права, которые есть в предоставленных, но отсутствуют в эталонных - избыточные.
	ИзбыточныеПраваПоОбъекту = Новый Массив();
	Для Каждого ВидПрава Из ПредоставленныеПрава Цикл
		Если ЭталонныеПрава.Найти(ВидПрава) = Неопределено Тогда
			ИзбыточныеПраваПоОбъекту.Добавить(ВидПрава);
		КонецЕсли;
	КонецЦикла;
	Если ИзбыточныеПраваПоОбъекту.Количество() > 0 Тогда
		ИзбыточныеПрава.Вставить(ОбъектМетаданных, ИзбыточныеПраваПоОбъекту);
	КонецЕсли;
	
КонецПроцедуры

Функция ВидыПравДляСтандартногоИнтерфейсаOData(Знач ОбъектМетаданных, Знач РазрешатьЧтениеДанных, Знач РазрешатьИзменениеДанных)
	
	ВсеВидыПрав = ДопустимыеПраваДляОбъектаМетаданных(ОбъектМетаданных);
	
	ОтборПрав = Новый Структура();
	ОтборПрав.Вставить("Интерактивное", Ложь);
	ОтборПрав.Вставить("АдминистрированиеИнформационнойБазы", Ложь);
	ОтборПрав.Вставить("АдминистрированиеОбластиДанных", Ложь);
	
	Если РазрешатьЧтениеДанных И Не РазрешатьИзменениеДанных Тогда
		ОтборПрав.Вставить("Чтение", РазрешатьЧтениеДанных);
	КонецЕсли;
	
	Если РазрешатьИзменениеДанных И Не РазрешатьЧтениеДанных Тогда
		ОтборПрав.Вставить("Изменение", РазрешатьИзменениеДанных);
	КонецЕсли;
	
	ТребуемыеВидыПрав = ВсеВидыПрав.Скопировать(ОтборПрав);
	
	Возврат ТребуемыеВидыПрав.ВыгрузитьКолонку("Имя");
	
КонецФункции

Процедура ЗаполнитьМодельДанныхПредоставляемыхДляСтандартногоИнтерфейсаOData(Знач Результат, Знач ПолноеИмя, Знач Исключаемые)
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ПолноеИмя);
	Если Не ЭтоДопустимыйОбъектМетаданныхOData(ОбъектМетаданных) Тогда
		Возврат;
	КонецЕсли;
	
	Строка = Результат.Найти(ПолноеИмя, "ПолноеИмя");
	Если Строка = Неопределено Тогда
		Строка = Результат.Добавить();
	КонецЕсли;
	
	СвойстваОбъектовМетаданных = ИнтерфейсODataСлужебный.СвойстваОбъектаМоделиКонфигурации(
		ИнтерфейсODataСлужебныйПовтИсп.ОписаниеМоделиДанныхКонфигурации(), ПолноеИмя);
	
	ЭтоРазделенныйОбъектМетаданных = Ложь;
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		ЭтоРазделенныйОбъектМетаданных = СвойстваОбъектовМетаданных.РазделениеДанных.Свойство(МодульРаботаВМоделиСервиса.РазделительОсновныхДанных());
	КонецЕсли;
	
	Строка.Чтение = Истина;
	Строка.ПолноеИмя = ПолноеИмя;
	Если ОбщегоНазначения.ЭтоПеречисление(ОбъектМетаданных) Тогда
		Строка.Изменение = Ложь;
	ИначеЕсли ОбщегоНазначения.ЭтоЖурналДокументов(ОбъектМетаданных) Тогда
		Строка.Изменение = Ложь;
	ИначеЕсли Не ЭтоРазделенныйОбъектМетаданных Тогда
		Строка.Изменение = Ложь;
	Иначе
		Строка.Изменение = Истина;
	КонецЕсли;
	
	Зависимости = СвойстваОбъектовМетаданных.Зависимости;
	Для Каждого КлючИЗначение Из Зависимости Цикл
		
		ПолноеИмяЗависимости = КлючИЗначение.Ключ;
		Если ПолноеИмяЗависимости = ПолноеИмя
			Или Исключаемые.Получить(ПолноеИмяЗависимости) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Строка.Зависимости.Добавить(ПолноеИмяЗависимости);
		
		СтрокаЗависимости = Результат.Найти(ПолноеИмяЗависимости, "ПолноеИмя");
		Если СтрокаЗависимости = Неопределено Тогда
			ЗаполнитьМодельДанныхПредоставляемыхДляСтандартногоИнтерфейсаOData(Результат, ПолноеИмяЗависимости, Исключаемые);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЭтоДопустимыйОбъектМетаданныхOData(Знач ОбъектМетаданных)
	
	Возврат ОбщегоНазначения.ЭтоСправочник(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоДокумент(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланОбмена(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланСчетов(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланВидовРасчета(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланВидовХарактеристик(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоРегистрБухгалтерии(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоРегистрСведений(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоРегистрРасчета(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоРегистрНакопления(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоЖурналДокументов(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПеречисление(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоЗадача(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоБизнесПроцесс(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоКонстанта(ОбъектМетаданных);
	
КонецФункции

Функция ПредставлениеИзбыточныхИлиНедостающихПрав(Знач ОписанияПрав, Знач Отступ)
	
	Результат = "";
	
	Для Каждого КлючИЗначение Из ОписанияПрав Цикл
		
		ОбъектМетаданных = КлючИЗначение.Ключ;
		Права = КлючИЗначение.Значение;
		
		Строка = "";
		
		Для Шаг = 1 По Отступ Цикл
			Строка = Строка + Символы.НПП;
		КонецЦикла;
		
		Строка = Строка + ОбъектМетаданных.ПолноеИмя() + ": " + СтрСоединить(Права, ", ");
		
		Если Не ПустаяСтрока(Результат) Тогда
			Результат = Результат + Символы.ПС;
		КонецЕсли;
		
		Результат = Результат + Строка;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ОбъектыИсключаемыеИзСтандартногоИнтерфейсаOData()
	
	ИсключаемыеТипы = Новый Массив;
	ИнтеграцияПодсистемБСП.ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузкиOData(ИсключаемыеТипы);
	Возврат ИсключаемыеТипы;
	
КонецФункции

Функция СвойстваПользователяСтандартногоИнтерфейсаOData()
	
	Если Не ПравоДоступа("АдминистрированиеДанных", Метаданные) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав доступа для настройки автоматического REST-сервиса'");
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Результат = Новый Структура;
	Результат.Вставить("Пользователь", Справочники.Пользователи.ПустаяСсылка());
	Результат.Вставить("Идентификатор");
	Результат.Вставить("Имя", "");
	Результат.Вставить("Аутентификация", Ложь);
	
	Пользователь = Константы.ПользовательСтандартногоИнтерфейсаOData.Получить();
	Если ЗначениеЗаполнено(Пользователь) Тогда
		
		Результат.Пользователь = Пользователь;
		Идентификатор = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Пользователь, "ИдентификаторПользователяИБ");
		Если ЗначениеЗаполнено(Идентификатор) Тогда
			
			Результат.Идентификатор = Идентификатор;
			ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(Идентификатор);
			Если ПользовательИБ <> Неопределено Тогда
				Результат.Имя = ПользовательИБ.Имя;
				Результат.Аутентификация = ПользовательИБ.АутентификацияСтандартная;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ИмяСобытияЖурналаРегистрации(Знач Суффикс)
	
	Возврат НСтр("ru = 'НастройкаСтандартногоИнтерфейсаOData.'") + СокрЛП(Суффикс);
	
КонецФункции

Процедура ПроверитьВозможностьСозданияПользователяДляВызововСтандартногоИнтерфейсаOData()
	
	УстановитьПривилегированныйРежим(Истина);
	КоличествоПользователей = ПользователиИнформационнойБазы.ПолучитьПользователей().Количество();
	УстановитьПривилегированныйРежим(Ложь);
	
	Если КоличествоПользователей = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Нельзя создать отдельные логин и пароль для использования автоматического REST-сервиса, т.к. в программе отсутствуют другие пользователи.'");
	КонецЕсли;
	
КонецПроцедуры

#Область Метаданные

Функция ДопустимыеПраваДляОбъектаМетаданных(Знач ОбъектМетаданных)
	
	ВидыПрав = Новый ТаблицаЗначений();
	ВидыПрав.Колонки.Добавить("Имя", Новый ОписаниеТипов("Строка"));
	ВидыПрав.Колонки.Добавить("Интерактивное", Новый ОписаниеТипов("Булево"));
	ВидыПрав.Колонки.Добавить("Чтение", Новый ОписаниеТипов("Булево"));
	ВидыПрав.Колонки.Добавить("Изменение", Новый ОписаниеТипов("Булево"));
	ВидыПрав.Колонки.Добавить("АдминистрированиеИнформационнойБазы", Новый ОписаниеТипов("Булево"));
	ВидыПрав.Колонки.Добавить("АдминистрированиеОбластиДанных", Новый ОписаниеТипов("Булево"));
	
	Если ТипЗнч(ОбъектМетаданных) = Тип("Строка") Тогда
		ИмяОбъектаМетаданных = ОбъектМетаданных;
		ОбъектМетаданныхДляАнализа = Метаданные.НайтиПоПолномуИмени(ОбъектМетаданных);
	Иначе
		ИмяОбъектаМетаданных = ОбъектМетаданных.ПолноеИмя();
		ОбъектМетаданныхДляАнализа = ОбъектМетаданных;
	КонецЕсли;
	
	Если ЭтоОбъектМетаданныхКонфигурация(ИмяОбъектаМетаданных) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Администрирование";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "АдминистрированиеДанных";
		ВидПрава.АдминистрированиеОбластиДанных = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ОбновлениеКонфигурацииБазыДанных";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "МонопольныйРежим";
		ВидПрава.АдминистрированиеОбластиДанных = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "АктивныеПользователи";
		ВидПрава.АдминистрированиеОбластиДанных = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ЖурналРегистрации";
		ВидПрава.АдминистрированиеОбластиДанных = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ТонкийКлиент";
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ВебКлиент";
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ТолстыйКлиент";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ВнешнееСоединение";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Automation";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "РежимВсеФункции";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "СохранениеДанныхПользователя";
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивноеОткрытиеВнешнихОбработок";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивноеОткрытиеВнешнихОтчетов";
		ВидПрава.АдминистрированиеИнформационнойБазы = Истина;
		ВидПрава.Интерактивное = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Вывод";
		ВидПрава.Интерактивное = Истина;
		
	ИначеЕсли ЭтоПараметрСеанса(ИмяОбъектаМетаданных) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Получение";
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Установка";
		ВидПрава.Изменение = Истина;
		
	ИначеЕсли ЭтоОбщийРеквизит(ИмяОбъектаМетаданных) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава = "Просмотр";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Редактирование";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
	ИначеЕсли ОбщегоНазначения.ЭтоКонстанта(ОбъектМетаданныхДляАнализа) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Чтение";
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Изменение";
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Просмотр";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Редактирование";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
	ИначеЕсли ЭтоСсылочныеДанные(ОбъектМетаданныхДляАнализа) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Чтение";
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Добавление";
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Изменение";
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Удаление";
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Просмотр";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивноеДобавление";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Редактирование";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивноеУдаление";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивнаяПометкаУдаления";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивноеСнятиеПометкиУдаления";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ИнтерактивноеУдалениеПомеченных";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Изменение = Истина;
		
		Если ОбщегоНазначения.ЭтоДокумент(ОбъектМетаданныхДляАнализа) Тогда
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "Проведение";
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ОтменаПроведения";
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеПроведение";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеПроведениеНеоперативное";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивнаяОтменаПроведения";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеИзменениеПроведенных";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
		КонецЕсли;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "ВводПоСтроке";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Чтение = Истина;
		
		Если ОбщегоНазначения.ЭтоБизнесПроцесс(ОбъектМетаданныхДляАнализа) Тогда
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивнаяАктивация";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "Старт";
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивныйСтарт";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
		КонецЕсли;
		
		Если ОбщегоНазначения.ЭтоЗадача(ОбъектМетаданныхДляАнализа) Тогда
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивнаяАктивация";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "Выполнение";
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеВыполнение";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
		КонецЕсли;
		
		Если ЭтоСсылочныеДанныеПоддерживающиеПредопределенныеЭлементы(ОбъектМетаданныхДляАнализа) Тогда
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеУдалениеПредопределенныхДанных";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивнаяПометкаУдаленияПредопределенныхДанных";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеСнятиеПометкиУдаленияПредопределенныхДанных";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "ИнтерактивноеУдалениеПомеченныхПредопределенныхДанных";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
		КонецЕсли;
		
	ИначеЕсли ИнтерфейсODataСлужебный.ЭтоНаборЗаписей(ИмяОбъектаМетаданных) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Чтение";
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Изменение";
		ВидПрава.Изменение = Истина;
		
		Если Не ИнтерфейсODataСлужебный.ЭтоНаборЗаписейПоследовательности(ИмяОбъектаМетаданных)
			И Не ИнтерфейсODataСлужебный.ЭтоНаборЗаписейПерерасчета(ИмяОбъектаМетаданных) Тогда
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "Просмотр";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Чтение = Истина;
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "Редактирование";
			ВидПрава.Интерактивное = Истина;
			ВидПрава.Изменение = Истина;
			
		КонецЕсли;
		
		Если ЭтоНаборЗаписейПоддерживающийИтоги(ОбъектМетаданныхДляАнализа) Тогда
			
			ВидПрава = ВидыПрав.Добавить();
			ВидПрава.Имя = "УправлениеИтогами";
			ВидПрава.АдминистрированиеОбластиДанных = Истина;
			
		КонецЕсли;
		
	ИначеЕсли ОбщегоНазначения.ЭтоЖурналДокументов(ОбъектМетаданныхДляАнализа) Тогда
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Чтение";
		ВидПрава.Чтение = Истина;
		
		ВидПрава = ВидыПрав.Добавить();
		ВидПрава.Имя = "Просмотр";
		ВидПрава.Интерактивное = Истина;
		ВидПрава.Чтение = Истина;
		
	КонецЕсли;
	
	Возврат ВидыПрав;
	
КонецФункции

// Проверяет, является ли переданный объект метаданных объектом ОбъектМетаданныхКонфигурация.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - проверяемый объект метаданных.
//
// Возвращаемое значение:
//   Булево
//
Функция ЭтоОбъектМетаданныхКонфигурация(Знач ОбъектМетаданных)
	
	Возврат ТипЗнч(ОбъектМетаданных) = Тип("ОбъектМетаданныхКонфигурация");
	
КонецФункции

// Проверяет, является ли переданный объект метаданных параметром сеанса.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - проверяемый объект метаданных.
//
// Возвращаемое значение:
//   Булево
//
Функция ЭтоПараметрСеанса(Знач ОбъектМетаданных)
	
	Возврат ИнтерфейсODataСлужебный.ЭтоОбъектМетаданныхКласса(ОбъектМетаданных,
		ИнтерфейсODataСлужебныйПовтИсп.КлассыМетаданныхВМоделиКонфигурации().ПараметрыСеанса);
	
КонецФункции

// Проверяет, является ли переданный объект метаданных общим реквизитом.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - проверяемый объект метаданных.
//
// Возвращаемое значение:
//   Булево
//
Функция ЭтоОбщийРеквизит(Знач ОбъектМетаданных)
	
	Возврат ИнтерфейсODataСлужебный.ЭтоОбъектМетаданныхКласса(ОбъектМетаданных,
		ИнтерфейсODataСлужебныйПовтИсп.КлассыМетаданныхВМоделиКонфигурации().ОбщиеРеквизиты);
	
КонецФункции

// Проверяет, является ли переданный объект метаданных ссылочным.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - проверяемый объект метаданных.
//
// Возвращаемое значение:
//   Булево
//
Функция ЭтоСсылочныеДанные(Знач ОбъектМетаданных)
	
	Возврат ОбщегоНазначения.ЭтоСправочник(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоДокумент(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоБизнесПроцесс(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоЗадача(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланСчетов(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланОбмена(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланВидовХарактеристик(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланВидовРасчета(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПеречисление(ОбъектМетаданных);
		
КонецФункции

// Проверяет, является ли переданный объект метаданных ссылочным с поддержкой предопределенных элементов.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - проверяемый объект метаданных.
//
// Возвращаемое значение:
//   Булево
//
Функция ЭтоСсылочныеДанныеПоддерживающиеПредопределенныеЭлементы(Знач ОбъектМетаданных)
	
	Возврат ОбщегоНазначения.ЭтоСправочник(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланСчетов(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланВидовХарактеристик(ОбъектМетаданных)
		Или ОбщегоНазначения.ЭтоПланВидовРасчета(ОбъектМетаданных);
	
КонецФункции

// Проверяет, является ли переданный объект метаданных набором записей, поддерживающим итоги.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - проверяемый объект метаданных.
//
// Возвращаемое значение:
//   Булево
//
Функция ЭтоНаборЗаписейПоддерживающийИтоги(Знач ОбъектМетаданных)
	
	Если ОбщегоНазначения.ЭтоРегистрСведений(ОбъектМетаданных) Тогда
		
		Если ТипЗнч(ОбъектМетаданных) = Тип("Строка") Тогда
			ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ОбъектМетаданных);
		КонецЕсли;
		
		Возврат ОбъектМетаданных.РазрешитьИтогиСрезПервых
			Или ОбъектМетаданных.РазрешитьИтогиСрезПоследних;
		
	ИначеЕсли ОбщегоНазначения.ЭтоРегистрНакопления(ОбъектМетаданных) Тогда
		Возврат Истина;
	ИначеЕсли ОбщегоНазначения.ЭтоРегистрБухгалтерии(ОбъектМетаданных) Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#КонецЕсли
