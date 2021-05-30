' MSTUDIO FOR COLOUR MAXIMITE

Mode 1:Cls
sel=1:selant=1

For TT = 0 To 23
 SetPin 11+TT,8
 Pin(11+TT) = 1
Next TT
Pin(D13)=0

Library Load "b:\mstudio\psglib.lib"
InitSound
Library UnLoad "b:\mstudio\psglib.lib"

Sub ResetVar
 A$=Right$("0000000000000000"+Bin$(yf),16)
 B$=Right$("0000000000000000"+Bin$(yfant),16)
 Poke RVIDEO,0,xf
 Poke RVIDEO,1,Val("&B"+Right$(A$,8))
 Poke RVIDEO,2,Val("&B"+Left$(A$,8))
 Poke RVIDEO,3,xfant
 Poke RVIDEO,4,Val("&B"+Right$(B$,8))
 Poke RVIDEO,5,Val("&B"+Left$(B$,8))
 Poke RVIDEO,6,sel:Poke RVIDEO,7,selant
 Clear
 xf=Peek(RVIDEO,0)
 yf=Peek(RVIDEO,1):yf=yf+Peek(RVIDEO,2)*256
 xfant=Peek(RVIDEO,3)
 yfant=Peek(RVIDEO,4):yfant=yfant+Peek(RVIDEO,5)*256
 sel=Peek(RVIDEO,6):selant=Peek(RVIDEO,7)
 Prg$ = "MStudio - v0.87b"
 Author$ = "Mauro Xavier - 2019"
 CP$="": DirCP$=""
 Dim File$(255) length 12
 Dim TP$(8) LENGTH 3
 Dim XL(2),XR(2),YU(2),YD(2)
 Dim XY(16,16),XYT(16,16)
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 fullscreen=0: notcls=0
 stype=1
End Sub

