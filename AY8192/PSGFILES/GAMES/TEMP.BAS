' CdN MEDIA STUDIO FOR COLOUR MAXIMITE

Mode 1

For TT = 0 To 13
 SetPin 21+TT,8
 Pin(21+TT) = 1
Next TT

Dim File$(255) length 12
Dim GD$(20) length 255
Dim TP$(7) LENGTH 3
Dim Vol(4)
Dim Ton(4)
Dim XL(2),XR(2),YU(2),YD(2)
Dim XY(16,16),XYT(16,16)

Prg$ = "CdN Media Studio - v0.8"
Author$ = "Mauro Xavier - 2018"
CP$="": DirCP$=""

sel=1: selant=1: GFX=0
xf=0: yf=0: xfant=0: yfant=0
maxx=MM.HRes-1
maxy=MM.VRes-1
fullscreen=0: notcls=0

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
 Line(0,maxy-55)-(maxx,maxy-9),0,BF
 ShowMenu = 0
 ScanLine White,0,MaxY
 Line(0,maxy-56)-(maxx,maxy-56)
 ScanLine Yellow,MaxY-56,MaxY-56
 ScanLine Cyan,MaxY-53,MaxY-8
 ScanLine Green,MaxY-8,MaxY
 yt=maxy-8: Dig=0
 Print@(0,yt) Prg$
 Print@(maxx-Len(Author$)*6,yt) Author$
 yt=maxy-52
 If Menu=0 Then
  Print@(0,yt) "Enter: Select": yt=yt+12
  Print@(0,yt) "  Esc: Exit": yt=yt+12
  Print@(0,yt) "  Del: Delete": yt=yt+12
  yt=maxy-52
  Print@(120,yt) "F1: About": yt=yt+12
  Print@(120,yt) "F2: Rename": yt=yt+12
  Print@(120,yt) " N: New SPR file": yt=yt+12
  yt=maxy-52
  Print@(240,yt) "C: Copy ";CP$;String$(12-Len(CP$)," "): yt=yt+12
  Print@(240,yt) "P: Paste": yt=yt+12
  Print@(240,yt) "M: Move": yt=yt+12
  Print@(240,yt) "T: Text View"
  yt=maxy-52+24
  yt=maxy-52
  Print@(maxx-66,yt) "  Dir: " : yt=yt+12
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
 ElseIf Menu=3 Then
  yt=maxy-52
  Print@(0,yt) "Esc: Back": yt=yt+12
  Print@(0,yt) "F10: Enable / disable sound bars"
  yt=yt+12
  yt=maxy-52
  Print@(353,yt) "Up/Down: Change Speed": yt=yt+12
  If AY=0 Then Print@(389,yt) "M: Force Mono"
  If FileType$ = ".PSG" Then Print@(335,yt) "Right/Left: Change Tone": yt=yt+12
  yt=maxy-52
  Print@(0,-12) ""
 ElseIf Menu=4 Then
  ScanLine Yellow,0,12
  ScanLine Yellow,60,72
  yt=maxy-52
  A$="To play MOD file it must be write to flash memory, and the video will"
  B$="turn off"
  Print@(0,yt) A$+" "+B$
  yt=yt+12
  A$="until this operation is complete."
  B$="Press ENTER to continue or ESC to return."
  Print@(0,yt) A$+" "+B$
  yt=yt+12
  Print@(0,yt) "PS: Keep in mind that flash memory has a limited life cycle!"
  Do While KeyDown<>0
  Loop
  Do While ShowMenu=0
   K = KeyDown
   If K=13 Then ShowMenu=1
   If K=27 Then ShowMenu=2
  Loop
 ElseIf Menu=5 Then
  ScanLine Yellow,0,12
  ScanLine Yellow,60,72
  yt=maxy-52
  Print@(0,yt) "Playing MOD file: " + Music$
  yt=yt+12
  Print@(0,yt) "File Size: " + Format$(FileSize/1024,"%.2f") + " Kb"
  yt=yt+12
  A$="Press ESC to stop music and return or B to play in background"
  B$="(consume memory!)."
  Print@(0,yt) A$+" "+B$
 EndIf
End Function

' READ FOLDERS AND FILES
ReadDir:
ChangeSpeed(0)
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
TP$(5)="RAW"
TP$(6)="MOD"
TP$(7)="PSG"
FileQt=0
For T = 1 To 7
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

yt=maxy-52
Print@(maxx-66,yt) "  Dir: " DirQt-2  : yt=yt+12
Print@(maxx-66,yt) "Files: " FileQt : yt=yt+12
max=sl

FileSelect:
 TPFound=0
 For T=1 To 7
  If Right$(file$(sel),1+Len(TP$(T)))="."+TP$(T) Then
   Print@(xf,yf,2) file$(sel)
   TPFound=1
  EndIf
 Next T
 If TPFound=0 Then
  Print@(xf,yf,2) "["+file$(sel)+"]"
 EndIf

 TPFound=0
 For T=1 To 7
  If Right$(file$(selant),1+Len(TP$(T)))="."+TP$(T) Then
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

 ' VIEW AS A TEXT
 If UCase$(I$)="T" Then GoTo ReadText

 ' OPEN BMP TO SCROLL DEMO
 Scroll=0
 If UCase$(I$)="S" Then
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

 ' NEW FILE
 If UCase$(I$)="N" Then
  file$(sel+1)=".SPR"
  Print@(144,MM.VRes-27) Space$(12)
  If Instr(1,file$(sel+1),".")>0 And Len(file$(sel+1))>3 Then
   Ren$=ReadKey$(144,MM.VRes-27,file$(sel+1),8,1)
   If Ren$<>"" Then
    SpriteNewFile(REN$)
   EndIf
  EndIf
  Cls
  GoTo ReadDir
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
  BLIT 0,maxy-50,0,maxy-51,maxx,53
  ScanLine Cyan,MaxY-T,MaxY
  ScanLine Green,MaxY-T-8,MaxY-T
T$="This is a media editor for game development"
  Print@(0,maxy-T+3) T$
T$="You can open, edit and create BMP, sprite and font files"
  Print@(0,maxy-T+15) T$
T$="To play corretly VGM/PSG files you need a specific hardware"
  Print@(0,maxy-T+27) T$
 Next T
 Do While Inkey$ = ""
 Loop
GoTo ReadDir

' VERIFY THE FILE TYPE AND MAKE A ACTION
Action:
 BMPMode=0
 FileType$=Right$(file$(sel),4)
 If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
  CP$="": DirCP$=""
 EndIf
 ' MOD
 If FileType$=".MOD" Then
  Music$=file$(sel)
  GoTo MODPlayer
 ' RAW
 ElseIf FileType$=".RAW" Then
  Music$=file$(sel)
  GoTo PlayRAW
 ' VGM
 ElseIf FileType$=".VGM" Then
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
  BMPScr=0
  GoTo VGMInit
 ' PSG
 ElseIf FileType$=".PSG" Then
  Music$=file$(sel)
  GoTo PSGInit
 ' BMP
 ElseIf FileType$=".BMP" Then
  Mode 4
  BMPMode=1
  Cls
  If scroll=0 Then
   Mode 4: xb=0: yb=0
   x=MM.HRes/2
   y=MM.VRes/2
   GoTo EditBMP
  Else
   BMPScrollerInit(file$(sel))
   F$=Dir$("*.VGM",FILE)
   ShowImage$=""
   Music$=""
   Do While F$ <> ""
    If Left$(F$,Instr(1,F$,".")-1)+".BMP" = file$(sel) Then
     Music$=Left$(F$,Instr(1,F$,".")-1)+".VGM"
    EndIf
    f$=Dir$()
   Loop
   BMPScr=1
   If Music$="" Then
    Do While BMPScr=1
     BMPScroller
     If Inkey$ = Chr$(13) Then Close #2: Mode 1: Cls: GoTo ReadDir
    Loop
   Else
    GoTo VGMInit
   EndIf
  EndIf
  Do While Inkey$ <> Chr$(13)
  Loop
  Do While I$ <> Chr$(27) And I$ <> Chr$(13)
   I$ = Inkey$
  Loop
  Mode 1: Cls
  GoTo ReadDir
 ' SPR
 ElseIf Right$(file$(sel),4)=".SPR" Then
  X=2: Y=2: GoTo SpriteSelect
 ' FNT
 ElseIf Right$(file$(sel),4)=".FNT" Then
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
  Cls2
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
  Pin(D12)=1
  Port(D0,8)=Num
  Pin(D12)=0
  Pause(0.1)
  Pin(D12)=1
 EndIf
