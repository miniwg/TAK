Thse files provide map coordinate system extensions for the ATAK TDAL plugin which is available on the playstore 
https://play.google.com/store/apps/details?id=com.atakmap.android.bng.plugin

##Installation##
1. Copy the files to the ATAK End User Device with the TDAL plugin already installed.
2. To replace the existing TDAL coordinate systems copy the file to the directory:
atak/tools/coordinate_systems/
Delete the exisiting coordinate_systems.xml file
Rename the file coordinate_systems.xml
Restart ATAK
3. To add the coordinate system:
Open the file
Copy the section between the <crs> and </crs> tags, including the tags
Open the existing atak/tools/coordinate_systems/coordinate_systems.xml
Paste the <crs> block just above the:
</CoordinateReferenceSystems> tag, making sure the indentation matches the other <crs> block entries
Save the file and restart ATAK
   
