Mode 1

Dim File$(255) length 12

sel=1: selant=1
xf=0: yf=0: xfant=0: yfant=0

ReadDir:

Cls
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
F$=Dir$("*.VGM",FILE)
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

max=sl

FileSelect:

 If Right$(file$(sel),3)="VGM" Then
  Print@(xf,yf,2) file$(sel)
 Else
  Print@(xf,yf,2) "["+file$(sel)+"]"
 EndIf

 If Right$(file$(selant),3)="VGM" Then
  Print@(xfant,yfant,0) file$(selant)
 Else
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
 SRate  = 44100
 'Sample = 2.267573696/1.1
 SAMPLE = 1
 Wait60 = (1000/(SRate/735))/xx/1
 Wait50 = (1000/(SRate/882))/xx/1
 SWait  = (1000/(SRate/Sample))/xx
 Print@(0,12*13,0) "Speed:          ";xx;"x   "
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

Function SeekHeaderAsc$(H,size)
 Temp$ = ""
 For S = 1 To size
  Seek #1,H+S
  Temp$ = Temp$ + Input$(1,#1)
 Next S
 MaxStr = 0
 For S = 1 To size-1
  If Mid$(Temp$,S,1)=Chr$(0) Then
   MaxStr = S
  EndIf
 Next S
 If MaxStr > 0 Then
  SeekHeaderAsc$ = Left$(Temp$,MaxStr)
 Else
  SeekHeaderAsc$ = ""
 EndIf
End Function

Silence
Cls
Speed=1.2

Open Music$ For INPUT As #1

Clk=SeekHeaderInt(&H0C,4)
EOFoffset=SeekHeaderInt(&H04,4)
TotalSamples=SeekHeaderInt(&H18,4)
VGMoffset=SeekHeaderInt(&H34,4)

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

Print "File Type:       "; SeekHeaderChar$(&H00,4)
Print "File Name:       "; Music$
Print "File Size:      ";  Lof(#1);" bytes"
Print "EOF offset:     ";  EOFoffset
Print "VGM offset:     ";  VGMoffset
Print "Version:         "; SeekHeaderBCD$(&H08,4)
Print "Total Samples:   "; Format$(TotalSamples,"%.0f")
Print "Loop Offset:     "; Format$(LOffset,"%.0f")
Print "Loop Samples:    "; Format$(LSamples,"%.0f")
Print "Loop Base:       "; Format$(LBase,"%.0f")
Print "Loop Modifier:   "; Format$(LModifier,"%.0f")
Print "Loops:           "; Format$(NumLoops,"%.0f")
Print "GD3 Offset:     ";  GD3
Print
Print
'GD3 Tags
Print "Track Name:      "; SeekHeaderAsc$(GD3+32,32)
Print "Game Name:       "; SeekHeaderAsc$(GD3+32*3,32)
Print "System Name:     "; SeekHeaderAsc$(GD3+32*5,32)

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

StartVGM:
I=VGMoffset
I=&H052
Seek #1,I
L=Lof(#1)
E=EOFoffset
Sample = 0: Timer = 0
PauseTime = 0: StartTime = 0
MP=0
'Loffset = 0   'desliga os loops
Do While I < L

 Restart:
 SetTick 2.267573696,PlayVGM
 'SetTick 0.6,PlayVGM

 Seek #1,I
 If I+240<L Then
  I=I+241
 Else
  I=I+(L-I)
 EndIf

 'If I > E Then
 ' GoTo BackDir
 'EndIf

 M$ = Input$(245,#1)
 MP = 0

 Do While (MP<240)
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

  If I+MP >= L And loffset>0 Then
   I=Loffset
   If NumLoops > 0 Then
    NumLoops=NumLoops-1
    If NumLoops <= 0 Then
     GoTo BackDir
    EndIf
   EndIf
   GoTo Restart
  EndIf

 Loop

Loop

BackDir:
SetTick 0,PlayVGM
Pause(10)
Close #1
Silence
GoTo ReadDir


 PlayVGM:

  If MP>=240 Then IReturn

  MP=MP+1
  H=Asc(Mid$(M$,MP,1))

  Do While (Timer - StartTime <= PauseTime)
  Loop

  If H = &H50 Then
   MP=MP+1
   Y=Asc(Mid$(M$,MP,1))
   If Y=0 Then IReturn
   Port(22,8)=Y
   Pin(30)=0
   StartTime = Timer
   PauseTime = SWait
   Pin(30)=1
   IReturn

  ElseIf H = &H61 Then
   Temp = Asc(Mid$(M$,MP+2,1))*256+Asc(Mid$(M$,MP+1,1))
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
Close #1
Silence
Cls
End


