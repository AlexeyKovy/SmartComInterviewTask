[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)] $DBServer,
    $DBName = "TestDatabase",
    $DBUsername = "",
    $DBPassword = "",
    $DBAccessToken = "",
    [Parameter(Mandatory=$true)] $SFTPIP,
    $SFTPDestinationFile = "/tmp",
    $SFTPUser = "",
    $SFTPPassword = ""
)

$SQLQuery = "
WITH products ([componentid], [productassemblyid], [componentlevel])
     AS (SELECT [componentid],
                [productassemblyid],
                0 AS ProductID
         FROM   [TestDatabase].[Production].[billofmaterials]
         WHERE  [productassemblyid] = 750
         UNION ALL
         SELECT e.[componentid],
                e.[productassemblyid],
                o.componentlevel + 1
         FROM   [TestDatabase].[Production].[billofmaterials] e
                INNER JOIN products o
                        ON e.productassemblyid = o.componentid)
SELECT o.productassemblyid AS AssemblyID,
       o.componentid AS ComponentID,
       e.[Name],
       o.ComponentLevel
FROM   [TestDatabase].[Production].[product] e
       INNER JOIN products o
               ON o.componentid = e.productid"


# Выполнение SQL запроса на сервере и сохранение в csv файле.
$FileName = Get-Date -format "yyyyMMddhhmmss"
if ($DBUsername) {
    $data = Invoke-Sqlcmd -ServerInstance $DBServer -Database $DBName $SQLQuery -Username $DBUsername -Password $DBPassword
}
elseif ($DBAccessToken) {
    $data = Invoke-Sqlcmd -ServerInstance $DBServer -Database $DBName $SQLQuery -AccessToken $DBAccessToken
}
else {
    $data = Invoke-Sqlcmd -ServerInstance $DBServer -Database $DBName $SQLQuery
}
$data | Export-Csv -Path "$FileName.csv"


# Отправка файла по SFTP.
if ($SFTPUser)
{
    $SFTPSecurePassword = $SFTPPassword | ConvertTo-SecureString -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SFTPUser, $SFTPSecurePassword
}
else
{
    $Credentials = (Get-Credential)
}

$SFTPSession = New-SFTPSession -ComputerName $SFTPIP -Credential $Credentials
Set-SFTPItem -SessionId $SFTPSession.SessionId -Path ".\$fileName.csv" -Destination $SFTPDestinationFile
Remove-SFTPSession -SFTPSession $SFTPSession