' CdN MIDIA STUDIO FOR COLOUR MAXIMITE

Mode 1

Dim File$(255) length 12
Dim GD$(20) length 255
Dim TP$(5) LENGTH 3
Dim Vol(4)
Dim Ton(4)
Dim AYMusA$(3),AYMusB$(3), Chan$(3)

Chan$(0)="00"
Chan$(1)="01"
Chan$(2)="10"
Chan$(3)="11"

Prg$ = "CdN Media Studio - v0.2"
Author$ = "Mauro Xavier - 2018"
CP$="": DirCP$=""

sel=1: selant=1: GFX=0
xf=0: yf=0: xfant=0: yfant=0
maxx=MM.HRes-1
maxy=MM.VRes-1

' READ KEYBOARD IN THE COORDINATES WITH A MASK
Function ReadKey$(xk,yk,rant$,max,ex)
 RK$=rant$
 ext$=Right$(RK$,Len(RK$)-Instr(1,RK$,"."))
 If ex=1 Then RK$=Left$(rant$,Instr(1,RK$,".")-1)
 Do While I$<>Chr$(13) And I$<>Chr$(27)
  I$ = Inkey$
  If ex=0 Then
   Print@(xk,yk) RK$+"_ "
  Else
   Print@(xk,yk) RK$+"_." + ext$ + " "
  EndIf
  If UCase$(I$)>Chr$(32) And UCase$(I$)<Chr$(127) And Len(RK$)<max Then
   RK$=RK$+UCase$(I$)
  EndIf
  If I$=Chr$(8) Then
   If Len(RK$)>0 Then RK$=Left$(RK$,Len(RK$)-1)
  EndIf
  If I$=Chr$(27) Then
   RK$=""
   If ex=1 Then max=max+4
   ex=0
  EndIf
 Loop
 ReadKey$=RK$
 If ex=1 Then ReadKey$=RK$+"."+ext$
 Print@(xk,yk) String$(max+2," ")
End Function

' SHOW INFERIOR MENU
Function ShowMenu(Menu)
 Line(0,maxy-55)-(maxx,maxy-12),0,BF
 ShowMenu = 0
 ScanLine White,0,MaxY
 Line(0,maxy-56)-(maxx,maxy-56)
 ScanLine Yellow,MaxY-56,MaxY-56
 ScanLine Cyan,MaxY-53,MaxY-8
 ScanLine Green,MaxY-8,MaxY
 yt=maxy-8: Dig=0
 Print@(0,yt) Prg$
 Print@(maxx-Len(Author$)*6,yt) Author$
 yt=maxy-50
 If Menu=0 Then
  Print@(0,yt) "ENTER: Select": yt=yt+12
  Print@(0,yt) "ESC:   Exit": yt=yt+12
  Print@(0,yt) "Del:   Delete": yt=yt+12
  yt=maxy-50
  Print@(120,yt) "F1:  About": yt=yt+12
  Print@(120,yt) "F2:  Rename": yt=yt+12
  yt=maxy-50
  Print@(240,yt) "C: Copy ";CP$;String$(12-Len(CP$)," "): yt=yt+12
  Print@(240,yt) "P: Paste": yt=yt+12
  Print@(240,yt) "M: Move": yt=yt+12
  yt=maxy-50
  Print@(maxx-66,yt) "Dir:   " : yt=yt+12
  Print@(maxx-66,yt) "Files: " : yt=yt+12
 ElseIf Menu=1 Then
  Print@(0,yt) "Choose Screen Mode: ": yt=yt+12
  Print@(0,yt) "1:  Mono High Def   ": yt=yt+12
  Print@(0,yt) "2:  8 Colors Low Def": yt=yt+12
  Do While ShowMenu=0
   I$ = Inkey$
   If I$="1" Then ShowMenu=1
   If I$="2" Then ShowMenu=4
  Loop
 ElseIf Menu=2 Then
  Print@(0,yt) "Are you sure you want to delete file ";file$(sel);" (Y/N)?"
  yt=yt+12
  Do While ShowMenu=0
   I$ = Inkey$
   If UCase$(I$)="Y" Then ShowMenu=1
   If UCase$(I$)="N" Or I$=Chr$(27) Then ShowMenu=2
  Loop
 EndIf
End Function

' READ FOLDERS AND FILES
ReadDir:
Cls
tt=ShowMenu(0)
F$=Dir$("*.*",DIR)
sl=0: xs=0: ys=0: DirQt=0
Do While F$ <> ""
 sl=sl+1
 File$(sl)=f$
 Print@(xs,ys) "["+f$+"]"
 ys=ys+12
 If ys>maxy-64 Then
  xs=xs+100: ys=0
 EndIf
 DirQt=DirQt+1
 f$=Dir$()
