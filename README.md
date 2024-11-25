# Контекстное меню Dolphin

### Сценарии при нажатии правой кнопкой мыши

Для решения рутинных задач с файлами и каталогами в файловом менеджере Dolphin, развиваемого в рамках среды рабочего стола KDE, присутствует возможность создавать *Сервисные меню (service menus)*.

**Сервисные меню** отображаются при выборе файлов и/или каталогов.  
Файлы *сценариев* хранятся в каталоге
```
/home/имя_пользователя/.local/share/kio/servicemenus/`  
```

## Установка

1. Скачайте [архив](https://github.com/tarman3/dolphine_servicemenus/archive/refs/heads/main.zip)

2. Распакуйте файлы в каталог `$HOME/.local/share/kio/servicemenus/`

3. Сделайте файлы сценариев исполняемыми

```
chmod +x $HOME/.local/share/nemo/actions/*.sh
chmod +x $HOME/.local/share/nemo/actions/*.desktop
```

## Установка дополнительных программ

1. В некоторых сенариях используются программы формирования диалогового окна **yad**, вывода уведомлений записи данных в буфер обмена **xclip**. Для их установки выполните в терминале следующую команду:  
`sudo pacman -S yad kdialog`


2. Для работы действий и сценариев, использующих специальные программы, требуется установка этих программ, например: cuneiform, doublecommnder, enca, ffmpeg, imagemagick, mediainfo, qcad, recoll, secure-delete, tesseract, webp. Для их установки выполните в терминале следующую команду:  
`sudo pacman -S cuneiform doublecmd-gtk enca ffmpeg freecad imagemagick mediainfo openscad recoll secure-delete tesseract-ocr tesseract-ocr-rus unoconv`


## Список сценариев


|Файл|Описание|
|---|---|

|**git_last_change**|Изменить последний commit на GitHub|
|**git**|Добавить commit на GitHub|
|**image_compress**|Сжать изображения|
|**image_convert**|Конвертировать формат изображения|
|**image_crop**|Изменить размер изображения|
|**image_gamma**|Изменить гамму изображений|
|**image_gray**|Сделать чёрно-белыми|
|**image_montage**|Объединить изображения|
|**image_resolution**|Изменить разрешение изображений|
|**image_rotate**|Повернуть изображения|
|**ocr_cuneiform**|Распознать текст программой cuneiform|
|**ocr**|Распознать текст программами cuneiform или tesseract|
|**ocr_tesseract**|Распознать текст программой tesseract|
|**pdf_compress**|Уменьшить размер файла PDF сжатием изображений |
|**pdf_convert_to_image_multiple**|Преобразовать несколько документов PDF в изображения|
|**pdf_convert_to_image**|Преобразовать страницы PDF в изображения|
|**pdf_convert_to_text**|Преобразовать PDF в текст|
|**pdf_decrypt**|Снять защиту с PDF|
|**pdf_export_image**|Извлечь изображения из PDF|
|**pdf_export_pages**|Извлечь страницы из PDF|
|**pdf_print**|Отправить на принтер по умолчанию документ|
|**pdf_search_text**|Найти строку в файлах PDF при помощи pdfgrep|
|**pdf_unite2**|Объединить файлы pdf и изображения в PDF|
|**pdf_unite**|Объединить (только) файлы PDF|
|**png2apng**|Объединить файлы png в анимированный apng|
|**secure_delete**|Удаление без возможности восстановления средствами Secure delete|
|**txt_convert_encoding**|Изменить кодировку текстовых файлов при помощи enconv|
|**video_cut**|Вырезать фрагмент мультимедиа|
|**video_info**|Получить информацию о файле мультимедиа при помощи mediainfo|
|**video_process**|Изменить формат, bitrate, разрешение, кодек, поворот|


## Полезные ссылки
[Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus)
[Shell scripting with KDE dialogs](https://develop.kde.org/docs/administration/kdialog)
