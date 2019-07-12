# Please do not leave any of the fields blank.

# Update the below with appsone collection service details
# Enterprise name should not be display name
$HOST_NAME = "10.226.211.160"
$PORT_ = 9101
$ENTERPRISE = "HDFC"
$COMPONENT = "CRMNEXT_MOUNTPOINT"
$COMPONENT_INST = "CRMNEXT_MOUNTPOINT_146"

$AGENT_ID = "cc227e53-69c1-4191-88ae-452b034d2a64"
$URL = "CollectionServiceData"

#Update BASE_PATH value where you will place this Script.
$BASE_PATH="F:\APPNOMIC\Windows_MountPoint_Monitoring"

	
##Define KPI related Details
#$KPI_NAME = ""
## <KPI_Name>:<value>
$DETAILS = @{}
$DETAILS[0] = "STATIC"



# Number of days to retain log
$Purge_Days = 1