Loop
TP$(1)="BMP"
TP$(2)="VGM"
TP$(3)="SPR"
TP$(4)="FNT"
FileQt=0
For T = 1 To 4
 F$=Dir$("*."+TP$(T),FILE)
 Do While F$ <> ""
  sl=sl+1
  File$(sl)=f$
  Print@(xs,ys) f$
  ys=ys+12
  If ys>maxy-64 Then
   xs=xs+100: ys=0
  EndIf
  FileQt=FileQt+1
  f$=Dir$()
 Loop
Next T

yt=maxy-50
Print@(maxx-66,yt) "Dir:   " DirQt  : yt=yt+12
Print@(maxx-66,yt) "Files: " FileQt : yt=yt+12
max=sl

FileSelect:
 TPFound=0
 For T=1 To 4
  If Right$(file$(sel),3)=TP$(T) Then
   Print@(xf,yf,2) file$(sel)
   TPFound=1
  EndIf
 Next T
 If TPFound=0 Then
  Print@(xf,yf,2) "["+file$(sel)+"]"
 EndIf

 TPFound=0
 For T=1 To 4
  If Right$(file$(selant),3)=TP$(T) Then
   Print@(xfant,yfant,0) file$(selant)
   TPFound=1
  EndIf
 Next T
 If TPFound=0 Then
  Print@(xfant,yfant,0) "["+file$(selant)+"]"
 EndIf

 Pause(5)
 I$=UCase$(Inkey$)

 ' EXIT PROGRAM
 If I$=Chr$(27) Then Cls: End

 ' SELECT FILE
 If I$=Chr$(13) Then GoTo Action: EndIf

 ' RUN VGM DIGITAL FILE (DOESN'T WORK)
 If UCase$(I$)="V" Then Dig=1: GoTo Action: EndIf

 ' OPEN BMP TO SCROLL DEMO
 Scroll=0
 If I$="S" Then
  If Instr(1,file$(sel),".BMP")>0 And Len(file$(sel))>3 Then
   Scroll=1: GoTo Action
  EndIf
 EndIf

 ' COPY / PASTE / MOVE FILE
 If UCase$(I$)="C" Then
  If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
   CP$=file$(sel)
   DirCP$=Cwd$+"\"
   tt=ShowMenu(0)
  EndIf
 EndIf
 If UCase$(I$)="P" Or UCase$(I$)="M" Then
  If CP$<>"" Then
   Copy DirCP$+CP$ To Cwd$+"\"+CP$
   If UCase$(I$)="M" Then
    Kill DirCP$+CP$
   EndIf
   CP$="": DirCP$=""
   Cls
   GoTo ReadDir
  EndIf
 EndIf

 ' DELETE FILE
 If I$=Chr$(127) Then
  If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
   TT=ShowMenu(2)
   If TT<>1 Then
    TT=ShowMenu(0)
   ElseIf TT=1 Then
    Kill DirCP$+file$(sel)
    sel=1: selant=1
    xf=0: yf=0: xfant=0: yfant=0
    GoTo ReadDir
   EndIf
  EndIf
 EndIf

 ' ABOUT
 If I$=Chr$(145) Then GoTo About

 ' RENAME FILE
 If I$=Chr$(146) Then
  If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
   Ren$=ReadKey$(xf,yf,file$(sel),8,1)
   If Ren$<>"" Then
    Name file$(sel) As Ren$
    GoTo ReadDir
   EndIf
  EndIf
 EndIf

 ' UP
 If I$=Chr$(128) Or I$=Chr$(136) Then
  selant=sel
  xfant=xf: yfant=yf
  yf=yf-12-12*(Asc(I$)-128)
  sel=sel-1-(Asc(I$)-128)
  If yf<0 Then
   xf=xf-100: yf=maxy-71:sel=yf/12+(xf/100)*31+1
   If xf<0 Then
    xf=0: sel=1: yf=0
   EndIf
  EndIf
 EndIf

 ' DOWN
 If I$=Chr$(129) Or I$=Chr$(137) Then
  selant=sel
  xfant=xf: yfant=yf
  sel=sel+1+(Asc(I$)-129)
  yf=yf+12+12*(Asc(I$)-129)
  If yf>maxy-64 Then xf=xf+100: yf=0: sel=(xf/100)*31+1
  If sel>max Then
   sel=max
   yf=(max-(xf/100)*31)*12-12
  EndIf
 EndIf

 ' RIGHT
 If I$=Chr$(131) Then
  selant=sel
  xfant=xf: yfant=yf
  sel=sel+31
  If sel>max Then
   sel=sel-31
  Else
   xf=xf+100
  EndIf
 EndIf

 ' LEFT
 If I$=Chr$(130) Then
  selant=sel
  xfant=xf: yfant=yf
  sel=sel-31
  If sel<0 Then
   sel=sel+31
  Else
   xf=xf-100
  EndIf
 EndIf

