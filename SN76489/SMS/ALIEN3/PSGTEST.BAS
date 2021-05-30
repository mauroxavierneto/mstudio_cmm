Mode 1

Dim File$(255) length 12
Dim GD$(20) length 255
Dim TP$(5) LENGTH 3
Dim Vol(4)
Dim Ton(4)
Dim Music$(16384) length 1

sel=1: selant=1
xf=0: yf=0: xfant=0: yfant=0
maxx=MM.HRes-1
maxy=MM.VRes-1

ReadDir:

Cls
ScanLine White,0,MaxY
F$=Dir$("*.*",DIR)
sl=0: xs=0: ys=0
Do While F$ <> ""
 sl=sl+1
 File$(sl)=f$
 Print@(xs,ys) "["+f$+"]"
 ys=ys+12
 If ys>400 Then
  xs=xs+100: ys=0
 EndIf
 f$=Dir$()
Loop
TP$(1)="BMP"
TP$(2)="VGM"
For T = 1 To 2
 F$=Dir$("*."+TP$(T),FILE)
 Do While F$ <> ""
  sl=sl+1
  File$(sl)=f$
  Print@(xs,ys) f$
  ys=ys+12
  If ys>400 Then
   xs=xs+100: ys=0
  EndIf
  f$=Dir$()
 Loop
Next T

max=sl

FileSelect:

 TPFound=0
 For T=1 To 2
  If Right$(file$(sel),3)=TP$(T) Then
   Print@(xf,yf,2) file$(sel)
   TPFound=1
  EndIf
 Next T
 If TPFound=0 Then
  Print@(xf,yf,2) "["+file$(sel)+"]"
 EndIf

 TPFound=0
 For T=1 To 2
  If Right$(file$(selant),3)=TP$(T) Then
   Print@(xfant,yfant,0) file$(selant)
   TPFound=1
  EndIf
 Next T
 If TPFound=0 Then
  Print@(xfant,yfant,0) "["+file$(selant)+"]"
 EndIf

 Pause(5)

 I$=Inkey$

 'exit program
 If I$=Chr$(27) Then Cls: End

 'select file
 If I$=Chr$(13) Then GoTo Action EndIf

 'down
 If I$=Chr$(128) Then
  selant=sel
  xfant=xf: yfant=yf
  yf=yf-12: sel=sel-1
  If yf<0 Then
   xf=xf-100: yf=400
   If xf<0 Then
    xf=0: sel=1: yf=0
   EndIf
  EndIf
 EndIf

 'up
 If I$=Chr$(129) Then
  selant=sel
  xfant=xf: yfant=yf
  sel=sel+1
  If sel>max Then
   sel=max
  Else
   yf=yf+12
   If yf>400 Then
    xf=xf+100: yf=0
   EndIf
  EndIf
 EndIf

 'right
 If I$=Chr$(131) Then
  selant=sel
  xfant=xf: yfant=yf
  sel=sel+34
  If sel>max Then
   sel=sel-34
  Else
   xf=xf+100
  EndIf
 EndIf

 'left
 If I$=Chr$(130) Then
  selant=sel
  xfant=xf: yfant=yf
  sel=sel-34
  If sel<0 Then
   sel=sel+34
  Else
   xf=xf-100
  EndIf
 EndIf

GoTo FileSelect

Action:

 If Right$(file$(sel),3)="VGM" Then
  Music$=file$(sel)
 ElseIf Right$(file$(sel),3)="BMP" Then
  Mode 4
  Cls
  LoadBMP file$(sel)
  Do While I$ <> Chr$(27)
  I$ = Inkey$
  Loop
  Cls
  Mode 1
  GoTo ReadDir
 Else
  Chdir file$(sel)
  sel=1: selant=1
  xf=0: yf=0: xfant=0: yfant=0
  GoTo ReadDir
 EndIf

ReadyPin = 36
For T = 0 To 9
 SetPin 22+T,8
 Pin(21+T) = 1
Next T
SetPin ReadyPin,2

