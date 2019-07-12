# Script name   : Windows_MountPoint_Monitoring.ps1
# Written by    : Sandesh Rane
# Date          : 24-June-2019
# Description   : Purpose of the script: Monitor Windows mount point free space.
#
#	Script genrates gives multiple mount point names with Free space info in percentage.
# Powershell version required is 5 and above.


Param(
	[switch]$v = $false,
	[switch]$h = $false
)


# Function to display usage
Function Usage
{
	write-host "Usage"
	write-host "	This scripts returns windows mountpoint details with fress space info in percentage."
	write-host "	.\Windows_MountPoint_Monitoring.ps1"
}

# Print version
if($v){
	write-host "VERSION IS 2.0"
	exit
}

# Print help message
if($h){
	Usage
	exit
}

if( $args.Count -gt 0) {
    write-host "Invalid arguments passed"
    Usage
	exit
   }

$BASE_DIR = split-path -parent $MyInvocation.MyCommand.Definition
$LogDay = Get-Date -Format "dd-MMM-yyyy"
$CONFIG_DIR = "$BASE_DIR\conf"
$CONFIG_FILE = "$CONFIG_DIR\Config.ps1"
$LOG_DIR = "$BASE_DIR\log\$LogDay"
$LOG_FILE = "$LOG_DIR\Windows_MountPoint_Monitoring.log"
$TMP_DIR= "$BASE_DIR\tmp"




# Create log folder if doesn't exist
If(!(test-path $LOG_DIR)) {
	New-Item -ItemType Directory -Force -Path $LOG_DIR | out-null
}


# Create tmp folder if doesn't exist
If(!(test-path $TMP_DIR)) {
	New-Item -ItemType Directory -Force -Path $TMP_DIR | out-null
}

# Function for writing log
Function Logwrite
{
	Param ([string]$logstring)
	$mark=Get-Date
	Add-content $LOG_FILE -value "$mark : INFO $logstring"
}

## Exit script function definition
Function Exit_Script([string]$exitstring)
{

	If((test-path $TMP_DIR)) {
	Remove-Item -path "$TMP_DIR" -recurse | out-null
	}
	Logwrite "$exitstring"
	[int]$Purge_Days = $Purge_Days
    if ($?) {
	Logwrite "Purge days : $Purge_Days"
	} else {
        Logwrite "Invalid log purge days defined."
        Logwrite "Considering default as 2"
        $Purge_Days = 2
    }

	if ( (!$Purge_Days) -and ($Purge_Days -eq 0) ) {
		$Purge_Days = 2
	}
    if ( $Purge_Days -ge 0 ) {
        Logwrite "Clearing log files and folders older than $Purge_Days days"
	    Get-ChildItem -Path "$BASE_DIR\log" |Where-Object {$_.psiscontainer -and $_.lastwritetime -le (Get-Date).adddays(-$Purge_Days)} |ForEach-Object {Remove-Item $BASE_DIR\log\$_ -Recurse -Force}
    } else {
        Logwrite "Purge log days values should be >= 1"
    }
    Logwrite "---------------------Execution finished-------------------"
	Exit
}



# Function to write to request/response xml file
Function xmlWrite($xmlfile,$logstring )
{
   Add-content $xmlfile -value $logstring
}

Function xmlTmpWrite ($KPI_NAME,$VALUE)
{
	$tmpxmlfile = "$TMP_DIR\tmp.xml"
   	$mytime = ((get-date).addhours(-5).addminutes(-30)).ToString('yyyy-MM-dd HH:mm:ss')
	xmlwrite $tmpxmlfile "<ComponentInstance name=`"$COMPONENT_INST`" component=`"$COMPONENT`" enterprise=`"$ENTERPRISE`" >"
	xmlwrite $tmpxmlfile "<KPIs>"
	xmlwrite $tmpxmlfile "<KPI name=`"$KPI_NAME`" value=`"$VALUE`"/>"
    xmlwrite $tmpxmlfile "<KPI name=`"Time`" value=`"$mytime`"/>"
	xmlwrite $tmpxmlfile "</KPIs>"
	xmlwrite $tmpxmlfile "</ComponentInstance>"

}

