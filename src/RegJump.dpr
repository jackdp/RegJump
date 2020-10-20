program RegJump;

// Disable extended RTTI
{$IF CompilerVersion >= 21.0} // >= Delphi 2010
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

{$SetPEFlags 1}   // IMAGE_FILE_RELOCS_STRIPPED
{$SetPEFlags $20} // IMAGE_FILE_LARGE_ADDRESS_AWARE

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows,
  Messages,
  ShellAPI,
  RJMP.Procs in 'RJMP.Procs.pas',
  RJMP.Types in 'RJMP.Types.pas',
  RJMP.Console in 'RJMP.Console.pas';


procedure DisplayBanner(const Short: Boolean = False);
begin
  Writeln(APP_FULL_NAME, '   ', '[', APP_BITS_STR, '-bit]   ', APP_DATE_STR, '   ', APP_LICENSE);
  if not Short then
  begin
    Writeln('Starts Registry Editor and opens the specified key.');
    TCon.WriteTLine('The program must be run with <color=yellow,black>administrator</color> privileges.');
    TCon.WriteTLine('<color=blue,black>' + URL_HOME + '</color>');
  end;
end;

procedure DisplayUsage;
begin
  TCon.WriteTLine('Usage: ' + ExeShortName + ' <color=cyan,black>REG_KEY</color> | -c | --license | --home');
  Writeln;
  TCon.WriteTLine('<color=cyan,black>REG_KEY</color>  Registry key to open, eg:');
  Writeln('             HKEY_CURRENT_USER\SOFTWARE');
  Writeln('             "HKEY_CURRENT_USER\some key"');
  Writeln('             HKEY_CLASSES_ROOT\.txt');
  TCon.WriteTLine('        -c  Copy <color=cyan,black>REG_KEY</color> from the system clipboard.');
  Writeln(' --license  Show program license.');
  Writeln('    --home  Opens program homepage in the default browser.');
  Writeln;
  Writeln('You can use the following aliases:');
  Writeln('  HKCR\ = HKEY_CLASSES_ROOT\');
  Writeln('  HKCU\ = HKEY_CURRENT_USER\');
  Writeln('  HKLM\ = HKEY_LOCAL_MACHINE\');
  Writeln('  HKCC\ = HKEY_CURRENT_CONFIG\');
  Writeln('   HKU\ = HKEY_USERS\');
end;



// ------------------------------------------------- ENTRY POINT ----------------------------------------------------


begin

  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  ExeShortName := ExtractFileName(ParamStr(0));

  case ParamCount of

    0:
      begin
        DisplayBanner;
        Writeln;
        DisplayUsage;
        ExitCode := 0;
      end;

    1:
      begin

        Param1 := ParamStr(1);
        UParam1 := UpperCase(Param1);

        // Display license
        if UParam1 = '--LICENSE' then
        begin
          DisplayBanner(True);
          TCon.WriteTLine('<color=yellow,black>LICENSE</color>');
          TCon.WriteTLine('<color=white,black>Freeware, OpenSource</color>');
          Writeln('This program is completely free. You can use it without any restrictions, also for commercial purposes.');
          TCon.WriteTLine('The program''s source files are available at <color=blue,black>' + URL_GITHUB + '</color>');
          TCon.WriteTLine('Compiled binaries can be downloaded from <color=blue,black>' + URL_HOME + '</color>');
          ExitCode := 0;
          Exit;
        end

        // Go to program home page
        else if UParam1 = '--HOME' then
        begin
          ShellExecute(0, 'open', URL_HOME, '', '', SW_SHOW);
          ExitCode := 0;
          Exit;
        end

        // RegKey = clipboard content
        else if (UParam1 = '-C') then
        begin

          if not ClipboardHasText then
          begin
            WriteError('Clipboard does not contain any text!');
            ExitCode := 1;
            Exit;
          end;

          if not GetClipboardText(RegKey) then
          begin
            WriteError('An error occurred while reading the clipboard content!');
            ExitCode := 1;
            Exit;
          end;

          if ContainsCRorLF(RegKey) then
          begin
            WriteError('The clipboard contains multiple lines of text. Only one was expected.');
            ExitCode := 1;
            Exit;
          end;

        end

        else

          RegKey := Param1;


        RegKey := ExpandRegRootKey(RegKey); // eg. HKLM -> HKEY_LOCAL_MACHINE

        if not RegPathExists(RegKey) then
        begin
          WriteError('Registry path not exists: ' + Param1);
          ExitCode := 1;
          Exit;
        end;


        // --------- Execute regedit.exe and jump! ---------------

        if _RegJump(RegKey) then ExitCode := 0 else ExitCode := 1;

        // -------------------------------------------------------

      end;

  else

    begin
      WriteError('Invalid number of parameters: ' + IntToStr(ParamCount));
      WriteError('Only one parameter was expected.');
      ExitCode := 1;
    end;

  end; // case



end.
