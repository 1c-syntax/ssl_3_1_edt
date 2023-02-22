///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Проверяет требуется ли обновление или настройка информационной базы
// перед началом использования.
//
// Параметры:
//  НастройкаПодчиненногоУзлаРИБ - Булево - (возвращаемое значение), устанавливается Истина,
//                                 если обновление требуется в связи с настройкой подчиненного узла РИБ.
//
// Возвращаемое значение:
//  Булево - возвращает Истина, если требуется обновление или настройка информационной базы.
//
Функция НеобходимоОбновление(НастройкаПодчиненногоУзлаРИБ = Ложь) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		// Обновление в модели сервиса.
		Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
			Если ОбновлениеИнформационнойБазы.НеобходимоОбновлениеИнформационнойБазы() Тогда
				// Заполнение разделенных параметров работы расширений.
				Возврат Истина;
			КонецЕсли;
			
		ИначеЕсли ОбновлениеИнформационнойБазыСлужебный.НеобходимоОбновлениеНеразделенныхДанныхИнформационнойБазы() Тогда
			// Обновление неразделенных параметров работы программы.
			Возврат Истина;
		КонецЕсли;
	Иначе
		// Обновление в локальном режиме.
		Если ОбновлениеИнформационнойБазы.НеобходимоОбновлениеИнформационнойБазы() Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
		МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
		
		// При запуске созданного начального образа подчиненного узла РИБ
		// загрузка не требуется, а обновление нужно выполнить.
		Если МодульОбменДаннымиСервер.НастройкаПодчиненногоУзлаРИБ() Тогда
			НастройкаПодчиненногоУзлаРИБ = Истина;
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Вызывает принудительное заполнение всех параметров работы программы.
Процедура ОбновитьВсеПараметрыРаботыПрограммы() Экспорт
	
	ЗагрузитьОбновитьПараметрыРаботыПрограммы();
	
КонецПроцедуры

// Возвращает дату успешной проверки/обновления параметров работы программы.
Функция ДатаОбновленияВсехПараметровРаботыПрограммы() Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.БазоваяФункциональность.ДатаОбновленияВсехПараметровРаботыПрограммы";
	ДатаОбновления = СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы(ИмяПараметра);
	
	Если ТипЗнч(ДатаОбновления) <> Тип("Дата") Тогда
		ДатаОбновления = '00010101';
	КонецЕсли;
	
	Возврат ДатаОбновления;
	
КонецФункции


// См. СтандартныеПодсистемыСервер.ПараметрРаботыПрограммы.
Функция ПараметрРаботыПрограммы(ИмяПараметра) Экспорт
	
	ОписаниеЗначения = ОписаниеЗначенияПараметраРаботыПрограммы(ИмяПараметра);
	
	Если СтандартныеПодсистемыСервер.ВерсияПрограммыОбновленаДинамически() Тогда
		Возврат ОписаниеЗначения.Значение;
	КонецЕсли;
	
	Если ОписаниеЗначения.Версия <> Метаданные.Версия Тогда
		Значение = Неопределено;
		ПроверитьВозможностьОбновленияВМоделиСервиса(ИмяПараметра, Значение, "Получение");
		Возврат Значение;
	КонецЕсли;
	
	Возврат ОписаниеЗначения.Значение;
	
КонецФункции

// См. СтандартныеПодсистемыСервер.УстановитьПараметрРаботыПрограммы.
Процедура УстановитьПараметрРаботыПрограммы(ИмяПараметра, Значение) Экспорт
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	ПроверитьВозможностьОбновленияВМоделиСервиса(ИмяПараметра, Значение, "Установка");
	
	ОписаниеЗначения = Новый Структура;
	ОписаниеЗначения.Вставить("Версия", Метаданные.Версия);
	ОписаниеЗначения.Вставить("Значение", Значение);
	
	УстановитьХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра, ОписаниеЗначения);
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ОбновитьПараметрРаботыПрограммы.
Процедура ОбновитьПараметрРаботыПрограммы(ИмяПараметра, Значение, ЕстьИзменения = Ложь, СтароеЗначение = Неопределено) Экспорт
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	
	ОписаниеЗначения = ОписаниеЗначенияПараметраРаботыПрограммы(ИмяПараметра, Ложь);
	СтароеЗначение = ОписаниеЗначения.Значение;
	
	Если Не ОбщегоНазначения.ДанныеСовпадают(Значение, СтароеЗначение) Тогда
		ЕстьИзменения = Истина;
	ИначеЕсли ОписаниеЗначения.Версия = Метаданные.Версия Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПараметрРаботыПрограммы(ИмяПараметра, Значение);
	
КонецПроцедуры


