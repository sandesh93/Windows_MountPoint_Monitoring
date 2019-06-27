# Please do not leave any of the fields blank.

# Update the below with appsone collection service details
# Enterprise name should not be display name
$HOST_NAME = "10.50.52.118"
$PORT_ = 9111
$ENTERPRISE = "HDFC"
$COMPONENT = "Windows_MountPoint_Monitoring"
$COMPONENT_INST = "CRMNext_FreeSpace_121"

$AGENT_ID = "248c75ad-2c99-4773-bbef-8af9e31439c7"
$URL = "CollectionServiceData"

#Update BASE_PATH value where you will place this Script.
$BASE_PATH="F:\Windows_MountPoint_Monitoring"

	
##Define KPI related Details
#$KPI_NAME = ""
## <KPI_Name>:<value>
$DETAILS = @{}
$DETAILS[0] = "STATIC"



# Number of days to retain log
$Purge_Days = 1