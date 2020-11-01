<% @LANGUAGE = VBScript %>
<%
'+----------------------------------------------------------------------------+
'| Description:                                                               |
'|    WikiAsp is a derivative of AspWiki, a wiki program written in ASP.      |
'|    WikiAsp will run on Windows with IIS, MDAC v2.5. WikiAsp will           |
'|    automatically create MS Access DB on first time use.                    |
'|                                                                            |
'|    The following are the dlls to make mdb creation work.                   |
'|    1. Program Files\Common Files\System\ado\msadox.dll                     |
'|    2. WINDOWS\System32\scrrun.dll                                          |
'|                                                                            |
'| Credits:                                                                   |
'|    Elrey Ronald Velicaria. - Author of WikiAsp. (lambda326@hotmail.com)    |
'|    Dino Chiesa - AspWiki author.                                           |
'|    Contributors: Bjarne D, Julian Tosh                                     |
'|                                                                            |
'| Websites:                                                                  |
'|    http://www.c2.com/cgi/wiki,  http://www.c2.com/cgi/wiki?WikiAsp         |
'+----------------------------------------------------------------------------+
'| Please retain the above credits on any future versions of this program     |
'+----------------------------------------------------------------------------+

Option Explicit
Response.CacheControl  = "no-cache"
Response.Expires       = -1
Response.AddHeader "Pragma", "no-cache"

Dim gPassword, gDefaultIcon, gDefaultHomePage, gAutoCreateMdb
Dim gHttpDomain , gDebug, gEngineVersion, gDbTableName
Dim gProvider, gDataConn, gDataSource, gDataSourceName
Dim gDocRootDir, gDataSourceDir, gDataSourceFile, gSpaceNames
Dim gScript, gScriptURL, giEditAreaRows, giEditAreaCols, giNumRecentFiles
Dim gHomeTopic, gStyleSheet, gIconName, gEditPassword, gIsOpenWiki
Dim glsTopic, glsMode  , gHideLastEditor,  gLoginFlag, gRemoveHtml,gBlackListedIps
Dim gRE, gHighlightFlag, gHideWikiSource, gHideWikiFooter, gHideLogin, gHtmlHeadStr
Dim gDisableSave,gTimeZoneOffset, gRssStyle, gRedirectURL
Dim gBannerTemplate, gWikiBodyPrefix, gHideTopSearch, gDisableScripting
Dim gMdbExtension , gSearchLabel, gBlackListedIpsRE ,gDeletePassword , gPersistPassword
Dim gPasswordLabel, gFooterHtml, gPagesUnprotected
Dim gBulletChar01, gBulletChar02, gBulletChar03, gBulletChar04, gBulletChar05, gBulletChar06, gBulletChar07, gBulletChar08, gBulletChar09   
Dim gHiddenDbs, gHiddenPwd, gHiddenLbl, gCamelBreak
'+-----------------------------------------------------------------------------+
'| AN IMPORTANT NOTE:  !!!!!                                                   |
'| Enter your password below for creating new DB and for Delete.               |
'| Enter your URL inside quotes below e.g. http://www28.brinkster.com/site     |
'| Modify gDefaultIcon, gDefaultHomePage here is FSO objects is not installed  |
'+-----------------------------------------------------------------------------+
gAutoCreateMdb     =  true                            ' Create db automatically. set to false to prevent create attempt.
gDisableSave       =  false                           ' Set to true if you have to fully disable save.
gBlackListedIps    =  ""                              ' List of IPs to reject. (Exact match 1st 3 digits of IP, delimit list by ~)
gBlackListedIpsRE  =  ""                              ' List of IPs to reject (Regular ExpressionMatch)
gRemoveHtml        =  false                           ' Set to true if  HTML input in wiki will be enabled.
gLoginFlag         =  "log"                           ' The default enable login flag ( must be overriden by config.asp).
gIsOpenWiki        =  false                           ' Allow editing or Password Protect Editing?
gHideWikiSource    =  false                           ' Allow viewing of unformatted wiki text when loggin in.
gHideWikiFooter    =  false                           ' Show or Hide the whole wiki footer
gHideLogin         =  false                           ' Enable/Disable double-click or Edit. This can be overriden by &log
gHideLastEditor    =  false                           ' Show/Hide in  the footer the info about last edit
gDeletePassword    = "passdell"                       ' password  for deleting, delete link  and db creation.  passed in URL &pw=XXXX
gEditPassword      = "user"                           ' password  for other users editing the site. uses pwd
gPassword          = "owner"                          ' password  for site owner editing RegisteredUsers page. used pwd
gHttpDomain        = "auto"                           ' URL for RSS links to work. Override in config.asp . Set to "" to remove rss footer links
gDefaultIcon       = "http://c2.com/sig/wiki.gif"     ' This default. Maybe overridden if your site has icon.gif, icon.jpg or xxxx.gif and if FSO is working.
gDefaultHomePage   = "WikiAsp"                        ' modify your start page here. this may be overridden by .ini file. The .ini file is same dir as mdb file.  Default home page mdb is auto created.
gDataSourceDir     = "Db"                             ' MSAccess folder. this is normally `db`
gDocRootDir        = ""                               ' physical absolute path of root (e.g. c:/dc2/mysite.com)  make it blank if `gDataSourceDir` is relative to wiki.asp
gTimeZoneOffset    = "-0400"                          ' Put your serverTimezone offset here. East Coast is -0400 .
gRssStyle          = ""                               ' For a readable RSS. Example:  "<?xml-stylesheet type=""text/xsl"" href=""rss.xsl"" ?>"
gRedirectURL       = ""                               ' Use a page to display on error. Put a URL here.
gMdbExtension      = ".mdb"                           ' Default ms access file extension
gBannerTemplate    = ""                               ' Banner html is now replaceable you need to remember $$icon$$, $$banner_text$$ variable though
gWikiBodyPrefix    = ""                               ' This will appear at the top of each wiki body.  Put wiki formatted text here.
gHideTopSearch     = false                            ' Search box hide
gDisableScripting  = false                            ' If true, replaces all <Script   with &lt;Script                             
gSearchLabel       = " Search On:"                    ' Appears on the search box
gPersistPassword   = true                             ' Remember password by default
gPasswordLabel     = " To edit, enter the password: " ' The prompt label to use when entering a password. 4/2010 replace gLoginPrompt
gFooterHtml        = "</body></html>"                 ' Now you can customize the footer with your chosen html. Even remove ads
gPagesUnprotected  = "VisitorsPage,WikiSandBox"       ' List of pages that do not need password
gBulletChar01      = "&#8226;"
gBulletChar02      = "&#959;"
gBulletChar03      = "&#9674;"
gBulletChar04      = "&#8594;"
gBulletChar05      = "&#9830;"
gBulletChar06      = "&#8226;"
gBulletChar07      = "&#959;"
gBulletChar08      = "&#8574;"
gBulletChar09      = "&#9827;"
gHiddenDbs         = "FamilyLinks"            'A mdb can be protected by as password.  Label can also be different for each
gHiddenPwd         = "pass2"
gHiddenLbl         = "Enter...2"
gCamelBreak        = "{}"                             ' Use this char sequence to break Camel case Interpretation.

'+-----------------------------------------------------------------------------+
'| DO YOU WANT TO SEPARATE SOME CONFIG SETTINGS IN ANOTHER FILE?               |
'+-----------------------------------------------------------------------------+
'| IF yes,just uncomment line after this box (by removing single quote as      |
'| the first character. If you do this,  BE SURE TO CREATE config.asp          |
'| which will override the same variable settings above this box               |
'+-----------------------------------------------------------------------------+

%><!--#include file="config.asp"--><%

gDebug               = 0                             ' 0 - no debug message 1-6 for verbose debug
gEngineVersion       = "v1.6.4.8 Elrey R.Velicaria." ' Engine Version
gScript              = "wiki.asp"                    ' Main ASP filename (this file)
gProvider            = "Microsoft.Jet.OLEDB.4.0"     ' Db Provider
giEditAreaRows       = 30                            ' Edit Rows
giEditAreaCols       = 115                           ' Edit Columns
giNumRecentFiles     = 15                            ' No. of wikipages to list in Recent files page
gDbTableName         = "WikiData"                    ' Table name in the database
gSpaceNames          = 1                             ' 1 means put spaces in WikiNames, 0 - no spaces


' Elrey 3/06  Now Override the gHttpDomain with this!!
If gHttpDomain = "auto" Then
  gHttpDomain  = "http://" & Request.ServerVariables("SERVER_name") & _
                 Replace(Request.ServerVariables("URL"), "/" & gScript, "" )
End If

'check for database name
If len(request("db")) > 0 Then
    gDataSourceFile = request("db")
Else
    gDataSourceFile = gDefaultHomePage
End If

If len(gDocRootDir) > 0 Then
  gDataSource = gDocRootDir & "\" & gDataSourceDir & "\" & gDataSourceFile & gMdbExtension 
Else
  gDataSource = gDataSourceDir & "\" & gDataSourceFile & gMdbExtension 
End If

'check for database human-readable name
If len(request("dbname")) > 0 Then
    gDataSourceName = request("dbname")
Else
    gDataSourceName = "DefaultDb"
End If

If not IsEmpty( request(gLoginFlag))  Then
    Session(gLoginFlag) = "1"
End If
If Not IsEmpty( Session(gLoginFlag)) Then
    gHideLogin = false  'via URL you can force a login ability in case the config turned if off ( jsut add &a=log )
End If

'set destination URL
gScriptURL    = gScript & "?db=" & gDataSourceFile  ' removed & "&dbname=" & server.urlencode(gDataSourceName)
gHomeTopic    = gDataSourceFile  ' default home topic is the same as ms access db name unless overwritten by .ini
gStyleSheet   = "wiki.css"


Call GetHomeTopic 'Get the topic from wiki.ini if it exists

gIconName = gDefaultIcon

Call GetIconName   'Get the real icon name

Dim rs, dts, i, sqlQuery

Const ADOERROR_NOFILE  = -2147467259  ' cannot find file (*.mdb)
Const ADOERROR_NOTABLE = -2147217865  ' Cannot find output table
Const FOR_READING      = 1
Const FOR_WRITING      = 2

' Determine the action mode (edit/browse/save/list/search) or browse
glsMode = ""
If Not isEmpty(request("a")) Then
   glsMode = request("a")
Else
   glsMode = "browse"
End If

' Determine the topic otherwise use home topic.
glsTopic = "WikiAsp"
If Not isEmpty(request("o")) Then
   glsTopic = request("o")
Else
   glsTopic = gHomeTopic
End If

' Determine if RSS contains highlighting or not
If Not isEmpty(request("h")) then
   gHighlightFlag = true
Else
   gHighlightFlag = false
End If

' Initialize the Regular Expression object variable
Set gRE=server.createobject("VBScript.Regexp")
gRE.IgnoreCase  = False
gRE.Global      = True

dim httpReferer
httpReferer= Request.ServerVariables("HTTP_REFERER")
 

' Get remote addresses globally
dim remoteIPHost
remoteIPHost = Request.ServerVariables("REMOTE_HOST")

dim remoteIPAddr
remoteIPAddr = Request.ServerVariables("REMOTE_ADDR")

If IsNull( remoteIPHost) Then
  remoteIPHost = "0.0.0.0"
End If

If IsNull( remoteIPHost) Then
  remoteIPAddr = "0.0.0.0"
End If

If  not IsEmpty(   Session("pwd") ) Then
    If  Session("pwd") = gPassword  Then
      remoteIPHost = "Editor"
      remoteIPAddr = ""
    End If
End If

'-- Let us get he IP first 3 numbers
dim remoteIPHost3numbers
Dim DotPos 
DotPos = InStrRev(remoteIPHost,".")
remoteIPHost3numbers= mid(remoteIPHost,1,DotPos)



'------------------------------------------------------------------------------------------------------------
'                                        SUBROUTINES AND FUNCTIONS
'------------------------------------------------------------------------------------------------------------

