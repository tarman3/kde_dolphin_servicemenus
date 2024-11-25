# Контекстное меню файлового менеджера Dolphin из рабочего окружения KDE

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

Для работы некоторых сенариев требуется установка дополнительных программ:

```
sudo pacman -S bc enca ffmpeg imagemagick kdialog mediainfo qpdf tesseract-ocr tesseract-ocr-deu tesseract-ocr-ita tesseract-ocr-rus yad
```

## Список сценариев

|Файл|Описание|
|---|---|
|**image_compress**|Сжать изображения|
|**image_convert**|Конвертировать формат изображения|
|**image_crop**|Изменить размер изображения|
|**image_gamma**|Изменить гамму изображений|
|**image_gray**|Сделать чёрно-белыми|
|**image_merge**|Объединить изображения|
|**image_resolution**|Изменить разрешение изображений|
|**image_rotate**|Повернуть изображения|
|**ocr**|Распознать текст программой tesseract|
|**pdf_compress**|Уменьшить размер файла PDF сжатием изображений |
|**pdf_convert2image**|Преобразовать страницы PDF в изображения|
|**pdf_decrypt**|Снять защиту с PDF|
|**pdf_export_image**|Извлечь изображения из PDF|
|**pdf_export_pages**|Извлечь страницы из PDF|
|**pdf_print**|Отправить на принтер по умолчанию документ|
|**pdf_conmine**|Объединить файлы PDF|
|**delete**|Удалить средствами Secure delete|
|**txt_convert_encoding**|Изменить кодировку текстовых файлов при помощи enconv|
|**video_cut**|Вырезать фрагмент мультимедиа|
|**video_process**|Изменить формат, bitrate, разрешение, кодек, поворот|


## Полезные ссылки
[Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus)  
[Shell scripting with KDE dialogs](https://develop.kde.org/docs/administration/kdialog)  
[Nemo Actions - LinuxMint](https://github.com/demonlibra/nemo-actions)  
