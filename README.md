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
sudo pacman -S bc enca ffmpeg imagemagick kdialog meld oxipng perl-lwp-protocol-https qpdf tesseract-ocr tesseract-ocr-deu tesseract-ocr-ita tesseract-ocr-rus unoconv wl-paste yad
```

## Список сценариев

|Файл|Описание|
|---|---|
|**delete**|Удалить средствами Secure delete|
|**docs2pdf**|Конвертировать документов в PDF|
|**git_add_commit**|Создать коммит Git|
|**git_replace_last_commit**|Заменить последний коммит Git|
|**hash**|Расчитать контрольные суммы|
|**images_compress**|Сжать изображения|
|**images_convert**|Конвертировать формат изображения|
|**images_crop**|Изменить размер изображения|
|**images_gamma**|Изменить гамму изображений|
|**imagess_gray**|Сделать чёрно-белыми|
|**images_merge**|Объединить изображения|
|**images_png_opti**|Оптимизировать PNG при помощи oxipng|
|**images_png8**|Преобразовать в PNG8|
|**images_resize**|Изменить разрешение изображений|
|**images_rotate**|Повернуть изображения|
|**media_cut**|Вырезать фрагмент мультимедиа|
|**media_process**|Изменить формат, bitrate, разрешение, кодек, поворот|
|**meld**|Сравнение файлов и каталогов по содержимому|
|**ocr**|Распознать текст программой tesseract|
|**pdf_combine**|Объединить PDF и изображения в PDF|
|**pdf_compress**|Уменьшить размер файла PDF сжатием изображений |
|**pdf_convert2image**|Преобразовать страницы PDF в изображения|
|**pdf_decrypt**|Снять защиту с PDF|
|**pdf_export_images**|Извлечь изображения из PDF|
|**pdf_export_pages**|Извлечь страницы из PDF|
|**timestamp**|Добавить дату к имени файла|
|**txt_encoding**|Изменить кодировку текстовых файлов при помощи enconv|
|**wget**|Скачать файл по ссылке из буфера обмена в выбранный каталог|

## Полезные ссылки
[Creating Dolphin service menus](https://develop.kde.org/docs/apps/dolphin/service-menus)  
[Shell scripting with KDE dialogs](https://develop.kde.org/docs/administration/kdialog)  
[Nemo Actions - LinuxMint](https://github.com/demonlibra/nemo-actions)  
