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
	Если НЕ ОценкаПроизводительностиСлужебный.ПодсистемаСуществует("СтандартныеПодсистемы.БазоваяФункциональность") Тогда
		ЭтотОбъект.Элементы.ФайлИмпорта.КнопкаВыбора = Ложь;
		ЕстьБСП = Ложь;
	Иначе
		ЕстьБСП = Истина;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВыбратьФайлаИмпортаПредложено(РасширениеРаботыСФайламиПодключено, ДополнительныеПараметры) Экспорт
	
	Если РасширениеРаботыСФайламиПодключено Тогда
		
		ВыборФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		ВыборФайла.МножественныйВыбор = Ложь;
		ВыборФайла.Заголовок = НСтр("ru = 'Выберите файл импорта замеров'");
		ВыборФайла.Фильтр = "Файлы импорта замеров (*.zip)|*.zip";
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ДиалогВыбораФайлаЗавершение", ЭтотОбъект, Неопределено);
		Если ЕстьБСП Тогда
			МодульФайловаяСистемаКлиент = Вычислить("ФайловаяСистемаКлиент");
			Если ТипЗнч(МодульФайловаяСистемаКлиент) = Тип("ОбщийМодуль") Тогда
				МодульФайловаяСистемаКлиент.ПоказатьДиалогВыбора(ОписаниеОповещения, ВыборФайла);
			КонецЕсли;
		Иначе
			ВыборФайла.Показать(ОписаниеОповещения);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлИмпортаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если ЕстьБСП Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ВыбратьФайлаИмпортаПредложено", ЭтотОбъект, Неопределено);
		МодульФайловаяСистемаКлиент = Вычислить("ФайловаяСистемаКлиент");
		Если ТипЗнч(МодульФайловаяСистемаКлиент) = Тип("ОбщийМодуль") Тогда
			МодульФайловаяСистемаКлиент.ПодключитьРасширениеДляРаботыСФайлами(ОписаниеОповещения);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Импорт(Команда)
	Файл = Новый Файл(ФайлИмпорта);
	Файл.НачатьПроверкуСуществования(Новый ОписаниеОповещения("ИмпортПослеПроверкиСуществования", ЭтотОбъект));
КонецПроцедуры

&НаКлиенте
Процедура ИмпортПослеПроверкиСуществования(Существует, ДополнительныеПараметры) Экспорт
	Если Не Существует Тогда 
		Сообщение = Новый СообщениеПользователю();
    	Сообщение.Текст = НСтр("ru = 'Выберите файл для импорта.'");
    	Сообщение.Поле = "ФайлИмпорта";
    	Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	ДвоичныеДанные = Новый ДвоичныеДанные(ФайлИмпорта);
    АдресХранилища = ПоместитьВоВременноеХранилище(ДвоичныеДанные, ЭтотОбъект.УникальныйИдентификатор);
    ВыполнитьИмпортНаСервере(ФайлИмпорта, АдресХранилища);	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ВыполнитьИмпортНаСервере(ИмяФайла, АдресХранилища)
	ОценкаПроизводительности.ЗагрузитьФайлОценкиПроизводительности(ИмяФайла, АдресХранилища);
КонецПроцедуры                                                                     

&НаКлиенте
Процедура ДиалогВыбораФайлаЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
    
    Если ВыбранныеФайлы <> Неопределено Тогда
		ФайлИмпорта = ВыбранныеФайлы[0];
	КонецЕсли;
		
КонецПроцедуры

#КонецОбласти