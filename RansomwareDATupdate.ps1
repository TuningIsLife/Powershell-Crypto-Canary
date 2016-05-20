##############################################
# "Crypto Canary" Powershell DAT file update script
# Written 2016-05-20 by P. Gill 
##############################################

#Get date
$date = get-date -format yyyyddMM

#Define locations
$csvFile = "$env:temp\Ransomware.dat$date"

# Create Excel object by pulling down Google Sheet export
$objExcel = new-object -comobject excel.application 
$objExcel.Visible = $False
$RansomwareOverview = $objExcel.Workbooks.Open("https://docs.google.com/spreadsheets/d/1TWS238xacAto-fLKh1n5uTsdijWdCEsGIM0Y0Hvmc5g/pub?output=xlsx") 
$ransomwareList = $RansomwareOverview.Worksheets.Item(1)

#Extract the extension list from the second column 
$rawExtensionsList = @()
$count = $ransomwareList.Cells.Item(65536, 2).End(-4162)
for($intRow=2;$intRow -le $count.row;$intRow++)
{
	#Generate list from column, and break on new lines
    $rawExtensionsList += $ransomwareList.Cells.Item($intRow, 2).Value() -split '[\n]'
    }

#Convert extension list from Object String type and remove blank entries. 
$extensions = $rawExtensionsList.Split("",[System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object @{Name='Name';Expression={$_}}

#Export extensions to CSV file
$extensions | Export-Csv -path $csvFile -NoType | ? {$_} 

#Exiting the excel object
$RansomwareOverview.close($false)
$objExcel.Quit()