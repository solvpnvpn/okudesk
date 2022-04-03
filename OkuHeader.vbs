Set objArgs = WScript.Arguments

Set reExtension = New RegExp
With reExtension
	.Pattern = "\.gc$"
	.IgnoreCase = True
	.Global = False
End With

Set reBounds = New RegExp
With reBounds
	'"; Bounds: X60 Y220 to X80 Y240"
	.Pattern = "^; Bounds: X.* Y.* X.* Y"
	.IgnoreCase = False
	.Global = True
End With

	
For i = 0 to objArgs.Count - 1: Do
	' read each file
	Set objFso = CreateObject("Scripting.FileSystemObject")
    Set file = objFso.GetFile(objArgs(i))
    
	' next file if it's not .gc file
	If Not reExtension.Test( file.Name ) Then
		Exit Do
	End If

	' if it's a .gc file, scan for the Bounds pattern
	Set f = objFso.OpenTextFile(file.Path)
	matched = False
	Do until f.AtEndOfStream
		currLine = f.ReadLine
		If reBounds.Test (currLine) Then
			matched = True
			Exit Do
		End If
	Loop
	f.Close
	
	' next file if no match
	If Not (matched) Then Exit Do

	' Calculate the 4 x,y values
	Dim a
	a = Split(currLine)
	xPos = Mid (a(2), 2)
	yPos = Mid (a(3), 2)
	xFrame = Mid (a(5), 2) - xpos
	yFrame = Mid (a(6), 2) - ypos
	
	' All Meta header info prepended are:
	';$M Meta untilchar XXXXXX
	';$M Frame Xnn Y2nn
	';$M Pos Xnn Ynn	
	
	metaHeaderStr = ";$M Meta untilchar 000000"
	metaFrameStr =  ";$M Frame X" & xFrame & " Y" & yFrame
	metaPosStr =    ";$M Pos X" & xPos & " Y" & yPos	
	
	' concat the metadata header
	meta = metaHeaderStr & vbLf
	meta = meta & metaFrameStr & vbLf
	meta = meta & metaPosStr & vbLf
	
	' set the total characters length of the header
	metaUntilChar = Len(meta)
	meta = Replace(meta, "untilchar 000000", "untilchar " & Right("000000" & metaUntilChar, 6))
	
	'Read the original .gc file again
	Set f = objFso.OpenTextFile(file.Path)
	strContents = f.ReadAll
	f.Close
	
	' create <filename>.gco
	' write the header to .gco file
	' write the content of original .gc file to .gco file
	Set f = objFso.CreateTextFile(file.Path & ".gco", True)
	f.WriteLine meta & strContents
	f.Close
	
Loop While False: Next