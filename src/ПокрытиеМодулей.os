#Использовать "."

Перем Конфигурация;

Функция ПолучитьСтрокиМодулей(Путь)

	СтрокиМодулей = Новый Соответствие();

	Файлы = НайтиФайлы(Путь, "*.bsl", Истина);
	
	Для Каждого ТекФайл Из Файлы Цикл
		
		СтрокиМодулей.Вставить(ТекФайл.ПолноеИмя, ПолучитьСтрокиМодуля(ТекФайл.ПолноеИмя));

	КонецЦикла;

	Возврат СтрокиМодулей;

КонецФункции // ПолучитьСтрокиМодулей()

Функция ПолучитьСтрокиМодуля(Путь)

	СтрокиМодуля = Новый Массив();

	Чтение = Новый ЧтениеТекста();
	Чтение.Открыть(Путь);

	ТекстСтроки = Чтение.ПрочитатьСтроку();

	НомерСтроки = 1;

	Пока НЕ ТекстСтроки = Неопределено Цикл

		Если НЕ ЕстьКодВСтроке(ТекстСтроки)Тогда
			ТекстСтроки = Чтение.ПрочитатьСтроку();
			НомерСтроки = НомерСтроки + 1;
			Продолжить;
		КонецЕсли;

		СтрокиМодуля.Добавить(НомерСтроки);

		ТекстСтроки = Чтение.ПрочитатьСтроку();
		НомерСтроки = НомерСтроки + 1;

	КонецЦикла;

	Возврат СтрокиМодуля;

КонецФункции // ПолучитьСтрокиМодуля()

