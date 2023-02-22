///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Идентификатор, который используется для начальной страницы в модуле ВариантыОтчетовПереопределяемый.
//
// Возвращаемое значение:
//   Строка - идентификатор, который используется для начальной страницы в модуле ВариантыОтчетовПереопределяемый.
//
Функция ИдентификаторНачальнойСтраницы() Экспорт
	
	Возврат "Подсистемы";
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Добавляет Ключ в Структуру если его нет.
//
// Параметры:
//   Структура - Структура    - дополняемая структура.
//   Ключ      - Строка       - имя свойства.
//   Значение  - Произвольный - значение свойства если оно отсутствует в структуре.
//
Процедура ДополнитьСтруктуруКлючом(Структура, Ключ, Значение = Неопределено) Экспорт
	Если Не Структура.Свойство(Ключ) Тогда
		Структура.Вставить(Ключ, Значение);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Полное имя подсистемы.
Функция ПолноеИмяПодсистемы() Экспорт
	Возврат "СтандартныеПодсистемы.ВариантыОтчетов";
КонецФункции

// Превращает строку поиска в массив слов с уникальными значениями, отсортированный по убыванию длины.
Функция РазложитьСтрокуПоискаВМассивСлов(СтрокаПоиска) Экспорт
	СловаИИхДлина = Новый СписокЗначений;
	ДлинаСтроки = СтрДлина(СтрокаПоиска);
	
	Слово = "";
	ДлинаСлова = 0;
	ОткрытаКавычка = Ложь;
	Для НомерСимвола = 1 По ДлинаСтроки Цикл
		КодСимвола = КодСимвола(СтрокаПоиска, НомерСимвола);
		Если КодСимвола = 34 Тогда // 34 - двойная кавычка ".
			ОткрытаКавычка = Не ОткрытаКавычка;
		ИначеЕсли ОткрытаКавычка
			Или (КодСимвола >= 48 И КодСимвола <= 57) // цифры
			Или (КодСимвола >= 65 И КодСимвола <= 90) // латиница большие
			Или (КодСимвола >= 97 И КодСимвола <= 122) // латиница маленькие
			Или (КодСимвола >= 1040 И КодСимвола <= 1103) // кириллица
			Или КодСимвола = 95 Тогда // символ "_"
			Слово = Слово + Символ(КодСимвола);
			ДлинаСлова = ДлинаСлова + 1;
		ИначеЕсли Слово <> "" Тогда
			Если СловаИИхДлина.НайтиПоЗначению(Слово) = Неопределено Тогда
				СловаИИхДлина.Добавить(Слово, Формат(ДлинаСлова, "ЧЦ=3; ЧВН="));
			КонецЕсли;
			Слово = "";
			ДлинаСлова = 0;
		КонецЕсли;
	КонецЦикла;
	
	Если Слово <> "" И СловаИИхДлина.НайтиПоЗначению(Слово) = Неопределено Тогда
		СловаИИхДлина.Добавить(Слово, Формат(ДлинаСлова, "ЧЦ=3; ЧВН="));
	КонецЕсли;
	
	СловаИИхДлина.СортироватьПоПредставлению(НаправлениеСортировки.Убыв);
	
	Возврат СловаИИхДлина.ВыгрузитьЗначения();
КонецФункции

// Превращает тип отчета в строковый идентификатор.
Функция ТипОтчетаСтрокой(Знач ТипОтчета, Знач Отчет = Неопределено) Экспорт
	ТипТипаОтчета = ТипЗнч(ТипОтчета);
	Если ТипТипаОтчета = Тип("Строка") Тогда
		Возврат ТипОтчета;
	ИначеЕсли ТипТипаОтчета = Тип("ПеречислениеСсылка.ТипыОтчетов") Тогда
		Если ТипОтчета = ПредопределенноеЗначение("Перечисление.ТипыОтчетов.Внутренний") Тогда
			Возврат "Внутренний";
		ИначеЕсли ТипОтчета = ПредопределенноеЗначение("Перечисление.ТипыОтчетов.Расширение") Тогда
			Возврат "Расширение";
		ИначеЕсли ТипОтчета = ПредопределенноеЗначение("Перечисление.ТипыОтчетов.Дополнительный") Тогда
			Возврат "Дополнительный";
		ИначеЕсли ТипОтчета = ПредопределенноеЗначение("Перечисление.ТипыОтчетов.Внешний") Тогда
			Возврат "Внешний";
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	Иначе
		Если ТипТипаОтчета <> Тип("Тип") Тогда
			ТипОтчета = ТипЗнч(Отчет);
		КонецЕсли;
		Если ТипОтчета = Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
			Возврат "Внутренний";
		ИначеЕсли ТипОтчета = Тип("СправочникСсылка.ИдентификаторыОбъектовРасширений") Тогда
			Возврат "Расширение";
		ИначеЕсли ТипОтчета = Тип("Строка") Тогда
			Возврат "Внешний";
		Иначе
			Возврат "Дополнительный";
		КонецЕсли;
	КонецЕсли;
КонецФункции

#Область ОбменПользовательскимиНастройками

Функция ИмяДействияПрименитьПереданныеНастройки() Экспорт 
	
	Возврат "ПрименитьПереданныеНастройки";
	
КонецФункции

#КонецОбласти

#КонецОбласти
