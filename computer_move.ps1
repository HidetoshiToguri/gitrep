#Set-ExecutionPolicy Bypass

cd C:\account\scripts

#ADmoduleインポート
import-module activedirectory

$filename = Get-Date -Format "yyyyMMdd"

$username = Get-Content env:username
$user = "実行アカウント：" + $username
Write-Output $user | Out-File -FilePath ..\log\movecomputer_$filename.log -Encoding UTF8 -Append

#CSV取得
$data = Import-Csv .\move_computers.csv -Encoding default
$Computer_name = $data

#コンピュータアカウント移動処理開始
foreach($Computer_name in $data)  
{

#ホスト名チェックで空なら処理スキップ
if($Computer_name.hostname -eq ""){continue}
else{}

get-adcomputer $Computer_name.hostname | Out-File -FilePath ..\log\movecomputer_before_$filename.log -Encoding UTF8 -Append

#コンピュータアカウントをINACTIVEへ移動
get-adcomputer $Computer_name.hostname | Move-ADObject -TargetPath 'OU=INACTIVE,OU=Resources,DC=testalice,DC=aandt,DC=co,DC=jp'

#コンピュータアカウント無効化
get-adcomputer $Computer_name.hostname | Disable-ADAccount

$hostname_log = $Computer_name.hostname + "をINACTIVEへ移動しました。"

Write-Output $hostname_log | Out-File -FilePath ..\log\movecomputer_$filename.log -Encoding UTF8 -Append

get-adcomputer $Computer_name.hostname | Out-File -FilePath ..\log\movecomputer_after_$filename.log -Encoding UTF8 -Append

}