' READ KEYBOARD IN THE COORDINATES WITH A MASK
Function ReadKey$(xk,yk,rant$,max,ex)
 Local A$
 RK$=rant$
 ext$=Right$(RK$,Len(RK$)-Instr(1,RK$,"."))
 A$=""
 If ex=1 Then RK$=Left$(rant$,Instr(1,RK$,".")-1): A$=Space$(max+1)
 Print@(xk,yk) RK$+"_ "+A$
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
 ShowMenu = 0
 If bmpmode=0 Then
  Line(0,maxy-55)-(maxx,maxy-9),0,BF
  ScanLine White,0,MaxY
  Line(0,maxy-56)-(maxx,maxy-56)
  ScanLine Yellow,MaxY-56,MaxY-56
  ScanLine Cyan,MaxY-53,MaxY-8
  ScanLine Green,MaxY-8,MaxY
 EndIf
 yt=maxy-8
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
  Print@(120,yt) " S: new Sprite": yt=yt+12
  yt=maxy-52
  Print@(240,yt) "C: Copy ";CP$;String$(12-Len(CP$)," "): yt=yt+12
  Print@(240,yt) "P: Paste": yt=yt+12
  If Len(CP$)>0 Then
   Print@(240,yt) "M: Move"
  Else
   Print@(240,yt) "M: new Map"
  EndIf
  yt=yt+12
  Print@(240,yt) "T: Text view"
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
   If UCase$(I$)="S" Or I$=Chr$(27) Then ShowMenu=2
  Loop
 ElseIf Menu=3 Then
  yt=maxy-52
  Print@(0,yt) "Esc: Back": yt=yt+12
  yt=yt+12
  yt=maxy-52
  Print@(353,yt) "Up/Down: Change Speed": yt=yt+12
  If AY=0 Then
   Print@(353,yt) "      T: Sound Type"
   Print@(0,yt) "S: Sound Out": yt=yt+12
   If SType=1 Then
    EnablePSG(1): SetAY(0)
    Print@(0,yt) "   SN76489 Card   "
   ElseIf SType=2 Then
    PlayVGM
    Print@(0,yt) "   PWM Channel 0,1"
    If MusicInit=0 Then MusicInit=1
    PWMMus=1: PWMChannel(0,1,sql)
    SetIntMusic(0)
    Silence
    SetIntMusic(2+sql*3)
   ElseIf SType=3 Then
    PlayVGM: SetIntMusic(2+sql*3)
    Print@(0,yt) "   PWM Channel 1,2  "
    PWMMus=1: PWMChannel(1,2,sql)
   ElseIf SType=4 Then
    PlayVGM: SetIntMusic(2+sql*3)
    Print@(0,yt) "   PWM Channel 0,2  "
    PWMMus=1: PWMChannel(0,2,sql)
   EndIf
  Else
   If ClkDiv=0 Then A$="/2" Else A$="  "
   SetAY(1)
   Print@(389,yt) "C: Clock Div"+A$
  EndIf
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
If CP$="" Then ResetVar
Mode 1: Cls
maxx=MM.HRes-1
maxy=MM.VRes-1
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
TP$(8)="MAP"
FileQt=0
For T = 1 To 8
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
 For T=1 To 8
  If Right$(file$(sel),1+Len(TP$(T)))="."+TP$(T) Then
   Print@(xf,yf,2) file$(sel)
   TPFound=1
  EndIf
 Next T
 If TPFound=0 Then Print@(xf,yf,2) "["+file$(sel)+"]"

 TPFound=0
 For T=1 To 8
  If Right$(file$(selant),1+Len(TP$(T)))="."+TP$(T) Then
   Print@(xfant,yfant,0) file$(selant):TPFound=1
  EndIf
 Next T
 If TPFound=0 Then
  Print@(xfant,yfant,0) "["+file$(selant)+"]"
 EndIf

 Pause(5)
 I$=UCase$(Inkey$)
 If I$=Chr$(27) Then Cls: End
 If I$=Chr$(13) Then DIG=0: GoTo Action: EndIf
 If UCase$(I$)="V" Then Dig=1: GoTo Action: EndIf
 If UCase$(I$)="T" Then GoTo ReadText

 Scroll=0
 If UCase$(I$)="0" Then
  If Instr(1,file$(sel),".BMP")>0 And Len(file$(sel))>3 Then
   Scroll=1: GoTo Action
  EndIf
 EndIf

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
   GoTo ReadDir
  EndIf
 EndIf

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

 If I$=Chr$(145) Then GoTo About

 If I$=Chr$(146) Then
  If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
   Ren$=ReadKey$(xf,yf,file$(sel),8,1)
   If Ren$<>"" Then
    Name file$(sel) As Ren$
    GoTo ReadDir
   EndIf
  EndIf
 EndIf

 If UCase$(I$)="S" Or UCase$(I$)="M" Then
  If UCase$(I$)="S" Then
   spr=1: A$=".SPR"
  Else
   spr=0: A$=".MAP"
  EndIf
  file$(sel+1)=A$
  If Instr(1,file$(sel+1),".")>0 And Len(file$(sel+1))>3 Then
   Ren$=ReadKey$(spr*144+(1-spr)*258,MM.VRes-29,file$(sel+1),8,1)
   If Ren$<>"" Then
    If Spr=1 Then SpriteNewFile(REN$) Else MapNewFile(REN$)
   EndIf
  EndIf
  GoTo ReadDir
 EndIf

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