// См. СтандартныеПодсистемыСервер.ИзмененияПараметраРаботыПрограммы.
Функция ИзмененияПараметраРаботыПрограммы(ИмяПараметра) Экспорт
	
	ИмяПараметраХраненияИзменений = ИмяПараметра + ":Изменения";
	ПоследниеИзменения = ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметраХраненияИзменений);
	
	Версия = Метаданные.Версия;
	СледующаяВерсия = СледующаяВерсия(Версия);
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И НЕ ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		// План обновления областей строится только для областей,
		// которые имеют версию не ниже версии неразделенных данных.
		// Для остальных областей запускаются все обработчики обновления.
		
		// Версия неразделенных (общих) данных.
		ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ(Метаданные.Имя, Истина);
	Иначе
		ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ(Метаданные.Имя);
	КонецЕсли;
	
	// При начальном заполнении изменение параметров работы программы не определено.
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "0.0.0.0") = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ОбновлениеВнеОбновленияИБ = ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, Версия) = 0;
	
	Если Не ЭтоИзмененияПараметраРаботыПрограммы(ПоследниеИзменения) Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Для параметра работы программы ""%1"" не найдены изменения.'"), ИмяПараметра)
			+ СтандартныеПодсистемыСервер.УточнениеОшибкиПараметровРаботыПрограммыДляРазработчика();
	КонецЕсли;
	
	// Изменения к более старшим версиям не нужны,
	// кроме случая когда обновление выполняется вне обновления ИБ,
	// т.е. версия ИБ равна версии конфигурации.
	// В этом случае дополнительно выбираются изменения к следующей версии.
	
	Индекс = ПоследниеИзменения.Количество()-1;
	Пока Индекс >= 0 Цикл
		ВерсияИзменения = ПоследниеИзменения[Индекс].ВерсияКонфигурации;
		
		Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, ВерсияИзменения) >= 0
		   И НЕ (  ОбновлениеВнеОбновленияИБ
		         И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(СледующаяВерсия, ВерсияИзменения) = 0) Тогда
			
			ПоследниеИзменения.Удалить(Индекс);
		КонецЕсли;
		Индекс = Индекс - 1;
	КонецЦикла;
	
	Возврат ПоследниеИзменения.ВыгрузитьКолонку("Изменения");
	
КонецФункции

// См. СтандартныеПодсистемыСервер.ДобавитьИзмененияПараметраРаботыПрограммы.
Процедура ДобавитьИзмененияПараметраРаботыПрограммы(ИмяПараметра, Знач Изменения) Экспорт
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	
	// Получение версии ИБ или неразделенных данных.
	ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ(Метаданные.Имя);
	
	// При переходе на другую программу используется текущая версия конфигурации.
	Если Не ОбщегоНазначения.РазделениеВключено()
	   И ОбновлениеИнформационнойБазыСлужебный.РежимОбновленияДанных() = "ПереходСДругойПрограммы" Тогда
		
		ВерсияИБ = Метаданные.Версия;
	КонецЕсли;
	
	// При начальном заполнении добавление изменений параметров пропускается.
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "0.0.0.0") = 0 Тогда
		Изменения = Неопределено;
	КонецЕсли;
	
	ИмяПараметраХраненияИзменений = ИмяПараметра + ":Изменения";
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ПараметрыРаботыПрограммы");
	ЭлементБлокировки.УстановитьЗначение("ИмяПараметра", ИмяПараметраХраненияИзменений);
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		ОбновитьСоставИзменений = Ложь;
		ПоследниеИзменения = ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметраХраненияИзменений);
		
		Если Не ЭтоИзмененияПараметраРаботыПрограммы(ПоследниеИзменения) Тогда
			ПоследниеИзменения = Неопределено;
		КонецЕсли;
		
		Если ПоследниеИзменения = Неопределено Тогда
			ОбновитьСоставИзменений = Истина;
			ПоследниеИзменения = КоллекцияИзмененийПараметраРаботыПрограммы();
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Изменения) Тогда
			
			// Если производится обновление вне обновления ИБ,
			// тогда требуется добавить изменения к следующей версии,
			// чтобы при переходе на очередную версию, изменения
			// выполненные вне обновления ИБ были учтены.
			Версия = Метаданные.Версия;
			
			ОбновлениеВнеОбновленияИБ =
				ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ , Версия) = 0;
			
			Если ОбновлениеВнеОбновленияИБ Тогда
				Версия = СледующаяВерсия(Версия);
			КонецЕсли;
			
			ОбновитьСоставИзменений = Истина;
			Строка = ПоследниеИзменения.Добавить();
			Строка.Изменения          = Изменения;
			Строка.ВерсияКонфигурации = Версия;
		КонецЕсли;
		
		МинимальнаяВерсияИБ = ОбновлениеИнформационнойБазыСлужебныйПовтИсп.МинимальнаяВерсияИБ();
		
		// Удаление изменений для версий ИБ, которые меньше минимальной
		// вместо версий меньше или равных минимальной, чтобы обеспечить
		// возможность обновления вне обновления ИБ.
		Индекс = ПоследниеИзменения.Количество()-1;
		Пока Индекс >=0 Цикл
			ВерсияИзменения = ПоследниеИзменения[Индекс].ВерсияКонфигурации;
			
			Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(МинимальнаяВерсияИБ, ВерсияИзменения) > 0 Тогда
				ПоследниеИзменения.Удалить(Индекс);
				ОбновитьСоставИзменений = Истина;
			КонецЕсли;
			Индекс = Индекс - 1;
		КонецЦикла;
		
		Если ОбновитьСоставИзменений Тогда
			ПроверитьВозможностьОбновленияВМоделиСервиса(ИмяПараметра, Изменения, "ДобавлениеИзменений");
			УстановитьХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметраХраненияИзменений,
				ПоследниеИзменения);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры


// Для вызова из процедуры ВыполнитьОбновлениеИнформационнойБазы.
Процедура ЗагрузитьОбновитьПараметрыРаботыПрограммы() Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ОбновитьПараметрыРаботыВерсийРасширенийCУчетомРежимаВыполнения(Ложь);
		Возврат;
	КонецЕсли;
	
	Попытка
		Если ТребуетсяЗагрузитьПараметрыРаботыПрограммы() Тогда
			ЗагрузитьПараметрыРаботыПрограммыCУчетомРежимаВыполнения(Ложь);
		КонецЕсли;
	Исключение
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными")
		   И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ПодключенныеРасширения)
		И Не ВыполнятьОбновлениеБезФоновогоЗадания() Тогда
		// Запуск фонового задания обновления параметров.
		Результат = ОбновитьПараметрыРаботыПрограммыВФоне(Неопределено, Неопределено, Ложь);
		ОбработанныйРезультат = ОбработанныйРезультатДлительнойОперации(Результат, Ложь);
		
		Если ЗначениеЗаполнено(ОбработанныйРезультат.КраткоеПредставлениеОшибки) Тогда
			ВызватьИсключение ОбработанныйРезультат.ПодробноеПредставлениеОшибки;
		КонецЕсли;
	Иначе
		Попытка
			ОбновитьПараметрыРаботыПрограммыCУчетомРежимаВыполнения(Ложь);
		Исключение
			Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными")
			   И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
				МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
				МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
			КонецЕсли;
			ВызватьИсключение;
		КонецПопытки;
		ОбновитьПараметрыРаботыВерсийРасширенийCУчетомРежимаВыполнения(Ложь);
	КонецЕсли;
	
КонецПроцедуры

// Для процедуры ЗагрузитьОбновитьПараметрыРаботыПрограммы и вызова из формы ИндикацияХодаОбновленияИБ.
Функция ТребуетсяЗагрузитьПараметрыРаботыПрограммы() Экспорт
	
	Возврат НеобходимоОбновление() И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ();
	
КонецФункции

// Для вызова из формы ИндикацияХодаОбновленияИБ.
Функция ЗагрузитьПараметрыРаботыПрограммыВФоне(ОжидатьЗавершение, ИдентификаторФормы, СообщитьПрогресс) Экспорт
	
	ПараметрыОперации = ДлительныеОперации.ПараметрыВыполненияВФоне(ИдентификаторФормы);
	ПараметрыОперации.НаименованиеФоновогоЗадания = НСтр("ru = 'Фоновая загрузка параметров работы программы'");
	ПараметрыОперации.ОжидатьЗавершение = ОжидатьЗавершение;
	
	Если ОбщегоНазначения.РежимОтладки() Тогда
		СообщитьПрогресс = Ложь;
	КонецЕсли;
	
	Возврат ДлительныеОперации.ВыполнитьВФоне(
		"РегистрыСведений.ПараметрыРаботыПрограммы.ОбработчикДлительнойОперацииЗагрузкиПараметровРаботыПрограммы",
		СообщитьПрогресс,
		ПараметрыОперации);
	
КонецФункции

