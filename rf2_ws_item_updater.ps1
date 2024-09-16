#
# simple script in order to update workshop items
#
# Dietmar Stein, 03/2024, info@simracingjustfair.org
#

# Notes

# source variables
. ./variables.ps1

$CURRENTDATE=(Get-Date -Format "yyMMdd")
$CURRENTLOCATION=((Get-Location).Path)

# getting SteamIDs by simply using $args
$STEAMIDS=$args

if (!$STEAMIDS) {
 # getting SteamIDs by simply using gci
 $STEAMIDS=(gci -Path $RF2WORKSHOPPKGS|select -Expand Name) 
}

# if there is no SteamCMD directory
if (-not (Test-Path "$CURRENTLOCATION\SteamCMD")) {

 mkdir $CURRENTLOCATION\SteamCMD

 # download SteamCMD
 $ARGUMENTS="Invoke-RestMethod -Uri https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -OutFile $CURRENTLOCATION\SteamCMD\steamcmd.zip"
 start-process -FilePath powershell -ArgumentList $ARGUMENTS -NoNewWindow -Wait

 # extract SteamCMD
 $ARGUMENTS="Expand-Archive -Force $CURRENTLOCATION\SteamCMD\steamcmd.zip -DestinationPath ""$CURRENTLOCATION\SteamCMD"""
 start-process -FilePath powershell -ArgumentList $ARGUMENTS -NoNewWindow -Wait
}

## create SteamCMD script from STEAMIDS
#foreach ($STEAMID in $STEAMIDS)
# {  
#    write-host "Adding SteamID $STEAMID to steamcmd script."
#    Add-Content -Path $CURRENTDATE".ids" -value "workshop_download_item 365960 $STEAMID validate"
# }

## running the script
## simple message  
#write-host "Finished generating script file."

## generating arguments string
#$ARGUMENTS=" +force_install_dir ""$STEAMBASEDIR"" +login anonymous +runscript $CURRENTLOCATION\$CURRENTDATE"".ids"" +quit"
#    
## downloading the workshop items
#start-process "$CURRENTLOCATION\SteamCMD\steamcmd.exe" -ArgumentList $ARGUMENTS -NoNewWindow -wait


###
# what to do with the given IDs
foreach ($STEAMID in $STEAMIDS)
 {  
    # simple message  
    write-host "Downloading SteamID "$STEAMID

    # generating arguments string
    $ARGUMENTS=" +force_install_dir ""$STEAMBASEDIR"" +login anonymous +workshop_download_item 365960 $STEAMID +quit"
    
    # downloading the workshop item by calling rf2_ws_installer.ps1 script one by one
    # start-process "$CURRENTLOCATION\SteamCMD\steamcmd.exe" -ArgumentList $ARGUMENTS -NoNewWindow -wait
    start-process -FilePath powershell -ArgumentList "$CURRENTLOCATION\rf2_ws_item_installer.ps1 $STEAMID" -NoNewWindow -wait
    
    # maybe Steam is thiniking it is a DOS ... so a timeout would be great
    start-sleep -seconds 3
 }
 ###

foreach ($STEAMID in $STEAMIDS)
 {  
    # looking for RFCMP to install (need to be sorted, think of GT3 vehicles, 3.60 base, 3.61 update)
    $RFCMPS=(gci $RF2WORKSHOPPKGS\$STEAMID *.rfcmp -recurse| select -Expand Name|sort)
    
    # install each RFCMP with modmgr ... assuming modmgr is configured
    foreach ($RFCMP in $RFCMPS)
    {
     write-host "Installing $RFCMP"

	 # arguments for installing RFCMP
     $ARGUMENTS=" -i""$RFCMP"" -p""$RF2WORKSHOPPKGS\$STEAMID"" -d""$RF2ROOT"" -c""$RF2ROOT"" "

	 # install RFCMP using modmgr
     start-process -FilePath "$RF2ROOT\bin64\ModMgr.exe" -ArgumentList $ARGUMENTS -nonewwindow -wait

     # start-process does not really wait for modmgr having finished so we need some xtra wait
     start-sleep -seconds 3
    }
}

# finally we remove the items list
#remove-item $CURRENTLOCATION"\*.ids"
 
