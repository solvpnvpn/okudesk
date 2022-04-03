# okudesk helper script

Description:
Adds a minimal header for the Okudesk gcode to show the framing area.  Used with Lightburn's Snapmaker output

Usage:
Drag one or multiple *.gc to OkuHeader.vbs
Output would be the same filename with extension .gco in the same directory as the input file

The input needs to have the bonding box information, eg:
; Bounds: X60 Y220 to X100 Y240

will give an output of

;$M Meta untilchar XXXXXX

;$M Frame X40 Y220

;$M Pos X60 Y220	
