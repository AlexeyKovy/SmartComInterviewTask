# Readme

## Зависимости


Требуемые зависимости PowerShell:
- sqlserver
- posh-ssh

Установить можно следующей командой


```ps
Install-Module posh-ssh
Install-Module sqlserver
```
**Важно: PowerShell должен быть запущен от имени администратора.**
## Запуск скрипта

Для создания `.csv` файла и отправки его по SFTP следует запустить скрипт `script.ps1`.

## Синтаксис
```ps
script.ps1 
    -DBServer <String> - Адресс сервера с базой 
    [-DBName <String>] - Назавние бд. Default: "TestDatabase"
    [-DBUsername <String>] - Имя пользователя для бд.
    [-DBPassword <String>] - Пароль для бд.
    [-DBAccessToken <String>] - Токен для бд.
    -SFTPIP <String> - Адресс SFTP сервера.
    [-SFTPDestinationFile <String>] - Директория на SFTP сервере в которую требуею положить csv файл. Default: "/tmp"
    [-SFTPUser <String>] - Пользователь для аутентификации на SFTP сервере.
    [-SFTPPassword <String>] - Пароль для аутентификации на SFTP сервере.
```
В случае если не указан флаг SFTPUser, аутентификация для SFTP сервера будет запущена в интерактивном режиме.