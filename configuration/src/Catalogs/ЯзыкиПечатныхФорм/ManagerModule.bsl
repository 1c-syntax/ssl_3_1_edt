///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Процедура ЗаполнитьПоставляемыеЯзыки() Экспорт
	
	Для Каждого КодЯзыка Из СтандартныеПодсистемыСервер.ЯзыкиКонфигурации() Цикл
		
		НачатьТранзакцию();
		Попытка
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник.ЯзыкиПечатныхФорм");
			ЭлементБлокировки.УстановитьЗначение("Код", КодЯзыка);
			Блокировка.Заблокировать();
			
			Если Не ЗначениеЗаполнено(Справочники.ЯзыкиПечатныхФорм.НайтиПоКоду(КодЯзыка)) Тогда
				Язык = Справочники.ЯзыкиПечатныхФорм.СоздатьЭлемент();
				Язык.Код = КодЯзыка;
				ОбновлениеИнформационнойБазы.ЗаписатьДанные(Язык);
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
	
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДоступныеЯзыки(СРегиональнымиНастройками = Ложь, ТолькоДополнительные = Ложь) Экспорт
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ЯзыкиПечатныхФорм.Код КАК Код
	|ИЗ
	|	Справочник.ЯзыкиПечатныхФорм КАК ЯзыкиПечатныхФорм
	|ГДЕ
	|	НЕ ЯзыкиПечатныхФорм.ПометкаУдаления
	|	И НЕ ЯзыкиПечатныхФорм.Код В (&СписокИсключений)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЯзыкиПечатныхФорм.РеквизитДопУпорядочивания,
	|	ЯзыкиПечатныхФорм.Ссылка";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("СписокИсключений", ?(ТолькоДополнительные,
		СтандартныеПодсистемыСервер.ЯзыкиКонфигурации(), Новый Массив));
	
	Языки = Запрос.Выполнить().Выгрузить();
	
	Если Не СРегиональнымиНастройками Тогда
		Для Каждого Язык Из Языки Цикл
			Язык.Код = СтрРазделить(Язык.Код, "_", Истина)[0];
		КонецЦикла;
		Языки.Свернуть("Код");
	КонецЕсли;
	
	Возврат Языки.ВыгрузитьКолонку("Код");
	
КонецФункции

Функция ДополнительныеЯзыкиПечатныхФорм() Экспорт
	
	Возврат ДоступныеЯзыки(Ложь, Истина);
	
КонецФункции

Функция ЭтоДополнительныйЯзыкПечатныхФорм(КодЯзыка) Экспорт
	
	Если Не ЗначениеЗаполнено(КодЯзыка) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Возврат СтандартныеПодсистемыСервер.ЯзыкиКонфигурации().Найти(КодЯзыка) = Неопределено;
	
КонецФункции

#КонецОбласти

#КонецЕсли