Function sendtoappsone()
{
	$tmpxmlfile = "$TMP_DIR\tmp.xml"
	$reqxmlfile = "$TMP_DIR\Request.xml"
	$resxmlfile = "$TMP_DIR\Response.xml"
	if ( Test-Path $reqxmlfile) { Remove-Item $reqxmlfile }
	if ( Test-Path $resxmlfile) { Remove-Item $resxmlfile }
	xmlwrite $reqxmlfile "<A1 xsi:noNamespaceSchemaLocation=`"A1DCASchema.xsd`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`">"
	xmlwrite $reqxmlfile "<A1Request id=`"$AGENT_ID`" version=`"1.0`" mode=`"MONITOR`">"
	xmlwrite $reqxmlfile "<Data>"

	Add-content "$reqxmlfile" -value (get-content "$tmpxmlfile")

	xmlwrite $reqxmlfile "</Data>"
	xmlwrite $reqxmlfile "</A1Request>"
	xmlwrite $reqxmlfile "</A1>"

	Logwrite "xml created as below:"
	add-content $LOG_FILE -value (get-content "$reqxmlfile")

	$content = [IO.File]::ReadAllText($reqxmlfile)
$reqBody = @"
$content
"@
	Logwrite "Trying to send data to appsone"
try {
	$endPoint = "http://"+$HOST_NAME+":"+"$PORT_/$URL"
	$wr = [System.Net.HttpWebRequest]::Create($endPoint)
	$wr.Method= 'POST';
	$wr.ContentType="application/xml";
	$Body = [byte[]][char[]]$reqBody;
	$wr.Timeout = 10000;
	$Stream = $wr.GetRequestStream();
	$Stream.Write($Body, 0, $Body.Length);
	$Stream.Flush();
	$Stream.Close();
	$resp = $wr.GetResponse().GetResponseStream()
	$sr = New-Object System.IO.StreamReader($resp)
	$respTxt = $sr.ReadToEnd()
	Logwrite "Response Below:"
	Add-content $LOG_FILE -value $respTxt
	}
catch {
	$errorStatus = "Exception Message: " + $_.Exception.Message;
	Logwrite "$errorStatus"
}

}


function Process
{

for($i=0; $i -lt $arg_cnt; $i++)
{
	$line = $($DETAILS[$i])
	if (!$line) { continue }

	$DriveDetails=(get-volume |select driveletter, FilesystemLabel, @{L='PCT_FREE';E={"{0:N}" -f (($_.sizeremaining/$_.size)*100)}})
	#echo $DriveDetails
	Clear-Content -Path $BASE_PATH\out.txt

	foreach ($line in $DriveDetails){
	#$line
	if ( -not [string]::IsNullOrWhiteSpace($line.driveletter) -and (-not [string]::IsNullOrWhiteSpace($line.PCT_FREE))){
	($line | Select-Object driveletter,PCT_FREE | Select-Object @{Label='MountPoint'; Expression={$_.driveletter}}, @{Label='Free_Space'; Expression={$_.PCT_FREE}}) | Add-Content $BASE_PATH\out.txt
 	}
	elseif(-not [string]::IsNullOrWhiteSpace($line.FilesystemLabel) -and (-not [string]::IsNullOrWhiteSpace($line.PCT_FREE))){
	($line | Select-Object FilesystemLabel,PCT_FREE | Select-Object @{Label='MountPoint'; Expression={$_.FilesystemLabel}}, @{Label='Free_Space'; Expression={$_.PCT_FREE}}) | Add-Content $BASE_PATH\out.txt
	}
}
$log=get-content $BASE_PATH\out.txt 
foreach ($line in $log) { 
	#((($line.Split('=',2)[1]) -replace "; Free_Space=" ," ")-replace ".$") ; xmlTmpWrite ($KPI_NAME) ($VALUE) ;     #####This should genrate KPI and its Value in xml

$KPI_NAME=(($line.Split(';=')[1])) ;
$VALUE=(($line.Split('=')[2]))-replace ".$"; 
 xmlTmpWrite ($KPI_NAME) ($VALUE);
	}

 
	}

	
 sendtoappsone
 return

}

Logwrite "-----------------------Execution started--------------------"

Function Main() {



	# Check if collection service ip is configure or not
	if (!$HOST_NAME ){
    	Logwrite "Collection service ip is not defined in the config file "
        return
    }

	# Check if collection service port is configure or not
	if (!$PORT_ ){
    	Logwrite "Collection service port is not defined in the config file "
        return
    }

	# Check if enterprise name is configure or not
	if (!$ENTERPRISE ){
    	Logwrite "ENTERPRISE name is not defined in the config file "
        return
    }

	# Check if component name is configure or not
	if (!$COMPONENT ){
    	Logwrite "Component name is not defined in the config file "
        return
    }


	# Check if agent identifier is configure or not
	if (!$AGENT_ID ){
    	Logwrite "Agent identifier is not defined in the config file "
        return
    }

	# Check if url ip is configure or not
	if (!$URL ){
    	Logwrite "Collection service url is not defined in the config file "
        return
    }

	Process
    return
}


# Check if config file is present
if ( -not (Test-Path $CONFIG_FILE)) {
LogWrite "Config file is missing Exit the script"
exit
}
Logwrite "----Config.ps1 Processing started----"
Logwrite "Reading variables from Config.ps1"
. $CONFIG_FILE

	if ($?) {
        Logwrite "Config.ps1 included"
		$arg_cnt = $Details.Count

    } else {

		Logwrite "Config.ps1 inclusion failed"
        Exit_Script "Exiting the script"
    }
Main
Exit_Script "Processing finished"