Sub SendByte(Num)
 If Num>0 Then
  Pin(30)=1
  Port(22,8)=Num
  Pin(30)=0
  Pause(0.1)
  Pin(30)=1
 EndIf
End Sub

'For Colour Maximite v45 - Port Command Bug
Sub SendByteV45(Num)
 A$ = Bin$(Num)
 B$ = String$(8-Len(A$),"0")+A$
 Pin(30)=1
 For T = 0 To 7
  Pin(22+T) = Val(Mid$(B$,8-T,1))
 Next T
 Pin(30)=0
End Sub

Sub ChangeSpeed(xx)
 Clock=3.579540 * 1000
 SRate  = 44100*1.3
 'Sample = 2.267573696/1.1
 SAMPLE = 1
 Wait60 = (1000/(SRate/735))/xx
 Wait50 = (1000/(SRate/882))/xx
 SWait  = (1000/(SRate/Sample))/xx
 Print@(0,12*13,0) "Speed:            ";xx;"x    "
End Sub

Sub Silence
 Pin(30)=1
 SendByte(&H9F)
 SendByte(&HBF)
 SendByte(&HDF)
 SendByte(&HFF)
 Port(22,8)=(&B10011111)
 Port(22,8)=(&B10111111)
 Port(22,8)=(&B11011111)
 Port(22,8)=(&B11111111)
 Pin(30)=0
 Pin(30)=1
End Sub