GoTo FileSelect

About:
 For T=0 To 42
  BLIT 0,maxy-52,0,maxy-53,maxx,53
  ScanLine Cyan,MaxY-T,MaxY
  ScanLine Green,MaxY-T-8,MaxY-T
T$="This is a Media editor for game development"
  Print@(0,maxy-T+3) T$
T$="You can open, edit and create BMP, sprite and font files"
  Print@(0,maxy-T+15) T$
T$="To play corretly VGM files you need a specific hardware"
  Print@(0,maxy-T+27) T$
 Next T
 Do While Inkey$ = ""
 Loop
GoTo ReadDir

' TRY TO ERASE FLASH DRIVE - DOESN'T WORK - BE CAREFUL
Sub EraseFlash
 F$=Dir$("*.*",DIR)
 Do While F$ <> ""
  sl=sl+1
  File$(sl)=f$
  Print@(xs,ys) "["+f$+"]"
  ys=ys+12
  If ys>maxy-64 Then
   xs=xs+100: ys=0
  EndIf
  DirQt=DirQt+1
  f$=Dir$()
 Loop

End Sub

' VERIFY THE FILE TYPE AND MAKE A ACTION
Action:
 BMPMode=0
 If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
  CP$="": DirCP$=""
 EndIf
 ' VGM
 If Right$(file$(sel),3)="VGM" Then
  Music$=file$(sel)
  ' SEACH TO A BMP WITH SAME VGM FILE NAME
  F$=Dir$("*.BMP",FILE)
  ShowImage$=""
  Do While F$ <> ""
   If Left$(F$,Instr(1,F$,".")-1)+".VGM" = Music$ Then
    ShowImage$=Left$(F$,Instr(1,F$,".")-1)+".BMP"
   EndIf
   f$=Dir$()
  Loop
  GoTo VGMInit
 ' BMP
 ElseIf Right$(file$(sel),3)="BMP" Then
  Mode 4
  BMPMode=1
  Cls
  If scroll=0 Then
   LoadBMP file$(sel),0,0
  Else
   BMPScroller(file$(sel))
  EndIf
  Do While Inkey$ <> Chr$(13)
  Loop
  Do While I$ <> Chr$(27) And I$ <> Chr$(13)
   I$ = Inkey$
  Loop
  Mode 1: Cls
  GoTo ReadDir
 ' SPR
 ElseIf Right$(file$(sel),3)="SPR" Then
  Mode 4: Cls
  ' SEARCH FOR THE MAX SPRITE NUMBER
  Open file$(sel) For INPUT As #1
  For T=1 To 5
   Line Input #1,Max$
   I=Instr(1,Max$,",")
   If I>0 Then
    MaxSpr=Val(Right$(Max$,Len(Max$)-I))
   EndIf
  Next T
  Close #1
  Sprite Load file$(sel)
  xsp=2:ysp=2
  For T=1 To MaxSpr
   Print@(xsp+13,ysp+3) T
   Line(xsp-2,ysp-2)-(xsp+32,ysp+17),Blue,B
   Sprite Paste T,xsp,ysp
   ysp=ysp+19
   If ysp+18>MM.VRes Then xsp=xsp+34: ysp=2
  Next T
  Do While Inkey$ <> Chr$(13)
  Loop
  Do While I$ <> Chr$(27) And I$ <> Chr$(13)
   I$ = Inkey$
  Loop
  Sprite Unload
  Mode 1: Cls
  GoTo ReadDir
 ' FNT
 ElseIf Right$(file$(sel),3)="FNT" Then
  TT=ShowMenu(1)
  Mode TT: Cls
  ' SEARCH FOR THE MIN AND MAX FONT NUMBER
  Open file$(sel) For INPUT As #1
  For T=1 To 15
   Line Input #1,Max$
   I=Instr(1,Max$,",")
   If I>0 Then
    Max$=Right$(Max$,Len(Max$)-I)
    I=Instr(1,Max$,",")
    Max$=Right$(Max$,Len(Max$)-I)
    I=Instr(1,Max$,",")
    MaxFnt=Val(Right$(Max$,Len(Max$)-I))
    MinFnt=Val(Left$(Max$,Len(Max$)-I))
   EndIf
  Next T
  Close #1
  Font Load file$(sel) As #5
  xsp=2:ysp=2
  Font #5
  Cls
  For T=MinFnt To MaxFnt
   Print Chr$(T);
  Next T
  Do While Inkey$ <> Chr$(13)
  Loop
  Do While I$ <> Chr$(27) And I$ <> Chr$(13)
   I$ = Inkey$
  Loop
  Font #1
  Font Unload #5
  Mode 1: Cls
  GoTo ReadDir
 Else
  ' CHANGE DIR
  Chdir file$(sel)
  sel=1: selant=1
  xf=0: yf=0: xfant=0: yfant=0
  GoTo ReadDir
 EndIf

