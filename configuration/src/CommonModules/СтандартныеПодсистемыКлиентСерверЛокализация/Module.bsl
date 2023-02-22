///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Описывает правил транслитерации национального алфавита в латиницу.
//
// Параметры:
//  Правила - Соответствие из КлючИЗначение:
//    * Ключ - Строка - буква национального алфавита;
//    * Значение - Строка - буква латинского алфавита.
//
Процедура ПриЗаполненииПравилТранслитерации(Правила) Экспорт
	
	// Локализация
	// Транслитерация, используемая в загранпаспортах 1997-2010.
	Правила.Вставить("а","a");
	Правила.Вставить("б","b");
	Правила.Вставить("в","v");
	Правила.Вставить("г","g");
	Правила.Вставить("д","d");
	Правила.Вставить("е","e");
	Правила.Вставить("ё","e"); // АПК:163 требуется транслитерация.
	Правила.Вставить("ж","zh");
	Правила.Вставить("з","z");
	Правила.Вставить("и","i");
	Правила.Вставить("й","y");
	Правила.Вставить("к","k");
	Правила.Вставить("л","l");
	Правила.Вставить("м","m");
	Правила.Вставить("н","n");
	Правила.Вставить("о","o");
	Правила.Вставить("п","p");
	Правила.Вставить("р","r");
	Правила.Вставить("с","s");
	Правила.Вставить("т","t");
	Правила.Вставить("у","u");
	Правила.Вставить("ф","f");
	Правила.Вставить("х","kh");
	Правила.Вставить("ц","ts");
	Правила.Вставить("ч","ch");
	Правила.Вставить("ш","sh");
	Правила.Вставить("щ","shch");
	Правила.Вставить("ъ",""); // Пропускается.
	Правила.Вставить("ы","y");
	Правила.Вставить("ь",""); // Пропускается.
	Правила.Вставить("э","e");
	Правила.Вставить("ю","yu");
	Правила.Вставить("я","ya");
	// Конец Локализация
	
КонецПроцедуры

#КонецОбласти