Функция ЕстьКодВСтроке(Знач ТекстСтроки)

	Если НЕ ЗначениеЗаполнено(СокрЛП(ТекстСтроки)) Тогда
		Возврат Ложь;
	КонецЕсли;

	Если Лев(СокрЛП(ТекстСтроки), 2) = "//" Тогда
		Возврат Ложь;
	КонецЕсли;

	Если НЕ Лев(СокрЛП(ТекстСтроки), 1) = "|" Тогда
		Возврат Истина;
	КонецЕсли;

	КоличествоДвойныхКавычек = СтрЧислоВхождений(ТекстСтроки, """""");

	Пока КоличествоДвойныхКавычек > 0 Цикл
		ТекстСтроки = СтрЗаменить(ТекстСтроки, """""", "");
	КонецЦикла;

	Возврат (СтрЧислоВхождений(ТекстСтроки, """") > 0);

КонецФункции // ЕстьКодВСтроке()

Функция ПолучитьДанныеПокрытияИзЛога(Путь)

	ТекстПоискаСтроки = "<dbgtgtRemoteRequestResponse:commandToDbgServer xmlns:d2p1=\x22http://v8.1c.ru/8.3/debugger/dbgtgtCommands\x22 xsi:type=\x22d2p1:DBGTGTExtCmdMeasureResults\x22>";
	ТекстПоискаНачала = "<?xml version=""1.0"" encoding=""UTF-8""?><request";
	ТекстПоискаОкончания = "</dbgtgtRemoteRequestResponse:commandToDbgServer></request>";

	ДанныеПокрытия = Новый Массив();

	Чтение = Новый ЧтениеТекста();
	Чтение.Открыть(Путь);

	ТекстСтроки = Чтение.ПрочитатьСтроку();

	Пока НЕ ТекстСтроки = Неопределено Цикл

		// Проверим, что это строка с данными замера
		Поз = СтрНайти(ТекстСтроки, ТекстПоискаСтроки);

		Если Поз = 0 Тогда
			ТекстСтроки = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		ТекстСтроки = СтрЗаменить(ТекстСтроки, "\x22", """");

		// найдем начало данных замера
		Поз = СтрНайти(ТекстСтроки, ТекстПоискаНачала);
		ТекстСтроки = Сред(ТекстСтроки, Поз);
		
		// найдем окончание данных замера
		Поз = СтрНайти(ТекстСтроки, ТекстПоискаОкончания);
		ТекстСтроки = Сред(ТекстСтроки, 1, Поз + СтрДлина(ТекстПоискаОкончания));

		ДанныеПокрытия.Добавить(ТекстСтроки);

		ТекстСтроки = Чтение.ПрочитатьСтроку();

	КонецЦикла;

	Возврат ДанныеПокрытия;

КонецФункции

Функция ПрочитатьДанныеПокрытия(ДанныеПокрытия)

	Чтение = Новый ЧтениеXML();
	Чтение.УстановитьСтроку(ДанныеПокрытия);

	Пока Чтение.Прочитать() Цикл

		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "request" Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
		Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Продолжить;
		КонецЕсли;

		Если Чтение.Имя = "dbgtgtRemoteRequestResponse:data" Тогда
			ПараметрыОтладки = ПрочитатьПараметрыОтладки(Чтение);
		ИначеЕсли Чтение.Имя = "d2p1:measure" Тогда
			Возврат ПрочитатьРезультатыЗамера(Чтение);
		КонецЕсли;

	КонецЦикла;

КонецФункции

Функция ПреобразоватьВОбщийФорматПокрытия(ДанныеПокрытия, Путь)

	Запись = Новый ЗаписьXML();
	Запись.ОткрытьФайл(Путь);

	Запись.ЗаписатьОбъявлениеXML();
	Запись.ЗаписатьНачалоЭлемента("coverage");
	Запись.ЗаписатьАтрибут("version", "1");

	РезультатыЗамера = ПрочитатьДанныеПокрытия(ДанныеПокрытия);

	Для Каждого ТекМодуль Из РезультатыЗамера.Модули Цикл

		МодульОбъекта = ПолучитьМодульОбъекта(ТекМодуль.Параметры.ObjectID);

		Если МодульОбъекта = "" Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокиМодуля = ПолучитьСтрокиМодуля(МодульОбъекта);

		Запись.ЗаписатьНачалоЭлемента("file");
		Запись.ЗаписатьАтрибут("path", МодульОбъекта);
		
		Для Каждого ТекСтрока Из СтрокиМодуля Цикл
			Запись.ЗаписатьНачалоЭлемента("lineToCover");
			Запись.ЗаписатьАтрибут("lineNumber", ТекСтрока);
			Если ТекМодуль.Строки.Получить(ТекСтрока) = Неопределено Тогда
				Запись.ЗаписатьАтрибут("covered", "false");
			Иначе
				Запись.ЗаписатьАтрибут("covered", "true");
			КонецЕсли;
			Запись.ЗаписатьКонецЭлемента();
			//Сообщить(Символы.Таб + ТекСтрока.LineNo + ": " + ТекСтрока.durability);
		КонецЦикла;

		Запись.ЗаписатьКонецЭлемента();

	КонецЦикла;

	Запись.ЗаписатьКонецЭлемента();

	Возврат Запись.Закрыть();

КонецФункции

Функция ПрочитатьЗначение(Чтение)

	Если НЕ Чтение.Прочитать() Тогда
		Возврат Неопределено;
	КонецЕсли;

	Если НЕ Чтение.ИмеетЗначение Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат Чтение.Значение;

КонецФункции

Функция ПрочитатьПараметрыОтладки(Чтение)

	Параметры = Новый Структура();

	Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Если НЕ Чтение.Имя = "dbgtgtRemoteRequestResponse:data" Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "dbgtgtRemoteRequestResponse:data" Тогда
				Возврат Параметры;
			КонецЕсли;
		КонецЕсли;
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если НЕ Чтение.ИмеетИмя Тогда
				Продолжить;
			КонецЕсли;
			Если Чтение.Имя = "dbgtgtRemoteRequestResponse:bpVersion" Тогда
				Параметры.Вставить("bpVersion", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "dbgtgtRemoteRequestResponse:rteProcVersion" Тогда
				Параметры.Вставить("rteProcVersion", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "dbgtgtRemoteRequestResponse:infoBaseAlias" Тогда
				Параметры.Вставить("infoBaseAlias", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "dbgtgtRemoteRequestResponse:seanceID" Тогда
				Параметры.Вставить("seanceID", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "dbgtgtRemoteRequestResponse:targetID" Тогда
				Параметры.Вставить("targetID", ПрочитатьЗначение(Чтение));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Параметры;

КонецФункции

Функция ПрочитатьРезультатыЗамера(Чтение)

	Параметры = Новый Структура("Модули", Новый Массив());

	Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Если НЕ Чтение.Имя = "d2p1:measure" Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "d2p1:measure" Тогда
				Возврат Параметры;
			КонецЕсли;
		КонецЕсли;
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если НЕ Чтение.ИмеетИмя Тогда
				Продолжить;
			КонецЕсли;
			Если Чтение.Имя = "debugMeasure:targetID" Тогда
				Параметры.Вставить("ПредметОтладки", ПрочитатьПараметрыПредметаОтладки(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:totalDurability" Тогда
				Параметры.Вставить("totalDurability", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:totalIndepServerWorkTime" Тогда
				Параметры.Вставить("totalIndepServerWorkTime", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:performanceFrequency" Тогда
				Параметры.Вставить("performanceFrequency", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:moduleData" Тогда
				РезультатМодуля = ПрочитатьРезультатыЗамераМодуля(Чтение);
				Параметры.Модули.Добавить(РезультатМодуля);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Параметры;

КонецФункции // ПрочитатьРезультатыЗамера()

Функция ПрочитатьПараметрыПредметаОтладки(Чтение)

	Параметры = Новый Структура();

	Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Если НЕ Чтение.Имя = "debugMeasure:targetID" Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "debugMeasure:targetID" Тогда
				Возврат Параметры;
			КонецЕсли;
		КонецЕсли;
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если НЕ Чтение.ИмеетИмя Тогда
				Продолжить;
			КонецЕсли;
			Если Чтение.Имя = "id" Тогда
				Параметры.Вставить("id", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "seanceId" Тогда
				Параметры.Вставить("seanceId", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "seanceNo" Тогда
				Параметры.Вставить("seanceNo", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "infoBaseInstanceID" Тогда
				Параметры.Вставить("infoBaseInstanceID", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "infoBaseAlias" Тогда
				Параметры.Вставить("infoBaseAlias", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "isServerInfoBase" Тогда
				Параметры.Вставить("isServerInfoBase", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "userName" Тогда
				Параметры.Вставить("userName", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "configVersion" Тогда
				Параметры.Вставить("configVersion", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "targetType" Тогда
				Параметры.Вставить("targetType", ПрочитатьЗначение(Чтение));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Параметры;

КонецФункции

Функция ПрочитатьРезультатыЗамераМодуля(Чтение)

	Параметры = Новый Структура("Строки", Новый Соответствие());

	Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Если НЕ Чтение.Имя = "debugMeasure:moduleData" Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "debugMeasure:moduleData" Тогда
				Возврат Параметры;
			КонецЕсли;
		КонецЕсли;
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если НЕ Чтение.ИмеетИмя Тогда
				Продолжить;
			КонецЕсли;
			Если Чтение.Имя = "debugMeasure:moduleID" Тогда
				Параметры.Вставить("Параметры", ПрочитатьПараметрыМодуля(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:lineInfo" Тогда
				РезультатыСтроки = ПрочитатьРезультатыЗамераСтроки(Чтение);
				Параметры.Строки.Вставить(Число(РезультатыСтроки.LineNo), РезультатыСтроки);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Параметры;

КонецФункции // ПрочитатьРезультатыЗамераМодуля()

Функция ПрочитатьПараметрыМодуля(Чтение)

	Параметры = Новый Структура();

	Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Если НЕ Чтение.Имя = "debugMeasure:moduleID" Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "debugMeasure:moduleID" Тогда
				Возврат Параметры;
			КонецЕсли;
		КонецЕсли;
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если НЕ Чтение.ИмеетИмя Тогда
				Продолжить;
			КонецЕсли;
			Если Чтение.Имя = "objectID" Тогда
				Параметры.Вставить("objectID", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "propertyID" Тогда
				Параметры.Вставить("propertyID", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "version" Тогда
				Параметры.Вставить("version", ПрочитатьЗначение(Чтение));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Параметры;

КонецФункции

Функция ПрочитатьРезультатыЗамераСтроки(Чтение)

	Параметры = Новый Структура();

	Если НЕ Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Если НЕ Чтение.Имя = "debugMeasure:lineInfo" Тогда
		Возврат Параметры;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			Если Чтение.Имя = "debugMeasure:lineInfo" Тогда
				Возврат Параметры;
			КонецЕсли;
		КонецЕсли;
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если НЕ Чтение.ИмеетИмя Тогда
				Продолжить;
			КонецЕсли;
			Если Чтение.Имя = "debugMeasure:lineNo" Тогда
				Параметры.Вставить("lineNo", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:frequency" Тогда
				Параметры.Вставить("frequency", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:durability" Тогда
				Параметры.Вставить("durability", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:pureDurability" Тогда
				Параметры.Вставить("pureDurability", ПрочитатьЗначение(Чтение));
			ИначеЕсли Чтение.Имя = "debugMeasure:serverCallSignal" Тогда
				Параметры.Вставить("serverCallSignal", ПрочитатьЗначение(Чтение));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Параметры;

КонецФункции

Функция ПолучитьМодульОбъекта(Ид)
	
	Идентификаторы = Конфигурация.Идентификаторы();
	
	Идентификатор = Идентификаторы.Получить(Ид);

	Если Идентификатор = Неопределено Тогда
		Сообщить(СтрШаблон("Не найден модуль с идентификатором %1", Ид));
		Возврат "";
	КонецЕсли;

	Для Каждого ТекСвойство Из Идентификатор Цикл
		Если Лев(ТекСвойство.Ключ, 5) = "Модул" Тогда
			Если НЕ ЗначениеЗаполнено(ТекСвойство.Значение) Тогда
				Продолжить;
			КонецЕсли;
			Возврат ТекСвойство.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";

КонецФункции // ПолучитьМодульОбъекта()

КаталогФикстур = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "tests", "fixtures");
КаталогИсходников = ОбъединитьПути(КаталогФикстур, "test_src");
ФайлЛога = ОбъединитьПути(КаталогФикстур, "test.log");

КаталогРезультатов = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "test-result");

Если АргументыКоманднойСтроки.Количество() > 0 Тогда
	КаталогИсходников = АргументыКоманднойСтроки[0];
КонецЕсли;
Если АргументыКоманднойСтроки.Количество() > 1 Тогда
	ФайлЛога = АргументыКоманднойСтроки[1];
КонецЕсли;
Если АргументыКоманднойСтроки.Количество() > 2 Тогда
	КаталогРезультатов = АргументыКоманднойСтроки[2];
КонецЕсли;

Конфигурация = Новый Конфигурация(КаталогИсходников);

ДанныеПокрытия = ПолучитьДанныеПокрытияИзЛога(ФайлЛога);

НомерФайла = 1;
Для Каждого ТекДанные Из ДанныеПокрытия Цикл

	ФайлРезультата = ОбъединитьПути(КаталогРезультатов, "coverage_" + СокрЛП(НомерФайла) + ".xml");

	Текст = ПреобразоватьВОбщийФорматПокрытия(ТекДанные, ФайлРезультата);
	
	НомерФайла = НомерФайла + 1;

КонецЦикла;