Sub SendByte(Num)
 If Num>0 Then
  Pin(30)=1
  Port(22,8)=Num
  Pin(30)=0
  Pause(0.1)
  Pin(30)=1
 EndIf
End Sub

' SEND BYTE FOR CMM V45 FIRMWARE - PORT COMMAND BUG
Sub SendByteV45(Num)
 A$ = Bin$(Num)
 B$ = String$(8-Len(A$),"0")+A$
 Pin(30)=1
 For T = 0 To 7
  Pin(22+T) = Val(Mid$(B$,8-T,1))
 Next T
 Pin(30)=0
End Sub

' CHANGE VGM FILE MUSIC SPEED
Sub ChangeSpeed(xx)
 Clock=3579545
 SRate  = 44100
 SampleTick = (Clock / Srate) / 100
 'SampleTick = 0.0811687075
 'Sample = 2.267573696
 'Sample = 3.5
 Wait60 = (1000/(SRate/735))/(xx+0.7)
 Wait50 = (1000/(SRate/882))/(xx+0.7)
 SWait  = (1000/(SRate/1))/(xx+0.7)
 If BMPMode=0 Then Print@(0,12*13,0) "Speed:            ";xx;"x    "
End Sub

' SILENCE PSG
Sub Silence
 Pin(30)=1
 SendByte(&H9F)
 SendByte(&HBF)
 SendByte(&HDF)
 SendByte(&HFF)
End Sub