Action:
 BMPMode=0
 FileType$=Right$(file$(sel),4)
 If Instr(1,file$(sel),".")>0 And Len(file$(sel))>3 Then
  CP$="": DirCP$=""
 EndIf
 If FileType$=".MOD" Then
  Music$=file$(sel)
  GoTo MODPlayer
 ElseIf FileType$=".RAW" Then
  Music$=file$(sel)
  GoTo PlayRAW
 ElseIf FileType$=".MAP" Then
  GoTo MapEditor
 ElseIf FileType$=".VGM" Then
  Music$=file$(sel)
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
 ElseIf FileType$=".PSG" Then
  Music$=file$(sel)
  GoTo PSGInit
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
     If Inkey$ = Chr$(13) Then Close #2: GoTo ReadDir
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
  GoTo ReadDir
 ElseIf Right$(file$(sel),4)=".SPR" Then
  X=2: Y=2
  GoTo SpriteSelect
 ElseIf Right$(file$(sel),4)=".FNT" Then
  TT=ShowMenu(1)
  Mode TT: Cls
  ' MIN AND MAX FONT NUMBER
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
  GoTo ReadDir
 Else
  Chdir file$(sel)
  sel=1: selant=1
  xf=0: yf=0: xfant=0: yfant=0
  GoTo ReadDir
 EndIf

Sub SendByte(Num)
 If Num>0 Then
  Pin(D8)=1
  Port(D0,8)=Num
  Pin(D8)=0
  Pause(0.1)
  Pin(D8)=1
 EndIf
End Sub

