-- AppleScript to create a new file in Finder
--
-- *** The following avoids a system warning about sending Keystrokes
-- Use it in Automator, with the following configuration:
-- With Automater:
-- Create Application
-- Add: Run AppleScript
-- Paste all this in
-- Save Somewhere.app
----------------------------------------------
-- With another Automater:
-- New -> Service
-- - Service receives: Files & Folders
-- - In: Finder.app
-- Add: Launch Application
-- Select: Other and find the Somewhere.app
-- Save service
----------------------------------------------
-- System Preferences > Security & Privacy > Accessibility: Add Somewhere.app to the permissions
-- System Preferences > Keyboard > Shortcuts > Services: Give SomewhereScript a shortcut
----------------------------------------------
-- If security keeps warning of alterations: Remove from Accessibility and re-add this.
----------------------------------------------

set file_name to text returned of (display dialog "Type your new filename.ext (Blank extension will be txt)" default answer "untitled")
if file_name is "" then
	set file_name to "untitled"
end if

if hasExtension(file_name) then
	set tmpExtension to getExtension(file_name)
	set file_name to getFileName(file_name)
	set file_ext to tmpExtension
else
	set file_ext to "txt"
end if

set is_desktop to false

-- get folder path and if we're in desktop (no folder opened)
try
	tell application "Finder"
		set this_folder to (folder of the front Finder window) as alias
	end tell
	
on error
	-- no open folder windows
	set this_folder to path to desktop folder as alias
	set is_desktop to true
end try

-- get the new file name (do not override an already existing file)
tell application "System Events"
	set file_list to get the name of every disk item of this_folder
end tell

set new_file to file_name & "." & file_ext
set x to 1
repeat
	if new_file is in file_list then
		set new_file to file_name & " " & x & "." & file_ext
		set x to x + 1
	else
		exit repeat
	end if
end repeat

-- create and select the new file
tell application "Finder"
	
	activate
	set the_file to make new file at folder this_folder with properties {name:new_file}
	if is_desktop is false then
		reveal the_file
	else
		select window of desktop
		set selection to the_file
		delay 0.1
	end if
end tell

-- press enter (rename)
tell application "System Events"
	tell process "Finder"
		keystroke return
	end tell
end tell

---- Sub Helper Function

on hasExtension(filename)
	return filename contains "."
end hasExtension

on getExtension(filename)
	set AppleScript's text item delimiters to "."
	set textSplits to text items of filename
	set AppleScript's text item delimiters to ""
	set counter to count text items of textSplits
	set extension to item (counter) of textSplits
	return extension
end getExtension

on getFileName(filename)
	set AppleScript's text item delimiters to "."
	set textSplits to text items of filename
	set counter to count text items of textSplits
	set filename to text 1 thru 2 of textSplits as string
	set AppleScript's text item delimiters to ""
	return filename
end getFileName