' SEEK HEADER CHAR TYPE
Function SeekHeaderChar$(H,size)
 Seek #1,H+1
 SeekHeaderChar$ = Input$(size,#1)
End Function

' SEEK HEADER INT NUMBER
Function SeekHeaderInt(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #1, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#1)))
 Next S
 SeekHeaderInt = Val("&H"+Temp$)
End Function

' BMP HEADER AND INFORMATION
Sub BMPHeader
 hy=0
 BMPIdent = SeekHeaderInt(hy,2): hy=hy+2
 BMPFileSize = SeekHeaderInt(hy,4): hy=hy+4
 hy=hy+4
 BMPOffSet = SeekHeaderInt(hy,4): hy=hy+4
 BMPHeadSize = SeekHeaderInt(hy,4): hy=hy+4
 BMPWidth = SeekHeaderInt(hy,4): hy=hy+4
 BMPHeight = SeekHeaderInt(hy,4): hy=hy+4
 hy=hy+2
 BMPBits = SeekHeaderInt(hy,2): hy=hy+2
 BMPCompress = SeekHeaderInt(hy,4): hy=hy+4
 If BMPCompress <> 0 Then
  Error "BMP Compression Unsupported :"+Str$(BMPCompress)
 EndIf
 BMPSize = SeekHeaderInt(hy,4): hy=hy+4
 hy=hy+8
 BMPColours = SeekHeaderInt(hy,4): hy=hy+4
 BMPHOffset = 14+40+4*BMPColours
 'Print@(100,100) BMPWidth;"x";BMPHeight;":";BMPBits;"b C";BMPColours
End Sub

' ALTERNATIVE BMP READER
Sub BMPScroller(bmp$)
 Open bmp$ For INPUT As #1
 BMPHeader
 BSeek=BMPHOffset
 If BMPHeight > MM.VRes Then
  Dif=BMPHeight-MM.VRes
  Bseek=BMPOffset+BMPWidth*Dif
  BMPHeight=14+40+4*16+Lof(#1)/(BMPWidth/2)
 EndIf
 'Seek #1, BSeek+1
 Seek #1, 14+40+4*16+1
 If BMPBits=4 Then
  WA=BMPWidth/2
  WB=BMPWidth
  HA=BMPHeight/2
  For BX = 1 To HA
   BA$=Input$(BMPWidth,#1)
   For BY = 1 To WA
     Pixel(239,BY*2+1)=Asc(Mid$(BA$,BY+1,1))/16
     Pixel(239,BY*2)=Asc(Mid$(BA$,BY,1)) Mod 8
   Next BY
   BLIT 1,0,0,0,239,WB
   For BY = WA+1 To WB
     Pixel(239,BY*2+1-WB)=Asc(Mid$(BA$,BY+1,1))/16
     Pixel(239,BY*2-WB)=Asc(Mid$(BA$,BY,1)) Mod 8
   Next BY
   BLIT 1,0,0,0,239,WB
  Next BX
 EndIf
 If BMPBits=24 Then
  For BY = BMPHeight To 1 Step -1
   For BX = 1 To BMPWidth Step 1
     T$=Input$(3,#1)
     R=Asc(Left$(T$,1))
     B=Asc(Mid$(T$,2,1))
     G=Asc(Right$(T$,1))
     If R>128 Then R=1 Else R=0
     If G>128 Then G=1 Else G=0
     If B>128 Then B=1 Else B=0
     Pixel(BX,BY)= R*4+G*2+B
   Next BX
  Next BY
 EndIf
 Close #1
End Sub

' SEEK HEADER HEXA
Function SeekHeaderHexa$(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #1, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#1)))
 Next S
 SeekHeaderHexa$ = Temp$
End Function

' SEEK HEADER BCD TYPE
Function SeekHeaderBCD$(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #1,H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#1)))
 Next S
 SeekHeaderBCD$ = Temp$
End Function

' READ GD3 HEADER
Sub ReadGD3Header
 Temp$ = ""
 For T=1 To 20
  GD$(T) = ""
 Next T
 ID=0: Jump=1
 GD3=SeekHeaderInt(&H14,4)
 If GD3=0 Then
  Return
 EndIf
 S=GD3
 Do While S < Lof(#1) And S<GD3+1000
  S=S+1
  Seek #1, S
  Temp$ = Temp$ + Input$(1,#1)
  MaxStr = Instr(1,Temp$,Chr$(0)+Chr$(0))
  If Len(Temp$) >= 255 Then
   MaxStr=255
  EndIf
  If MaxStr>0 Then
   If Jump=0 Or ID>=6 Then
    ID=ID+1
    Jump=1
   Else
    Jump=0
   EndIf
   GD$(ID)=Left$(Temp$,MaxStr-1)
   If ID<11 And Len(Temp$)>80 Then
    GD$(ID)=""
   EndIf
   MaxStr=0
   Temp$=""
  EndIf
 Loop
End Sub

' INITIATE GENERAL VGM FILE AND HEADERS
VGMInit:
ReadyPin = 36
For TT = 0 To 9
 SetPin 22+TT,8
 Pin(21+TT) = 1
Next TT
SetPin ReadyPin,2
Silence
Cls
Speed=1

Open Music$ For INPUT As #1

Clk=SeekHeaderInt(&H0C,4)
EOFoffset=SeekHeaderInt(&H04,4)
TotalSamples=SeekHeaderInt(&H18,4)
VGMoffset=SeekHeaderInt(&H34,4)
If VGMOffSet = 0 Then
 VGMOffSet = &H40
EndIf

SNFB$=SeekHeaderHexa$(&H28,2)
If SNFB$="09" Then
 SNType$ = "SEGA Videogame Integrated VDP"
ElseIf SNFB$="03" Then
 SNType$ = "SEGA Computer 3000H, BBC Micro"
ElseIf SNFB$="06" Then
 SNType$ = "SN76494, SN76496"
Else
 SNType$ = "0x" + SNFB$ +" - Not set"
EndIf

SNSR$=SeekHeaderHexa$(&H2A,1)
If SNSR$="10" Then
 SNSRType$ = "SEGA Videogame Integrated VDP"
ElseIf SNSR$="F" Then
 SNSRType$ = "SEGA Computer 3000H, BBC Micro"
Else
 SNSRType$ = "0x" + SNSR$ +" - Not set"
EndIf

SNFL$=Bin$(SeekHeaderInt(&H2B,1))
SNFL$=String$(8-Len(SNFL$),"0")+SNFL$

If Mid$(SNFL$,6,1) = "0" Then
 St$ = "Yes"
Else
 St$ = "No"
EndIf

If Mid$(SNFL$,5,1) = "0" Then
 ClkDiv$ = "On"
Else
 ClkDiv$ = "Off"
EndIf

LOffSet   = SeekHeaderInt(&H1C,4)
LSamples  = SeekHeaderInt(&H20,4)
LBase     = SeekHeaderInt(&H7E,1)
LModifier = SeekHeaderInt(&H7F,1)

If LModifier <> 0 Or Lbase <> 0 Then
 NumLoops = Abs(LModifier - LBase)
Else
 NumLoops = -1
EndIf

GD3 = SeekHeaderInt(&H14,4)
ReadGD3Header

' VGM INFO
Print "File Type:         "; SeekHeaderChar$(&H00,4)
Print "File Name:         "; Music$
Print "File Size:        ";  Lof(#1);" bytes"
Print "EOF offset:       ";  EOFoffset
Print "VGM offset:       ";  VGMoffset
Print "Version:           "; SeekHeaderBCD$(&H08,4)
Print "Total Samples:     "; Format$(TotalSamples,"%.0f")
Print "Loop Offset:       "; Format$(LOffset,"%.0f")
Print "Loop Samples:      "; Format$(LSamples,"%.0f")
Print "Loop Base:         "; Format$(LBase,"%.0f")
Print "Loop Modifier:     "; Format$(LModifier,"%.0f")
Print "Loops:             "; Format$(NumLoops,"%.0f")
Print "GD3 Offset:       ";  GD3
Print
Print
' GD3 TAGS
If Len(GD$(1))>2 Then
 Print "Track Name:        "; GD$(1)
EndIf
If Len(GD$(2))>2 Then
 Print "Game Name:         "; GD$(2)
EndIf
If Len(GD$(3))>2 Then
 Print "System Name:       "; GD$(3)
EndIf
If Len(GD$(4))>2 Then
 Print "Orig. Trk Author:  "; GD$(4)
EndIf
If Len(GD$(5))>2 Then
 Print "Game Release Date: "; GD$(5)
EndIf
If Len(GD$(6))>2 Then
 Print "VGM Converted by:  "; GD$(6)
EndIf
If Len(GD$(7))>2 Then
 Print "Notes:             "; GD$(7)
EndIf

' PSG INFO
X=190: Y=12*5
Line(X-4,Y-2)-(475,Y+12*9-1),1,B
Print@(X,0)
Print@(X,Y) "SN76489 Info:"
Y=Y+12: Print@(X,Y,1)
Y=Y+12: Print@(X,Y,1) "Clock:           "; Format$(Clk,"%.0f")
Y=Y+12: Print@(X,Y,1) "Feedback:        "; SNType$
Y=Y+12: Print@(X,Y,1) "Shift Reg Width: "; SNSRType$
Y=Y+12: Print@(X,Y,1) "Flags:           "; SNFL$
Y=Y+12: Print@(X,Y,1) "Output Neg Flag: "; Mid$(SNFL$,7,1)
Y=Y+12: Print@(X,Y,1) "Stereo?          "; St$
Y=Y+12: Print@(X,Y,1) "/8 Clock Div:    "; ClkDiv$

T$="F10: Enable/disable sound bars"
Print@(maxx-Len(T$)*6-2,0) T$
T$="(can slow down the music)"
Print@(maxx-Len(T$)*6-2,12) T$

' COLORIZE THE INFERIOR SCREEN TO GRAPH BARS EFFECT WHEN PLAYING VGM
ChangeSpeed(Speed)
ScanLine Red,MaxY-150,MaxY-80
ScanLine Yellow,MaxY-84,MaxY-24
ScanLine Green,MaxY-24,MaxY
For T = 1 To 12 Step 2
 ScanLine Red,MaxY-85+T,MaxY-85+T
 ScanLine Green,MaxY-25-T,MaxY-25-T
Next T

If ShowImage$<>"" Then
 Mode 4: Cls: LoadBMP ShowImage$
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 BMPMode=1
EndIf

' MAIN BLOCK - START VGM
StartVGM:
I=VGMoffset
'I=&H052
Seek #1,1
Seek #1,I
L=Lof(#1)
E=EOFoffset
Timer = 0
PauseTime = 0: StartTime = 0
MP=241: Ymus = 0: Yant = 0
GFX=0: Buf=240
Silence
Pause(20)
If Dig=0 Then
 SetTick SampleTick,PlayVGM
Else
 SetTick 0.5,PlayDig
EndIf
For T=0 To 3
 Ton(T)=0: Vol(T)=0
Next T

' MAIN VGM LOOP
Do While I < L
 Restart:
 NoSnd=1
 If I = 0 Then GoTo BackDir
 MP = MP - Buf - 1
 Seek #1,I
 M$ = Input$(Buf+15-150,#1)
 NoSnd=0
 If I+Buf<L Then
  I=I+Buf
 Else
  I=I+(L-I)
 EndIf
 M$ = M$ + Input$(150,#1)
 If I >= L And Loffset>=0 Then
  If NumLoops > 0 Then
   NumLoops=NumLoops-1
   If NumLoops <= 0 Then
    GoTo BackDir
   EndIf
   I=Loffset
  EndIf
 EndIf
 If I >= Lof(#1) Then GoTo BackDir

 BackLoop:
  If MP>Buf Then NoSnd=1: GoTo Restart
  ' KEYBOARD ACTIONS WHEN PLAYING VGM FILE
  I$ = Inkey$
  If I$=Chr$(27) Then
   GoTo BackDir
  EndIf
  If I$=Chr$(128) Then
   Speed=Speed+0.1
   ChangeSpeed(Speed)
  EndIf
  If I$=Chr$(129) Then
   Speed=Speed-0.1
   If Speed < 0.5 Then
    Speed=0.5
   EndIf
   ChangeSpeed(Speed)
  EndIf
  If I$=Chr$(154) Then
   If GFX=0 Then
    GFX=1
    Speed=Speed+0.5
    ChangeSpeed(Speed)
   Else
    GFX=0
    Line(10,maxy-120)-(65,maxy),0,BF
    Speed=Speed-0.5
    ChangeSpeed(Speed)
   EndIf
  EndIf

  ' GRAPH BARS
  If GFX=1 Then
   For T=0 To 3
    VolTon=((Ton(T)/2)*(Vol(T)/3))/10
    If VolTon>120 Then VolTon=120
    xv=10+T*15
    Line(xv,maxy-VolTon)-(xv+10,maxy),1+t,BF
    Line(xv,maxy-120)-(xv+10,maxy-VolTon-1),0,BF
   Next T
  EndIf

 GoTo BackLoop

Loop

' RETURN TO THE FILE SELECTION
BackDir:
 SetTick 0,PlayVGM
 Silence
 Pause(100)
 Mode 1
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 BMPMode=0
 Close #1
 GoTo ReadDir

' PSG LEDS
PSGLeds:
 AA$ = Bin$(Ymus)
 BB$ = String$(8-Len(AA$),"0")+AA$
 St = (1-Val(Left$(BB$,1)))*75
 BLIT 20,maxy-140,20,maxy-150,150,145
 For T=7 To 1 IF Step -1
  Line(T*10+10+st,maxy-5)-(T*10+15+st,maxy),2+Val(Mid$(BB$,t,1))*2,bf
 Next T
Return

' PLAY VGM INTERRUPT
 PlayVGM:
 If MP>Buf Or NoSnd=1 Then NoSnd=1: IReturn
 Do While (Timer - StartTime <= PauseTime)
  IReturn
 Loop

 If Hx<>&H62 And Hx<>&H63 And (Hx < &H70 Or Hx > &H7F) Then
  PauseTime=SWait*400
  StartTime=Timer
 EndIf

 FastLoop:
 If MP>Buf Or NoSnd=1 Then NoSnd=1: IReturn
 MP=MP+1
 Hx=H
 H=Asc(Mid$(M$,MP,1))

 If H = &H50 Then
  'StartTime = Timer: PauseTime = SWait*1000
  ThinkAgain:
  'PauseTime=PauseTime - SWait*100
  MP=MP+1
  Yant=Ymus
  Ymus=Asc(Mid$(M$,MP,1))

  If GFX=1 Then
   AA$ = Right$("0000000"+Bin$(Ymus),8)
   BB$ = Right$("0000000"+Bin$(Yant),8)
   Ch=Val("&B"+Mid$(AA$,2,2))
   If Mid$(AA$,1,1)="1" Then
    If Mid$(AA$,4,1)="1" Then
     Vol(Ch)=(&B1111 - Val("&B"+Right$(AA$,4)))
    Else
     Ton(Ch)=Clock/((1025-Val("&B"+Right$(AA$,4)))*32)
    EndIf
   Else
    Ton(Ch)=Clock/((1025-Val("&B"+Right$(BB$,6)+Right$(AA$,4)))*32)
   EndIf
  EndIf

  If Ymus=0 And Right$(Bin$(Yant),4)="0000" Then
   B$ = Right$("0000000"+Bin$(Yant),8)
   Port(22,8)=0
   Pin(30)=0
   Pin(30)=1
   Port(22,8)=Val("&B"+Left$(B$,4)+"0001")
  Else
   Port(22,8)=Ymus
  EndIf
  Pin(30)=0
  Pin(30)=1
  If Asc(Mid$(M$,MP+1,1))=&H50 Then
   MP=MP+1
   If MP>Buf Then
    NoSnd=1:IReturn
   Else
    GoTo ThinkAgain
   EndIf
  EndIf
  IReturn

 ElseIf H = &HA0 Then
  YmusR=Asc(Mid$(M$,MP+1,1))
  Ymus=Asc(Mid$(M$,MP+2,1))
  'A$ = Bin$(Ymus)
  'B$ = String$(8-Len(A$),"0")+A$
  B$ = Right$("0000000"+Bin$(Ymus),8)
  MP=MP+2
  If YmusR = 7 Then
   If Right$(B$,1)="1" Then ChMus=1
   If Mid$(B$,7,1)="1" Then ChMus=2
   If Mid$(B$,6,1)="1" Then ChMus=3
  EndIf
  If YMusR = 0 Then AYMusB$(0)=B$:Ch=0
  If YMusR = 1 Then AYMusA$(0)=B$:Ch=0
  If YMusR = 2 Then AYMusB$(1)=B$:Ch=1
  If YMusR = 3 Then AYMusA$(1)=B$:Ch=1
  If YMusR = 4 Then AYMusB$(2)=B$:Ch=2
  If YMusR = 5 Then AYMusA$(2)=B$:Ch=2
  If YMusR = 0 Or YMusR = 2 Or YMusR = 4 Then
   CMus = Val("&B"+AYMusA$(Ch)+AYMusB$(Ch))
   CMus = (CMus+1\4)-1
   MConv$ = Righ$("000000000"+Bin$(CMus),10)
   'Print CMus
   'Print AYMusA$(Ch)+AYMusB$(Ch)

   Port(22,8)=Val("&B1"+Chan$(Ch)+"0"+Right$(MConv$,4))
   Pin(30)=1: Pin(30)=0
   Port(22,8)=Val("&B00"+Left$(MConv$,6))
   Pin(30)=1: Pin(30)=0
  EndIf
  If YMusR >= 10 And YMusR <= 12 Then
   VolT=15-Val(Right$(B$,4))
   Port(22,8)=Val("&B1" + Chan$(YMusR-10) + "1"+Right$("0000"+Bin$(VolT),4))
   Pin(30)=1: Pin(30)=0
  EndIf
  IReturn

 ElseIf H = &H61 Then
  Temp = Asc(Mid$(M$,MP+2,1))*256+Asc(Mid$(M$,MP+1,1))
  MP=MP+2: StartTime = Timer: PauseTime = SWait * Temp: GoTo PlayVGM

 ElseIf H = &H62 Then
  StartTime = Timer: PauseTime = Wait60: GoTo PlayVGM

 ElseIf H = &H63 Then
  StartTime = Timer: PauseTime = Wait50: GoTo PlayVGM

 ElseIf H = &H66 Then
  If NumLoops>0 And Loffset>=0 Then
   NumLoops=NumLoops-1
   If NumLoops <= 0 Then GoTo BackDir
   NoSnd=1:MP=Buf+1:I=Loffset
   IReturn
  Else
   NoSnd=1:I=L+1:MP=Buf+1
   IReturn
  EndIf
  IReturn

 ElseIf H >= &H70 And H <= &H7F Then
  Frames = (H - &H6F): StartTime = Timer: PauseTime = SWait * Frames
  GoTo PlayVGM

 ElseIf H >= &H30 And H < &H50 Then
  MP=MP+1: GoTo FastLoop
 ElseIf H >= &H50 And H < &HC0 Then
  MP=MP+2: GoTo FastLoop
 ElseIf H >= &HC0 And H <= &HE0 Then
  MP=MP+3: GoTo FastLoop
 ElseIf H >= &HE1 Then
  MP=MP+4: GoTo FastLoop
 Else
  GoTo FastLoop
 EndIf

 IReturn
Loop

GoTo BackDir

' TRY TO PLAY DIGITIZED VGM SOUNDS - DOESN'T WORK YET
PlayDig:
 If MP>Buf Or NoSnd=1 Then NoSnd=1: IReturn
 MP=MP+1
 If Asc(Mid$(M$,MP,1)) = &H50 Then
  MP=MP+1
  AgainDig:
  If MP>Buf Or NoSnd=1 Then NoSnd=1: IReturn
  Pin(30)=1
  Port(22,8)=Asc(Mid$(M$,MP,1))
  Pin(30)=0
  If Asc(Mid$(M$,MP+1,1)) = &H50 Then
   MP=MP+2
   GoTo AgainDig
  EndIf
 EndIf
IReturn