// Для вызова из формы ИндикацияХодаОбновленияИБ.
Функция ОбновитьПараметрыРаботыПрограммыВФоне(ОжидатьЗавершение, ИдентификаторФормы, СообщитьПрогресс) Экспорт
	
	ПараметрыОперации = ДлительныеОперации.ПараметрыВыполненияВФоне(ИдентификаторФормы);
	ПараметрыОперации.НаименованиеФоновогоЗадания = НСтр("ru = 'Фоновое обновление параметров работы программы'");
	ПараметрыОперации.ОжидатьЗавершение = ОжидатьЗавершение;
	ПараметрыОперации.БезРасширений = Истина;
	
	Если ОбщегоНазначения.РежимОтладки()
	   И Не ЗначениеЗаполнено(ПараметрыСеанса.ПодключенныеРасширения) Тогда
		СообщитьПрогресс = Ложь;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ПодключенныеРасширения)
	   И Не ДоступноВыполнениеФоновыхЗаданий() Тогда
		
		ВызватьИсключение
			НСтр("ru = 'Обновление параметров работы программы, когда подключены расширения конфигурации,
			           |может быть выполнено только в фоновом задании без расширений конфигурации.
			           |
			           |В файловой информационной базе фоновое задание невозможно запустить
			           |из другого фонового задания, а также из COM-Соединения.
			           |
			           |Для выполнения обновления необходимо, либо делать обновление интерактивно
			           |через запуск 1С:Предприятия, либо временно отключать расширения конфигурации.'");
	КонецЕсли;
	
	Возврат ДлительныеОперации.ВыполнитьВФоне(
		"РегистрыСведений.ПараметрыРаботыПрограммы.ОбработчикДлительнойОперацииОбновленияПараметровРаботыПрограммы",
		СообщитьПрогресс,
		ПараметрыОперации);
	
КонецФункции

// Для вызова из формы ИндикацияХодаОбновленияИБ.
Функция ОбновитьПараметрыРаботыВерсийРасширенийВФоне(ОжидатьЗавершение, ИдентификаторФормы, СообщитьПрогресс) Экспорт
	
	ПараметрыОперации = ДлительныеОперации.ПараметрыВыполненияВФоне(ИдентификаторФормы);
	ПараметрыОперации.НаименованиеФоновогоЗадания = НСтр("ru = 'Фоновое обновление параметров работы версий расширений'");
	ПараметрыОперации.ОжидатьЗавершение = ОжидатьЗавершение;
	
	Если ОбщегоНазначения.РежимОтладки() Тогда
		СообщитьПрогресс = Ложь;
	КонецЕсли;
	
	Возврат ДлительныеОперации.ВыполнитьВФоне(
		"РегистрыСведений.ПараметрыРаботыПрограммы.ОбработчикДлительнойОперацииОбновленияПараметровВерсийРасширений",
		СообщитьПрогресс,
		ПараметрыОперации);
	
КонецФункции

// Для вызова из формы ИндикацияХодаОбновленияИБ.
Функция ОбработанныйРезультатДлительнойОперации(Результат, Операция) Экспорт
	
	КраткоеПредставлениеОшибки   = Неопределено;
	ПодробноеПредставлениеОшибки = Неопределено;
	
	Если Результат = Неопределено Или Результат.Статус = "Отменено" Тогда
		
		Если Операция = "ЗагрузкаПараметровРаботыПрограммы" Тогда
			КраткоеПредставлениеОшибки =
				НСтр("ru = 'Не удалось загрузить параметры работы программы по причине:
				           |Фоновое задание, выполняющее загрузку отменено.'");
			
		ИначеЕсли Операция = "ОбновлениеПараметровРаботыПрограммы" Тогда
			КраткоеПредставлениеОшибки =
				НСтр("ru = 'Не удалось обновить параметры работы программы по причине:
				           |Фоновое задание, выполняющее обновление отменено.'");
			
		Иначе // ОбновлениеПараметровРаботыВерсийРасширений.
			КраткоеПредставлениеОшибки =
				НСтр("ru = 'Не удалось обновить параметры работы версий расширений по причине:
				           |Фоновое задание, выполняющее обновление отменено.'");
		КонецЕсли;
		
	ИначеЕсли Результат.Статус = "Выполнено" Тогда
		РезультатВыполнения = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
		УдалитьИзВременногоХранилища(Результат.АдресРезультата);
		
		Если ТипЗнч(РезультатВыполнения) = Тип("Структура") Тогда
			КраткоеПредставлениеОшибки   = РезультатВыполнения.КраткоеПредставлениеОшибки;
			ПодробноеПредставлениеОшибки = РезультатВыполнения.ПодробноеПредставлениеОшибки;
			
		ИначеЕсли Операция = "ЗагрузкаПараметровРаботыПрограммы" Тогда
			КраткоеПредставлениеОшибки =
				НСтр("ru = 'Не удалось загрузить параметры работы программы по причине:
				           |Фоновое задание, выполняющее загрузку не вернуло результат.'");
			
		ИначеЕсли Операция = "ОбновлениеПараметровРаботыПрограммы" Тогда
			КраткоеПредставлениеОшибки =
				НСтр("ru = 'Не удалось обновить параметры работы программы по причине:
				           |Фоновое задание, выполняющее обновление не вернуло результат.'");
			
		Иначе // ОбновлениеПараметровРаботыВерсийРасширений.
			КраткоеПредставлениеОшибки =
				НСтр("ru = 'Не удалось обновить параметры работы версий расширений по причине:
				           |Фоновое задание, выполняющее обновление не вернуло результат.'");
		КонецЕсли;
		
	ИначеЕсли Результат.Статус <> "ЗагрузкаПараметровРаботыПрограммыНеТребуется"
	        И Результат.Статус <> "ЗагрузкаИОбновлениеПараметровРаботыПрограммыНеТребуются"
	        И Результат.Статус <> "ОбновлениеПараметровРаботыВерсийРасширенийНеТребуется" Тогда
		
		// Ошибка выполнения фонового задания.
		КраткоеПредставлениеОшибки   = Результат.КраткоеПредставлениеОшибки;
		ПодробноеПредставлениеОшибки = Результат.ПодробноеПредставлениеОшибки;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ПодробноеПредставлениеОшибки)
	   И    ЗначениеЗаполнено(КраткоеПредставлениеОшибки) Тогда
		
		ПодробноеПредставлениеОшибки = КраткоеПредставлениеОшибки;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(КраткоеПредставлениеОшибки)
	   И    ЗначениеЗаполнено(ПодробноеПредставлениеОшибки) Тогда
		
		КраткоеПредставлениеОшибки = ПодробноеПредставлениеОшибки;
	КонецЕсли;
	
	ОбработанныйРезультат = Новый Структура;
	ОбработанныйРезультат.Вставить("КраткоеПредставлениеОшибки",   КраткоеПредставлениеОшибки);
	ОбработанныйРезультат.Вставить("ПодробноеПредставлениеОшибки", ПодробноеПредставлениеОшибки);
	
	Возврат ОбработанныйРезультат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Для вызова из фонового задания с текущим составом расширений конфигурации.
Процедура ОбработчикДлительнойОперацииЗагрузкиПараметровРаботыПрограммы(СообщитьПрогресс, АдресХранилища) Экспорт
	
	РезультатВыполнения = Новый Структура;
	РезультатВыполнения.Вставить("КраткоеПредставлениеОшибки",   Неопределено);
	РезультатВыполнения.Вставить("ПодробноеПредставлениеОшибки", Неопределено);
	
	Попытка
		ЗагрузитьПараметрыРаботыПрограммыCУчетомРежимаВыполнения(СообщитьПрогресс);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		РезультатВыполнения.КраткоеПредставлениеОшибки   = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
		РезультатВыполнения.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		// Переход в режим открытия формы повторной синхронизации данных перед запуском
		// с двумя вариантами "Синхронизировать и продолжить" и "Продолжить".
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными")
		   И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(РезультатВыполнения, АдресХранилища);
	
КонецПроцедуры

// Для вызова из фонового задания без подключенных расширений конфигурации.
Процедура ОбработчикДлительнойОперацииОбновленияПараметровРаботыПрограммы(СообщитьПрогресс, АдресХранилища) Экспорт
	
	РезультатВыполнения = Новый Структура;
	РезультатВыполнения.Вставить("КраткоеПредставлениеОшибки",   Неопределено);
	РезультатВыполнения.Вставить("ПодробноеПредставлениеОшибки", Неопределено);
	
	Попытка
		ОбновитьПараметрыРаботыПрограммыCУчетомРежимаВыполнения(СообщитьПрогресс);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		РезультатВыполнения.КраткоеПредставлениеОшибки   = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
		РезультатВыполнения.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		// Переход в режим открытия формы повторной синхронизации данных перед запуском
		// с двумя вариантами "Синхронизировать и продолжить" и "Продолжить".
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными")
		   И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(РезультатВыполнения, АдресХранилища);
	
КонецПроцедуры

// Для вызова из фонового задания с текущим составом расширений конфигурации.
Процедура ОбработчикДлительнойОперацииОбновленияПараметровВерсийРасширений(СообщитьПрогресс, АдресХранилища) Экспорт
	
	РезультатВыполнения = Новый Структура;
	РезультатВыполнения.Вставить("КраткоеПредставлениеОшибки",   Неопределено);
	РезультатВыполнения.Вставить("ПодробноеПредставлениеОшибки", Неопределено);
	
	Попытка
		ОбновитьПараметрыРаботыВерсийРасширенийCУчетомРежимаВыполнения(СообщитьПрогресс);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		РезультатВыполнения.КраткоеПредставлениеОшибки   = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
		РезультатВыполнения.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
		// Переход в режим открытия формы повторной синхронизации данных перед запуском
		// с двумя вариантами "Синхронизировать и продолжить" и "Продолжить".
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными")
		   И ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(РезультатВыполнения, АдресХранилища);
	
КонецПроцедуры

Процедура ЗагрузитьПараметрыРаботыПрограммыCУчетомРежимаВыполнения(СообщитьПрогресс)
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		ВызватьИсключение
			НСтр("ru = 'Не удалось загрузить параметры работы программы по причине:
			           |Загрузку невозможно выполнить в области данных.'");
	КонецЕсли;
	
	НастройкаПодчиненногоУзлаРИБ = Ложь;
	Если Не НеобходимоОбновление(НастройкаПодчиненногоУзлаРИБ)
	 Или Не ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() Тогда
		Возврат;
	КонецЕсли;
	
	// РИБ-обмен данными, обновление в подчиненном узле ИБ.
	МодульОценкаПроизводительности = Неопределено;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОценкаПроизводительности") Тогда
		МодульОценкаПроизводительности = ОбщегоНазначения.ОбщийМодуль("ОценкаПроизводительности");
		ВремяНачала = МодульОценкаПроизводительности.НачатьЗамерВремени();
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
		МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не НастройкаПодчиненногоУзлаРИБ Тогда
		СтандартнаяОбработка = Истина;
		ОбщегоНазначенияПереопределяемый.ПередЗагрузкойПриоритетныхДанныхВПодчиненномРИБУзле(
			СтандартнаяОбработка);
		
		Если СтандартнаяОбработка = Истина
		   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
			
			// Загрузка предопределенных элементов и идентификаторов объектов метаданных из главного узла.
			МодульОбменДаннымиСервер.ЗагрузитьПриоритетныеДанныеВПодчиненныйУзелРИБ();
		КонецЕсли;
		
		Если СообщитьПрогресс Тогда
			ДлительныеОперации.СообщитьПрогресс(5);
		КонецЕсли;
	КонецЕсли;
	
	// Проверка загрузки идентификаторов объектов метаданных из главного узла.
	СписокКритичныхИзменений = "";
	Попытка
		Справочники.ИдентификаторыОбъектовМетаданных.ВыполнитьОбновлениеДанных(Ложь, Ложь, Истина, , СписокКритичныхИзменений);
	Исключение
		// Переход в режим открытия формы повторной синхронизации данных перед запуском
		// с одним вариантом "Синхронизировать и продолжить".
		Если Не НастройкаПодчиненногоУзлаРИБ
		   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЗначениеЗаполнено(СписокКритичныхИзменений) Тогда
		
		ИмяСобытия = НСтр("ru = 'Идентификаторы объектов метаданных.Требуется загрузить критичные изменения'",
			ОбщегоНазначения.КодОсновногоЯзыка());
		
		ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Ошибка, , , СписокКритичныхИзменений);
		
		// Переход в режим открытия формы повторной синхронизации данных перед запуском
		// с одним вариантом "Синхронизировать и продолжить".
		Если Не НастройкаПодчиненногоУзлаРИБ
		   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
			МодульОбменДаннымиСервер.ВключитьПовторениеЗагрузкиСообщенияОбменаДаннымиПередЗапуском();
		КонецЕсли;
		
		ТекстОшибки =
			НСтр("ru = 'Информационная база не может быть обновлена из-за проблемы в главном узле:
			           |- главный узел был некорректно обновлен (возможно не был увеличен номер версии конфигурации,
			           |  из-за чего не заполнился справочник Идентификаторы объектов метаданных);
			           |- либо были отменены к выгрузке приоритетные данные (элементы
			           |  справочника Идентификаторы объектов метаданных).
			           |
			           |Необходимо заново выполнить обновление главного узла, зарегистрировать к выгрузке
			           |приоритетные данные и повторить синхронизацию данных:
			           |- в главном узле запустите программу с параметром /C ЗапуститьОбновлениеИнформационнойБазы;
			           |%1'");
		
		Если НастройкаПодчиненногоУзлаРИБ Тогда
			// Настройка подчиненного узла РИБ при первом запуске.
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки,
				НСтр("ru = '- затем повторите создание подчиненного узла.'"));
		Иначе
			// Обновление подчиненного узла РИБ.
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки,
				НСтр("ru = '- затем повторите синхронизацию данных с этой информационной базой
				           | (сначала в главном узле, затем в этой информационной базе после перезапуска).'"));
		КонецЕсли;
		
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(10);
	КонецЕсли;
	
	Если МодульОценкаПроизводительности <> Неопределено Тогда
		МодульОценкаПроизводительности.ЗакончитьЗамерВремени("ВремяЗагрузкиПриоритетныхДанных", ВремяНачала);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьПараметрыРаботыПрограммыCУчетомРежимаВыполнения(СообщитьПрогресс)
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ПодключенныеРасширения)
		И Не ВыполнятьОбновлениеБезФоновогоЗадания() Тогда
		ВызватьИсключение
			НСтр("ru = 'Не удалось обновить параметры работы программы по причине:
			           |Найдены подключенные расширения конфигурации.'");
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		ВызватьИсключение
			НСтр("ru = 'Не удалось обновить параметры работы программы по причине:
			           |Обновление невозможно выполнить в области данных.'");
	КонецЕсли;
	
	МодульОценкаПроизводительности = Неопределено;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОценкаПроизводительности") Тогда
		МодульОценкаПроизводительности = ОбщегоНазначения.ОбщийМодуль("ОценкаПроизводительности");
		ВремяНачала = МодульОценкаПроизводительности.НачатьЗамерВремени();
	КонецЕсли;
	
	// Нет РИБ-обмена данными
	// или обновление в главном узле ИБ
	// или обновление при первом запуске подчиненного узла
	// или обновление после загрузки справочника "Идентификаторы объектов метаданных" из главного узла.
	ОбновитьПараметрыРаботыПрограммы(СообщитьПрогресс);
	
	Если МодульОценкаПроизводительности <> Неопределено Тогда
		МодульОценкаПроизводительности.ЗакончитьЗамерВремени("ВремяОбновленияКэшейМетаданных", ВремяНачала);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьПараметрыРаботыВерсийРасширенийCУчетомРежимаВыполнения(СообщитьПрогресс)
	
	Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(65);
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ПараметрЗапускаКлиента = ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить("ПараметрЗапуска");
	УстановитьПривилегированныйРежим(Ложь);
	Если СтрНайти(НРег(ПараметрЗапускаКлиента), НРег("ЗапуститьОбновлениеИнформационнойБазы")) > 0 Тогда
		РегистрыСведений.ПараметрыРаботыВерсийРасширений.ОчиститьВсеПараметрыРаботыРасширений();
	КонецЕсли;
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(75);
	КонецЕсли;
	
	РегистрыСведений.ПараметрыРаботыВерсийРасширений.ЗаполнитьВсеПараметрыРаботыРасширений();
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(95);
	КонецЕсли;
	
КонецПроцедуры

// Для функции ИзмененияПараметраРаботыПрограммы.
Функция СледующаяВерсия(Версия)
	
	Массив = СтрРазделить(Версия, ".");
	
	Возврат ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(
		Версия) + "." + Формат(Число(Массив[3]) + 1, "ЧГ=");
	
КонецФункции

// Для процедур ЗагрузитьОбновитьПараметрыРаботыПрограммы.
Процедура ОбновитьПараметрыРаботыПрограммы(СообщитьПрогресс = Ложь)
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(15);
	КонецЕсли;
	
	Если Не СтандартныеПодсистемыПовтИсп.ОтключитьИдентификаторыОбъектовМетаданных() Тогда
		Справочники.ИдентификаторыОбъектовМетаданных.ВыполнитьОбновлениеДанных(Ложь, Ложь, Ложь);
	КонецЕсли;
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(25);
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
		МодульУправлениеДоступомСлужебный.ОбновитьПараметрыОграниченияДоступа();
	КонецЕсли;
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(45);
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтрольВеденияУчета") Тогда
		МодульКонтрольВеденияУчетаСлужебный = ОбщегоНазначения.ОбщийМодуль("КонтрольВеденияУчетаСлужебный");
		МодульКонтрольВеденияУчетаСлужебный.ОбновитьПараметрыПроверокУчета();
	КонецЕсли;
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(55);
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
		МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
		МодульОбменДаннымиСервер.ВыполнитьОбновлениеПравилДляОбменаДанными();
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Печать") Тогда
		МодульУправлениеПечатью = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатью");
		МодульУправлениеПечатью.ОбновитьКонтрольнуюСуммуМакетов();
	КонецЕсли;
	
	Если СообщитьПрогресс Тогда
		ДлительныеОперации.СообщитьПрогресс(65);
	КонецЕсли;
	
	ИмяПараметра = "СтандартныеПодсистемы.БазоваяФункциональность.ДатаОбновленияВсехПараметровРаботыПрограммы";
	СтандартныеПодсистемыСервер.УстановитьПараметрРаботыПрограммы(ИмяПараметра, ТекущаяДатаСеанса());
	
	Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных()
	   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		
		МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
		МодульУправлениеДоступомСлужебный.УстановитьОбновлениеДоступа(Истина);
	КонецЕсли;
	
КонецПроцедуры

// Для функции ПараметрРаботыПрограммы и процедуры ОбновитьПараметрРаботыПрограммы.
Функция ОписаниеЗначенияПараметраРаботыПрограммы(ИмяПараметра, ПроверитьВозможностьОбновленияВМоделиСервиса = Истина)
	
	ОписаниеЗначения = ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра);
	
	Если ТипЗнч(ОписаниеЗначения) <> Тип("Структура")
	 Или ОписаниеЗначения.Количество() <> 2
	 Или Не ОписаниеЗначения.Свойство("Версия")
	 Или Не ОписаниеЗначения.Свойство("Значение") Тогда
		
		Если СтандартныеПодсистемыСервер.ВерсияПрограммыОбновленаДинамически() Тогда
			СтандартныеПодсистемыСервер.ПотребоватьПерезапускСеансаПоПричинеДинамическогоОбновленияВерсииПрограммы();
		КонецЕсли;
		ОписаниеЗначения = Новый Структура("Версия, Значение");
		Если ПроверитьВозможностьОбновленияВМоделиСервиса Тогда
			ПроверитьВозможностьОбновленияВМоделиСервиса(ИмяПараметра, Null, "Получение");
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОписаниеЗначения;
	
КонецФункции

// Для функций ОписаниеЗначенияПараметраРаботыПрограммы, ИзмененияПараметраРаботыПрограммы и
// процедуры ДобавитьИзмененияПараметраРаботыПрограммы.
//
Функция ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИмяПараметра", ИмяПараметра);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПараметрыРаботыПрограммы.ХранилищеПараметра
	|ИЗ
	|	РегистрСведений.ПараметрыРаботыПрограммы КАК ПараметрыРаботыПрограммы
	|ГДЕ
	|	ПараметрыРаботыПрограммы.ИмяПараметра = &ИмяПараметра";
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ХранилищеПараметра.Получить();
	КонецЕсли;
	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	Возврат Неопределено;
	
КонецФункции

// Для процедур УстановитьПараметрРаботыПрограммы, ДобавитьИзмененияПараметраРаботыПрограммы.
Процедура УстановитьХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра, ХранимыеДанные)
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ИмяПараметра.Установить(ИмяПараметра);
	
	НоваяЗапись = НаборЗаписей.Добавить();
	НоваяЗапись.ИмяПараметра       = ИмяПараметра;
	НоваяЗапись.ХранилищеПараметра = Новый ХранилищеЗначения(ХранимыеДанные);
	
	ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписей, , Ложь, Ложь);
	
КонецПроцедуры

Процедура ПроверитьВозможностьОбновленияВМоделиСервиса(ИмяПараметра, НовоеЗначение, Операция)
	
	Если Не ОбщегоНазначения.РазделениеВключено()
	 Или Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	// Запись контекста ошибки в журнал регистрации для администратора сервиса.
	ОписаниеЗначения = ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметра);
	
	ИмяПараметраХраненияИзменений = ИмяПараметра + ":Изменения";
	ПоследниеИзменения = ХранимыеДанныеПараметраРаботыПрограммы(ИмяПараметраХраненияИзменений);
	
	ИмяСобытия = НСтр("ru = 'Параметры работы программы.Не выполнено обновление в неразделенном режиме'",
		ОбщегоНазначения.КодОсновногоЯзыка());
	
	Комментарий =
		НСтр("ru = '1. Перешлите сообщение в техническую поддержку.
		           |2. Попытайтесь устранить проблему самостоятельно. Для этого
		           |запустите программу с параметром командной строки 1С:Предприятия 8
		           |""/С ЗапуститьОбновлениеИнформационнойБазы"" от имени пользователя
		           |с правами администратора сервиса, то есть в неразделенном режиме.
		           |
		           |Сведения об проблемном параметре:'");

	Комментарий = Комментарий + Символы.ПС +
	"ВерсияМетаданных = " + Метаданные.Версия + "
	|ИмяПараметра = " + ИмяПараметра + "
	|Операция = " + Операция + "
	|ОписаниеЗначения =
	|" + XMLСтрока(Новый ХранилищеЗначения(ОписаниеЗначения)) + "
	|НовоеЗначение =
	|" + XMLСтрока(Новый ХранилищеЗначения(НовоеЗначение)) + "
	|ПоследниеИзменения =
	|" + XMLСтрока(Новый ХранилищеЗначения(ПоследниеИзменения));
	
	ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Ошибка,,, Комментарий);
	
	// Исключение для пользователя.
	ТекстОшибки =
		НСтр("ru = 'Параметры работы программы не обновлены в неразделенном режиме.
		           |Обратитесь к администратору сервиса. Подробности в журнале регистрации.'");
	
	ВызватьИсключение ТекстОшибки;
	
КонецПроцедуры

// Параметры:
//  ПоследниеИзменения - см. КоллекцияИзмененийПараметраРаботыПрограммы
//
Функция ЭтоИзмененияПараметраРаботыПрограммы(ПоследниеИзменения)
	
	Если ТипЗнч(ПоследниеИзменения)              <> Тип("ТаблицаЗначений")
	 ИЛИ ПоследниеИзменения.Колонки.Количество() <> 2
	 ИЛИ ПоследниеИзменения.Колонки[0].Имя       <> "ВерсияКонфигурации"
	 ИЛИ ПоследниеИзменения.Колонки[1].Имя       <> "Изменения" Тогда
		
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция ДоступноВыполнениеФоновыхЗаданий()
	
	Если ТекущийРежимЗапуска() = Неопределено
	   И ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		
		Сеанс = ПолучитьТекущийСеансИнформационнойБазы();
		Если Сеанс.ИмяПриложения = "COMConnection"
		 Или Сеанс.ИмяПриложения = "BackgroundJob" Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция ВыполнятьОбновлениеБезФоновогоЗадания()
	
	Если Не ДоступноВыполнениеФоновыхЗаданий()
	   И Не ЕстьРолиМодифицированныеРасширениями() Тогда
		
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ЕстьРолиМодифицированныеРасширениями()
	
	Для Каждого Роль Из Метаданные.Роли Цикл
		Если Роль.ЕстьИзмененияРасширениямиКонфигурации() Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

// Возвращаемое значение:
//  ТаблицаЗначений:
//   * ВерсияКонфигурации - Строка
//   * Изменения - Произвольный
//
Функция КоллекцияИзмененийПараметраРаботыПрограммы()

	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("ВерсияКонфигурации");
	Результат.Колонки.Добавить("Изменения");

	Возврат Результат;
	
КонецФункции

#КонецОбласти

#КонецЕсли