Sub GetHomeTopic
    '-----------------------------------------------------------------------
    ' This looks for the Home Topic Name from the 1-line file wiki.ini file.
    '-----------------------------------------------------------------------
    Dim objFSO
    err.Clear
    On Error Resume Next
    Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
    On Error GoTo 0
    If Not IsObject(objFSO) Then
        Exit Sub
    End If

    'Open the ini file which should be at same dir as access db file
    Dim objTextStream
    Dim strIniFile

    if len(gDocRootDir) > 0 then
       strIniFile= gDocRootDir & "\" & gDataSourceDir & "\" & gDataSourceFile & ".ini"
    else
       strIniFile= Server.MapPath( gDataSourceDir & "\" & gDataSourceFile & ".ini")
    end if

    If objFSO.FileExists(strIniFile) Then
        Set objTextStream = objFSO.OpenTextFile(strIniFile, FOR_READING)
        gHomeTopic = objTextStream.ReadLine()
        objTextStream.Close
    End If

    '
    ' Check For db specific style sheet if any. First look CSS at the roo
    ' If it is not there, look in the DB Folder.  If not again there don't
    ' Override the default  (which is Wiki.css).
    '
    Dim strCss
    strCss= Server.MapPath( gDataSourceFile & ".css")
    If objFSO.FileExists(strCss) Then
        gStyleSheet = gDataSourceFile & ".css"
    Else
        Dim strCssFile
        strCssFile= Server.MapPath( gDataSourceDir & "\" & gDataSourceFile & ".css")
        If objFSO.FileExists(strCssFile) Then
            gStyleSheet =  gDataSourceDir & "\" & gDataSourceFile & ".css"
        End If
    End If

    Set objTextStream = Nothing
    Set objFSO = Nothing

End Sub

Function DayName (intDay)
  '------------------------------------------
  ' Returns Abbreviated Day of Week
  '------------------------------------------
  select case intDay
      case 1
          DayName = "Sun"
      case 2
          DayName = "Mon"
      case 3
          DayName = "Tue"
      case 4
          DayName = "Wed"
      case 5
          DayName = "Thu"
      case 6
          DayName = "Fri"
      case 7
          DayName = "Sat"
  end select
end function

function MonthName(intMonth)
  '-----------------------------------------
  ' Returns Abbreviated Month Name
  '-----------------------------------------
  select case intMonth
      case 1
         MonthName = "Jan"
      case 2
         MonthName = "Feb"
      case 3
         MonthName = "Mar"
      case 4
         MonthName = "Apr"
      case 5
         MonthName = "May"
      case 6
         MonthName = "Jun"
      case 7
         MonthName = "Jul"
      case 8
         MonthName = "Aug"
      case 9
         MonthName = "Sep"
      case 10
         MonthName = "Oct"
      case 11
         MonthName = "Nov"
      case 12
          MonthName = "Dec"
  end select
end function

Function GetRFC822date(dateVar)
   '----------------------------------------------
   ' Returns standard format date for RSS feeds
   '----------------------------------------------
   GetRFC822date =  DayName (WeekDay(dateVar)) & ", " & _
                    Day(dateVar) & " " & MonthName(Month(dateVar)) & " " & _
                    Year(dateVar) & " " & FormatDateTime(dateVar, 4) &":00 " & gTimeZoneOffset
End Function


Function WrappedQueryExecute( connObject, queryString )  
   '----------------------------------------------
   ' If something is wrong with db connection redirect to URL
   '----------------------------------------------
  Dim rsResult
  If gRedirectURL = "" Then
      set rsResult = connObject.execute(queryString)
  Else
      on error resume next
      set rsResult = connObject.execute(queryString)
      on error goto 0
      
      If  isEmpty(rsResult) then
           Response.Redirect gRedirectURL
         Response.End
      End If
  End If
  Set WrappedQueryExecute = rsResult
End Function


Function AnyFileExistsIn( objFSO, extensions, baseFilename)

    Dim arrIconExts, sIconPathFile, sIconFile, element
        
    AnyFileExistsIn = false
    arrIconExts = Split(extensions, ",")

    For Each element In arrIconExts
    
        sIconFile =  baseFilename & element
        sIconPathFile= Server.MapPath( sIconFile)

        If objFSO.FileExists(sIconPathFile) Then
           gIconName = sIconFile
           AnyFileExistsIn = true
           Exit For
        End If
        
    Next
    

End Function


Sub GetIconName
    '-------------------------------------------------
    ' Get the icon file name. gif first then jpg
    ' Now it look a various places to guarantee an icon
    '-------------------------------------------------
    Dim objFSO, sIconPathFile, sIconFile
    err.Clear
    On Error Resume Next
    Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
    On Error GoTo 0
    If Not IsObject(objFSO)  Then
        Exit Sub
    End If
    
    ' look for <msaccessdb>.xxx icon file
    
    Dim iconSearchOrder 
    iconSearchOrder = ".gif,.jpg,.png"
    
    ' first look at the db directory, then on root , then for icon.xxx, otherwise default to the c2 icon
    
    If not AnyFileExistsIn( objFSO, iconSearchOrder, gDataSourceDir & "/" & gDataSourceFile ) Then
        If not AnyFileExistsIn( objFSO, iconSearchOrder, gDataSourceFile ) Then
            If not AnyFileExistsIn( objFSO, iconSearchOrder , "icon" ) Then
                gIconName = "http://c2.com/sig/wiki.gif"
            End If
        End If
    End If
    Set objFSO = Nothing
End Sub

Function SpaceName(strX)
   '------------------------------------------------------------
   ' This function splits up a string into words by inserting a
   ' space before each upper case letter.
   '------------------------------------------------------------
   Dim i, strY
   i = 1
   strY = ""
   Do While i <= len(strX)
     If UCase(mid(strX,i,1)) = mid(strX,i,1) Then
       strY = strY & " "
     End If
     strY = strY & mid(strX,i,1)
     i = i + 1
   Loop
   EmitDebug 9,  2, "Original string: " & strX & " ... Spaced out string: " & strY & "<br/>"
   SpaceName = strY
End Function


Function removeHTML(txt)
  removeHTML=server.htmlencode(txt)
End Function

Function safeQuote(txt)
  If IsNull(txt) Then
     txt = ""
  End If
  safeQuote=replace(txt,"'","''")
End Function


Function replaceBoundingPattern(txt, pattern, tag)
  Dim workingText
  workingText = txt
  gRE.Pattern = pattern & "([^\n]{0,}?)" & pattern    ' kgreiner
  workingText= gRE.Replace(workingText, "<" & tag & ">$1</" & tag & ">")
  replaceBoundingPattern = workingText
End Function

' Elrey Ronald
Function replaceTableColumnPattern(txt)
  Dim workingText
  Dim aryLines, aryLinesCount
  Dim i
  workingText = txt

  aryLines = Split(workingText,vbCRLF)
  aryLinesCount = UBound(aryLines)

  For i = 0 To aryLinesCount
           If left(aryLines(i), 6 ) = "_tmp_0"  Then
               aryLines(i) = Replace(aryLines(i), "_tmp_0", "<tr><td valign=top class=TableCell>")
               aryLines(i) = Replace(aryLines(i), "||", "</td><td  valign=top class=TableCell>")
           End If
           If left(aryLines(i), 6 ) = "_tmp_1"  Then
               aryLines(i) = Replace(aryLines(i), "_tmp_1", "<tr class=TableRow1><td  valign=top class=TableCell>")
               aryLines(i) = Replace(aryLines(i), "||", "</td><td  valign=top class=TableCell>")
           End If
           If left(aryLines(i), 6 ) = "_tmp_2"  Then
               aryLines(i) = Replace(aryLines(i), "_tmp_2", "<tr class=TableRow2><td  valign=top class=TableCell>")
               aryLines(i) = Replace(aryLines(i), "||", "</td><td  valign=top class=TableCell>")
           End If
           If left(aryLines(i), 6 ) = "_tmp_3"  Then
               aryLines(i) = Replace(aryLines(i), "_tmp_3", "<tr class=TableRow3><td  valign=top class=TableCell>")
               aryLines(i) = Replace(aryLines(i), "||", "</td><td  valign=top class=TableCell>")
           End If
  Next
  replaceTableColumnPattern= Join(aryLines,vbCRLF)
End Function


'Elrey 3/06
Function RandomInteger(HighValue , LowValue )
     Rnd -1
     Randomize (time)
     RandomInteger = Int((HighValue - Lowvalue + 1) * Rnd() + Lowvalue)
End Function


Function replaceListPattern(txt, wikiPattern, topPattern, bottomPattern, startLinePattern, endLinePattern)
  '
  ' Search through the text, creating numbered lists
  ' where so indicated by the pattern occurances.
  '
  ' To indicate a numbered list, the pattern must always
  ' appear at the very beginning of a line.
  '
  Dim workingText,replaceText
  Dim aryLines,aryLinesCount
  Dim nPatternLength,bInsidePattern
  Dim i

  'Elrey  - added multiple pattern
  Dim aPatterns
  Dim aPatternsCount
  Dim aPatternLength
  aPatterns = Split(wikiPattern,"^")
  aPatternsCount = UBound(aPatterns)
  Dim patternFound, j

  Dim aStartPattern
  aStartPattern = Split(startLinePattern,"^")

  workingText = txt
  nPatternLength = len(wikiPattern)
  bInsidePattern = False
  aryLines = Split(workingText,vbCRLF)
  aryLinesCount = UBound(aryLines)

  For i = 0 To aryLinesCount
         ' Elrey
         patternFound = 0
         For j = 0 to aPatternsCount
             aPatternLength = len( aPatterns(j) )
             If  left( aryLines(i), aPatternLength ) = aPatterns(j) Then
                patternFound = 1
                Exit For
             End If
         Next

    If patternFound = 1 Then
        If Not bInsidePattern Then
            replaceText = topPattern & vbCRLF & aStartPattern (j)

            bInsidePattern = True
        Else
            replaceText = aStartPattern (j)
        End If
        aryLines(i) = replaceText & right(aryLines(i),len(aryLines(i)) - aPatternLength ) & endLinePattern
    Else
        If bInsidePattern Then
            aryLines(i) = bottomPattern & vbCRLF & aryLines(i)
            bInsidePattern = False
        End If
    End If
  Next

  replaceListPattern = Join(aryLines,vbCRLF)

End Function


Function imageize(txt)
  ' Include a tag like img:http://www.brinkster.com/images/brinksterlogo.gif
  ' to get an inlined-image. <img src="foo">
  Dim workingText
  workingText = txt

  ' referencing local images  Elrey Ronald 1/2006
  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(image:local|img:local):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<img src='$3'  >")

  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(imageleft:local|imgleft:local):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<img src='$3' align='left' style='margin-right:15pt'>")

  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(imageright:local|imgright:local):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<img src='$3' align='right' style='margin-left:15pt'>")

  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(imgcenter:local|imagecenter:local|imgmiddle:local|imagemiddle:local):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<p align=center><img src='$3' align='middle'></p>" )


  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(img|image):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<img title='$3' src='$3'>")

  gRE.Pattern = "(\s)(imgleft|imageleft):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<img title='$3' src='$3' align='left' style='margin-right:15pt'>")

  gRE.Pattern = "(\s)(imgright|imageright):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<img title='$3' src='$3' align='right' style='margin-left:15pt'>")

  gRE.Pattern = "(\s)(imgcenter|imagecenter|imgmiddle|imagemiddle):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<p align=center><img title='$3' src='$3' align='middle' ></p>")

  ' local links
  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(local):([^ \t\n\r]+)"
  workingText=gRE.Replace(workingText,"$1<a href='$3' >$3</a>")


  gRE.IgnoreCase = False
  imageize = workingText

End Function

Function isbnize(txt)
  ' include a tag like isbn:0000000000
  ' to get a link to a book on Amazon <a href="amazonURL?isbn=0000">0000</a>
  Dim workingText
  workingText = txt

  gRE.IgnoreCase = True
  gRE.Pattern = "(\s)(isbn|ISBN):(\d{9}[\dX])"
  workingText=gRE.Replace(workingText,"$1<a  title='Amazon $3' href='http://www.amazon.com/exec/obidos/ISBN=$3'>ISBN:$3</a>")

  gRE.IgnoreCase = False  ' switch it back
  isbnize = workingText

End Function

'
'  Simple scheme to prevent bots.  Determines if request is from wiki page.
'
Function IsRequestFromWikiASPPage

  dim sHidden
  sHidden = Request.Form("hiddenInput")

  If IsEmpty(sHidden) Then
     response.write "hmmm empty"
     IsRequestFromWikiASPPage = False
  End if

  If sHidden <> "errv2010" Then
     response.write "hmmm=" & sHidden
     IsRequestFromWikiASPPage = False
  End if

  IsRequestFromWikiASPPage = True

End Function