Function SeekHeaderChar$(H,size)
 Seek #1,H+1
 SeekHeaderChar$ = Input$(size,#1)
End Function

Function SeekHeaderInt(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #1, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#1)))
 Next S
 SeekHeaderInt = Val("&H"+Temp$)
End Function

Function SeekHeaderHexa$(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #1, H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#1)))
 Next S
 SeekHeaderHexa$ = Temp$
End Function

Function SeekHeaderBCD$(H,size)
 Temp$ = ""
 For S = size To 1 Step -1
  Seek #1,H+S
  Temp$ = Temp$ + Hex$(Asc(Input$(1,#1)))
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
 NumLoops = LModifier - LBase
Else
 NumLoops = -1
EndIf

GD3 = SeekHeaderInt(&H14,4)
ReadGD3Header

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
Memory
Print
'GD3 Tags
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

X=190: Y=12*4
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

'Print ""; SeekHeaderChar$(&H00,4)

'GoTo noplay
ChangeSpeed(Speed)
ScanLine Red,MaxY-150,MaxY-80
ScanLine Yellow,MaxY-84,MaxY-24
ScanLine Green,MaxY-24,MaxY
For T = 1 To 12 Step 2
 ScanLine Red,MaxY-85+T,MaxY-85+T
 ScanLine Green,MaxY-25-T,MaxY-25-T
Next T

StartVGM:

L=Lof(#1)

If Lof > 16384 Then GoTo Backdir

E=EOFoffset

Seek #1,VGMoffset-2

For T=0 To L-VGMoffset-2-1
 Music$(T)=Input$(1,#1)
Next T
EndMus = T
Close #1

Sample = 0: Timer = 0
PauseTime = 0: StartTime = 0
MP=0: Ymus = 0: Yant = 0
Loffset = Loffset - I   'desliga os loops
SetTick 2.2267573696,PlayVGM
'SetTick 1,PlayVGM

Restart:

MP = 0

Do While (MP<EndMus)

 If H=&H50 And 1=2 Then
  For Mut = 0 To 3
   VolTon=Ton(Mut)*Vol(Mut)*1.5
   If VolTon>120 Then VolTon=120
   xv=10+Mut*15: yv=15+mut*15
   Line(xv,maxy-VolTon)-(yv,maxy),ch+1,BF
   Line(xv,maxy-120)-(yv,maxy-VolTon-1),0,BF
  Next Mut
 EndIf

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

 If MP >= E-VGMoffset-2 And loffset>0 Then
  MP=Loffset-VGMOffset-2
  If NumLoops > 0 Then
   NumLoops=NumLoops-1
   If NumLoops <= 0 Then
    GoTo BackDir
   EndIf
  EndIf
  GoTo Restart
 EndIf

Loop

BackDir:
 SetTick 0,PlayVGM
 Pause(10)
 Silence
 GoTo ReadDir

PSGLeds:
 AA$ = Bin$(Ymus)
 BB$ = String$(8-Len(AA$),"0")+AA$
 St = (1-Val(Left$(BB$,1)))*75
 BLIT 20,maxy-140,20,maxy-150,150,145
 For T=7 To 1 Step -1
 Line(T*10+10+st,maxy-5)-(T*10+15+st,maxy),2+Val(Mid$(BB$,t,1))*2,bf
 Next T
Return

PlayVGM:

 Do While (Timer - StartTime <= PauseTime - Wt)
  IReturn
 Loop

 MP=MP+1
 H=Asc(Music$(MP))

 If H = &H50 Then
  ThinkAgain:
  MP=MP+1
  Yant=Ymus
  Ymus=Asc(Music$(MP))

  If 1=2 Then
   AA$ = "00000000"+Bin$(Ymus)
   BB$ = "00000000"+Bin$(Yant)
   Ch=Val("&B"+Mid$(AA$,Len(AA$)-6,2))
   If Mid$(AA$,Len(AA$)-7,1)="1" Then
    If Mid$(AA$,Len(AA$)-4,1)="1" Then
     Vol(Ch)=(&B1111 - Val("&B"+Right$(AA$,4)))
    Else
     Ton(Ch)=Clock/(1025-(Val("&B"+Right$(AA$,4))*32))
    EndIf
   ElseIf Mid$(BB$,Len(BB$)-7,1)="0" Then
    Ton(Ch)=Clock/(1025-(Val("&B"+Right$(BB$,6)+Right$(AA$,4))*32))
   EndIf

   VolTon=Ton(Ch)*Vol(Ch)*1.2
   If VolTon>120 Then VolTon=120
   xv=10+Ch*15: yv=11+Ch*15
   Line(xv,maxy-VolTon)-(yv,maxy),ch+1,BF
   Line(xv,maxy-120)-(yv,maxy-VolTon-1),0,BF
  EndIf

  Pin(30)=1
  If Ymus=0 Then
   Ymus=1
   A$ = Bin$(Yant)
   B$ = String$(8-Len(A$),"0")+A$
   Port(22,8)=0
   Pin(30)=0
   Pin(30)=1
   Port(22,8)=Val("&B"+Left$(B$,4)+"0001")
  Else
   Port(22,8)=Ymus
  EndIf
  Pin(30)=0
  Pin(30)=1
  StartTime = Timer
  PauseTime = 0
  If Asc(Music$(MP+1))=&H50 Then
   MP=MP+1
   Wt=Wt+3
   If Wt>12 Then Wt=12
   GoTo ThinkAgain
  Else
   Pause(3-Wt/6)
   Wt=Wt-6
   If Wt<0 Then Wt=0
  EndIf
  IReturn

 ElseIf H = &H61 Then
  Temp = Asc(Music$(MP+2))*256+Asc(Music$(MP+1))
  MP=MP+2
  StartTime = Timer
  PauseTime = SWait * Temp
  IReturn

 ElseIf H = &H62 Then
  StartTime = Timer
  PauseTime = Wait60
  IReturn

 ElseIf H = &H63 Then
  StartTime = Timer
  PauseTime = Wait50
  IReturn

 ElseIf H >= &H70 And H <= &H7F Then
  Frames = (H - &H6F)
  StartTime = Timer
  PauseTime = SWait * Frames
  IReturn

 ElseIf H >= &H30 And H < &H50 Then
  MP=MP+1
 ElseIf H >= &H50 And H < &HC0 Then
  MP=MP+2
 ElseIf H >= &HC0 And H <= &HE0 Then
  MP=MP+3
 ElseIf H >= &HE1 Then
  MP=MP+4
 'Else
 'StartTime = Timer
 'PauseTime = SWait
 'Print "-----------------------------------";Hex$(H)
 EndIf

 IReturn
Loop

GoTo BackDir

EndVGM:
 Print Format$(Sample,"%.0f")
 SetTick 0,PlayVGM
 Silence
 Cls
End
