unit RJMP.Procs;

interface

uses
  Windows, Messages, ShellAPI,
  RJMP.Types;



function _RegJump(const Key: string; const ShowCmd: DWORD = SW_SHOWNORMAL; const SleepTime: DWORD = 80): Boolean;

function ClipboardHasText: Boolean;
function GetClipboardText(var Text: string): Boolean;

function ExtractFileName(const FullFileName: string): string;
function UpperCase(const s: string): string;
function AnsiUpperCase(const s: string): string;
function ContainsCRorLF(const s: string): Boolean;
function PosCS(const substr, s: string; bCaseSensitive: Boolean = False): integer;
function GetStringBounds(const InStr, SubStr: string; var Left, Right: integer; IgnoreCase: Boolean): Boolean;
function StrReplace(const s, OldPattern, NewPattern: string; IgnoreCase: Boolean; ReplaceAll: Boolean): string;
function RemoveAll(const Text, ToRemove: string; IgnoreCase: Boolean = False): string; overload;
function RemoveAll(const Text: string; const StringsToRemove: array of string; IgnoreCase: Boolean = False): string; overload;
function ContainsText(const InStr, SubStr: string): Boolean;

function ExpandRegRootKey(const RegKey: string): string;
function GetRootKeyFromStr(const RegKey: string): HKEY;
function RootKeyToStr(const RootKey: HKEY): string;
procedure SplitRegPath(const RegPath: string; var RootKey: HKEY; var RegKey: string);
function IsPredefinedRegKey(const Key: HKEY): Boolean;
function RegKeyExists(const RootKey: HKEY; const RegKey: string): Boolean;
function RegPathExists(const RegPath: string): Boolean;

procedure WriteError(const ErrorText: string; const Colors: string = 'white,darkred');
function IntToStr(const x: integer): string;


implementation

uses
  RJMP.Console;



function _RegJump(const Key: string; const ShowCmd: DWORD = SW_SHOWNORMAL; const SleepTime: DWORD = 80): Boolean;
const
  MAIN_WINDOW_CLASS = 'RegEdit_RegEdit'; // RegEdit main window class = RegEdit_RegEdit (Win2000..Win10)
var
  i: integer;
  hMainWindow, hEdit, hTreeWindow: HWND;
  sei: ShellExecuteInfo;
begin

  Result := False;

  hMainWindow := FindWindow(MAIN_WINDOW_CLASS, nil);

  // Launching the RegEdit (if the main window cannot be found)
  if hMainWindow = 0 then
  begin
    FillChar(sei, SizeOf(sei), 0);
    with sei do
    begin
      cbSize := SizeOf(sei);
      fMask := SEE_MASK_NOCLOSEPROCESS;
      lpVerb := PChar('open');
      lpFile := PChar('regedit.exe');
      nShow := ShowCmd;
    end;
    ShellExecuteEx(@sei);
    WaitForInputIdle(sei.hProcess, 2000);
    hMainWindow := FindWindow(MAIN_WINDOW_CLASS, nil);
  end;

  if hMainWindow = 0 then Exit;

  ShowWindow(hMainWindow, ShowCmd);



  // TreeView on the left: SysTreeView32 (window with the values: SysListView32)
  hTreeWindow := FindWindowEx(hMainWindow, 0, 'SysTreeView32', nil);
  if hTreeWindow = 0 then Exit;

  SetForegroundWindow(hTreeWindow); // <-- Activate and set focus. Probably not necessary

  // Collapsing the tree: "Left Arrow" key down x 32
  for i := 1 to 32 do
  begin
    SendMessage(hTreeWindow, WM_KEYDOWN, VK_LEFT, 0);
    Sleep(15);
  end;



  // Windows 10 Creators Update: The Edit control below the main menu
  hEdit := FindWindowEx(hMainWindow, 0, 'Edit', nil);

  // Setting the edit text and pressing the Enter key
  if hEdit > 0 then
  begin
    SetForegroundWindow(hEdit); // Activate edit
    SendMessage(hEdit, WM_SETTEXT, 0, 0);                                     // Clear the edit
    for i := 1 to Length(Key) do SendMessage(hEdit, WM_CHAR, Ord(Key[i]), 0); // Set edit text
    SendMessage(hEdit, WM_KEYDOWN, VK_RETURN, 0);                             // Press Enter
    Result := True;
  end

  else

  begin

    // Expand tree: 1-st level
    Sleep(SleepTime);
    SendMessage(hTreeWindow, WM_KEYDOWN, VK_RIGHT, 0);
    // Now all main registry branches should be visible: HKEY_CLASSES_ROOT, HKEY_CURRENT_USER...
    Sleep(SleepTime);


    for i := 1 to Length(Key) do
    begin
      // The "\" character marks the end of a key name.
      // Press the "Right Arrow" key and RegEdit automatically expands the selected key.
      if Key[i] = '\' then
      begin
        SendMessage(hTreeWindow, WM_KEYDOWN, VK_RIGHT, 0);
        Sleep(SleepTime);
      end
      else
        // Sending the names of successive keys character by character.
        // RegEdit automatically selects the key in the current branch.
        // You can do it manually, but you have to enter characters very quickly!
        SendMessage(hTreeWindow, WM_CHAR, Ord(Key[i]), 0);
    end;

    Result := True;

  end;