Function SeekHeaderNull$(H,search)
A$=""
i=0
Seek #4,H+1
B$ = Input$(250,#4)
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

'Function SeekHeaderInt(H,size,num)
' Local S
' Temp$ = ""
' For S = size To 1 Step -1
'  Seek #num, H+S
'  Temp$ = Temp$ + Hex$(Asc(Input$(1,#num)))
' Next S
' SeekHeaderInt = Val("&H"+Temp$)
'End Function

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
End Sub

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
 For tt=0 To 2 Step 2
  BX = BX + 1
  BA$=Input$(BMPWidth,#2)
  For BY = 1 To WA
    Pixel(236+tt,BY*2+1)=Peek(VAR BA$,BY+1)/16
    Pixel(236+tt,BY*2)=Peek(VAR BA$,BY) Mod 8
  Next BY
  For BY = WA+1 To WB
    Pixel(237+tt,BY*2+1-WB)=Peek(VAR BA$,BY+1)/16
    Pixel(237+tt,BY*2-WB)=Peek(VAR BA$,BY) Mod 8
  Next BY
 Next tt
 BLIT 4,0,0,0,237,WB+1
 Line(236,0)-(239,WB+2),Black,bf
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

Function SeekHeaderHexa$(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #4, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#4)))
 Next S
 SeekHeaderHexa$ = Temp$
End Function

Function SeekHeaderBCD$(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #4,H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#4)))
 Next S
 SeekHeaderBCD$ = Temp$
End Function

Sub ReadGD3Header
 Temp$ = ""
 For T=1 To 20
  GD$(T) = ""
 Next T
 ID=0: Jump=1
 GD3=SeekHeaderInt(&H14,4)
 If GD3<>0 Then
  S=GD3
  Do While S < Lof(#4) And S<GD3+1000
   S=S+1
   Seek #4, S
   Temp$ = Temp$ + Input$(1,#4)
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

Sub ResetYM
 Pin(D8)=1  'WR
 Pin(D12)=1 'CS
 Pin(D13)=0 'IC
 Pin(19)=0  'A0
 Pin(20)=0  'A1
 Pin(D13)=1
End Sub

AYInit:
Print SeekHeaderChar$(0,4)
Print SeekHeaderChar$(4,8)
nb=SeekHeaderInt(12,4)
Print "Nb:";nb
SongAtr$=Bin$(SeekHeaderInt(16,4))
Print "Atrib:";SongAtr$
FrameLoop=SeekHeaderInt(24,4)
Print "FrameLoop:";FrameLoop
Print "Digidrums:";SeekHeaderInt(20,2)
ExtFreq=SeekHeaderInt(22,4)
Print "External Freq.:";ExtFreq
Print "Song Info:"
Print SeekHeaderNull$(28,10)
If Left$(SongAtr$,1)="1" Then GoTo backdir

PSGInit:
Library Load "b:\mstudio\psglib.lib"
Silence
Cls
InitSound
LoadPSG(Music$)

If BMPScr=0 Then
 tt=ShowMenu(3)
 Print "File Type:    "; SeekHeaderChar$(0,4)
 Print "File Name:    "; Music$
 Temp=Lof(#4)/1024
 Print "File Size:   ";  Lof(#4);" bytes / ";Format$(Temp,"%.2f");" Kb"
EndIf
PlayPSG
ChangeSpeed(1)
SetIntMusic(0.5)

LoopPSG:
Do While EndPSG=0
 I$ = Inkey$
 If I$<>"" Then
  If I$=Chr$(27) Then
   UnloadMusic
   Library UnLoad "b:\mstudio\psglib.lib"
   GoTo BackDir
  EndIf
  If I$=Chr$(128) Then Speed=Speed+0.5: ChangeSpeed(Speed)
  If I$=Chr$(129) Then Speed=Speed-0.5: ChangeSpeed(Speed)
  If UCase$(I$)="C" And AY=1 Then
   If ClkDiv=0 Then
    ClkDiv=1: A$="  "
   Else
    ClkDiv=0: A$="/2"
   EndIf
   If ClkDiv=0 Then A$="/2" Else A$="  "
   Print@(389,391) "C: Clock Div"+A$
   SetAY(1)
   Pin(D13)=ClkDiv
  EndIf
 EndIf
Loop
UnloadMusic
Library UnLoad "b:\mstudio\psglib.lib"
GoTo BackDir

VGMInit:
Library Load "b:\mstudio\psglib.lib"
initsound
LoadVGM(Music$)

Silence
Cls
If BMPScr=0 Then tt=ShowMenu(3)

Clk=SeekHeaderInt(&H0C,4)
ClkAY=SeekHeaderInt(&H74,4)
ClkYM=SeekHeaderInt(&H2C,4)
If ClkAY>0 Then SetAY(1)
If Clk>0 Then SetAY(0)

EOFoffset=SeekHeaderInt(&H04,4)
TotalSamples=SeekHeaderInt(&H18,4)
VGMoffset=SeekHeaderInt(&H34,4)
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

SNFL$=Bin$(SeekHeaderInt(&H2B,1))
SNFL$=String$(8-Len(SNFL$),"0")+SNFL$

Port(D10,2)=&B00
If Mid$(SNFL$,6,1) = "0" Then
 St$ = "Yes": Stereo=0
Else
 St$ = "No": Stereo=0
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
Rate = SeekHeaderInt(&H24,4)
If rate = 50 Then changeSpeed(1.1)

Dim GD$(20) length 255
ReadGD3Header

If BMPScr=1 Then GoTo NoInfo

Temp=Val(SeekHeaderBCD$(&H08,4))/100
Print "File Type:         "; SeekHeaderChar$(&H00,4);"Version";Temp
Print "File Name:         "; Music$
Temp=Lof(#4)/1024
Print "File Size:        ";  Lof(#4);" bytes / ";Format$(Temp,"%.2f");" Kb"
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

X=190: Y=12*5
Line(X-4,Y-2)-(475,Y+12*9-1),1,B
Print@(X,0)
If AY=1 Then
 Print@(X,Y) "AY Info:"
 Y=Y+12: Print@(X,Y,1)
 Y=Y+12: Print@(X,Y,1) "Clock:           "; Format$(ClkAY,"%.0f")
 If ClkAY=0 Then SetAY(1)
 Y=Y+12: Print@(X,Y,1) "Chip Type:       "; AYType$
Else
 Print@(X,Y) "SN76489 Info:"
 Y=Y+12: Print@(X,Y,1)
 Y=Y+12: Print@(X,Y,1) "Clock:           "; Format$(Clk,"%.0f")
 Y=Y+12: Print@(X,Y,1) "Stereo?          "; St$;
 Y=Y+12: Print@(X,Y,1) "/8 Clock Div:    "; ClkDiv$
 Y=Y+24: Print@(X,Y) "YM2612 Info:"
 Y=Y+12: Print@(X,Y,1)
 Y=Y+12: Print@(X,Y,1) "Clock:           "; Format$(ClkYM,"%.0f")
EndIf

Erase gd$

If ShowImage$<>"" Then
 Mode 4: Cls: LoadBMP ShowImage$
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 BMPMode=1
EndIf

NoInfo:

StartVGM:
PlayVGM
SetIntMusic(0.5)

BackLoop:
 I$ = UCase$(Inkey$)
 If I$=Chr$(27) Or EndMus=1 Then
  UnloadMusic
  Library UnLoad "b:\mstudio\psglib.lib"
  GoTo BackDir
 EndIf
 If I$="M" And AY=0 Then ForceMono=1: Port(D10,3)=&B000
 If I$="T" And AY=0 Then
  If sql=0 Then
   sql=1:tt=ShowMenu(3)
  Else
   sql=0:tt=ShowMenu(3)
  EndIf
 EndIf
 If I$="S" Then
  SType=SType+1
  If SType>4 Then
   SType=1: PWMMus=0: SetIntMusic(0): Silence: Pause(200): SetIntMusic(1)
  EndIf
  tt=ShowMenu(3)
 EndIf
 If I$="C" And AY=1 Then
  If ClkDiv=0 Then
   ClkDiv=1: A$="  "
  Else
   ClkDiv=0: A$="/2"
  EndIf
  Print@(389,391) "C: Clock Div"+A$
  Pin(D13)=ClkDiv
 EndIf
 If I$=Chr$(131) Then BLIT 0,0,236,0,4,212 :BLIT 4,0,0,0,236,212
 If BMPScr=1 Then BMPScroller
GoTo BackLoop

BackDir:
 Do While KeyDown=27: Loop
 Option Error Abort
 Pause(100)
 Mode 1
 maxx=MM.HRes-1
 maxy=MM.VRes-1
 BMPMode=0
 If BMPScr<>0 Then Close #2
GoTo ReadDir

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

PlayRAW:
 I=1:T=-5
 Open Music$ For INPUT As #1
 Seek #1,1
 M$ = Input$(255,#1)
 RAWI=1
 Mode 4
 Cls
 Line(38,57)-(46+152,57+86),7,B
 Do While Eof(#1)=0
  If Eof(#1) Then Close #1: Tone stop: GoTo ReadDir
  K$ = UCase$(Inkey$)
  If K$ = "N" Then RAWI=RAWI+10000: Seek #1,RAWI
  If K$ = "P" Then
   RAWI=RAWI-10000
   If RAWI<1 Then RAWI=1
   Seek #1,RAWI
  EndIf
  RawInt
  If K$ = Chr$(27) Then
   Tone STOP: Close #1: GoTo ReadDir
  EndIf
  BLIT 50,58,45,58,146,85,G
  For I=1 To 10
   Line(180+i,102)-(180+I,Peek(VAR M$,I*25)/3+60),2
  Next I
 Loop
 Tone STOP: Close #1
GoTo ReadDir

Sub RAWInt
 RAWI=RAWI+255
 M$ = Input$(255,#1)
 For RAWP=1 To 255 Step 1.4
  S=Peek(VAR M$,RAWP)/2.55
  PWM 1000000,S,S
 Next RAWP
End Sub

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

  If (K=Asc("C") Or K=Asc("c")) And Smode=1 Then
   K=0
   For t=1 To 16
    For tt=1 To 16
     XY(t,tt)=Pixel(t+MM.HRes-18,tt+MM.VRes-18)
    Next tt
   Next t
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
GoTo ReadDir

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
 GoTo ReadDir

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
 ' REAL SCALE SPRITE PREVIEW
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
   If K=136 Then
    For XT=1 To 16
     For YT=1 To 15
      XYT(XT,YT)=XY(XT,YT+1)
      XYT(XT,16)=XY(XT,1)
     Next YT
    Next XT
   ElseIf K=137 Then
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
      Print #2, Space$(16)
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

Sub SpriteNewFile(NewFile$)
 Open NewFile$ For output As #2
 Print #2,"' SPRITES MADE WITH CDN MEDIA STUDIO"
 Print #2,"16,1"+Chr$(13)
 For YT=1 To 16
  Print #2, Space$(16)+Chr$(13)
 Next YT
 Close #2
End Sub

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
GoTo ReadDir

MapEditor:
 Mode 4: Cls
 Dim MP(36,36)

 SprF$=Left$(file$(sel),Instr(1,file$(sel),".")-1)+".SPR"
 Open SprF$ For INPUT As #3
 For T=1 To 5
  Line Input #3,Max$
  I=Instr(1,Max$,",")
  If I>0 Then
   MaxSpr=Val(Right$(Max$,Len(Max$)-I))
  EndIf
 Next T
 Close #3
 Sprite Load (SprF$)

 Open file$(sel) For Input As #2
 Line Input #2,A$
 For y=1 To 36
  For x=1 To 38
   t=Asc(Input$(1,#2))
   If x<37 Then MP(x,y)=t
 Next x,y
 Close #2

 Print@(2,MM.VRes-42,1) "< >: Select"
 Print@(2,MM.VRes-31,1) "Spc: on/off"
 Print@(2,MM.VRes-20,1) "Del: Delete"
 Print@(2,MM.VRes-9,1) "Esc: Exit"
 Print@(192,MM.VRes-42,1) "N: Num."
 Print@(192,MM.VRes-31,1) "W: sWap"
 Print@(192,MM.VRes-20,1) "C: Copy"
 Print@(192,MM.VRes- 9,1) "S: Save"
 EndMapEdit=0: x=0: y=0

 TilSel=1: Til=1: RefTil=1
 xx=0: yy=0: sx=0: sy=0
 xa=1:xb=14:ya=1:yb=10:bkg=32

 Do While EndMapEdit=0
  If RefTil=1 Then
   RefTil=0
   For ty=ya To yb
     For tx=xa To xb
       T=MP(tx+sx,ty+sy)
       Line((tx-1)*17+1,(ty-1)*17+1)-((tx-1)*17+16,(ty-1)*17+16),0,BF
       Line((tx-1)*17,(ty-1)*17)-((tx-1)*17+17,(ty-1)*17+17),1,B
       If T>32 And T<=MaxSpr+32 Then
        Sprite Paste T-32,(tx-1)*17+1,(ty-1)*17+1
       EndIf
       If snumb=1 Or T>MaxSpr+32 Then putnum((tx-1)*17-6,(ty-1)*17+1,T)
    Next tx,ty
   EndIf
  EndIf
  xa=1:xb=14:ya=1:yb=10
  If TilSel=1 Then
   Print@(95,MM.VRes-20) "Char"
   If til+32>99 Then t=71 Else t=77
   Print@(T,MM.VRes-9) " "+Str$(Til+32)+"/255"
   Print@(145,MM.VRes-20) "Tile"
   Print@(145,MM.VRes-9) Str$(Til)+"/"+Str$(MaxSpr)+"  "
   Line(122,MM.VRes-20)-(141,MM.VRes-1),0,BF
   Line(122,MM.VRes-20)-(141,MM.VRes-1),1,B
   Sprite Paste Til,124,MM.VRes-18
   TilSel=0
  EndIf

  K=KeyDown
  If K>=128 And K<=131 Then tim=tim+1: If tim>100 Then st=0: tim=0
  If ST=0 Then
   If K=Asc("<") Then Til=Til-1: TilSel=1: If Til<1 Then Til=MaxSpr
   If K=Asc(">") Then Til=Til+1: TilSel=1: If Til>MaxSpr Then Til=1
   If K>=128 And K<=131 Then Line(xx*17,yy*17)-(xx*17+17,yy*17+17),1,B
   If k<>0 And (co>MaxSpr+32 Or snumb=1) Then PutNum(x-6,y+1,co)
   If K=131 Then xx=xx+1
   If K=130 Then xx=xx-1
   If K=129 Then yy=yy+1
   If K=128 Then yy=yy-1
   If XX<0 Then
    XX=0
    If sx+xx>0 Then sx=sx-1: RefTil=1: xb=1: BLIT 0,0,17,0,17*13,17*10
   EndIf
   If XX>13 Then
    XX=13
    If sx+xx<35 Then sx=sx+1: RefTil=1: xa=14: BLIT 17,0,0,0,17*13,17*10
   EndIf
   If YY<0 Then
    YY=0
    If sy+yy>0 Then sy=sy-1: RefTil=1: yb=1: BLIT 0,0,0,17,17*14,17*9
   EndIf
   If YY>9 Then
    YY=9
    If sy+yy<35 Then sy=sy+1: RefTil=1: ya=10: BLIT 0,17,0,0,17*14,17*9
   EndIf
   x=xx*17: y=yy*17
   co=MP(xx+1+sx,yy+1+sy)
   If K=83 Or K=115 Then MapSaveFile(file$(sel))
   If K=110 Or K=78 Then RefTil=1: If snumb=1 Then snumb=0 Else snumb=1
   If K=119 Or K=87 Then
    Bkg=MP(xx+1+sx,yy+1+sy)
    For ty=1 To 36
     For tx=1 To 36
      If MP(tx,ty)=Bkg Then MP(tx,ty)=Til+32
    Next tx,ty
    RefTil=1
    xa=1:xb=14:ya=1:yb=10
   EndIf
   If K=67 Or K=99 Then
    If co>32 Then TilSel=1: Til=co-32
   EndIf
   If K=127 Then Line(x,y)-(x+17,y+17),0,BF: MP(xx+sx+1,yy+sy+1)=32
   If K=13 Then
    T=co
    A$=Str$(Asc(Chr$(T)))
    Color 7
    I$=Inkey$
    Tile$=ReadKey$(x+1,y+1,A$,3,0)
    T=Val(Tile$)
    If T>32 And T<=255 Then
     MP(xx+sx+1,yy+sy+1)=T
     Line(x,y)-(x+17,y+17),0,BF
     If T<=MaxSpr Then Sprite Paste T-32, x+1,Y+1
    EndIf
    RefTil=1
   EndIf
   If K=32 Then
    Line(x,y)-(x+17,y+17),0,BF
    Sprite Paste Til, x+1,Y+1
    MP(xx+1+sx,yy+1+sy)=Til+32
   EndIf
   ST=1
  EndIf
  If K=0 Then ST=0: tim=0
  If K=27 Then EndMapEdit=1
  Line(x,y)-(x+17,y+17),7,B
 Loop
 Sprite Unload
GoTo ReadDir

Sub PutNum(x,y,t)
 If t<=9 Then x=x+3
 If t<=99 Then x=x+4
 y=y+3
 Print@(x-1,y,1) CLR$(0) t
 Print@(x+1,y,1) CLR$(0) t
 Print@(x,y+1,1) CLR$(0) t
 Print@(x,y-1,1) CLR$(0) t
 Print@(x,y,1) CLR$(7) t
End Sub

Sub MapNewFile(NewFile$)
 Open NewFile$ For output As #2
 Print #2,"' MAP MADE WITH CDN MEDIA STUDIO"
 A$=""
 For T=1 To 36: A$=A$+Chr$(32): Next T
 For T=1 To 36: Print #2,A$: Next T
 Close #2
End Sub

Sub MapSaveFile(SaveFile$)
 Open SaveFile$ For output As #2
 Print #2,"' MAP MADE WITH CDN MEDIA STUDIO"
 A$=""
 For TY=1 To 36
  For TX=1 To 36: A$=A$+Chr$(MP(TX,TY)): Next TX
  Print #2,A$: A$=""
 Next TY
 Close #2
End Sub


