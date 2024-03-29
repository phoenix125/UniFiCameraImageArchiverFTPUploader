Ubiquiti UniFi Camera Image Archiver & FTP Uploader - A Utility to archive & FTP upload snapshot.jepgs from Ubiquiti cameras.
- Latest version: UniFiCameraImageArchiverFTPUploader_v1.5 (2023-01-07)
- By Phoenix125 | http://www.Phoenix125.com | http://discord.gg/EU7pzPs | kim@kim125.com
- Written in AutoIT v3.3.14.5 using SciTE4AutoIT3

----------
 FEATURES
----------
• Create archives of Ubiquiti UniFi cameras (or any camera with http snapshot).
• Upload images via FTP.  Works with Wunderground.
• Resize images for upload and archive.
• Use third-party software to create time-lapse videos from archived images. I personally use AviDemux.
• Works with 1-100 cameras.
• Each camera has independent settings:
	○ Save Folder		○ Upload folder		○ Independent archive and FTP frequency
• Logs of archives and FTPs.

--------------
 INSTRUCTIONS
--------------
• Run UniFiCameraImageArchiverFTPUploader_vX.exe
• Config window will open.  Set parameters.
• Click on Camera Number to change camera.
• Hove mouse over any option for details.
• To enable UniFi Camera Snapshot URL, see See ReadMe.PDF at http://www.phoenix125.com/share/unificameraimagearchiverftpuploader/ReadMe.pdf

----------------
 DOWNLOAD LINKS
----------------
Latest Version: http://www.phoenix125.com/share/unificameraimagearchiverftpuploader/UniFiCameraImageArchiverFTPUploader.zip
Previous Versions: http://www.phoenix125.com/share/unificameraimagearchiverftpuploader/archives
Source Code (AutoIT): http://www.phoenix125.com/share/unificameraimagearchiverftpuploader/UniFiCameraImageArchiverFTPUploader.au3
GitHub: https://github.com/phoenix125/UniFiCameraImageArchiverFTPUploader
Readme.txt: http://www.phoenix125.com/share/unificameraimagearchiverftpuploader/ReadMe.pdf

Website: http://www.Phoenix125.com
Discord: http://discord.gg/EU7pzPs

------------------
 REVISION HISTORY
------------------
2023-01 v1.5 Added optional year and month to save folder name
- Added: Optionally save images to folder with year/month name. ex) 2023-01

2021-12-27 v1.4 Added FTP Port Assignment Field
- Added: FTP Port Assignment Field
- Fixed: Line 1434 error when changing URL in config window

2021-05-31 v1.3 Fixed Line 16397 Error
- Fixed: Line 16397 error when changing camera URL

2021-03-06 v1.2 Config GUI!
- Added: Config GUI
- Added: Separate options for archiving and uploading full size and resized images

2021-02-28 v1.1
- Added: Separate save intervals for each camera
- Added: Optionally add sequential numbers at end of filename instead of date. Useful for some Image-To-Video programs

2020-12-13 v1.0 Initial Release