end;

function ClipboardHasText: Boolean;
begin
  Result := IsClipboardFormatAvailable(CF_UNICODETEXT) or IsClipboardFormatAvailable(CF_TEXT);
end;

function GetClipboardText(var Text: string): Boolean;
var
  ClipboardData: THandle;
begin
  Result := False;
  Text := '';

  if not ClipboardHasText then Exit;

  // https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openclipboard
  if not OpenClipboard(0) then Exit;

  try

    // https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclipboarddata
    // The clipboard format is automatically converted to the requested format (eg. CF_TEXT -> CF_UNICODETEXT)
    ClipboardData := GetClipboardData(CF_UNICODETEXT);
    if ClipboardData = 0 then Exit;

    try
      Text := PChar(GlobalLock(ClipboardData));
    finally
      GlobalUnlock(ClipboardData);
    end;

  finally
    CloseClipboard;
  end;

  Result := True;
end;

//{$WARNINGS OFF}
function ExtractFileName(const FullFileName: string): string;
var
  i: integer;
begin
  Result := FullFileName;
  for i := Length(FullFileName) downto 1 do
  begin
    if AnsiChar(FullFileName[i]) in ['\', '/'] then
    begin
      Result := Copy(FullFileName, i + 1, Length(FullFileName));
      Break;
    end;
  end;
end;
//{$WARNINGS ON}

function UpperCase(const s: string): string;
var
  i: integer;
begin
  Result := s;
  for i := 1 to Length(Result) do Result[i] := UpCase(Result[i]);
end;

function AnsiUpperCase(const s: string): string;
begin
  Result := s;
  if s = '' then Exit;
  UniqueString(Result);
  CharUpperBuff(PChar(Result), Length(Result));
end;

function ContainsCRorLF(const s: string): Boolean;
var
  znak: Char;
begin
  Result := False;
  for znak in s do
    if Ord(znak) in [$0D {CR}, $0A {LF}] then
    begin
      Result := True;
      Break;
    end;
end;

function PosCS(const substr, s: string; bCaseSensitive: Boolean = False): integer;
begin
  if bCaseSensitive then Result := Pos(substr, s)
  else Result := Pos(AnsiUpperCase(substr), AnsiUpperCase(s));
end;

function GetStringBounds(const InStr, SubStr: string; var Left, Right: integer; IgnoreCase: Boolean): Boolean;
var
  xp: integer;
begin
  Result := False;
  xp := PosCS(SubStr, InStr, not IgnoreCase);
  if xp = 0 then Exit;
  Left := xp;
  Right := xp + Length(SubStr) - 1;
  Result := True;
end;

function StrReplace(const s, OldPattern, NewPattern: string; IgnoreCase: Boolean; ReplaceAll: Boolean): string;
var
  xLeft, xRight: integer;
begin
  Result := s;

  while True do
  begin
    if GetStringBounds(Result, OldPattern, xLeft, xRight, IgnoreCase) then
      Result := Copy(Result, 1, xLeft - 1) + NewPattern + Copy(Result, xRight + 1, Length(Result))
    else
      Break;
    if not ReplaceAll then Break;
  end;
end;

function RemoveAll(const Text, ToRemove: string; IgnoreCase: Boolean = False): string;
begin
  Result := StrReplace(Text, ToRemove, '', IgnoreCase, True);
end;

function RemoveAll(const Text: string; const StringsToRemove: array of string; IgnoreCase: Boolean = False): string; overload;
var
  i: integer;
begin
  Result := Text;
  for i := 0 to Length(StringsToRemove) - 1 do
    Result := RemoveAll(Result, StringsToRemove[i], IgnoreCase);
end;

function ContainsText(const InStr, SubStr: string): Boolean;
begin
  Result := PosCS(SubStr, InStr, False) > 0;
end;

function ExpandRegRootKey(const RegKey: string): string;
var
  s: string;
begin
  Result := RegKey;

  s := UpperCase(Result);
  if s = 'HKCR' then Result := 'HKEY_CLASSES_ROOT'
  else if s = 'HKCU' then Result := 'HKEY_CURRENT_USER'
  else if s = 'HKLM' then Result := 'HKEY_LOCAL_MACHINE'
  else if s = 'HKU' then Result := 'HKEY_USERS'
  else if s = 'HKCC' then Result := 'HKEY_CURRENT_CONFIG'
  else
  begin
    Result := StrReplace(Result, 'HKCR\', 'HKEY_CLASSES_ROOT\', True, True);
    Result := StrReplace(Result, 'HKCU\', 'HKEY_CURRENT_USER\', True, True);
    Result := StrReplace(Result, 'HKLM\', 'HKEY_LOCAL_MACHINE\', True, True);
    Result := StrReplace(Result, 'HKU\', 'HKEY_USERS\', True, True);
    Result := StrReplace(Result, 'HKCC\', 'HKEY_CURRENT_CONFIG\', True, True);
  end;
end;

function GetRootKeyFromStr(const RegKey: string): HKEY;
begin
  if ContainsText(RegKey, 'HKEY_CLASSES_ROOT') or ContainsText(RegKey, 'HKCR\') then Result := HKEY_CLASSES_ROOT
  else if ContainsText(RegKey, 'HKEY_CURRENT_USER') or ContainsText(RegKey, 'HKCU\') then Result := HKEY_CURRENT_USER
  else if ContainsText(RegKey, 'HKEY_LOCAL_MACHINE') or ContainsText(RegKey, 'HKLM\') then Result := HKEY_LOCAL_MACHINE
  else if ContainsText(RegKey, 'HKEY_USERS') or ContainsText(RegKey, 'HKU\') then Result := HKEY_USERS
  else if ContainsText(RegKey, 'HKEY_CURRENT_CONFIG') or ContainsText(RegKey, 'HKCC\') then Result := HKEY_CURRENT_CONFIG
  else Result := HKEY_NONE;
end;

function RootKeyToStr(const RootKey: HKEY): string;
begin
  if RootKey = HKEY_CLASSES_ROOT then Result := 'HKEY_CLASSES_ROOT'
  else if RootKey = HKEY_CURRENT_USER then Result := 'HKEY_CURRENT_USER'
  else if RootKey = HKEY_LOCAL_MACHINE then Result := 'HKEY_LOCAL_MACHINE'
  else if RootKey = HKEY_USERS then Result := 'HKEY_USERS'
  else if RootKey = HKEY_CURRENT_CONFIG then Result := 'HKEY_CURRENT_CONFIG'
  else Result := '';
end;

procedure SplitRegPath(const RegPath: string; var RootKey: HKEY; var RegKey: string);
var
  xLeft, xRight: integer;
  RootKeyStr: string;
begin
  RegKey := '';
  RootKey := GetRootKeyFromStr(RegPath);
  if RootKey = HKEY_NONE then Exit;
  RegKey := ExpandRegRootKey(RegPath);

  RootKeyStr := RootKeyToStr(RootKey);

  if not GetStringBounds(RegKey, RootKeyStr, xLeft, xRight, True) then
  begin
    RootKey := HKEY_NONE;
    RegKey := '';
    Exit;
  end;

  RegKey := Copy(RegKey, xRight + 1, Length(RegKey));
  if (RegKey <> '') and (RegKey[1] = '\') then Delete(RegKey, 1, 1);
end;

function IsPredefinedRegKey(const Key: HKEY): Boolean;
begin
  Result :=
   (Key = HKEY_CLASSES_ROOT) or (Key = HKEY_CURRENT_CONFIG) or (Key = HKEY_CURRENT_USER) or
   (Key = HKEY_LOCAL_MACHINE) or (Key = HKEY_USERS);
end;

function RegKeyExists(const RootKey: HKEY; const RegKey: string): Boolean;
const
  {$IFDEF CPU32}
  REG_ACCES_FLAG_READ_ONLY = STANDARD_RIGHTS_READ; // or KEY_WOW64_64KEY;
  {$ELSE}
  REG_ACCES_FLAG_READ_ONLY = STANDARD_RIGHTS_READ; // or KEY_WOW64_32KEY;
  {$ENDIF}
var
  phkResult: HKEY;
  samDesired: DWORD;
  x: integer;
begin
  Result := False;

  samDesired := REG_ACCES_FLAG_READ_ONLY;

  // https://docs.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regopenkeyexw
  //   phkResult - A pointer to a variable that receives a handle to the opened key.
  //   If the key is not one of the predefined registry keys, call the RegCloseKey function
  //   after you have finished using the handle.
  x := RegOpenKeyEx(RootKey, PChar(RegKey), 0, samDesired, phkResult);
  if (phkResult <> 0) and (not IsPredefinedRegKey(phkResult)) then RegCloseKey(phkResult);

  if x <> ERROR_SUCCESS then Exit;

  Result := phkResult <> 0;
end;

function RegPathExists(const RegPath: string): Boolean;
var
  RootKey: HKEY;
  RegKey: string;
begin
  Result := False;

  SplitRegPath(RegPath, RootKey, RegKey);
  if RootKey = HKEY_NONE then Exit;

  if RegKey <> '' then Result := RegKeyExists(RootKey, RegKey)
  else Result := True;
end;


procedure WriteError(const ErrorText: string; const Colors: string = 'white,darkred');
begin
  TCon.WriteTaggedTextLine('<color=' + Colors + '>' + ErrorText + '</color>');
end;

function IntToStr(const x: integer): string;
var
  s: ShortString;
begin
  Str(x, s);
  Result := string(s);
end;

end.
