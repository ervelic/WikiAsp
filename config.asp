


<%
' ------------------------------------------------------------------------------------------------
'
' THE PURPOSE OF THIS FILE IS TO OVERRIDE THE SETTINGS IN THE MAIN FILE --> WIKI.ASP
'
' This file becomes the effective settings in a particular website.   I separated these
' settings to avoid re-entering the values everytime there is an update in wiki.asp
'
' That means, if there is a new Wiki.asp,  your settings will be preserved by this file.
'
' ------------------------------------------------------------------------------------------------

'response.write(Server.MapPath("wiki.asp") & "<br>")

gDisableSave       =  false                           ' Set to true if you have to fully disable save.
gRemoveHtml        =  false                           ' Set to true if  HTML input in wiki will be enabled.
gLoginFlag         =  "logg"                          ' The default enable login flag ( must be overriden by config.asp).
gIsOpenWiki        =  false                           ' Allow editing or Password Protect Editing?
gHideWikiSource    =  true                            ' Allow viewing of unformatted wiki text when loggin in.
gHideWikiFooter    =  true                            ' Show or Hide the whole wiki footer
gHideLogin         =  true                            ' Enable/Disable double-click or Edit. This can be overriden by &log
gHideLastEditor    =  false                           ' Show/Hide in  the footer the info about last edit
gEditPassword      = "gpass"                          ' password  for editing the site
gPassword          = "spass"                          ' password  for editing and delete and db creation.
gDeletePassword    = "padel"                          ' password  for deleting
gHttpDomain        = "auto"                           ' URL for RSS links to work. default is AUTO Override in config.asp . Set to "" to remove rss footer links
gDefaultIcon       = "icon.png"                       ' This default. Maybe overridden if your site has icon.gif, icon.jpg or xxxx.gif and if FSO is working.
gDefaultHomePage   = "?"                              ' modify your start page here. this may be overridden by .ini file. The .ini file is same dir as mdb file
gDataSourceDir     = "db"                             ' MSAccess folder. this is normally `db`
gDocRootDir        = ""                               ' physical absolute path of root (e.g. c:/dc2/mysite.com)  make it blank if `gDataSourceDir` is relative to wiki.asp
gHtmlHeadStr       = ""
gDataSourceDir     = "database"                                                     ' MSAccess folder. this is normally 'db'
gDocRootDir        = "D:\HostingSpaces\velicari\velicaria.com"                      ' physical absolute path of website root (e.g. c:/dc2/mysite.com)  make it blank if 'dsourcedir' is relative to wiki.asp
gRssStyle          = "<?xml-stylesheet type=""text/xsl"" href=""rss.xsl"" ?>"
gPasswordLabel     = " (r.z..1..) (p..d.l) : "
gBlackListedIpsRE  = "^89\.149\.195.*"                                              ' List of Ips to reject in RE.
gBlackListedIps    = ""                                                             ' List of IPs to reject.
gHiddenDbs         = "db1,db2" 
gHiddenPwd         = "sample1,sample2"
gHiddenLbl         = "<p style='font-size:40px'>pw sample in</p>,enter pw"

%>

























































