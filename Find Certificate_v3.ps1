$CurrentDate = Get-Date #get date
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy-hh-mm-ss') #convert date to this format
New-Item -Path "$PSScriptRoot\results" -Name $CurrentDate -ItemType "directory" #create a folder with date and time script is run
Copy-Item "$PSScriptRoot\computers.txt" -Destination "$PSScriptRoot"\results\"$CurrentDate" #copies computers.txt to results date folder for recording purposes

$computers = get-content "$PSScriptRoot\computers.txt" #imports the list of computers

foreach($computer in $computers) #creates variable $computer from computers.txt for each line and loops
{
if (Test-Connection $computer -count 1 -Quiet) #if test-connection succeeds do the following
{

echo ("Checking " + $computer)
$results = Invoke-Command -ComputerName $computer -ScriptBlock {Get-ChildItem -Path Cert:\LocalMachine\Root |`
Where-Object {$_.Thumbprint -eq "D2D18014060C598B081F4EDE670A08899D409519"}}

if (!$results) {echo $computer | out-file $PSScriptRoot"\results\"$CurrentDate"\Z_ComputersMissingCert_"$CurrentDate.txt -Append} #if the cert is missing or WinRM fails
    else {echo $computer | out-file $PSScriptRoot"\results\"$CurrentDate"\Z_ComputersWithCert_"$CurrentDate.txt -Append} #if the cert is found add to this txt file

}

else{ #if test-connection fails, add computer name to offline text file
echo $computer" offline"
echo $computer | out-file $PSScriptRoot"\results\"$CurrentDate"\Z_Offline_"$CurrentDate.txt -Append
}

}