End Sub

' CHANGE FILE MUSIC TONE
Sub ChangeTone(xx)
 If filetype$=".PSG" Then
  If tone<-50 Then tone=-50
  If tone>50 Then tone=50
  Print@(0,12*5,0) "Adjust Tone:  ";Format$(xx,"%.1f");"  "
  Tone=xx
 EndIf
End Sub

' CHANGE FILE MUSIC SPEED
Sub ChangeSpeed(xx)
 If filetype$=".PSG" Then
  If xx<-10 Then xx=-10
  If xx>14 Then xx=14
  Print@(0,12*4,0) "Adjust Speed: ";Format$(xx+1,"%.1f");"  "
  Speed=xx
  Return
 EndIf
 Clock = 3579545
 If Rate<>0 Then
  SRate = 44100*3
  Sample = 2.267573696/1.1
  Wait60 = (1000/(SRate/735))'/(1+1.3)
  Wait50 = (1000/(SRate/882))'/(1+1.3)
  SWait  = (1000/(SRate/Sample))'/(1+0.4)
 Else
  SRate = 44100*25
  Sample = 2.267573696
  Wait60 = (1000/(SRate/735))/(1+1.3)
  Wait50 = (1000/(SRate/882))/(1+1.3)
  SWait  = (1000/(SRate/Sample))/(0.15)
 EndIf
 If AY=1 Or Rate=0 Then
  PTime  = 1000-ClkAY/6500
  PTime  = 750-(19.5-xx)*50
  SRate  = 44100
  SWait  = PTime/SRate
  Wait60 = SWait*735
  Wait50 = SWait*882
  'Print "SWait:";SWait
  'Print "Wait60:";Wait60
  'Print "Wait50:";Wait50
  'Print "Max Wait:";(SWait*65535)
  'End
 EndIf

 'Wait60 = (1000/(SRate/735))
 'Wait50 = (1000/(SRate/882))
 'SWait  = (1000/(SRate/Sample))

 If xx>19.5 Then xx=19.5
 If BMPMode=0 And xx>0 Then
  If AY=0 And rate<>0 Then
   Print@(0,12*14,0) "Interrupt Timer:   ";Format$(20-xx,"%.1f");"ms "
  Else
   Print@(0,12*14,0) "Adjust Speed:      ";Format$(20.5-xx,"%.1f")
  EndIf
 EndIf

 If xx>0 Then
  If ay=0 And rate<>0 Then SetTick 20-xx,PlayVGM,1 Else SetTick 0.5,PlayVGM,1
 Else
  SetTick 0,PlayVGM,1
 EndIf
End Sub

' SILENCE PSG
Sub Silence
 Pin(D11)=0
 Pin(D11)=1
 Pin(D12)=0
 Pin(D9)=0: Pin(D10)=0
 Pin(D12)=1
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