' Regular expression version ---------------------------
Function IsRemoteAdressBlackListedRE

  If Trim(gBlackListedIpsRE  ) = "" Then
     IsRemoteAdressBlackListedRE = False
  else
     gRE.Pattern = gBlackListedIpsRE  
  
     IsRemoteAdressBlackListedRE = gRE.Test( remoteIPHost)
  End If
End Function

' Non RE version (Exact)--------------------------------
Function IsRemoteBlackListed 

    IsRemoteBlackListed = False

    Dim pos

    pos =  InStr(gBlackListedIps, remoteIPHost3numbers) ' Leading 3 digits. Set IP list as ~1.2.3.~4.5.3~

    If Not IsNull(pos) and pos > 0 Then
       IsRemoteBlackListed = True
    End If

End Function


Function hyperlink(txt)
  Dim workingText
  Dim matches
  Dim nHits
  Dim thisMatchBefore, thisMatchAfter

  workingText = txt


  'pattern with no spaces:
  'gRE.Pattern = "(http|https)://[^ \t\n\r]+"
  'gRE.Pattern = "([^A-Za-z0-9'])((http://|https://|ftp://|mailto:|news:)[^\s\<\>\(\)\[\]]+)"

  'ElreyRonald 8/03  Bjarne 10/31
  gRE.Pattern = "([^\[])\[([^\|\]]+)\|((http://|https://|ftp://|mailto:|news:|file:)[^\]\r\n\t]+)\]"
  workingText=gRE.Replace(workingText,"$1<a href='$3'>$2</a>")

  'ElreyRonald  local links inside [ | ]
  gRE.Pattern = "([^\[])\[([^\|\]]+)\|(local):([^ \t\n\r]+)\]"
  workingText=gRE.Replace(workingText,"$1<a href='$4'>$2</a>")


  'gRE.Pattern = "([^A-Za-z0-9'])((http://|https://|ftp://|mailto:|news:)[^\s\<\>\(\)\[\]\r\n\t]+)"
  'Bjarne
  gRE.Pattern = "([^A-Za-z0-9'])((http://|https://|ftp://|mailto:|news:|file:)[^\s\<\>\(\)\[\]\r\n\t]+)"
  workingText=gRE.Replace(workingText,"$1<a href=""$2"">$2</a>")


   'This is new  5/2006 see [/Drop]
  '[Drop#001##Test]
            '       1    [    2      ::              3            ]
  gRE.Pattern = "([^\[])\[Drop\#(\S+)\#\#([^\<\>\(\)\=\r\n\t\]]+)\]"
  workingText=gRE.Replace(workingText,   _
   "$1<div><span style=""font-weight: bold; color: white; background-color: green ; cursor: pointer"" onclick=""var div=document.getElementById('$2');if(div.style.display=='none') {div.style.display='block'; this.innerText='&nbsp;&#8592;&nbsp;';} else {div.style.display='none';this.innerText='&nbsp;+&nbsp;'}"">&nbsp;+&nbsp;</span>$3<div id='$2' style='display:none'> " )



  ' interwiki  by Elrey
  ' example:  [Sample One=CpOrders::SampleOne]
            '       1    [     2    =   3      ::               4            ]
  gRE.Pattern = "([^\[])\[([^=\]]+)\=([^=\]]+)\:\:([^\s\<\>\(\)\=\r\n\t\]]+)\]"
  workingText=gRE.Replace(workingText,"$1<a href='" & gScript & "?db=$3&o=$4'>$2</a>")

  ' interwiki  by Elrey
  ' example:  [Sample One=CpOrders::]
            '       1    [     2    =   3      ::    ]
  gRE.Pattern = "([^\[])\[([^=\]]+)\=([^=\]]+)\:\:\]"
  workingText=gRE.Replace(workingText,"$1<a href='" & gScript & "?db=$3'>$2</a>")



  ' intern link by Bernd Michalke 9/15/2005
  ' [anything geht=WikiASP]

  gRE.Pattern = "([^\[])\[([^=\]]+)\=([^\s\<\>\(\)\=\r\n\t\]]+)\]"
  workingText=gRE.Replace(workingText,"$1<a href='"& gScriptURL & "&o=$3'>$2</a>")

  ' intern link by Elrey 3/2006
  ' [=WikiASP]
  '              (--1--)   (-2----)
  gRE.Pattern = "([^\[])\[=([^\]]+)\]"
  workingText=gRE.Replace(workingText,"$1<a href='"& gScriptURL & "&o=$2'>$2</a>")

' intern link by Elrey 3/2006
  ' [[WikiAS P topic]]
  '              (--1--)    (---2--)
  gRE.Pattern = "([^\[])\[\[([^\]]+)\]\]"
  workingText=gRE.Replace(workingText,"$1<a href='"& gScriptURL & "&o=$2'>$2</a>")


  ' interwiki  by Elrey
  ' example:  [CpOrders::SampleOne]
            '       1    [     2   ::   3         ]
  gRE.Pattern = "([^\[])\[([^=\]]+)\:\:([^\s\<\>\(\)\=\r\n\t\]]+)\]"
  workingText=gRE.Replace(workingText,"$1<a href='" & gScript & "?db=$2&o=$3'>$3</a>")

  ' interwiki  by Elrey
  ' example:  [CpOrders::]
            '       1    [    2  ::    ]
  gRE.Pattern = "([^\[])\[([^=\]]+)\:\:\]"
  workingText=gRE.Replace(workingText,"$1<a href='" & gScript & "?db=$2'>$2</a>")


  hyperlink = workingText

End Function



Function PreHack(isTeksten)
    Dim arr
    Dim element
    Dim preOn
    Dim newText

    preOn = False
    arr = Split(isTeksten, vbCrLf)

    For Each element In arr
    If newtext <> "" Then
        newtext = newtext & vbCrLf
    End If
    ' line begins with a space
    If left(element, 1) = " " Then
        ' start pre tag
        If preOn = False Then
        preon = true
        newText = newtext & "<pre>" & vbcrlf & element
        ' already in pre tag
        else
        newtext = newtext & element
        end if
    ' empty line
    elseif element = "" then
        newtext = newtext & vbcrlf
    ' line begins with something besides a space
    else
        ' turn pre off
        if preon then
        newText = newtext & "</pre>" & vbcrlf & element
        preon = false
        ' just append element
        else
        newtext = newtext & element
        end if
    end if
    next
    if preon then
    newtext = newtext & "</pre>"
    preon = false
    end if
    prehack = newtext
end function



function xform(isTeksten)
  ' this is the transformation routine, in which all the markup
  ' is transformed into HTML.
  '
  ' ordering of the stages is important.
  '

  dim newText
  newText = vbcrlf & isTeksten ' need a space to deal with first-line wikiname

  'Elrey - move HTML removal into here
  If gRemoveHtml Then
     newText = removeHTML(newText)
  End If

  gBulletChar01 = "&#8226;"
  gBulletChar02 = "&#959;"
  gBulletChar03 = "&#9674;"
  gBulletChar04 = "&#8594;"
  gBulletChar05 = "&#9830;"
  gBulletChar06 = "&#8226;"
  gBulletChar07 = "&#959;"
  gBulletChar08 = "&#8574;"
  gBulletChar09 = "&#9827;"
  
  
  
  ' indented paragraph second level using '>' (  '|' is now used with Tables - Elrey
  newText=replace(newText,vbcrlf & "&gt;&gt;&gt;&gt;",vbcrlf & "<p style=""margin-left:80pt;"">")
  newText=replace(newText,vbcrlf & "&gt;&gt;&gt;",vbcrlf & "<p style=""margin-left:60pt;"">")
  newText=replace(newText,vbcrlf & "&gt;&gt;",vbcrlf & "<p style=""margin-left:40pt;"">")
  newText=replace(newText,vbcrlf & "&gt;",vbcrlf & "<p style=""margin-left:20pt;"">")
  
 ' Bullet indention.  Elrey 3/2007
 newText=replace(newText,vbcrlf & ">>>>>>>>>*",vbcrlf & "<p style=""margin-left:135pt;margin-top:2pt;"">" & gBulletChar09 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>>>>>>>*",vbcrlf & "<p style=""margin-left:120pt;margin-top:2pt;"">" & gBulletChar08 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>>>>>>*",vbcrlf & "<p style=""margin-left:105pt;margin-top:2pt;"">" & gBulletChar07 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>>>>>*",vbcrlf & "<p style=""margin-left:90pt;margin-top:2pt;"">" & gBulletChar06 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>>>>*",vbcrlf & "<p style=""margin-left:75pt;margin-top:2pt;"">" & gBulletChar05 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>>>*",vbcrlf & "<p style=""margin-left:60pt;margin-top:2pt;"">" & gBulletChar04 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>>*",vbcrlf & "<p style=""margin-left:45pt;margin-top:2pt;"">" & gBulletChar03 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">>*",vbcrlf & "<p style=""margin-left:30pt;margin-top:2pt;"">" & gBulletChar02 & "&nbsp;")
 newText=replace(newText,vbcrlf & ">*",vbcrlf & "<p style=""margin-left:15pt;margin-top:2pt;"">" & gBulletChar01 & "&nbsp;")

  ' Non-bullet indented paragraph second level using '>' (  '|' is now used with Tables - Elrey  updated 3/2007
  newText=replace(newText,vbcrlf & ">>>>>>>>>",vbcrlf & "<p style=""margin-left:135pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>>>>>>>",vbcrlf & "<p style=""margin-left:120pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>>>>>>",vbcrlf & "<p style=""margin-left:105pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>>>>>",vbcrlf & "<p style=""margin-left:90pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>>>>",vbcrlf & "<p style=""margin-left:75pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>>>",vbcrlf & "<p style=""margin-left:60pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>>",vbcrlf & "<p style=""margin-left:45pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">>",vbcrlf & "<p style=""margin-left:30pt;margin-top:2pt;"">")
  newText=replace(newText,vbcrlf & ">",vbcrlf & "<p style=""margin-left:15pt;margin-top:2pt;"">")
  



  ' newlines: three newlines = a blank line
  newText=replace(newText,vbcrlf & vbcrlf & vbcrlf,vbcrlf & "<br/>&nbsp;<br/></p><p>" & vbcrlf )

  ' newlines: two newlines = a hard return
  newText=replace(newText,vbcrlf & vbcrlf,vbcrlf & "<br/></p><p>" & vbcrlf )


  EmitDebug 10, 4, "xform-before(" &  newText & ")<br/>"

  If right(newText,2) <> vbcrlf Then
    newText = newText & vbcrlf
  End If

  'Elrey Ronald
  newText=replaceListPattern(newText, "        *", "<ul>", "</ul>", "<li> ", "</li>")
  newText=replaceListPattern(newText, "        :*", "<ol>", "</ol>", "<li> ", "</li>")
  newText=replaceListPattern(newText, "        1.", "<ol>", "</ol>", "<li> ", "</li>")

  'Elrey Ronald - more convenient bullet list
  newText=replaceListPattern(newText, " *", "<ul>", "</ul>", "<li> ", "</li>")
  newText=replaceListPattern(newText, " :*", "<ol>", "</ol>", "<li> ", "</li>")
  newText=replaceListPattern(newText, " 1.", "<ol>", "</ol>", "<li> ", "</li>")

  'Elrey Ronald - Table Pattern
  newText=replaceListPattern(newText, "||^!|^|!^!!", "<table border=1 class=TableClass>", "</table>", "_tmp_0^_tmp_1^_tmp_2^_tmp_3", "</td></tr>")

  newText=replaceTableColumnPattern(newText)

  ' leading space rule
  newText = PreHack(newText)

' outline ( ElreyRonald )

  gRE.Pattern = "\r\n\[(\d+)\]======([^\r\n]+)"
  newText=gRE.Replace(newText,"<h6>[<a name='$1' href='#fn_$1'>$1</a>] $2</h6>")
  gRE.Pattern = "\r\n\[(\d+)\]=====([^\r\n]+)"
  newText=gRE.Replace(newText,"<h5>[<a name='$1' href='#fn_$1'>$1</a>] $2</h5>")
  gRE.Pattern = "\r\n\[(\d+)\]====([^\r\n]+)"
  newText=gRE.Replace(newText,"<h4>[<a name='$1' href='#fn_$1'>$1</a>] $2</h4>")
  gRE.Pattern = "\r\n\[(\d+)\]===([^\r\n]+)"
  newText=gRE.Replace(newText,"<h3>[<a name='$1' href='#fn_$1'>$1</a>] $2</h3>")
  gRE.Pattern = "\r\n\[(\d+)\]==([^\r\n]+)"
  newText=gRE.Replace(newText,"<h2>[<a name='$1' href='#fn_$1'>$1</a>] $2</h2>")

  ' footnote ( ElreyRonald )

  gRE.Pattern = "\r\n\[(\d+)\]\r\n"    ' blank footnote will just be an anchor (ElreyRonald)
  newText=gRE.Replace(newText,  "<a name='$1' href='#fn_$1'><hr size=1></a>" & vbcrlf)

  gRE.Pattern = "\r\n\[(\d+)\]"
  newText=gRE.Replace(newText,  "<br>[<a name='$1' href='#fn_$1'>$1</a>]")

  gRE.Pattern = "\[(\d+)\]"
  newText=gRE.Replace(newText, "[<a href='#$1' name='fn_$1'>$1</a>]")

  ' topic line (ElreyRonald)
  gRE.Pattern = "\r\n======([^\r\n]+)"
  newText=gRE.Replace(newText,"<h6>$1</h6>")
  gRE.Pattern = "\r\n=====([^\r\n]+)"
  newText=gRE.Replace(newText,"<h5>$1</h5>")
  gRE.Pattern = "\r\n====([^\r\n]+)"
  newText=gRE.Replace(newText,"<h4>$1</h4>")
  gRE.Pattern = "\r\n===([^\r\n]+)"
  newText=gRE.Replace(newText,"<h3>$1</h3>")
  gRE.Pattern = "\r\n==([^\r\n]+)"
  newText=gRE.Replace(newText,"<h2>$1</h2>")

  ' horizontal rule
  gRE.Pattern = "\r\n-{4,}"
  newText=gRE.Replace(newText,vbCrLf & "<hr size=1 noshade=false />" & vbcrlf)

  ' special case for dash and a-umlaut - MARKUS
  'newText=replace(newText,"-", "&minus;")  ' this change breaks image URLs that include dashes
  newText=replace(newText,"", "&auml;")

  ' removed by ElreyRonald, use "|"
  ' newText=replace(newText,chr(9) & " :" & chr(9),"<p style=""margin-left:20pt;"">")

  ' Removed by ElreyRonald, use "|"
  ' newText=replace(newText,vbcrlf & chr(9) & "]",vbcrlf & "<p style=""margin-left:20pt;"">")


  '[MARKUS] Underline neu hinzugefgt - -_ irgendwas _-
  newText=replace(newText,"-__", "<u>")
  newText=replace(newText,"__-","</u>")

  '[Markus] LEERSTELLEN werden in HTML-Leerstellen umgewandelt
  'newText=replace(newText," ","&nbsp;")  ' this change screws up images.  Why necessary?   dinoch Thu, 17 Oct 2002

  ' bulleted lists: tab-star
  'newText=replace(newText,chr(9) & "*","<li> ")
  newText=replaceListPattern(newText, chr(9) & "*", "<ul>", "</ul>", "<li> ", "</li>")

  ' numbered lists: tab-colon-star
  newText=replaceListPattern(newText, chr(9) & ":*", "<ol>", "</ol>", "<li> ", "</li>")

  ' numbered lists: Changed to use 1. to conform with http://www.c2.com/cgi/wiki?TextFormattingRules
  newText=replaceListPattern(newText, chr(9) & "1.", "<ol>", "</ol>", "<li> ", "</li>")

  ' COLORS: (german and english)- german removed (ElreyRonald)
  'SCHRIFTFARBEN {schwarz} {braun} {grn} {blau} {gelb} {rot} {orange}
  '{farbe} {/farbe}
  newText=replace(newText,"{black}","<font color=black>")
  newText=replace(newText,"{/black}","</font>")
  newText=replace(newText,"{green}","<font color=darkgreen>")
  newText=replace(newText,"{/green}","</font>")
  newText=replace(newText,"{blue}","<font color=darkblue>")
  newText=replace(newText,"{/blue}","</font>")
  newText=replace(newText,"{sienna}","<font color=sienna>")
  newText=replace(newText,"{/sienna}","</font>")
  newText=replace(newText,"{red}","<font color=firebrick>")
  newText=replace(newText,"{/red}","</font>")
  newText=replace(newText,"{pink}","<font color=deeppink>")
  newText=replace(newText,"{/pink}","</font>")

  ' 5/2006
  newText=replace(newText,"[/Drop]","</div></div>")

  '
  newText=replace(newText,"{italic}","<I>")
  newText=replace(newText,"{/italic}","</I>")
  newText=replace(newText,"{bold}","<strong>")
  newText=replace(newText,"{/bold}","</strong>")

  ' CHANGE SIZE / SCHRIFTGRSSE
  'SMALLER / KLEINER
  newText=replace(newText,"{small}","<font size='-1'>")
  newText=replace(newText,"{/small}","</font>")
  newText=replace(newText,"{smaller}","<font size='-2'>")
  newText=replace(newText,"{/smaller}","</font>")
  newText=replace(newText,"{smallest}","<font size='-3'>")
  newText=replace(newText,"{/smallest}","</font>")
  'LARGER / GRSSER
  newText=replace(newText,"{big}","<font size='+1'>")
  newText=replace(newText,"{/big}","</font>")
  newText=replace(newText,"{bigger}","<font size='+2'>")
  newText=replace(newText,"{/bigger}","</font>")
  newText=replace(newText,"{biggest}","<font size='+3'>")
  newText=replace(newText,"{/biggest}","</font>")

  ' this is were you can insert your own bracket comands...
  newText=replace(newText,"{br}","<br/>")


  ' images:
  newText= imageize(newText)

  ' isbns:
  newText= isbnize(newText)

  ' auto-hyperlinks
  newText= hyperlink(newText)

  ' bold text: three single quotes
  newText= replaceBoundingPattern(newText,"'''","b")

  ' em text: two single quotes
  newText= replaceBoundingPattern(newText,"''","em")

  ' consolidate a series of trailing vbcrlf to just 2.
  gRE.Pattern = "(\r\n){3,}$"
  newText=gRE.Replace(newText, vbcrlf & vbcrlf)

  If  gDisableScripting = true Then
    ' 2007.08.25 disable scripts
    gRE.Pattern = "<([s|S][c|C][r|R][i|I][p|P][t|T])"
    newText=gRE.Replace(newText, "&lt;$1")
  End If


  EmitDebug 11, 4, "xform-after(" &  newText & ")<br/>"

  newText = Replace(newText, "#@91;", "[")
  newText = Replace(newText, "#@93;", "]")
  newText = Replace(newText, "#@3A;", ":")
  newText = Replace(newText, "#@3C;", "<")
  newText = Replace(newText, "#@3E;", ">")

  xform = newText

End Function


Function WalkWiki(isTeksten)
    Dim wikiNames
    Dim thisHit
    Dim nHits
    Dim rsPages
    Dim myText

    myText = isTeksten

    'Bjarne
    'myText = Replace(myText, "&#228;", "")
    'myText = Replace(myText, "&#246;", "")
    'myText = Replace(myText, "&#252;", "")
    'myText = Replace(myText, "&#230;", "")
    'myText = Replace(myText, "&#248;", "")
    'myText = Replace(myText, "&#229;", "")
    'myText = Replace(myText, "&#196;", "")
    'myText = Replace(myText, "&#214;", "")
    'myText = Replace(myText, "&#220;", "")
    'myText = Replace(myText, "&#198;", "")
    'myText = Replace(myText, "&#216;", "")
    'myText = Replace(myText, "&#197;", "")



    'find wikiNames:
    'gRE.Pattern = "([A-Z][a-z]+)([A-Z][a-z]+)+"
    'Bjarne
    gRE.Pattern = "([A-Z][a-z0-9]+)([A-Z][a-z0-9]+)+"
    Set wikiNames = gRE.Execute(myText)
    nHits = wikiNames.Count

    'find the duplicates:  (dinoch 07 Nov 00)
    Dim i, j
    Dim isDuplicate()
    ReDim isDuplicate(nHits)
    isDuplicate(0)= 0
    For i = 0 To nHits-2
    For j = i+1 To nHits-1
      isDuplicate(j)=0
      If (wikiNames.Item(i) = wikiNames.Item(j)) Then
          isDuplicate(j)=1
          Exit For
      End If
    Next
    Next

    For j = 0 To nHits-1
    If (isDuplicate(j) = 0) Then
        'only process the name if it is not a duplicate
        thisHit = wikiNames.Item(j)  '
        EmitDebug 12, 2, "WalkWiki:thisHit(" & thisHit & ")<br/>"
        ' insert hyperlinks as appropriate
        ' - added & and = to exclude certain URLs (2002/4/12 greinerk@yahoo.com)
        ' - added umlauts (MARKUS)
    'gRE.Pattern = "([^=>?&A-Za-z0-9\/])(" & thisHit & ")([^=A-Za-z])"
    'Bjarne
    gRE.Pattern = "([^=>?&A-Za-z0-9\/])(" & thisHit & ")([^=A-Za-z])"

        EmitDebug 12.1, 2, "WalkWiki:thisHit regexp=" & gRE.Pattern  & "<br/>"

        sqlQuery = "select Title from " & gDbTableName & " where title='" & thisHit & "'"
        EmitDebug 13, 2, "sqlquery: " & sqlquery & "<br/>"
        
        'Set rsPages = gDataConn.Execute(sqlQuery)
        set rsPages = WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007        

        'EmitDebug 14, 2, "rs.recordcount: " & rsPages.recordcount & "<br/>"
        EmitDebug 15, 2, "eof/bof: " & rsPages.eof & "/" & rsPages.bof & "<br/>"

        If rsPages.eof = False Then
        ' found, make a link
        EmitDebug 16, 2, "walkwiki: topic found<br/>"
        'myText = gRE.Replace(myText, "$1<a href=""" & gScript & "?$2"">$2</a>$3")
        'myText = gRE.Replace(myText, "$1<a href=""" & gScriptURL & "&o=$2"">$2</a>$3")
        'Bjarne
        If gSpaceNames = 1 Then
           myText = gRE.Replace(myText, "$1<a href=""" & gScriptURL & "&o=$2"">" & SpaceName(thisHit) & "</a>$3")
        Else
           myText = gRE.Replace(myText, "$1<a href=""" & gScriptURL & "&o=$2"">$2</a>$3")
        End If
        Else
        ' not found, make a ? link
        EmitDebug 17, 2, "walkwiki: topic not found<br/>"
        'myText = gRE.Replace(myText, "$1<span>$2</span><a href=""" & gScript & "?a=edit&o=$2"">?</a>$3")
        'myText = gRE.Replace(myText, "$1<span>" & left(thisHit, len(thisHit)-1) & "</span><a href=""" & gScriptURL & "&a=edit&o=$2"">" & right(thisHit,1) & "</a>$3")
        'Bjarne
        'If gSpaceNames = 1 Then
        '   myText = gRE.Replace(myText, "$1<span>" & left(SpaceName(thisHit), len(SpaceName(thisHit))-1) & "</span><a href=""" & gScriptURL & "&a=edit&o=$2"">" & right(thisHit,1) & "</a>$3")
        'Else
           'myText = gRE.Replace(myText, "$1<span>" & left(thisHit, len(thisHit)-1) & "</span><a title='Click to create this page' href=""" & gScriptURL & "&a=edit&o=$2"">" & right(thisHit,1) & "</a>$3")
        myText = gRE.Replace(myText, "$1<a title='Click to create this page' class='NoWikiYet' href=""" & gScriptURL & "&a=edit&o=$2"">" & thisHit & "</a>$3")
        'End If
        End If

        EmitDebug 18, 3, "WalkWiki:myText(" & myText & ")<br/>"

    End If

    Next

    'WalkWiki = WalkWiki2(myText)

	myText = Replace(myText, gCamelBreak, "")
	
    WalkWiki = myText   ' WalkWiki2 removed by Elrey 3/2006

End Function


'ElreyRonald - added to support [[wikiword]] - see above
Function WalkWiki2_old(isTeksten)
    Dim wikiNames
    Dim thisHit
    Dim nHits
    Dim rsPages
    Dim myText

    myText = isTeksten

    gRE.Pattern = "(\[\[[A-Za-z0-9\_\s]+\]\])+"

    Set wikiNames = gRE.Execute(myText)
    nHits = wikiNames.Count

    Dim i, j
    Dim isDuplicate()
    ReDim isDuplicate(nHits)
    isDuplicate(0)= 0
    For i = 0 To nHits-2
      For j = i+1 To nHits-1
        isDuplicate(j)=0
        If (wikiNames.Item(i) = wikiNames.Item(j)) Then
          isDuplicate(j)=1
          Exit For
        End If

      Next
    Next

    For j = 0 To nHits-1
      If (isDuplicate(j) = 0 ) Then
        'only process the name if it is not a duplicate
        thisHit = RemoveBrackets(wikiNames.Item(j))

        gRE.Pattern = "([^=>?&A-Za-z0-9\/\[])(\[\[)(" & thisHit & ")(\]\])([^=A-Za-z0-9\]])"
        sqlQuery = "select Title from " & gDbTableName & " where title='" & RemoveSpaces(thisHit) & "'"
        Set rsPages = gDataConn.Execute(sqlQuery)
        If rsPages.eof = False Then
           myText = gRE.Replace(myText, "$1<a href=""" & gScriptURL & "&o=$3"">$3</a>$5")
        Else
           myText = gRE.Replace(myText, "$1" & left(thisHit, len(thisHit)-1) & _
            "<a href=""" & gScriptURL & "&a=edit&o=$3"">" & right(thisHit,1) & "</a>$5")
        End If

        myText = replace( myText, "&o=" & thisHit , "&o=" & RemoveSpaces(thisHit)  )

     End If

    Next

    WalkWiki2 = myText

End function





function RemoveBrackets(s)
  Dim ts
  ts = replace( s, "[","")
  ts = replace( ts, "]","")
  RemoveBrackets = ts
end function

function RemoveSpaces(s)
  Dim ts
  ts = replace( s, " ","")
  RemoveSpaces = ts
end function



Sub EmitDebug(sig,lvl,arg)
  If gDebug >= lvl Then Response.Write("debug:" & sig & " " & arg & vbcrlf)
End Sub


'----------------------------------------------------
' This function builds and returns the connection
' string, based on input provided from the web form.
'
function ConnStr(includeMode)
  dim localDs
  ' Map MDB database to physical path
   if len(gDocRootDir) > 0 then
      localDs = gDataSource
   else
      localDs = Server.MapPath(gDataSource)
   end if

  ConnStr= "Provider=" & gProvider & ";Data Source=" & localDs & ";"
  if (includeMode) then
      ConnStr=   ConnStr & "mode= Share Deny None"
  end if
  EmitDebug 20, 3, "ConnStr= (" &  ConnStr & ")<br/>"
end function



sub CheckDbErrors
  if  gDataConn.errors.count> 0 then
    dim counter
    response.write "<br/><b>Database Errors Occurred" & "</b><br/>" & vbcrlf
    for counter= 0 to gDataConn.errors.count
      response.write "Error #" & gDataConn.errors(counter).number & vbcrlf & "<br/>"
      response.write "  Description(" & gDataConn.errors(counter).description & ")" & vbcrlf & "<br/>"
    next
  else
    response.write "<br/><b>No Database Errors Occurred" & "</b><br/>" & vbcrlf
  end if
end sub


' Elrey Ronald  2/21/05
sub VerifyWikiTableNoAdoxComponent
  EmitDebug 20, 3, "Opening ConnStr"
  on error resume next
  gDataConn.Open ConnStr(0)
  on error goto 0

  EmitDebug 20, 3, "Select PageData" & gDbTableName

  on error resume next
  gDataConn.execute("select PageData, Title from " & gDbTableName & " where ID = 2")
  on error goto 0

end sub

'----------------------------------------------------------------------------
' VerifyWikiTable
' This routine:
' (a) verifies the existence of the target database (dbname) at the given
'     ADO connection.  If necessary, this routine creates that
'     database.
' (b) verifies the existence of the table in that database.  If necessary,
'     this routine will create the required table, and build the table
'     structure.  The columns in the target table are determined by the
'     fields in the source record set (sourceRs).   Two additional
'     columns are also added. (in fact we do not use the entire recordset,
'     but only the collection of fields in the recordset.
'

sub VerifyWikiTable

  if not gAutoCreateMdb then
     Call VerifyWikiTableNoAdoxComponent
     Exit Sub
  End If

  dim tbl, cat, dbname, fso
  dim fsoErrMessage, adoxErrMessage, instructions

  fsoErrMessage  = "<font color=red >ERROR: Server has no working FileSystemObject component. DB creation failed.</font><BR>"
  adoxErrMessage = "<font color=red >ERROR: Server has no working ADOX.Catalog component. DB creation failed. Try manual upload Some file actions are disabled</font><BR>"
  instructions =   "<LI>You may have to <b>MANUALLY</b> create the folder/MsAccess file -> <b>" & gDataSource & " </b> </LI>"  & _
                   "<LI>You may modify 'gDefaultIcon', 'gDefaultHomePage' variables in the WikiAsp program to view your default icon and access the proper Ms Access file (mdb).</LI>" & _
                   "<LI>You may modify 'gAutoCreateMdb' and set it to false to prevent creation of MDB and avoid this message." & _
                   "<LI>The program will attempt to continue using default values, if this works you can just remove these comments from the program (look for VerifyWikiTable  subroutine).</LI>" & _
                   "<BR><BR><B><i>Still ... trying to use default values to see if this would work...</i></B>"

  err.clear
  ' Check if ADOX.Catalog component is available in this computer
  on error resume next
  set cat= CreateObject("ADOX.Catalog")
  on error goto 0

  ' Check if FileSystemObject component is available in this computer
  on error resume next
  set fso = CreateObject("Scripting.FileSystemObject")
  on error goto 0

  If Not IsObject(cat) or cat is nothing Then
     Response.Write( adoxErrMessage)
     Response.Write( instructions )
     Call VerifyWikiTableNoAdoxComponent
     Exit Sub
  End If

  err.clear
  If Not IsObject(fso)  Then
     Response.Write( fsoErrMessage)
     Response.Write( instructions )
     Call VerifyWikiTableNoAdoxComponent
     Exit Sub
  End If

  ' gDocRootDir  is the absolute path to the folder like c:\home\wikiasp
  if len (gDocRootDir) > 0 then 
    dbname = gDataSource
  else
    dbname = Server.MapPath(gDataSource)
  end if

  '--------------------------------------------
  ' step 0: check the directory, create if necessary
  dim folder, f1
  if len (gDocRootDir) > 0 then
    f1 = gDocRootDir & "\" & gDataSourceDir
  else
    f1 = Server.MapPath(gDataSourceDir)
  end if
  if not fso.FolderExists(f1) then
      on error resume next
      Set folder = fso.CreateFolder(f1)
      on error goto 0
      If Not IsObject(folder) Then
         Response.Write( "Unable to create folder [" & f1 & "].  Please modify DOCROOT and gDataSourceDir in the program. Consult your website settings." )
         Response.End
      End If
      set folder = nothing
  end if
  set fso = nothing
  
  '
  '  Remember.  gDataSourceFile  is the mdb name.
  '             The default home page will be auto-created if necessary.
  '             If other db is specified not same as default home page.    pw must be passed.
  
  '---- some security here

  EmitDebug 21, 2, vbcrlf & " Comparing gDataSourceFile(a.k.a. mdb name)= " & gDataSourceFile & " and gDefaultHomePage=" & gDefaultHomePage & "  ... checking pw <br/>"

  If gDataSourceFile <> gDefaultHomePage Then
  
    Dim pwd
  
    If Request.QueryString("pw") <> gDeletePassword Then
        EmitDebug 21, 2, vbcrlf & " gDataSourceFile vs gDefaultHomePage not equal and  pw passed is = " & Request.QueryString("pw") & " <br/>"
        
        Response.Write("Sorry but the Database (db) requested does not exist.  Correct password must be sent to create it.")
        Response.End
    End If
 

  End If
  '--------------------------------------------
  ' step 1: create the new db catalog, if necessary
  Err.Clear
  EmitDebug 21, 2, vbcrlf & " creating db " & dbname & "<br/>"
  
  on error resume next
  cat.Create ConnStr(0)
  on error goto 0
  EmitDebug 22, 2, ">> error(" & err.Number & "," & err.Description &  ")<br/>"
  'EmitDebug 23, 2, vbcrlf & " catConnErrorCount(" & _
  '    cat.ActiveConnection.errors.count  & ")<br/>"

  if not (err.Number = 0) then
    if not (err.Description = "Database already exists." ) then
      dim sError
      sError = ">> error(" & err.Number & "," & err.Description & ")" & _
          "(EXPECTED ""Database already exists"")..." & "<br/>"
      EmitDebug 24, 2, sError
      Response.Write( "<span style='color:red'>Fatal error creating db: " & err.Number & " " & err.description & "</span>")
    else
      EmitDebug 25, 2, ">> Database already exists..." & "<br/>"
      cat.ActiveConnection= ConnStr(0)
    end if
  else
    EmitDebug 26, 2, ">> Database has just been created..." & "<br/>"
  end if
  EmitDebug 27, 2, " Database now exists..." & "<br/>"


  '--------------------------------------------
  ' step 2: create the new table, with columns, if necessary
  Err.Clear
  EmitDebug 28, 2, " verifying presence of table(" & gDbTableName & ")<br/>"
  'if not isNothing(gDataConn) then set gDataConn = nothing
  on error resume next
  set gDataConn = Server.CreateObject("ADODB.Connection")
  on error goto 0
  If Not IsObject(gDataConn) Then
    Response.Write ( "Unable to establish connection. Missing ADO object.")
    Response.End
  End If

  on error resume next
  gDataConn.Open ConnStr(0)
  on error goto 0


  on error resume next
  gDataConn.execute("select PageData, Title from " & gDbTableName & " where ID = 2")
  on error goto 0

  if (0 = gDataConn.errors.count) then
      EmitDebug 29, 1, vbcrlf & "(no db errors, ergo table exists)"  & "<br/>"
  elseif ((gDataConn.errors.count>0) and ( ADOERROR_NOTABLE = gDataConn.errors(0).number)) then
      set gDataConn = nothing
      ' error: table does not exist.
      EmitDebug 30, 2, vbcrlf & " creating table " & gDbTableName  & "<br/>"
      Dim idx 'As New ADOX.Index
      set idx= CreateObject("ADOX.Index")
      ' now, create a new table in the db:
      set tbl= CreateObject("ADOX.Table")
      With tbl
      ' drop tbl into a MDB provider context; need to do this NOW
      ' to be able to use autoIncrement, later.
      set .ParentCatalog = cat

      ' Name the new table.
      .Name = gDbTableName

      .Columns.Append "ID", 3
      .Columns("ID").Properties("AutoIncrement") = True

      .Columns.Append "Title", 202, 127
      .Columns.Append "PageData", 203
      .Columns.Append "PrevPageData", 203
      .Columns("PrevPageData").Properties("Jet OLEDB:Allow Zero Length") = True
      .Columns("PrevPageData").Properties("Nullable") = True
      .Columns.Append "LastUpdate", 7     ' timestamp
      .Columns.Append "LastEditor", 202, 127

      ' create the Primary Key :
      idx.Name = "RecordIndex"
      idx.Columns.Append "ID"
      idx.PrimaryKey = True
      idx.Unique = True
      .Indexes.Append idx



      End With

      ' this appends the table to the db catalog
      cat.Tables.Append  tbl
      EmitDebug 31, 2, vbcrlf & " post-append: catConnErrorCount(" & _
      cat.ActiveConnection.errors.count  & ")<br/>"

      set idx= nothing

      ' insert the first record into the newly-created table
      EmitDebug 32, 2,  ">> inserting into table(" & gDbTableName  & ")<br/>"

      set gDataConn = Server.CreateObject("ADODB.Connection")
      gDataConn.Open ConnStr(1)

      dts = Now
      EmitDebug 33, 2,  ">> the time is now(" & dts  & ")<br/>"

      DoInitialPageCreation(".")

  else
      EmitDebug 34, 2,  ">> table " & tablename & " already exists?" & "<br/>"
  end if

  set cat = nothing
  set tbl = nothing
  on error goto  0

end sub


Function DoInitialPageCreation(folderspec)
  Dim fso, f, f1, fc, s, dts, sPageData, fPage, stmnt
  Set fso = CreateObject( "Scripting.FileSystemObject" )

  EmitDebug 35, 2,  ">> checking dir (" & Server.MapPath(folderspec) & ")<br/>"
  Set f = fso.GetFolder(Server.MapPath(folderspec))
  Set fc = f.Files
  EmitDebug 36, 2,  ">> files counted (" & fc.Count & ")<br/>"
  For Each f1 in fc
    if (Right(f1.name, 4) = ".wik") then
        s = Left(f1.name, Len(f1.name)-4)
        EmitDebug 37, 2,  ">> found file  (" & s & ")<br/>"
        on error resume next
        set fPage= fso.OpenTextFile(Server.MapPath(f1.name),FOR_READING)
        sPageData = fPage.ReadAll
        on error goto 0
        fPage.Close
        set fPage = nothing
        dts = Now  ' timestamp
        EmitDebug 38, 2,  ">> inserting record (" & s & ")<br/>"

        stmnt = "INSERT INTO " & gDbTableName & " (Title,PageData,PrevPageData,LastUpdate,LastEditor) " & _
        "VALUES ( '" & s & "','" & safeQuote(sPageData) & "', '--', '" & dts & "', '" & gScript & " (initial creation)');"
        on error resume next
        gDataConn.execute(stmnt)
        on error goto 0
        if gDebug>=1 then CheckDbErrors
    end if
  Next
  set fso = nothing
  set f = nothing
  set fc = nothing

end Function



function theWhereClause(theStr)
  dim result
  result= ""
  dim myArray
  dim element
  EmitDebug 39, 1, "whereClause(" & theStr & ")<br/>" & vbcrlf

  myArray = split(Trim(theStr), " ")
  for each element in myArray
    element = Trim(element)
    if (result = "") then
      result = " where "
    else
      result = result & " and "
    end if
    result= result &  " PageData like '%" & element & "%'"
  next
  EmitDebug 40, 1, "whereClause:result(" & result & ")<br/>" & vbcrlf
  theWhereClause = result

end function



sub handleEdit

    If gHideLogin Then
        exit sub
    End If

    Dim readonlyflag, disableflag
    readonlyflag = ""
    disableflag  = ""
  
    ' Special pages that should not be edit.  Requires the admin password (a.k.a delete password)
    If glsTopic = "TextFormattingRules"  and Request.QueryString("pw") <> gDeletePassword Then
        Response.Write("<br/>Sorry, Authorization needs to be passed to edit this page.")
        Response.End
        exit sub
    End If


    If IsRemoteBlackListed Then
        Response.Write("<br/><center><h2>Please contact web master asap.</center>")
        Response.End
        Exit Sub
    End If


    If (  IsEmpty( InStr(1, gPagesUnprotected, glsTopic ) ) or  InStr(1, gPagesUnprotected, glsTopic ) = 0  ) _
         and ( not gIsOpenWiki  ) Then 
    
        'Ask for password if this page is not in the unprotected list.
        'and  it is not configured as Open Wiki (meaning no password).
        'pwd is passwed either in url and posted in the form.
        If Not IsEmpty(Request.Form("pwd")) Then  Session("pwd") = Request.Form("pwd")

        If IsEmpty( Session("pwd") ) or      _
           ( Session("pwd") <> gEditpassword    and  _
             Session("pwd") <> gPassword ) Then
            ' Either gEditpassword or gPassowrd can enable to edit a page.
            Response.Write "<br/><center><img src='" &gIconName   & "'><form id=form1 name=form1 method=post action='" & _
                      gScript & "?a=edit&o=" & glsTopic & "&db=" & gDataSourceFile &  _
                      "'> " & gPasswordLabel & "<input type=password name=pwd id=pwd><input type=submit value=Go></form>"
                      ' "<hr><a href=mailto:lambda326@hotmail.com>Send me an E-mail </a> to get a password . For now, you can only <b>click and edit</b> <a href=wiki.asp?o=WikiSandBox>WikiSandBox</a><hr></center>"

            readonlyflag = "readonly style='font-size:8pt; background:silver; border:solid 1px '"
            disableflag  = " disabled "
        End If
    End If

    sqlQuery = "select PageData,Title, lastupdate, PrevPageData from " & gDbTableName & " where title='" & glsTopic & "'"
    EmitDebug 41, 2, "Edit query(" & sqlQuery & ")<br/>" & vbcrlf

    'set rs = gDataConn.execute(sqlQuery)
    set rs = WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007        
      
      
    dim strPageData, strTitle, strLastUpdate, strPrevPageData

    if not rs.eof then
         'page exists
          strTitle = rs("title")
          strPageData = rs("pageData")
          strLastUpdate = CStr(rs("lastupdate"))
          strPrevPageData = rs("PrevPageData")
    else
          'page does not exist
          strTitle = glsTopic
          strPageData = ""
          strLastUpdate = ""
          strPrevPageData = ""
    end if

    'If Not gHideWikiSource Then
    response.write("<form id=form1 name=form1 method=""POST"" action=""" & gScript & """>" & vbcrlf)
    response.write "<h4>Edit: <font color=blue>&nbsp;" & SpaceName(strTitle) & "</font>&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit value=Save " & disableflag & ">&nbsp;&nbsp;&nbsp;&nbsp;<input type=button value='Cancel' onclick='location.href=""" & gScriptURL & "&o=" & strTitle & """'></h4>"  & vbcrlf
    ' [MARKUS - replace virtual with hard]
    response.write("<textarea id=""pagetext""  name=""pagetext"" rows='" & giEditAreaRows & "'  " & readonlyflag &" cols='" & giEditAreaCols & _
        "'  style='width:100%'>"  & _
        Server.HtmlEncode(strPageData) & _
        "</textarea>" & vbcrlf & _
        "<br/> <input type=submit value=' Save ' " & disableflag & " >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=button value='Cancel' onclick='location.href=""" & gScriptURL & "&o=" & strTitle & """'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" & _
        "<br/></br/> "  & _
        vbcrlf & "<input type=hidden name=lupdt value='" & strLastUpdate & "'>" & _
        vbcrlf & "<input type=hidden name=o value='" & strTitle & "'>" & _
        vbcrlf & "<input type=hidden name=db value='" & gDataSourceFile & "'>" & _
        vbcrlf & "<input type=hidden name=hiddenInput value='errv2010'>" & _
        vbcrlf & "<input type=hidden name=dbname value='" & gDataSourceName & "'>" & _
        vbcrlf & "<input type=hidden name='a' value='save'>" & vbcrlf )
 
    'End If
    
    If gHideWikiSource then
       'Do not show previous versions.
       exit sub
    end if
    
    If disableflag <> "" Then
       exit sub
    end if



    ' History of changes will display previous versions of the wiki page.  Just in case you have to restore something.
    '
    response.write("<br><br><br><br><br><h3>History of Changes:</h3><textarea readonly style='font-size:8pt; background:silver;' rows='" & giEditAreaRows & "' cols='" & giEditAreaCols & _
    "'  style='width:100%'>" & strPrevPageData & "</textarea>")

    'Original Text
    response.Write("<textarea name=""pagetextorig"" rows=0 cols=0 style='width:0;'>" & strPageData & "</textarea></form>" )
    response.Write("<script language=javascript>form1.pagetext.rows=window.screen.height/26;</script>")

    Session("CurrentEditPage") = "# "  & strTitle 
    
end sub


sub handleSearch

  dim pageTitle, s
  's= Request.QueryString("o")  BUG - Fri, 2002 jan 22 - Dan Shaw
  s= glsTopic
  if not isEmpty(s) then
    EmitDebug 42, 2, "<br/>SEARCH(" & s & ")<br/>" & vbcrlf
    pageTitle = "Search Results (" & s & ")"
    dim myClause
    myClause= theWhereClause(s)
    sqlQuery="select ID, Title, LastUpdate , LastEditor from " & gDbTableName & myClause & " order by Title"
  end if

  EmitTabularOutput pageTitle, ""

end sub

'ElreyRonald 4/2004
Sub HandleDelete
  Dim pwd, topic, sh
  sh = "<br><a href='" & gScriptURL & "' >Click here proceed to home page</a>"
  If Request.QueryString("pw") <> gDeletePassword  Then
   Response.Write( "Authorization to delete failed" & sh)
   Response.End
  End If
  topic = Request.QueryString("o") ' Topic to delete
  If IsNull(topic) or topic = "" Then
   Response.Write( "Specify page name to delete i.e.  &o=MyPage" & sh)
   Response.End
  End If
  Dim stmnt
  stmnt = "delete from WikiData where Title='" & topic & "'"
  Set gDataConn = Server.CreateObject("ADODB.Connection")
  on error resume next
  gDataConn.Open ConnStr(1)
  on error goto 0
  on error resume next
  gDataConn.execute(stmnt)
  on error goto 0
  If  gDataConn.errors.count = 0 then
    Response.Write( "<b>" & topic & " </b> was successfully deleted. " )
  Else
    Response.Write( "<b>" & topic & " </b>  was not deleted due to some errors. " )
  End if
  Set gDataConn = nothing
  Response.write  sh
  Response.End
end sub

'ElreyRonald 4/2004
sub handleRss

  dim pageTitle, initialRow, s, sSortOrder
  dim modifiedUrl

  sqlQuery="select top " & giNumRecentFiles & " ID, LastEditor, Title,PageData,PrevPageData, LastUpdate from " & gDbTableName & " order by LastUpdate DESC"

  sqlQuery = sqlQuery & sSortOrder

  set gDataConn = Server.CreateObject("ADODB.Connection")

  on error resume next
  gDataConn.Open ConnStr(1)
  on error goto 0

  if not (0 = gDataConn.errors.count) then
    if (ADOERROR_NOFILE = gDataConn.errors(0).number) then
      EmitDebug 54, 1, "<br/>ErrorCount(" & gDataConn.errors.count & ")<br/>" & vbcrlf
      EmitDebug 55, 1, "<br/>Error(" & gDataConn.errors(0).number &") desc(" &_
      gDataConn.errors(0).description & ")<br/>" & vbcrlf
      VerifyWikiTable
    end if
  end if

  'set rs= gDataConn.execute(sqlQuery)
  set rs = WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007        
  

  modifiedUrl = Replace(gScriptURL, "&", "&amp;")
  if not rs.eof then
    response.ContentType = "text/xml"
    response.Write("<?xml version=""1.0"" encoding=""ISO-8859-1"" ?>")
    response.Write(gRssStyle)
    response.Write("<rss version=""2.0"">")
    response.Write("<channel>")
    response.Write("<title>" & SpaceName(gHomeTopic) & "</title> ")
    response.Write("<link>" & gHttpDomain & "/" & modifiedUrl &  "&amp;a=rss</link> ")
    Response.Write("<ttl>1000</ttl>")
    response.Write("<description>Latest changes and postings for the topic:" & SpaceName(gHomeTopic) & ". </description> ")
    response.Write("<copyright>Copyright (C)2003  Elrey Ronald Velicaria. All rights reserved.</copyright> ")
    response.Write("<generator> WikiAsp RSS Generator by Elrey </generator> ")
    Response.Write("<webMaster>lambda326@hotmail.com</webMaster>")
    response.Write("<image><width>80</width><height>40</height>")
    response.Write("<title>" & SpaceName(gHomeTopic) & "</title> ")
    response.Write("<link>" & gHttpDomain & "/" & modifiedUrl & "</link> ")
    If  left(gIconName,4) = "http" Then
      response.Write("<url>" &  gIconName &" </url></image>")
    Else
      response.Write("<url>" & gHttpDomain & "/" & gIconName &" </url></image>")
    End If

    Do while Not rs.eof
      If rs("Title") <> "RegisteredUsers"  Then
        Response.Write("<item>")
        Response.Write("<title>" & SpaceName(rs("Title"))&  "</title>")
        Response.Write("<link>" & gHttpDomain & "/" & modifiedUrl & "&amp;o=" & rs("Title") & "</link> ")
        Response.Write("<category>" & SpaceName(gHomeTopic) & "</category>")
        Response.Write("<author>user@" & rs("LastEditor")& "</author>")
        Response.Write("<description>")
        Response.Write( "<![CD" & "ATA[ ")
        If gHighlightFlag Then
            Response.Write(  ProcessRssItem(rs) )
        Else
            Response.Write WalkWiki(xform(  rs("PageData")  ))
        End If
        Response.Write("]]></description>")
        Response.Write("<pubDate>" & GetRFC822date(rs("LastUpdate")) & "</pubDate> ")
        Response.Write("</item>")
      End If
      rs.MoveNext
      i= i+1
    Loop

    response.Write( "</channel></rss>")
  end if
  Set gDataConn = nothing
  Set rs = nothing
end sub


'Get the nth page in History
'ElreyRonald
Function GetPrevData(rs, n)
   Dim arrD, tmpStr, i, cnt, getFlag
   Dim prevData
   prevData = rs("PrevPageData")
   If    IsNull(prevData) Then
      GetPrevData   = ""
   Else

      arrD    =  Split( rs("PrevPageData"), vbCRLF)
      cnt     = 0
      getFlag = 0
      tmpSTr  = ""
      For i = 1 to UBound(arrD)
         If left(arrD(i), 8) = "--------"   Then
            cnt = cnt + 1
            if getFlag = 1 Then Exit For
            if  n =  cnt Then
               getFlag = 1
            end if
         End If
         If getFlag = 1 and left(arrD(i), 8) <> "--------" Then
            tmpStr = tmpStr & arrD(i) & vbCRLF
         End If

      Next
      GetPrevData = tmpStr
   End If
End Function


'Process the current record (rs) for RSS
'ElreyRonald
Function    ProcessRssItem(rs)
   Dim currData, prevData, markedStr
   Dim beginMark, endMark, tmpS
   beginMark = "###s###"
   endMark  = "###e###"
   currData = rs("PageData")
   prevData = GetPrevData( rs, 1 )
   markedStr =  MarkWhatWasAdded( prevData, currData, beginMark , endMark)
   tmpS = WalkWiki(xform(markedStr))
   tmpS = Replace( tmpS, beginMark, "<U style='background:yellow' >")
   tmpS = Replace( tmpS, endMark,   "</U>")
   ProcessRssItem = tmpS
End Function

Function MarkWhatWasAdded( prevData, currData, st, en)
Dim arrCurrData, arrPrevData
Dim currMaxIndex
Dim prevMaxIndex, i
arrCurrData  = Split( currData, vbCRLF)
arrPrevData  = Split( prevData, vbCRLF)
currMaxIndex =  UBound( arrCurrData )
prevMaxIndex =  UBound( arrPrevData )
If  prevMaxIndex <  0 Then
  MarkWhatWasAdded = currData
  Exit Function
End If

Dim marked, prevPtr, started
marked =    0
prevPtr = 0
started = 0
'Search delta forward
For i = 0 to prevMaxIndex
   If lTrim(rtrim(arrPrevData(i))) <> "" Then Exit For
Next
prevPtr = i  'start here
For i   = 0 to currMaxIndex
   If lTrim(rtrim(arrCurrData(i))) = "" and started = 0Then

   Else
      Started = 1
      If    prevPtr <=  prevMaxIndex Then
         If arrCurrData(i)  <>  arrPrevData( prevPtr) Then
            if ( i > 0 ) then
               if arrCurrData(i-1) = "" Then
                 arrCurrData(i-1)   =  vbCRLF & arrCurrData(i-1) & st
               else
                 arrCurrData(i-1)   = arrCurrData(i-1) & st
               end if
            else
               arrCurrData(i)   = st &   vbCRLF & arrCurrData(i)
            end if
            marked =    1
            Exit For
         End If
         prevPtr = prevPtr + 1
         if prevPtr >  prevMaxIndex and i < currMaxIndex then
            arrCurrData(i)  = arrCurrData(i+1) & st
            marked = 1
            exit for
         end if
      End If
   End If
Next

If  marked =    0 Then
   MarkWhatWasAdded = currData
   exit function
End If

'Search delta Backwards
For i = prevMaxIndex to 0 step -1
   If lTrim(rtrim(arrPrevData(i))) <> "" Then Exit For
Next
Dim pi
pi  = i
started = 0
For i   = currMaxIndex  to  0 step -1
  If lTrim(rtrim(arrCurrData(i))) = "" and started = 0Then
     ' do nothing
  Else
    Started  = 1
    If  pi  >= 0 Then
      'Response.Write "backward Compare " & Cstr(i) & "-" & Cstr(pi) &" [" &arrCurrData(i) & "]=["& arrPrevData(pi) & "] " &    vbCRLF
      If    arrCurrData(i)  <>  arrPrevData(pi) Then
         arrCurrData(i) = arrCurrData(i) & en
         Exit For
      End If
      pi    = pi - 1
      if pi < 0 and i > 0 then
         arrCurrData(i-1)   = arrCurrData(i-1) & en
         exit for
      End if
    End If
  End If
Next

Dim sres
sres = ""
For i   = 0 to currMaxIndex
   sres = sres  & arrCurrData(i) & vbCRLF
Next
MarkWhatWasAdded = sres

End Function




sub handleList

  dim pageTitle, initialRow, s, sDirection, sSortOrder, sNextDirectionTitle, sNextDirectionDate
  ' Request.ServerVariables("HTTP_REFERER")

  initialRow= ""
  s = Request.QueryString("o")
  EmitDebug 43, 2, "<br/>" & s & "<br/>" & vbcrlf
  if (s = "recent") then
    pageTitle = "Recently Modified Topics"
    sqlQuery="select top " & giNumRecentFiles & " ID, Title, LastUpdate, LastEditor from " & gDbTableName & " order by LastUpdate DESC"
  else
    pageTitle = "List of All Topics"
    sqlQuery= "select ID, Title, LastUpdate , LastEditor from " & gDbTableName & " order by "
    sDirection = Request.QueryString("d")

    if (s = "ByDate") then
      sqlQuery = sqlQuery & "LastUpdate "
      if (sDirection = "down") then
    sSortOrder = ""  ' the reverse natural sort order (oldest first)
    sNextDirectionDate= ""
      else
    sSortOrder = "DESC"  ' the natural sort order (most recent first)
    sNextDirectionDate= "&d=down"
      end if
    elseif (s = "ByTitle") then
      sqlQuery = sqlQuery & "Title "
      if (sDirection = "down") then
    sSortOrder = "DESC"   ' the reverse natural sort order (alphabetic)
    sNextDirectionTitle = ""
      else
    sSortOrder = ""   ' the natural sort order (alphabetic)
    sNextDirectionTitle = "&d=down"
      end if
    end if

    sqlQuery = sqlQuery & sSortOrder


    'initialRow= "<tr style='background-color:White;'> <td></td><td align='right'><a href='" & gScript & "?a=list&o=ByTitle" & sNextDirectionTitle & "'>Sort</a></td> <td align='right'><a href='" & gScript & "?a=list&o=ByDate" & sNextDirectionDate & "'>Sort</a></td></tr>"
    initialRow= "<tr style='background-color:White;'> <td></td><td align='right'><a href='" & gScriptURL & "&a=list&o=ByTitle" & sNextDirectionTitle & "'>Sort by Title</a></td> <td align='right'><a href='" & gScriptURL & "&a=list&o=ByDate" & sNextDirectionDate & "'>Sort by Date</a></td></tr>"


  end if

  EmitTabularOutput pageTitle, initialRow

end sub



sub EmitTabularOutput(pageTitle, initialRow)

  EmitDebug 44, 2, "<br/>query(" & sqlQuery & ")<br/>" & vbcrlf
  
  'set rs= gDataConn.execute(sqlQuery)
  set rs = WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007        
  

  if not rs.eof  then
    Response.write("<h2>" & pageTitle & ":</h2><table cellpadding=5  cellspacing=0 border=0 >" & vbcrlf)
    i = 1
    if not isEmpty(initialRow) then
      Response.write initialRow & vbcrlf
    end if
    Do while (Not rs.eof )
      if (i mod 2 = 0) then
          Response.Write("<tr style=""background-color:whitesmoke;"">")
      else
          Response.Write("<tr style=""background-color:lightcyan;"">")
      end if

      Dim deleteColumn
      deleteColumn = ""

      ' gDelete is only passed on querystring
      If Request.QueryString("pw") = gDeletePassword  Then
          deleteColumn = "<td class='tabular'><a href=""" & gScriptURL & "&o=" & rs("Title")&"&a=del&pw=" & gDeletePassword   & """> del </td>" 
      End If


      if rs("Title") <> "RegisteredUsers" then
        Response.Write("<td class='tabular'>" & i & ".</td><td class='tabular'><a href=""" &_
                    gScriptURL & "&o=" & rs("Title") & """>" & rs("Title") & "</a></td> <td class='tabular'>" & _
                    rs("LastUpdate") & " by " & rs("LastEditor")& "</td>" &  deleteColumn & _
                    "</tr>" &  vbcrlf)
        i= i+1
      end if
      rs.MoveNext
    Loop
    Response.write("</table>" & vbcrlf)
  else
    Response.write("<h2>" & pageTitle & ":</h2><table style='border: 1px solid gainsboro'>" & vbcrlf)
    Response.write("<tr><td>This topic is not mentioned on any other page! </td></tr>" & vbcrlf)
    Response.write("</table>" & vbcrlf)
  end if

  response.write "</td></tr><tr bgcolor='#CCCCCC'><td><br>"
  response.write "<a href='" & gScriptURL & "'>Home</a> | "
  response.write "<a href='" & gScriptURL & "&a=list&o=ByTitle' title='this may take a loooong time'>List all pages</a> |  "
  response.write "<a href='" & gScriptURL & "&a=list&o=recent'>List Recently modified pages</a>&nbsp;&nbsp;&nbsp;&nbsp;"
  response.write "<form method='POST' action=""" & gScript & """ id=""form1"" name=""form1"">Search for: <input title='Type in your search terms and press [Enter]' type='text' name='o' value=''/><input type='hidden' name='db' value='"& gDataSourceFile & "'><input type='hidden' name='dbname' value='" & gDataSourceName & "'><input type='hidden' name='a' value='search'></form>"
  response.write "<center><font size='1'>WikiAsp Engine version:  " & gEngineVersion & "</font></center>" & vbcrlf
end sub


sub handleSave
  if gDisableSave = true then
    response.write "<br/> Sorry, save is disabled."
    exit sub
  end if

  dim sText, dts, sLupdt
  dim sChanges, sTextOrig
  sText=request.Form("pagetext")
  sTextOrig=request.Form("pagetextorig")
  sLupdt=request.Form("lupdt")  ' last update (ElreyRonald)


  Dim lastPageEdited
  if IsEmpty (Session("CurrentEditPage") ) Then
        lastPageEdited = "*"
     response.write "bb"        
    '      Exit Sub
  else
       response.write "cc"
    lastPageEdited =Session("CurrentEditPage")
  end if

  If not IsRequestFromWikiASPPage Then
     response.write("1:>" & remoteIPHost & " - " & remoteIPAddr  )
     response.end
     exit sub
  End if

  If IsRemoteAdressBlackListedRE Then
     response.write("2:>" & remoteIPHost & " - " & remoteIPAddr  )
     exit sub
  End if

  If IsRemoteBlackListed Then
     response.write("3:>" & remoteIPHost & " - " & remoteIPAddr  )
     exit sub
  End if

  If not gPersistPassword Then 
    Session("pwd") = ""
         response.write "dd"
  End If

  sqlQuery = "select Title,PageData, lastupdate , PrevPageData, LastEditor from " & gDbTableName & " where title='" & glsTopic & "'"
  EmitDebug 45, 2, "<br/>save-check query(" & sqlQuery & ")<br/>" & vbcrlf


  'set rs = gDataConn.execute(sqlQuery)
  set rs = WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007          
  
  dts = Now

       response.write "ee"
       
  'update record
  if not rs.eof then


       response.write "ff"

      EmitDebug 46, 2, "Record already exists....<br/>" & vbcrlf

      ' check if someone has updated the record while you were editing (ElreyRonald)
      if  Trim(Cstr( rs("lastupdate"))) <> Trim(sLupdt) then
        response.write("<html><head></head><body>")
        Response.Write(  "["& Trim(Cstr( rs("lastupdate"))) & "]["& Trim(sLupdt)& "]<br>" )
        Response.Write("<b>Sorry! That page is being edited by another user or is in the process of being saved. <br>Your changes were not saved.</b>" )

        response.write( "<br><br> <a href='" & gScriptURL & "&a=edit&o=" & glsTopic & "'>Click here to re-edit the page. </a>" )
        response.end
      else

      ' consolidate a series of trailing vbcrlf to just 2.
      gRE.Pattern = "(\r\n){3,}$"
      sText=gRE.Replace(sText, vbcrlf & vbcrlf)

      ' replace 8 spaces with tab (ElreyRonald)
      sText = replace(sText, vbcrlf & "        *", vbcrlf & chr(9) & "*" )
      sText = replace(sText, vbcrlf & chr(9) & " :        ", vbcrlf & chr(9)& " :" & chr(9) )

      If abs( len(sText) - len(sTextOrig) ) > 10 Then
        sChanges =  vbcrlf & vbcrlf & "@@@@@@@@@@@@@@@@" & rs("lastupdate") & " : " & _
          rs("lasteditor") & "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" & vbcrlf & vbcrlf &  rs("PageData")  & rs("PrevPageData")
        sChanges =  left(sChanges, 15000)
      else
        sChanges = rs("PrevPageData")
      End if

      sqlQuery = "UPDATE " & gDbTableName & " SET PageData='" &_
      safeQuote(sText) & "',PrevPageData='" & safeQuote(  sChanges   ) &_
      "',LastUpdate='" & dts & "', LastEditor='" & remoteIPHost  &_
      "'  WHERE title='" & rs("title") & "'"


      EmitDebug 47, 1, "update sqlQuery(" & sqlQuery & ")<br/>"
      
      'gDataConn.execute(sqlQuery)

      call WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007        
      
      
      end if
      ' new record
  else

     
      EmitDebug 48, 2, "Record does not exist, inserting...." & vbcrlf
      sqlQuery = "INSERT INTO " & gDbTableName & " (Title,PageData,LastEditor,LastUpdate) " & _
      "VALUES ('" & glsTopic   & "', '" & safeQuote(sText) & "', '" & remoteIPHost   &_
       "', '" & dts & "')"
      EmitDebug 49, 1, "<br/>sqlQuery(" & sqlQuery & ")<br/>"
      
      'gDataConn.execute(sqlQuery)

      call WrappedQueryExecute( gDataConn, sqlQuery )  ' ERV 3/2007        
      
      
  end if

  ' direct to the newly saved page :
  'Response.Redirect gScript & "?" & glsTopic
  Response.Redirect gScriptURL & "&o=" & glsTopic

end sub


Sub HandleBrowse

  Dim WrdArray  
  Dim PwdArray 
  Dim LblArray 
  Dim k
  Dim Found
  Dim FoundPwd
  Dim FoundLbl
  Dim dbsrc
  Dim dbpwd
  Dim dblbl
  
  Found = 0
  FoundPwd = ""

  WrdArray = Split(gHiddenDbs, ",")
  PwdArray = Split(gHiddenPwd, ",")
  LblArray = Split(gHiddenLbl, ",")
  

  k =0
  for each dbsrc  in WrdArray
    k = k + 1
	if  dbsrc = gDataSourceFile Then Found = k
  next
  k = 0
  for each dbpwd  in PwdArray
    k = k + 1
	if  k = Found Then FoundPwd = dbpwd
  next
  k = 0
  for each dblbl  in LblArray
    k = k + 1
	if  k = Found Then FoundLbl = dblbl
  next
  

  ' Prevent this page from being viewed
  if not IsEmpty(Request.Form( gDataSourceFile )) then Session(gDataSourceFile) = Request.Form(gDataSourceFile)
 
  if Found > 0 Then
  
	if Session(gDataSourceFile)  <> FoundPwd then
	 
			Response.Write "<br/><center><img src='" &gIconName   & "'><form id=form1 name=form1 method=post action='" & _
						  gScript & "?o=" & glsTopic & "&db=" & gDataSourceFile &  _
						  "'> " & FoundLbl & " <input type=password name=" & gDataSourceFile & " id=" & gDataSourceFile & "><input type=submit value=Go></form>"
			'Get password
			Exit Sub
	End If
  
  End If

  

  ' Prevent this page from being viewed.
  if not IsEmpty(Request.Form("pwd")) then Session("pwd") = Request.Form("pwd")
  if glsTopic = "RegisteredUsers" then
     If  IsEmpty( Session("pwd")) or  Session("pwd") <> gPassword then
       exit sub
     End If
  end if

  sqlQuery = "select PageData,Title,LastEditor,LastUpdate from " & gDbTableName & " where title='" & glsTopic & "'"
  EmitDebug 50, 2, "Browse query(" & sqlQuery & ")<br/>" & vbcrlf

  set rs = gDataConn.execute(sqlQuery)

  if rs.eof=true then
    response.write("Sorry! The page --> <b>" &  glsTopic & "</b>  <--- is not existing or it is a page that must be created </h4>")
    response.write( "<br><a href='" & gScriptURL & "&a=edit&o=" & glsTopic & "'>Click this link to create this page.</a>" )
    response.write( "<br><br><a href='" & gScriptURL & "'>No,  don't create it.</a>" )

  else
      EmitDebug 51, 3, "found...(" & rs("PageData") & ")<br/>" & vbcrlf

      If Not gHideLogin Then
        response.write" <body ondblclick=" & chr(34) & "document.location.href='" & _
            gScriptURL & "&a=edit&o=" & glsTopic    & "'" & chr(34) &">"
      Else
         response.write" <body >"

      End If

      
      ''''''''''''''''''''''''' removed
      ' response.write "<table border='0' width='100%' cellpadding='10' cellspacing='0'><tr height=10pt ><td   class='h1background' ><h1 class='h1text'><a  href='" & gScriptURL & _
      '  "'><img src=" & gIconName & " border=0 alt='Go to Start Page'></a> "
      ' response.write "<a  title=""search for references to '" & rs("title") & "'"" href='" & gScriptURL & "&a=search&o=" & rs("title") & "'>" &  _
      '  SpaceName(rs("title")) & "</a></h1></td></tr></table>"

      Dim iconPart, bannerPart, bannerTextPart
      
      iconPart = "<a  href='" & gScriptURL & "'><img src='" & gIconName & "' border='0' alt='Go to Start Page'></a>"

      bannerTextPart =   "<a  title='Search for references to " & rs("title") & "' href='" & gScriptURL & "&a=search&o=" & rs("title") & "'>" &  SpaceName(rs("title")) & "</a>"
      
      If gBannerTemplate = "" Then
        
         bannerPart =                " <table class='cssBannerTable' id='idBannerTable' cellSpacing='0' cellPadding='0' border='0'>"
         bannerPart =  bannerPart &  "    <tr class='cssBannerRow' id='idBannerRow'> "
         bannerPart =  bannerPart &  "          <td class='cssBannerCellIcon' id='idBannerCellIcon' valign='top'> $$icon$$</td>"
         bannerPart =  bannerPart &  "          <td width=90% class='cssBannerCellText' id='idBannerCellText' valign='bottom' align='left' >"
         bannerPart =  bannerPart &  "            <h1 class='cssBannerSpanText' id='idBannerSpanText'>$$banner_text$$</h1>"
         bannerPart =  bannerPart &  "          </td>"
         bannerPart =  bannerPart &  "          <td>"
         bannerPart =  bannerPart &  "          <td class='cssTopSearch'id='idTopSearch' >"             
         If not gHideTopSearch Then
             bannerPart =  bannerPart &  "          <form method=POST action='wiki.asp?a=search&db="& gDataSourceFile &"' id=search001 name=search001 >" & gSearchLabel & "<br/><input class='cssTopSearchbox' id='idTopSearchbox' title='Click and enter search text here!' size=12 type=text name=o value='" & gDataSourceFile & "' onclick=this.value="""" /></form>&nbsp;&nbsp;&nbsp;&nbsp;"
         End If
         bannerPart =  bannerPart &  "          </td><td>&nbsp;&nbsp;&nbsp;</d>"
         bannerPart =  bannerPart &  "    </tr>"
         bannerPart =  bannerPart &  " </table>"
      
      Else
      
         bannerPart = gBannerTemplate
      End if
      
      bannerPart = Replace( bannerPart, "$$icon$$", iconPart)
      bannerPart = Replace( bannerPart, "$$banner_text$$", bannerTextPart)
      
         
      Response.Write ( bannerPart )

      response.write " <div class='wikibody'>" & WalkWiki(  xform( "<span id=bodyPrefix>" & vbcrlf & gWikiBodyPrefix & VbCrLF & "</span>" & VbCrLF &  rs("PageData")))  ' Elrey - xform func now removes html
      
      response.write "</b></i></font></u></strong></font>"

      
      dim hideScript
      hideScript = "var div1=document.getElementById('wikifooter'); if (div1) {div1.style.display='none';}"
      hideScript = hideScript & "div1=document.getElementById('bodyPrefix'); if (div1) {div1.style.display='none';}"
      hideScript = hideScript & "div1=document.getElementById('idTopSearch'); if (div1) {div1.style.display='none';}"


      If Not gHideWikiFooter Then
          response.write "<div id=wikifooter class=footer ><form method='POST' action=""" & gScript & """ id=""formFooter"" name=""formFooter""><br>"
          response.write "<hr size=1 noshade=true>"
          If Not gHideLastEditor Then
            response.write "<span title='Click this now to prepare page for Printing by removing unnecessary portions! ' onclick=""" & hideScript & """ > <font size=-1>Last Updated " & rs("LastUpdate") & " by '" & rs("LastEditor") &  "' </font></span><br/>"
          end if
          response.write "<a href='" & gScriptURL & "' title='GO TO START PAGE'>Home</a> | "
          if  Not gHideLogin Then
            response.write "<a href='" & gScriptURL & "&a=edit&o=" & rs("title") & "'>Edit page</a> | "
          end if
          response.write "<a href='" & gScriptURL & "&a=list&o=ByTitle'>List pages</a> |  "
          response.write "<a href='" & gScriptURL & "&a=list&o=recent'>Recent pages</a>"
          If gHttpDomain <> "" Then
            response.write " | <a href='" & gScriptURL & "&a=rss' ><span style='background:#FF6600;text-decoration:none;font-family:tahoma;' >&nbsp;<b><font color=white>RSS</font></b>&nbsp;</span></a>"
          End If
          
          response.write "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Search&nbsp;for:&nbsp;<input title='Type in your search terms and press [Enter]' type='text' name='o' value=''/><input type='hidden' name='db' value='"& gDataSourceFile & "'><input type='hidden' name='dbname' value='" & gDataSourceName & "'><input type='hidden' name='a' value='search'></form></div> "
          response.write "</div>"
      End If
  end if

end sub



sub handleCreate
  on error resume next
  VerifyWikiTable
  on error goto 0
  Response.Redirect gScriptURL
end sub



'Intercept RSS request here
if ( glsMode = "rss" ) then
  If ( gHttpDomain = "" ) then
    response.write("RSS is not enabled")
  Else
    handleRss
  End If
  response.End
end if
'Intercept delete request here
if ( glsMode = "del") then
  handleDelete
  response.End
end if


'********************************************************************
'*********************************************************************

%>
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
        <title>
            <%
      if not isEmpty(glsMode) and glsMode <> "browse" then
        response.write(glsMode & " ")
      end if
      response.write(SpaceName(glsTopic) & vbcrlf)
    %>
        </title>
        <LINK REL=StyleSheet HREF="<%=gStyleSheet%>" TYPE="text/css" >

<%

       Response.Write(gHtmlHeadStr)
%>


    </head>
    <body>

        <%

      if  Session("Hits") = "" then
    Session("Hits")= 1
      else
    Session("Hits")= Session("Hits") + 1
      end if

      EmitDebug 52, 1, "debug(" & gDebug & ")<br/>" & vbcrlf
      EmitDebug 53, 1, "<br/>QueryString = (" & Request.QueryString & ")<br/>" & _
    "Hits(" & Session("Hits") & ")<br/>" & _
    "mode(" & glsMode & ")<br/>" & _
    "topic(" & glsTopic & ")<br/>"

      set gDataConn = Server.CreateObject("ADODB.Connection")

      ' 21 nov - need resume next to catch "no file" error
      on error resume next
      gDataConn.Open ConnStr(1)
      on error goto 0

      if not (0 = gDataConn.errors.count) then
    if (ADOERROR_NOFILE = gDataConn.errors(0).number) then
      EmitDebug 54, 1, "<br/>ErrorCount(" & gDataConn.errors.count & ")<br/>" & vbcrlf
      EmitDebug 55, 1, "<br/>Error(" & gDataConn.errors(0).number &") desc(" &_
        gDataConn.errors(0).description & ")<br/>" & vbcrlf
      VerifyWikiTable
    end if
      end if

    select case (glsMode)
		case "edit"    handleEdit
		case "list"    handleList
		case "search"  handleSearch
		case "create"  handleCreate
		case "save"    handleSave
		case "browse"  handleBrowse
		case else
    end select

      EmitDebug 56, 2, "<br/>done...<br/>" & vbcrlf
      gDataConn.Close()
      set gDataConn = nothing
    %>

<% Response.Write(gFooterHtml) %>
<% Response.Flush  %>
