$hosts_path = "C:\Windows\System32\drivers\etc\hosts"
$hosts_backup_path = "C:\Windows\System32\drivers\etc\hosts_backup.bak"
$hosts_file_contents = Get-Content $hosts_path | Out-String

$begin_marker = "# @homestead_hyperv_begin"
$check_begin_position = $hosts_file_contents.Indexof($begin_marker)
if ($check_begin_position -eq -1) {
    Write-Host "The begin marker '$begin_marker' is not present in '$hosts_path'"
    Exit
}

$end_marker = "# @homestead_hyperv_end"
$check_end_position = $hosts_file_contents.Indexof($end_marker)
if ($check_end_position -eq -1) {
    Write-Host "The end marker '$end_marker' is not present in '$hosts_path'"
    Exit
}

[io.file]::WriteAllText($hosts_backup_path, $hosts_file_contents) 


$ip_addresses = Get-VM | Get-VMNetworkAdapter | Where-Object -FilterScript {$_.VMName -EQ 'homestead'} | Where-Object {$_.switchName -EQ 'Default Switch'} | ft IPAddresses | Out-String
$ipv4_address = $ip_addresses.Split("{,}")[1]

$hosts_file_entry_replacements = "`r`n" + $ipv4_address + " chargenationcrm.test`r`n" + $ipv4_address + " chargenationapi.test`r`n"


$begin_position = $hosts_file_contents.Indexof($begin_marker) + $begin_marker.Length
$hosts_file_contents_first_half = $hosts_file_contents.SubString(0, $begin_position)

$end_position = $hosts_file_contents.Indexof($end_marker)
$hosts_file_contents_second_half = $hosts_file_contents.SubString($end_position);


$hosts_file_contents_replacements = $hosts_file_contents_first_half + $hosts_file_entry_replacements + $hosts_file_contents_second_half

[io.file]::WriteAllText($hosts_path, $hosts_file_contents_replacements) 