Function SeekHeaderNull$(H,search)
A$=""
i=0
Seek #1,H+1
B$ = Input$(250,#1)
Do While search>0 And i<250
 i=i+1
 C$ = Mid$(B$,i,1)
 If C$=Chr$(0) Then
  A$=A$+Chr$(13)
  search=search-1
 Else
  A$=A$+Mid$(B$,i,1)
 EndIf
Loop
SeekHeaderNull$ = A$
End Function

' SEEK HEADER INT NUMBER
Function SeekHeaderInt2(H,size,num)
 Temp$ = ""
 For S = 1 To size
  Seek #num, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#num)))
 Next S
 SeekHeaderInt2 = Val("&H"+Temp$)
End Function

' SEEK HEADER INT NUMBER
Function SeekHeaderInt(H,size,num)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #num, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#num)))
 Next S
 SeekHeaderInt = Val("&H"+Temp$)
End Function

' BMP HEADER AND INFORMATION
Sub BMPHeader
 hy=0
 BMPIdent = SeekHeaderInt(hy,2,2): hy=hy+2
 BMPFileSize = SeekHeaderInt(hy,4,2): hy=hy+4
 hy=hy+4
 BMPOffSet = SeekHeaderInt(hy,4,2): hy=hy+4
 BMPHeadSize = SeekHeaderInt(hy,4,2): hy=hy+4
 BMPWidth = SeekHeaderInt(hy,4,2): hy=hy+4
 BMPHeight = SeekHeaderInt(hy,4,2): hy=hy+4
 hy=hy+2
 BMPBits = SeekHeaderInt(hy,2,2): hy=hy+2
 BMPCompress = SeekHeaderInt(hy,4,2): hy=hy+4
 If BMPCompress <> 0 Then
  Error "BMP Compression Unsupported :"+Str$(BMPCompress)
 EndIf
 BMPSize = SeekHeaderInt(hy,4,2): hy=hy+4
 hy=hy+8
 BMPColours = SeekHeaderInt(hy,4,2): hy=hy+4
 BMPHOffset = 14+40+4*BMPColours
 'Print@(100,100) BMPWidth;"x";BMPHeight;":";BMPBits;"b C";BMPColours
End Sub

' ALTERNATIVE BMP READER
Sub BMPScrollerInit(bmp$)
 Open bmp$ For INPUT As #2
 BMPHeader
 BSeek=BMPHOffset
 If BMPHeight > MM.VRes Then
  Dif=BMPHeight-MM.VRes
  Bseek=BMPOffset+BMPWidth*Dif
  BMPHeight=14+40+4*16+Lof(#2)/(BMPWidth/2)
 EndIf
 Seek #2, 119
 If BMPBits=4 Then
  WA=BMPWidth/2
  WB=BMPWidth
  HA=BMPHeight/2
 EndIf
 BX=1
End Sub

Sub BMPScroller
 BX = BX + 1
 BA$=Input$(BMPWidth,#2)
 For BY = 1 To WA
   Pixel(238,BY*2+1)=Peek(VAR BA$,BY+1)/16
   Pixel(238,BY*2)=Peek(VAR BA$,BY) Mod 8
 Next BY
 'BLIT 1,0,0,0,239,WB+1
 For BY = WA+1 To WB
   Pixel(239,BY*2+1-WB)=Peek(VAR BA$,BY+1)/16
   Pixel(239,BY*2-WB)=Peek(VAR BA$,BY) Mod 8
 Next BY
 BLIT 2,0,0,0,238,WB+1
 Line(238,0)-(239,WB+2),Black,bf
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
 If BX = HA Then BMPScr=0: Close #2
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
 GD3=SeekHeaderInt(&H14,4,1)
 'Print SeekHeaderChar$(GD3,10)
 'Exit
 If GD3<>0 Then
  S=GD3
  Do While S < Lof(#1) And S<GD3+1000
   S=S+1
   Seek #1, S
   Temp$ = Temp$ + Input$(1,#1)
   MaxStr = Instr(1,Temp$,Chr$(0)+Chr$(0))
   If Len(Temp$) >= 100 Then MaxStr=100: Exit
   If MaxStr>0 Then
    If Jump=0 Or ID>=6 Then
     ID=ID+1
     Jump=1
    Else
     Jump=0
    EndIf
    GD$(ID)=Left$(Temp$,MaxStr-1)
    If ID<11 And Len(Temp$)>80 Then GD$(ID)=""
    MaxStr=0
    Temp$=""
   EndIf
  Loop
 EndIf
End Sub

AYInit:
Print SeekHeaderChar$(0,4)
Print SeekHeaderChar$(4,8)
nb=SeekHeaderInt(12,4,1)
Print "Nb:";nb
SongAtr$=Bin$(SeekHeaderInt(16,4,1))
Print "Atrib:";SongAtr$
FrameLoop=SeekHeaderInt(24,4,1)
Print "FrameLoop:";FrameLoop
Print "Digidrums:";SeekHeaderInt(20,2,1)
ExtFreq=SeekHeaderInt(22,4,1)
Print "External Freq.:";ExtFreq
Print "Song Info:"
Print SeekHeaderNull$(28,10)
If Left$(SongAtr$,1)="1" Then GoTo backdir

Sub PlayPSG
 Do While (Timer - StartTime <= PauseTime-2)
  Return
 Loop
 If nosnd=1 Then
  If YmusA=&HFD Then R=4: YmusA=0
  Seek #1, R
  Mus$=Input$(255,#1)
  I=0
  xy=0
  nosnd=0
 EndIf
 Do While (xy<210 Or I<>0) And (YmusA<>&HFD) And Eof(#1)=0
  Do While (Timer - StartTime <= PauseTime-2)
   Return
  Loop
  I=I+1
  xy=xy+1
  YmusA = Peek(VAR Mus$,xy)
  YmusB = Peek(VAR Mus$,xy+1)
  If YmusA<16 Then
   If YMusA=0 Or YMusA=2 Or YMusA=4 Then YmusB=YMusB+Tone
   If YMusA=1 Or YMusA=11 Then ToneA=YmusB
   If YMusA=3 Then ToneB=YmusB
   If YMusA=5 Then ToneC=YmusB
   If YMusA=8 Then VolTonA=YmusB
   If YMusA=9 Then VolTonB=YmusB
   If YMusA=10 Then VolTonC=YmusB
   XYT(I,1) = YmusA: XYT(I,2)=YmusB: xy=xy+1
  EndIf
  If YmusA=&HFF Then
   For T=1 To I
    Pin(D8)=1: Port(D0,8)=XYT(T,1): Pin(D8)=0
    Port(D0,8)=XYT(T,2): Pin(D8)=1
   Next T
   For T=1 To 16
    XYT(T,1)=16: XYT(T,2)=255
   Next T
   PauseTime = 12-I-Speed: StartTime = Timer
   I=0
  EndIf
  If YmusA=&HFE Then
   For T=1 To I
    Port(D0,8)=XYT(T,1): Pin(D8)=0
    Port(D0,8)=XYT(T,2): Pin(D8)=1
   Next T
   PauseTime = (12-i)*YmusB*7.5: StartTime = Timer
   For T=1 To 16
    XYT(T,1)=16: XYT(T,2)=255
   Next T
   I=0
  EndIf
 Loop
 R=R+xy: nosnd=1
End Sub

' INITIATE GENERAL PSG FILE
PSGInit:
Silence
PauseTime = 0: StartTime = 0
Cls: AY=1: R=4: nosnd=1
ChangeSpeed(0): ChangeTone(0)
Pin(D13)=1
Pin(D11)=0 ' RESET AY
Pin(D11)=1
Open Music$ For INPUT As #1
For T=1 To 16
 XYT(T,1)=16: XYT(T,2)=255
Next T
If BMPScr=0 Then
 tt=ShowMenu(3)
 Print "File Type:    "; SeekHeaderChar$(0,4)
 Print "File Name:    "; Music$
 Temp=Lof(#1)/1024
 Print "File Size:   ";  Lof(#1);" bytes / ";Format$(Temp,"%.2f");" Kb"
EndIf
SetGrScanlines
SetTick 10,PlayPSG,1

LoopPSG:
Do While Eof(#1)=0

 xv=10
 For ttt=1 To 3
  If ttt=1 Then
   V=VolTonA*0.5*ToneA
  ElseIf ttt=1 Then
   V=VoltonB*0.5*ToneB
  Else
   V=VolTonC*0.5*ToneC
  EndIf
  xv=xv+30
  Line(xv,maxy-V-60)-(xv+10,maxy-60),1+t,BF
  Line(xv,maxy-140)-(xv+10,maxy-V-61),0,BF
 Next ttt

 I$ = Inkey$
 If I$<>"" Then
  If I$=Chr$(27) Then SetTick 0,PlayPSG,1: GoTo BackDir
  If I$=Chr$(128) Then Speed=Speed+0.5: ChangeSpeed(Speed)
  If I$=Chr$(129) Then Speed=Speed-0.5: ChangeSpeed(Speed)
  If I$=Chr$(130) Then Tone=Tone+1: ChangeTone(Tone)
  If I$=Chr$(131) Then Tone=Tone-1: ChangeTone(Tone)
 EndIf
Loop
GoTo BackDir

' INITIATE GENERAL VGM FILE AND HEADERS
VGMInit:
Pin(D9)=0 ' RIGHT PSG
Pin(D10)=0 ' LEFT PSG
Silence
Cls
If BMPScr=0 Then tt=ShowMenu(3)
Speed=11

Open Music$ For INPUT As #1
Clk=SeekHeaderInt(&H0C,4,1)
ClkAY=SeekHeaderInt(&H74,4,1)

'ENABLE AY
If CLK=0 Then
 AY=1
 Pin(D13)=1
 Pin(D11)=0 ' RESET AY
 Pin(D11)=1
 ' TURN OFF PSG
 Pin(D9)=1
 Pin(D10)=1
Else
 AY=0
EndIf

EOFoffset=SeekHeaderInt(&H04,4,1)
TotalSamples=SeekHeaderInt(&H18,4,1)
VGMoffset=SeekHeaderInt(&H34,4,1)
If VGMOffSet = 0 Then
 VGMOffSet = &H40
EndIf

Temp$=SeekHeaderHexa$(&H28,2)
If Temp$="00" Then
 AYType$ = "AY8910"
ElseIf Temp$="01" Then
 AYType$ = "AY8912"
ElseIf Temp$="02" Then
 AYType$ = "AY8913"
ElseIf Temp$="03" Then
 AYType$ = "AY8930"
ElseIf Temp$="10" Then
 AYType$ = "YM2149"
ElseIf Temp$="11" Then
 AYType$ = "YM3439"
ElseIf Temp$="12" Then
 AYType$ = "YMZ284"
ElseIf Temp$="13" Then
 AYType$ = "YMZ294"
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

SNFL$=Bin$(SeekHeaderInt(&H2B,1,1))
SNFL$=String$(8-Len(SNFL$),"0")+SNFL$

Pin(D9)=0: Pin(D10)=0
If Mid$(SNFL$,6,1) = "0" Then
 St$ = "Yes"
Else
 St$ = "No"
EndIf
Stereo=0

If Mid$(SNFL$,5,1) = "0" Then
 ClkDiv$ = "On"
Else
 ClkDiv$ = "Off"
EndIf

LOffSet   = SeekHeaderInt(&H1C,4,1)
LSamples  = SeekHeaderInt(&H20,4,1)
LBase     = SeekHeaderInt(&H7E,1,1)
LModifier = SeekHeaderInt(&H7F,1,1)

If LModifier <> 0 Or Lbase <> 0 Then
 NumLoops = Abs(LModifier - LBase)
Else
 NumLoops = -1
EndIf

GD3 = SeekHeaderInt(&H14,4,1)
Rate = SeekHeaderInt(&H24,4,1)
ReadGD3Header

'rate=0
If rate=60 Then
 Speed=12
ElseIf rate=50 Then
 Speed=11
Else
 Speed=19.5
EndIf
If ay=1 Then speed=19.5
If BMPScr=1 Then GoTo NoInfo

' VGM INFO
Temp=Val(SeekHeaderBCD$(&H08,4))/100
Print "File Type:         "; SeekHeaderChar$(&H00,4);"Version";Temp
Print "File Name:         "; Music$
Temp=Lof(#1)/1024
Print "File Size:        ";  Lof(#1);" bytes / ";Format$(Temp,"%.2f");" Kb"
Print "EOF offset:       ";  EOFoffset
Print "VGM offset:       ";  VGMoffset
Print "Total Samples:     "; Format$(TotalSamples,"%.0f")
Print "Loop Offset:       "; Format$(LOffset,"%.0f")
Print "Loop Samples:      "; Format$(LSamples,"%.0f")
Print "Loop Base:         "; Format$(LBase,"%.0f")
Print "Loop Modifier:     "; Format$(LModifier,"%.0f")
Print "Loops:             "; Format$(NumLoops,"%.0f")
Print "GD3 Offset:       ";  GD3
Print "Rate:              "; Format$(Rate,"%.0f");" Hz"
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
If AY=1 Then
 Print@(X,Y) "AY Info:"
 Y=Y+12: Print@(X,Y,1)
 Y=Y+12: Print@(X,Y,1) "Clock:           "; Format$(ClkAY,"%.0f")
 Y=Y+12: Print@(X,Y,1) "Chip Type:       "; AYType$
Else
 Print@(X,Y) "SN76489 Info:"
 Y=Y+12: Print@(X,Y,1)
 Y=Y+12: Print@(X,Y,1) "Clock:           "; Format$(Clk,"%.0f")
 Y=Y+12: Print@(X,Y,1) "Feedback:        "; SNType$
 Y=Y+12: Print@(X,Y,1) "Shift Reg Width: "; SNSRType$
 Y=Y+12: Print@(X,Y,1) "Flags:           "; SNFL$
 Y=Y+12: Print@(X,Y,1) "Output Neg Flag: "; Mid$(SNFL$,7,1)
 Y=Y+12: Print@(X,Y,1) "Stereo?          "; St$;
 Y=Y+12: Print@(X,Y,1) "/8 Clock Div:    "; ClkDiv$
EndIf

SetGraphScanlines

If ShowImage$<>"" Then
 Mode 4: Cls: LoadBMP ShowImage$
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 BMPMode=1
EndIf

' COLORIZE THE INFERIOR SCREEN TO GRAPH BARS EFFECT WHEN PLAYING MUSIC
Sub SetGrScanLines
 ScanLine Red,MaxY-140,MaxY-121
 ScanLine Yellow,MaxY-120,MaxY-84
 ScanLine Green,MaxY-84,MaxY-60
 For T = 1 To 12 Step 2
  ScanLine Red,MaxY-120+T,MaxY-120+T
  ScanLine Green,MaxY-85-T,MaxY-85-T
 Next T
End Sub

' RESTART VGM
Sub RestartVGM
 MP = MP - Buf - 1
 Option Error Continue
 Seek #1,I
 If MM.Errno <> 0 Then EndMus=1
 M$ = Input$(Buf+15-150,#1)
 'M$ = Input$(Buf+15,#1)
 If I+Buf<L Then
  I=I+Buf-2
 Else
  I=I+(L-I)
 EndIf
 M$ = M$ + Input$(150,#1)
 If I >= Lof(#1) Then EndMus=1
 If I >= L And Loffset>=0 Then I=Loffset
End Sub

NoInfo:

' MAIN BLOCK - START VGM
StartVGM:
 Option Error Continue
 Timer=0
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
 For T=0 To 3
  Ton(T)=0: Vol(T)=0
 Next T
 RestartVGM
 EndMus=0
 ChangeSpeed(Speed)

' MAIN VGM LOOP INTERFACE
BackLoop:

 ' KEYBOARD ACTIONS WHEN PLAYING VGM FILE
 I$ = Inkey$
 If I$=Chr$(27) Or EndMus=1 Then GoTo BackDir
 If UCase$(I$)="M" And AY=0 Then Stereo=0:Pin(D9)=0: Pin(D10)=0
 If I$=Chr$(128) Then Speed=Speed-0.5: ChangeSpeed(Speed)
 If I$=Chr$(129) Then Speed=Speed+0.5: ChangeSpeed(Speed)
 If I$=Chr$(131) Then BLIT 0,0,236,0,4,212 :BLIT 4,0,0,0,236,212
 If I$=Chr$(154) Then
  If GFX=0 Then
   GFX=1
   'Speed=Speed+0.8
   'ChangeSpeed(Speed)
  Else
   GFX=0
   Line(10,maxy-140)-(65,maxy-60),0,BF
   'Speed=Speed-0.8
   'ChangeSpeed(Speed)
  EndIf
 EndIf

 ' GRAPH BARS
 If GFX=1 Then
  For T=0 To 3
   VolTon=((Ton(T)/2)*(Vol(T)/3))/10
   If VolTon>60 Then VolTon=60
   xv=10+T*15
   Line(xv,maxy-VolTon-60)-(xv+10,maxy-60),1+t,BF
   Line(xv,maxy-140)-(xv+10,maxy-VolTon-61),0,BF
  Next T
  AA$ = Right$("0000000"+Bin$(Ymus),8)
  BB$ = Right$("0000000"+Bin$(Yant),8)
  Ch=Val("&B"+Mid$(AA$,2,2))
  If Peek(VAR AA$,1)=49 Then
   If Peek(VAR AA$,4)=49 Then
    Vol(Ch)=(&B1111 - Val("&B"+Right$(AA$,4)))
   Else
    Ton(Ch)=Clock/((1025-Val("&B"+Right$(AA$,4)))*32)
   EndIf
  Else
   Ton(Ch)=Clock/((1025-Val("&B"+Right$(BB$,6)+Right$(AA$,4)))*32)
  EndIf
 EndIf

 'BMP SCROLLING
 If BMPScr=1 Then BMPScroller

GoTo BackLoop

   no=0
   If (Reg=4 Or Reg=3 Or Reg=5 Or Reg=13) And Bit>15 Then no=1
   If (Reg=6 Or Reg=8 Or reg=9 Or Reg=10) And Bit>31 Then no=1
   If no=0 Then
   EndIf

' RETURN TO THE FILE SELECTION
BackDir:
 Option Error Abort
 ChangeSpeed(0)
 Silence
 Pause(100)
 Mode 1
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 BMPMode=0
 Close #1
 If BMPScr<>0 Then Close #2
GoTo ReadDir

' PLAY VGM INTERRUPT
Sub PlayVGM
 If MP>Buf Then RestartVGM
 Do While (Timer - StartTime <= PauseTime-2)
  Return
 Loop
 MP=MP+1
 H=Peek(VAR M$,MP)
 If H = &HA0 Then
  Reg=Peek(VAR M$,MP+1)
  Bit=Peek(VAR M$,MP+2)
  Port(D0,8)=Reg: Pin(D8)=0
  Port(D0,8)=Bit: Pin(D8)=1
  MP=MP+2
  Return
 EndIf
 If AY=0 Then
  If H=&H30 Then stereo=1: Pin(D9)=1: Pin(D10)=0
  If H=&H50 And stereo=1 Then Pin(D9)=0: Pin(D10)=1
  If H=&H4F Then
   H$=Hex$(Peek(VAR M$,MP+1))
   MP=MP+2
   If H$="FF" Then Pin(D9)=0: Pin(D10)=0
   If Left$(H$,1)<>"F" Then Pin(D9)=0: Pin(D10)=1
   If Right$(H$,1)<>"F" Then Pin(D9)=1: Pin(D10)=0
   H=Peek(VAR M$,MP)
  EndIf
 EndIf
 If (H=&H50 Or H=&H30) And AY=0 Then
  ThAgain=1
  Do While ThAgain=1
   ThAgain=0
   MP=MP+1
   Yant=Ymus
   Ymus=Peek(VAR M$,MP)
   Port(D0,8)=Ymus
   If Ymus=0 Then
    If Right$(Bin$(Yant),4)="0000" Then
     B$ = Right$("0000000"+Bin$(Yant),8)
     Port(D0,8)=0
     Pin(D12)=0
     Pin(D12)=1
     Port(D0,8)=Val("&B"+Left$(B$,4)+"0001")
    EndIf
   EndIf
   Pin(D12)=0
   Pin(D12)=1
   If Peek(VAR M$,MP+1)=&H50 Then
    MP=MP+1
    ThAgain=1
    If MP>Buf Then ThAgain=0: Return
   EndIf
  Loop
 ElseIf H = &H61 Then
  Temp = Peek(VAR M$,MP+2)*256+Peek(VAR M$,MP+1)
  PauseTime = SWait * Temp: MP=MP+2: StartTime = Timer: Return
 ElseIf H = &H62 Then
  PauseTime = Wait60: StartTime = Timer: Return
 ElseIf H = &H63 Then
  PauseTime = Wait50: StartTime = Timer: Return
 ElseIf H = &H66 Then
  If Loffset>=0 Then
   MP=Buf+1:I=Loffset
   RestartVGM
  Else
   I=L+1:MP=Buf+1
   Return
  EndIf
  Return
 ElseIf H >= &H70 And H <= &H7F Then
  Frames = (H - &H6F): PauseTime = SWait * Frames: StartTime = Timer: Return
 ElseIf H >= &H30 And H < &H50 Then
  MP=MP+1
 ElseIf H >= &H50 And H < &HC0 Then
  MP=MP+2
 ElseIf H >= &HC0 And H <= &HE0 Then
  MP=MP+3
 ElseIf H >= &HE1 Then
  MP=MP+4
 EndIf
End Sub

' TRY TO PLAY DIGITIZED VGM SOUNDS - DOESN'T WORK YET
PlayDig:
 If MP>Buf Then IReturn
 MP=MP+1
 If Peek(VAR M$,MP) = &H50 Then
  MP=MP+1
  AgainDig:
  If MP>Buf Then IReturn
  Pin(D12)=1
  Port(D0,8)=Peek(VAR M$,MP)
  Pin(D12)=0
  If Peek(VAR M$,MP+1) = &H50 Then
   MP=MP+2
   GoTo AgainDig
  EndIf
 EndIf
IReturn

MODPlayer:
 Open Music$ For INPUT As #1
  FileSize = Lof(#1)
  Cls
  Print@(0,0) "Song Title: "
  Print@(0,24) SeekHeaderChar$(0,20)
  Print@(0,60) "Sample Description:"
  For t = 0 To 14
   Print@(0,84+12*t) SeekHeaderChar$(20+30*t,22)
  Next t
 Close #1
 If FileSize > 150000 Then GoTo ReadDir
 If ShowMenu(4)=1 Then
  tt=ShowMenu(5)
  PlayMOD STOP
  Copy music$ To "a:temp.mod"
  PlayMOD "A:temp.mod"
  Result=0
  Do While Result=0
   I$ = Inkey$
   If UCase$(I$)="B" Then Result=1
   If I$=Chr$(27) Then Result=2
  Loop
  If Result=2 Then PlayMOD STOP
  Do While KeyDown<>0
  Loop
 EndIf
GoTo ReadDir

' PLAY RAW 8 BIT UNSIGNED 8000 HZ - VERY BAD! (YET)
PlayRAW:
 I=1
 Open Music$ For INPUT As #1
 Seek #1,1
 M$ = Input$(255,#1)
 PWM 0,100,100
 RAWI=1
 ChangeSpeed(0)
 Do While Eof(#1)=0
  If Eof(#1) Then Close #1: Tone stop: GoTo ReadDir
  K$ = UCase$(Inkey$)
  If K$ = "N" Then RAWI=RAWI+10000
  If K$ = "P" Then
   RAWI=RAWI-10000
   If RAWI<1 Then RAWI=1
  EndIf
  RawInt
  If K$ = Chr$(27) Then
   Tone STOP: Mode 1: Cls: Close #1: GoTo ReadDir
  EndIf
 Loop
 Tone STOP: Mode 1: Cls: Close #1
GoTo ReadDir

'PLAYING RAW IN BACKGROUND
Sub RAWInt
 Seek #1,RAWI
 M$ = Input$(255,#1)
 RAWI=RAWI+255
 For RAWP=1 To 255
  PWM 4500+Peek(VAR M$,RAWP)*15
 Next RAWP
End Sub

'SIMPLE BMP EDITOR
EditBMP:
 If notcls=0 Then Cls
 notcls=0
 LoadBMP file$(sel),xb,yb
 SP=1:CO=-1
 EndEdit=0
 LOW=0: Smode=1: StartBMP=0
 If Smode=1 And fullscreen=0 Then
  Line(0,MM.VRes-38)-(MM.HRes,MM.VRes),0,Bf
  Print@(0,MM.VRes-36+12*0) "PgUp: Up     PgDown: Down      F:Fullscr"
  Print@(0,MM.VRes-36+12*1) "   >: Right       <: Left"
  Print@(0,MM.VRes-36+12*2) " Esc: Back        C: Create Sprite -"
  Print@(212,MM.VRes-36+12*2,1) ">"
  Line(MM.HRes-18,MM.VRes-18)-(MM.HRes-1,MM.VRes-1),1,B
 Else
  x=100: y=-16
 EndIf
 Do While EndEdit=0
  If Smode=1 Then BLIT x-7,y-7,MM.HRes-17,MM.VRes-17,16,16: Pause(20)
  If StartBMP=1 Then
   For T=1 To 2 - Smode
    If Smode=0 Then
     Pixel(X-T,Y)=XL(T)
     Pixel(X+T,Y)=XR(T)
     Pixel(X,Y-T)=YU(T)
     Pixel(X,Y+T)=YD(T)
    Else
     Pixel(X-T*8,Y-T*8)=XL(T)
     Pixel(X+T*9,Y-T*8)=XR(T)
     Pixel(X-T*8,Y+T*9)=YU(T)
     Pixel(X+T*9,Y+T*9)=YD(T)
    EndIf
   Next T
  EndIf
  StartBMP=1
  K=KeyDown
  If K=27 Then EndEdit=1
  If K=131 Then X=X+1
  If K=130 Then X=X-1
  If K=129 Then Y=Y+1
  If K=128 Then Y=Y-1
  If K=137 Then yb=yb+64: GoTo EditBMP
  If K=136 Then yb=yb-64: GoTo EditBMP
  If K=Asc(">") Then xb=xb+64: GoTo EditBMP
  If K=Asc("<") Then xb=xb-64: GoTo EditBMP
  If K=Asc("F") Or K=Asc("f") Then
   If fullscreen=1 Then
    fullscreen=0: notcls=1: GoTo EditBMP
   Else
    fullscreen=1: notcls=1: GoTo EditBMP
   EndIf
  EndIf

  ' CREATE SPRITE FROM BMP
  If (K=Asc("C") Or K=Asc("c")) And Smode=1 Then
   K=0
   For t=1 To 16
    For tt=1 To 16
     XY(t,tt)=Pixel(t+MM.HRes-18,tt+MM.VRes-18)
    Next tt
   Next t
   ' TEST IF FILE EXIST
   F$=Left$(file$(sel),Instr(1,file$(sel),".")-1)+".SPR"
   Option Error Continue
   Open F$ For INPUT As #3
   If MM.Errno<>0 Then
    Option Error Abort
    SpriteNewFile(F$)
    Open F$ For input As #3
    NotAdd=1
    SP=1
   Else
    NotAdd=0
   EndIf
   ' SEARCH FOR THE MAX SPRITE NUMBER
   For T=1 To 5
    Line Input #3,Max$
    I=Instr(1,Max$,",")
    If I>0 Then
     MaxSpr=Val(Right$(Max$,Len(Max$)-I))
    EndIf
   Next T
   NotGetSpr=1
   SeekSpr=Lof(#3)-16*18-16
   Close #3
   If NotAdd=0 Then
    SP=MaxSpr
    SpriteOp(2)
    Open F$ For input As #3
    SeekSpr=Lof(#3)
    If MaxSpr=1 Then SeekSpr=SeekSpr-15
    Close #3
   EndIf
   GoSub SpriteSave
   GoTo EditBMP
  EndIf
  For T=1 To 2 - Smode
   If Smode=0 Then
    XL(T)=Pixel(X-T,Y-T)
    XR(T)=Pixel(X+T,Y-T)
    YU(T)=Pixel(X-T,Y+T)
    YD(T)=Pixel(X+T,Y+T)
   Else
    XL(T)=Pixel(X-T*8,Y-T*8)
    XR(T)=Pixel(X+T*9,Y-T*8)
    YU(T)=Pixel(X-T*8,Y+T*9)
    YD(T)=Pixel(X+T*9,Y+T*9)
   EndIf
  Next T
  C=C+1: If C>7 Then C=1
  For T=1 To 2 - Smode
   If Smode=0 Then
    Pixel(X-T,Y)=C
    Pixel(X+T,Y)=C
    Pixel(X,Y-T)=C
    Pixel(X,Y+T)=C
    If CO>=0 Then Pixel(X,Y)=CO
   Else
    Pixel(X-T*8,Y-T*8)=C
    Pixel(X+T*9,Y-T*8)=C
    Pixel(X-T*8,Y+T*9)=C
    Pixel(X+T*9,Y+T*9)=C
   EndIf
  Next T
  Pause(10)
 Loop
 Mode 1: Cls
GoTo ReadDir

' SPRITE SELECTOR
SpriteSelect:
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
 Option Error Abort
 Sprite Load file$(sel)
 xsp=2:ysp=2
 For T=1 To MaxSpr
  'Print@(xsp+13,ysp+3) T
  Line(xsp-2,ysp-2)-(xsp+17,ysp+17),Blue,B
  Sprite Paste T,xsp,ysp
  ysp=ysp+19
  If ysp+36>MM.VRes Then xsp=xsp+19: ysp=2
 Next T
 EndSprEdit=0
 NotGetSpr=0
 ST=1: CopySpr=0
 Print@(90,MM.VRes-22) "E: Edit"
 Print@(90,MM.VRes-11)  "C: Copy"
 Print@(170,MM.VRes-22) "Del: Delete"
 Print@(170,MM.VRes-11) "  A: Add"
 Print@(1,MM.VRes-22) " Preview -"
 Print@(57,MM.VRes-22,1) ">"
 Print@(1,MM.VRes-11) " Num: "
 BPC=0
 Do While EndSprEdit=0
  K=KeyDown
  XX=X: YY=Y
  Line(x-2,y-2)-(x+17,y+17),1,B
  If K=131 And ST=0 Then X=X+19
  If K=130 And ST=0 Then X=X-19
  If K=129 And ST=0 Then Y=Y+19
  If K=128 And ST=0 Then Y=Y-19
  If K=Asc("C") Or K=Asc("c") Then
   CopySpr=SP
   Print@(90,MM.VRes-11)  "P: Paste"
   Line(143,MM.VRes-20-2)-(145+17,MM.VRes-20+17),0,BF
   Sprite Paste CopySpr, 145,MM.VRes-20
   Line(143,MM.VRes-20-2)-(145+17,MM.VRes-20+17),1,B
   GoSub SpriteMatrix
  EndIf
  If (K=Asc("P") Or K=Asc("p")) And CopySpr>0 Then
   T=MM.HRes/2-55: TT=MM.VRes/2-10
   Line(T-10,TT-10)-(T+109,TT+20),0,BF
   Line(T-10,TT-10)-(T+109,TT+20),7,B
   Print@(T,TT) "Wait a moment ..."
   NotGetSpr=1
   GoSub SpriteMatrix
   CopySpr=0
   SaveMatrix=2
   GoSub SpriteSave
   NotGetSpr=0
   Sprite Unload
   GoTo SpriteSelect
  EndIf
  If K=Asc("E") Or K=Asc("e") Then CopySpr=0: GoTo SpriteMatrix
  If K=Asc("A") Or K=Asc("a") Then SpriteOp(0): GoTo SpriteSelect
  If K=127 And MaxSpr>1 Then SpriteOp(1): GoTo SpriteSelect
  If K=27 Then EndSprEdit=1
  If (K=Asc("B") Or K=Asc("b")) And ST=0 Then
   BPC=BPC+1: If BPC>7 Then BPC=0
  EndIf
  If Y+38>MM.VRes Then X=X+19:Y=2
  If Y<2 Then X=X-19:Y=2+9*19
  If X<2 Then X=2: Y=YY
  If X>((MaxSpr/10)*19+2) Then X=XX
  SSP=SP: SP=Int((X/19)*10 + (Y/19))
  If SP>MaxSpr Or SP<1 Then X=XX: Y=YY: SP=SSP
  Line(x-2,y-2)-(x+17,y+17),7,B
  If ST=1 Then
   Print@(37,MM.VRes-11) Str$(SP)+" "
  EndIf
  If (K>=128 And K<=131) Or K=Asc("B") Or K=Asc("b") Then
   ST=1:T=MM.VRes-20
   Line(68-2,T-2)-(68+17,T+17),1,b
   Line(68-1,T-1)-(68+16,T+16),BPC,BF
   Sprite Paste SP,68,T
  Else
   ST=0
  EndIf
  Pause(10)
 Loop
 Sprite Unload
 Mode 1: Cls
 GoTo ReadDir

' SHOW SPRITE MATRIX ZOOMED
SpriteMatrix:
 BPC=0
 T=MM.HRes/2-35: TT=MM.VRes/2-10
 If CopySpr=0 Then
  Line(T-10,TT-10)-(T+68,TT+20),0,BF
  Line(T-10,TT-10)-(T+68,TT+20),7,B
  Print@(T,TT) "Loading..."
 EndIf
 ' SEARCH FOR THE SPRITE AND PUT IN A MATRIX TO EDIT
 Open file$(sel) For INPUT As #1
 NumL=-1: LY=0
 SeekSpr=0: SeekT=0: FoundS=0: EndSC=0
 Do While Eof(#1)=0 And EndSC=0
  Line Input #1,Spr$
  I=Instr(1,Spr$,",")
  II=Instr(1,Spr$,"'")
  If I<=0 And II<=0 Then
   NumL=NumL+1
   If NumL>=(SP-1)*16 And NumL<=(SP-1)*16+15 Then
    LY=LY+1
    If FoundS=0 Then FoundS=1: SeekSpr=SeekT
    For XT=1 To 16
     TT$=Mid$(Spr$,XT,1)
     If TT$>="0" And TT$<="7" Then TC=Val(TT$) Else TC=-1
     If NotGetSpr=0 Then XY(XT,LY)=TC
    Next XT
   ElseIf NumL>(SP-1)*16+15 Then
    EndSC=1
   EndIf
  EndIf
  SeekT=SeekT+Len(Spr$)+2
 Loop
 Close #1
 If CopySpr>0 Then Return
 Cls
 ' START SHOWING REAL SCALE SPRITE PREVIEW
 MiniSpriteMatrix:
 S=8
 Line(XT+140-19,YT+S-17)-(XT+142,YT+S+4),BPC,BF
 For XT=1 To 16
  For YT=1 To 16
   Line(XT*S,YT*S)-(XT*S+S,YT*S+S),1,B
   If XY(XT,YT)>=0 Then
    Line(XT*S+1,YT*S+1)-(XT*S+S-1,YT*S+S-1),XY(XT,YT),BF
    Pixel(XT+140,YT+S+2)=XY(XT,YT)
   Else
    Line(XT*S+1,YT*S+1)-(XT*S+S-1,YT*S+S-1),BPC,BF
    Pixel(XT*S+S/2,YT*S+S/2)=1
   EndIf
  Next YT
 Next XT
 Line(XT+140-19,YT+S-17)-(XT+142,YT+S+4),1,b
 Print@(XT+160-13,YT+S-17+12*0) "B: Preview"
 Print@(XT+160-13,YT+S-17+12*1) "   Bg Colour"
 Print@(XT+135,YT+S-9+12*2) "SPC: Set Pixel"
 Print@(XT+135,YT+S-9+12*3) "Esc: Return"
 Print@(XT+135,YT+S-9+12*4) "Del: Transp."
 Color 7,0: Print@(XT+170-19,YT+S+52+14*2) " 0: Black   "
 Color 0,1: Print@(XT+170-19,YT+S+52+14*3) " 1: Blue    "
 Color 0,2: Print@(XT+170-19,YT+S+52+14*4) " 2: Green   "
 Color 0,3: Print@(XT+170-19,YT+S+52+14*5) " 3: Cyan    "
 Color 0,4: Print@(XT+170-19,YT+S+52+14*6) " 4: Red     "
 Color 0,5: Print@(XT+170-19,YT+S+52+14*7) " 5: Magenta "
 Color 0,6: Print@(XT+170-19,YT+S+52+14*8) " 6: Yellow  "
 Color 0,7: Print@(XT+170-19,YT+S+52+14*9) " 7: White   "
 Color 7,0
 Print@(4,YT+128+12*0) "S: Save      R: Rotate 90"
 Print@(154,YT+132+12*0-5) "."
 Print@(4,YT+128+12*1) "V: Vertical  H: Horizontal"
 Print@(4,YT+128+12*2) "F: Free Rot. C: Chg. Color"
 Line(0,YT+129+12*0-3)-(XT+170-25,YT+128+12*3),1,B

 Print@(4,YT+138+12*3) "   <: Left        >: Right"
 Print@(4,YT+138+12*4) "PgUP: Up     PgDown: Down "
 Line(0,YT+138+12*3-3)-(XT+170-25,YT+138+12*5),1,B

 For T=2 To 9
  Line(XT+170-20,YT+S+51+14*T)-(XT+223,YT+S+52+14*T),T-2,BF
 Next T
 Line(XT+170-20,YT+S+50+14*2)-(XT+222,YT+S+64+14*9),1,B
 EndSprMat=0
 Co=0
 FirstEdit=1
 Do While EndSprMat=0
  K=KeyDown
  If FirstEdit=0 Then Line(XX*S,YY*S)-(XX*S+S,YY*S+S),1,B
  FirstEdit=0
  If Co>0 Then
   Color Co,Co
  Else
   Color 0,0
  EndIf
  If Co>=0 Then T=Co+2 Else T=10
  Print@(XT+170-19,YT+S+52+14*T) ">"
  Color 7,0
  If K=131 And ST=0 Then XX=XX+1
  If K=130 And ST=0 Then XX=XX-1
  If K=129 And ST=0 Then YY=YY+1
  If K=128 And ST=0 Then YY=YY-1
  If K>=128 And K<=131 Then ST=1 Else ST=0
  If K=27 Then EndSprMat=1
  For T=48 To 55
   If K=T Then Co=T-48
  Next T
  Del=0
  If K=127 Then K=32: Cot=Co: Co=-1: Del=1
  If K=32 Then
   XY(XX,YY)=Co
   If Co>=0 Then
    Line(XX*S+1,YY*S+1)-(XX*S+S-1,YY*S+S-1),Co,BF
    Pixel(XX+140,YY+S+2)=Co
   Else
    Line(XX*S+1,YY*S+1)-(XX*S+S-1,YY*S+S-1),BPC,BF
    Pixel(XX*S+S/2,YY*S+S/2)=1
    Pixel(XX+140,YY+S+2)=BPC
   EndIf
  EndIf
  If Del=1 Then Co=Cot
  If K=Asc("B") Or K=Asc("b") Then
   BPC=BPC+1
   If BPC>7 Then BPC=0
   GoTo MiniSpriteMatrix
  EndIf
  If K=Asc("H") Or K=Asc("h") Then
   For XT=1 To 16
    For YT=1 To 16
     XYT(XT,YT)=XY(17-XT,YT)
    Next YT
   Next XT
   For XT=1 To 16
    For YT=1 To 16
     XY(XT,YT)=XYT(XT,YT)
    Next YT
   Next XT
   GoTo MiniSpriteMatrix
  EndIf
  If K=Asc("V") Or K=Asc("v") Then
   For XT=1 To 16
    For YT=1 To 16
     XYT(XT,YT)=XY(XT,17-YT)
    Next YT
   Next XT
   For XT=1 To 16
    For YT=1 To 16
     XY(XT,YT)=XYT(XT,YT)
    Next YT
   Next XT
   GoTo MiniSpriteMatrix
  EndIf
  If K=Asc("R") Or K=Asc("r") Then
   For XT=1 To 16
    For YT=1 To 16
     XYT(XT,YT)=XY(YT,17-XT)
    Next YT
   Next XT
   For XT=1 To 16
    For YT=1 To 16
     XY(XT,YT)=XYT(XT,YT)
    Next YT
   Next XT
   GoTo MiniSpriteMatrix
  EndIf
  If K=Asc("C") Or K=Asc("c") Then
   Print@(4,YT+128+12*2) Space$(26)
   Print@(4,YT+128+12*1) ""
   Input " Change To (0-7 or T): ",c$
   If c$="T" Or c$="t" Then C$="-1"
   CoA=Pixel(XX+140,YY+S+2)
   For XT=1 To 16
    For YT=1 To 16
     If XY(XT,YT)=CoA Then XY(XT,YT)=Val(C$)
    Next YT
   Next XT
   GoTo MiniSpriteMatrix
  EndIf
  If K=136 Or K=137 Or K=Asc("<") Or K=Asc(">") Then
   If K=136 Then ' PAGE DOWN
    For XT=1 To 16
     For YT=1 To 15
      XYT(XT,YT)=XY(XT,YT+1)
      XYT(XT,16)=XY(XT,1)
     Next YT
    Next XT
   ElseIf K=137 Then ' PAGE UP
    For XT=1 To 16
     For YT=2 To 16
      XYT(XT,YT)=XY(XT,YT-1)
      XYT(XT,1)=XY(XT,16)
     Next YT
    Next XT
   ElseIf K=Asc(">") Then
    For XT=2 To 16
     For YT=1 To 16
      XYT(XT,YT)=XY(XT-1,YT)
      XYT(1,YT)=XY(16,YT)
     Next YT
    Next XT
   ElseIf K=Asc("<") Then
    For XT=1 To 15
     For YT=1 To 16
      XYT(XT,YT)=XY(XT+1,YT)
      XYT(16,YT)=XY(1,YT)
     Next YT
    Next XT
   EndIf
   For XT=1 To 16
    For YT=1 To 16
     XY(XT,YT)=XYT(XT,YT)
    Next YT
   Next XT
   GoTo MiniSpriteMatrix
  EndIf
  If K=Asc("F") Or K=Asc("f") Then
   Print@(4,YT+128+12*2) Space$(26)
   Print@(4,YT+128+12*1) ""
   Input " Insert Degree: ",deg$
   ang=-Val(deg$)*0.0174533
   For XT=1 To 16
    For YT=1 To 16
     XXT= Cos(-ang)*(XT-8) + Sin(-ang)*(YT-8)+8
     YYT=-Sin(-ang)*(XT-8) + Cos(-ang)*(YT-8)+8
     If XXT<=16 And YYT<=16 And XXT>0 And YYT>0 Then
      XYT(XT,YT)=XY(XXT,YYT)
     Else
      XYT(XT,YT)=-1
     EndIf
    Next YT
   Next XT
   For XT=1 To 16
    For YT=1 To 16
     XY(XT,YT)=XYT(XT,YT)
    Next YT
   Next XT
   GoTo MiniSpriteMatrix
  EndIf
  If K=Asc("S") Or K=Asc("s") Then SaveMatrix=1: GoTo SpriteSave
  If XX>16 Then XX=1
  If YY>16 Then YY=1
  If XX<1 Then XX=16
  If YY<1 Then YY=16
  Line(XX*S,YY*S)-(XX*S+S,YY*S+S),7,B
  If Co>0 Then
   Color 0,Co
  Else
   Color 7,0
  EndIf
  Print@(XT+170-19,YT+S+52+14*(Co+2)) ">"
  Color 7,0
  Pause(10)
 Loop
 Sprite Unload
GoTo SpriteSelect

' SAVE MEMORY MATRIX INTO SPRITE FILE
SpriteSave:
 If NotGetSpr=0 Then Print@(4,YT+128+12*0) "S: Saving..."
 F$=Left$(file$(sel),Instr(1,file$(sel),".")-1)+".SPR"
 Open F$ For RANDOM As #1
 NumL=-1: LY=0
 Dif=0
 If SaveMatrix=2 Then SeekSpr=SeekSpr+1: SaveMatrix=0
 If SaveMatrix=1 Then SeekSpr=SeekSpr+1: SaveMatrix=0
 n=0: TSeekSpr=SeekSpr+1
 For YT=1 To 16
  Seek #1,TSeekSpr
  Spr$=""
  For XT=1 To 16
   Co=XY(XT,YT)
   If Co>=0 Then Spr$=Spr$+Chr$(48+Co) Else Spr$=Spr$+Chr$(32)
  Next XT
  Print#1,Spr$
  TSeekSpr=TSeekSpr+18
 Next YT
 Close #1
 If NotGetSpr>0 Then Return
GoTo SpriteMatrix

'SPRITE OPERATIONS: 0 - ADD, 1 - DEL, 2 - INCREASE MAX SPR NUMBER
Sub SpriteOp(Op)
 T=MM.HRes/2-55: TT=MM.VRes/2-10
 Line(T-10,TT-10)-(T+109,TT+20),0,BF
 Line(T-10,TT-10)-(T+109,TT+20),7,B
 Print@(T,TT) "Wait a moment ..."
 F$=Left$(file$(sel),Instr(1,file$(sel),".")-1)+".SPR"
 Open F$ For input As #1
 Open "CDNTMP.SPR" For output As #2
 NumL=-1
 Print #2,"' SPRITES MADE WITH CDN MEDIA STUDIO"
 If Op=0 Or Op=2 Then
  T=MaxSpr+1
 ElseIf Op=1 Then
  T=MaxSpr-1
 EndIf
 Print #2,"16,"+Str$(T)+Chr$(13)
 Do While Eof(#1)=0
  Line Input #1,Spr$
  I=Instr(1,Spr$,",")
  II=Instr(1,Spr$,"'")
  If I<=0 And II<=0 Then
   NumL=NumL+1
   If Op=0 Then
    Print #2,Spr$
    If NumL=(SP-1)*16+15 Then
     For YT=1 To 16
      Print #2, Space$(16)'+Chr$(13)
     Next YT
    EndIf
   ElseIf Op=1 Then
    If NumL<(SP-1)*16 Or NumL>(SP-1)*16+15 Then Print #2,Spr$
   ElseIf Op=2 Then
    Print #2,Spr$
   EndIf
  EndIf
 Loop
 Close #1: Close #2
 Copy "CDNTMP.SPR" To F$
 Kill "CDNTMP.SPR"
 If NotGetSpr=0 Then Sprite Unload
End Sub

' CREATE NEW SPRITE FILE
Sub SpriteNewFile(NewFile$)
 Open NewFile$ For output As #2
 Print #2,"' SPRITES MADE WITH CDN MEDIA STUDIO"
 Print #2,"16,1"+Chr$(13)
 For YT=1 To 16
  Print #2, Space$(16)+Chr$(13)
 Next YT
 Close #2
End Sub

' READ AS A TEXT
ReadText:
 Cls
 t=ShowMenu(0)
 Open file$(sel) For input As #2
 No=0: T=-1
 Do While No=0
  Print@(0,T*12)
  Line Input #2, A$ + Space$(78-Len(A$))
  Print A$: T=T+1
  If Eof(#2)<>0 And T<=28 Then T=29
  If T>29 Then
   T=29
   NoB=0
   Do While NoB=0
    K=KeyDown
    If K=129 Then YY=YY+1: NoB=1
    If K=128 Then YY=YY-1: NoB=1
    If Eof(#2)<>0 Then NoB=0
    If K=27 Then Nob=1: No=1
   Loop
   BLIT 0,12,0,0,MM.HRes,MM.VRes-70
  EndIf
 Loop
 Close #2
 Cls
GoTo ReadDir
