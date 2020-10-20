unit RJMP.Console;

{
  Truncated version of the JPL.Console unit from the JPLib: https://github.com/jackdp/JPLib/blob/master/Base/JPL.Console.pas
}

{$IF CompilerVersion >= 23}
  {$DEFINE DELPHIXE2_OR_ABOVE}
  {$DEFINE HAS_SYSTEM_UITYPES}
  {$DEFINE HAS_UNIT_SCOPE}
  {$DEFINE HAS_VCL_STYLES}
  {$DEFINE HAS_ANSI_ENCODING}
{$ENDIF}

interface

uses
  Types,
  Windows,
  RJMP.Procs;



const

  ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;

  ESC_CHAR = Char(27);
  AEC_START = ESC_CHAR + '[';   // AEC - Ansi Escape Code
  CSI = AEC_START;
  AEC_RESET = ESC_CHAR + '[0m';


  CON_COLOR_NONE = 200;

  VK_ANY = 0;

  CON_COLOR_RED_DARK = 4;
  CON_COLOR_RED_LIGHT = 12;
  CON_COLOR_GREEN_DARK = 2;
  CON_COLOR_GREEN_LIGHT = 10;
  CON_COLOR_BLUE_DARK = 1;
  CON_COLOR_BLUE_LIGHT = 9;

  CON_COLOR_BLACK = 0;
  CON_COLOR_BLACK_DARK = CON_COLOR_BLACK;
  CON_COLOR_BLACK_LIGHT = 8;

  CON_COLOR_WHITE = 15;
  CON_COLOR_WHITE_DARK = 7;
  CON_COLOR_WHITE_LIGHT = CON_COLOR_WHITE;

  // WHITE, WHITE_LIGHT, WHITE_DARK - taki ma³y absurd, trochê jak "ko³o, ko³o kwadratowe, ko³o trójk¹tne"

  CON_COLOR_GRAY_DARK = CON_COLOR_BLACK_LIGHT;
  CON_COLOR_GRAY_LIGHT = CON_COLOR_WHITE_DARK;

  CON_COLOR_CYAN_DARK = 3;
  CON_COLOR_CYAN_LIGHT = 11;

  CON_COLOR_MAGENTA_DARK = 5;
  CON_COLOR_MAGENTA_LIGHT = 13;

  CON_COLOR_YELLOW_DARK = 6;
  CON_COLOR_YELLOW_LIGHT = 14;

type

  TConsoleColors = record
    Text: Byte;
    Background: Byte;
  end;


  TCon = record
  private
    class var FOutputCodePage: UINT;
    class var FOriginalOutputCodePage: UINT;
    class function GetOutputCodePage: UINT; static;
    class function GetStdErrorHandle: HWND; static;
    class function GetStdOutputHandle: HWND; static;
    class function GetStdInputHandle: HWND; static;
    class procedure SetOutputCodePage(AValue: UINT); static;

    {$IFDEF DELPHIXE2_OR_ABOVE}
    class function GetTextCodePage: Cardinal; static;
    class procedure SetTextCodePage(AValue: Cardinal); static;
    {$ENDIF}
  public

    {$region '     colors       '}

    const clNone = CON_COLOR_NONE;

    const clBlackText = CON_COLOR_BLACK;
    const clWhiteText = CON_COLOR_WHITE;
    const clBlackBg = clBlackText;
    const clWhiteBg = clWhiteText;

    // foreground light colors
    const clLightBlackText = CON_COLOR_BLACK_LIGHT;
    const clLightWhiteText = CON_COLOR_WHITE;
    const clLightRedText = CON_COLOR_RED_LIGHT;
    const clLightGreenText = CON_COLOR_GREEN_LIGHT;
    const clLightBlueText = CON_COLOR_BLUE_LIGHT;
    const clLightCyanText = CON_COLOR_CYAN_LIGHT;
    const clLightMagentaText = CON_COLOR_MAGENTA_LIGHT;
    const clLightYellowText = CON_COLOR_YELLOW_LIGHT;

    // foreground dark colors
    const clDarkBlackText = CON_COLOR_BLACK;
    const clDarkWhiteText = CON_COLOR_WHITE_DARK;
    const clDarkRedText = CON_COLOR_RED_DARK;
    const clDarkGreenText = CON_COLOR_GREEN_DARK;
    const clDarkBlueText = CON_COLOR_BLUE_DARK;
    const clDarkCyanText = CON_COLOR_CYAN_DARK;
    const clDarkMagentaText = CON_COLOR_MAGENTA_DARK;
    const clDarkYellowText = CON_COLOR_YELLOW_DARK;

    // background colors = foreground colors
    const clLightBlackBg = clLightBlackText;
    const clLightWhiteBg = clLightWhiteText;
    const clLightRedBg = clLightRedText;
    const clLightGreenBg = clLightGreenText;
    const clLightBlueBg = clLightBlueText;
    const clLightCyanBg = clLightCyanText;
    const clLightMagentaBg = clLightMagentaText;
    const clLightYellowBg = clLightYellowText;
    const clDarkBlackBg = clBlackText;
    const clDarkWhiteBg = clDarkWhiteText;
    const clDarkRedBg = clDarkRedText;
    const clDarkGreenBg = clDarkGreenText;
    const clDarkBlueBg = clDarkBlueText;
    const clDarkCyanBg = clDarkCyanText;
    const clDarkMagentaBg = clDarkMagentaText;
    const clDarkYellowBg = clDarkYellowText;

    const clLightGrayText = clDarkWhiteText;
    const clDarkGrayText = clLightBlackText;
    const clLightGrayBg = clLightGrayText;
    const clDarkGrayBg = clDarkGrayText;
    {$endregion colors}

    class procedure ResetColors; static;
    class procedure ResetColorsAEC; static;

    class procedure SetTextColor(const Color: Byte); static;
    class procedure SetBackgroundColor(const Color: Byte); static;
    class procedure SetColors(const TextColor, BgColor: Byte); static;


    class procedure WriteColoredText(const s: string; const TextColor, BgColor: Byte); overload; static;
    class procedure WriteColoredText(const s: string; const cc: TConsoleColors); overload; static;
    class procedure WriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte = CON_COLOR_NONE); overload; static;
    class procedure WriteColoredTextLine(const s: string; const cc: TConsoleColors); overload; static;
    class procedure WriteTaggedText(s: string); static;
    class procedure WriteTaggedTextLine(s: string); static;
    class procedure WriteTLine(s: string); static;

    class procedure Init; static;

    class function RestoreOriginalOutputCodePage: Boolean; static;

    class function IsInputRedirected: Boolean; static;

    class property OriginalOutputCodePage: UINT read FOriginalOutputCodePage;
    class property OutputCodePage: UINT read GetOutputCodePage write SetOutputCodePage;
    class property StdOutputHandle: HWND read GetStdOutputHandle;
    class property StdInputHandle: HWND read GetStdInputHandle;
    class property StdErrorHandle: HWND read GetStdErrorHandle;

    {$IFDEF DELPHIXE2_OR_ABOVE}
    class property TextCodePage: Cardinal read GetTextCodePage write SetTextCodePage;
    {$ENDIF}
  end;


procedure ConInit;

function ConOK: Boolean;
procedure ConUpdateStandardHandles;
function ConGetCurrentTextAttr: WORD;
procedure ConSetTextAttrs(const Attrs: WORD);

// To use ANSI Escape Codes on Windows, ENABLE_VIRTUAL_TERMINAL_PROCESSING must be set in the console mode.
function ConSetVirtualTerminalProcessing(const Enable: Boolean): Boolean;

function ConCanUseAEC: Boolean; // AEC - ANSI Escape Codes

procedure ConSetTextColor(const Color: Byte);
procedure ConSetBackgroundColor(const Color: Byte);
procedure ConSetColors(const TextColor, BgColor: Byte);

procedure ConResetColors;
procedure ConResetColorsAEC;

procedure ConWriteAnsiEscapeCode(const Attr, TextColor, BgColor: Byte);

procedure ConWriteColoredText(const s: string; const TextColor, BgColor: Byte); overload;
procedure ConWriteColoredText(const s: string; const cc: TConsoleColors); overload;
procedure ConWriteColoredTextLine(const s: string; const cc: TConsoleColors); overload;
procedure ConWriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte = CON_COLOR_NONE); overload;

procedure ConGetColorsFromStr(const sColors: string; out TextColor, BgColor: Byte);
function ConColorToStr(const Color: Byte): string;
function ConColorToStrID(const Color: Byte; const sInvalidColor: string = 'none'): string;

procedure ConWriteTaggedText(s: string);
procedure ConWriteTaggedTextLine(s: string);



// If True, we can use ANSI Escape Codes. If False, we should use plain text only.
// Character device: console, terminal, printer
// Non-character device: file (redirection with ">"), pipe ...
function OutputIsCharacterDevice: Boolean;
function ConIsInputRedirected: Boolean;

var

  ConOutputIsCharacterDevice: Boolean;

  // Forces the use of ANSI Escape Codes, even if the output is not a character device.
  ConForceAnsiEscapeCodes: Boolean;

  ConStdOut: HWND;
  ConStdInput: HWND;
  ConStdError: HWND;
  ConCurrentTextAttrs: WORD;
  ConOriginalTextAttrs: WORD;
  ConInitialized: Boolean = False;
  ConVirtualTerminalProcessingEnabled: Boolean;


implementation


function ConCanUseAEC: Boolean;
begin
  Result := ConOutputIsCharacterDevice or ConForceAnsiEscapeCodes;
end;

function ConGetCurrentTextAttr: WORD;
begin
  Result := ConCurrentTextAttrs;
end;

procedure ConSetTextAttrs(const Attrs: WORD);
begin
  if not ConOK then Exit;
  SetConsoleTextAttribute(ConStdOut, Attrs);
end;

function ConSetVirtualTerminalProcessing(const Enable: Boolean): Boolean;
var
  dwMode: DWORD;
begin
  Result := False;
  if not ConOK then Exit;
  dwMode := 0; // FPC-LAZ: initialize
  if not GetConsoleMode(ConStdOut, dwMode) then Exit;
  if Enable then dwMode := dwMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING
  else dwMode := dwMode and (not ENABLE_VIRTUAL_TERMINAL_PROCESSING);
  Result := SetConsoleMode(ConStdOut, dwMode);
  ConVirtualTerminalProcessingEnabled := Result and Enable;
end;


procedure ConSetTextColor(const Color: Byte);
begin
  if not ConOK then Exit;
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $F0) or (Color and $0F);
  SetConsoleTextAttribute(ConStdOut, ConCurrentTextAttrs);
end;

procedure ConSetBackgroundColor(const Color: Byte);
begin
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $0F) or Word((Color shl 4) and $F0);
  SetConsoleTextAttribute(ConStdOut, ConCurrentTextAttrs);
end;

procedure ConSetColors(const TextColor, BgColor: Byte);
begin
  if not ConOK then Exit;
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $F0) or (TextColor and $0F);
  ConCurrentTextAttrs := (ConCurrentTextAttrs and $0F) or Word((BgColor shl 4) and $F0);
  SetConsoleTextAttribute(ConStdOut, ConCurrentTextAttrs);
end;

procedure ConResetColors;
begin
  if not ConOK then Exit;
  ConSetTextAttrs(ConOriginalTextAttrs);
  ConCurrentTextAttrs := ConOriginalTextAttrs;
end;


procedure ConResetColorsAEC;
begin
  if not ConCanUseAEC then Exit;
  Write(AEC_RESET);
end;

procedure ConWriteAnsiEscapeCode(const Attr, TextColor, BgColor: Byte);
begin
  if not ConCanUseAEC then Exit;
  Write(CSI, Attr, ';', TextColor, ';', BgColor, 'm');
end;

procedure ConWriteColoredText(const s: string; const TextColor, BgColor: Byte);
begin
  if TextColor <> CON_COLOR_NONE then ConSetTextColor(TextColor);
  if BgColor <> CON_COLOR_NONE then ConSetBackgroundColor(BgColor);
  Write(s);
  ConResetColors;
end;

procedure ConWriteColoredText(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredText(s, cc.Text, cc.Background);
end;

procedure ConWriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte);
begin
  ConWriteColoredText(s, TextColor, BgColor);
  Writeln;
end;

procedure ConWriteColoredTextLine(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredTextLine(s, cc.Text, cc.Background);
end;



{$region '                  ConGetColorsFromStr                           '}
procedure ConGetColorsFromStr(const sColors: string; out TextColor, BgColor: Byte);
var
  x: integer;
  sTextColor, sBgColor: string;
begin
  TextColor := CON_COLOR_NONE;
  BgColor := CON_COLOR_NONE;

  x := Pos(',', sColors);
  if x > 0 then
  begin
    sTextColor := Copy(sColors, 1, x - 1);
    sBgColor := Copy(sColors, x + 1, Length(sColors));
  end
  else
  begin
    sTextColor := sColors;
    sBgColor := '';
  end;

  sTextColor := RemoveAll(sTextColor, ' BG');
  sTextColor := RemoveAll(sTextColor, ' FG');
  sTextColor := RemoveAll(sTextColor, ['_', ' ', '-']);

  sBgColor := RemoveAll(sBgColor, ' BG');
  sBgColor := RemoveAll(sBgColor, ' FG');
  sBgColor := RemoveAll(sBgColor, ['_', ' ', '-']);

  sTextColor := UpperCase(sTextColor);
  sBgColor := UpperCase(sBgColor);


  if sTextColor <> '' then
    if (sTextColor = 'RED') or (sTextColor = 'LIGHTRED') then TextColor := TCon.clLightRedText
    else if (sTextColor = 'DARKRED') then TextColor := TCon.clDarkRedText

    else if (sTextColor = 'GREEN') or (sTextColor = 'LIGHTGREEN') then TextColor := TCon.clLightGreenText
    else if (sTextColor = 'DARKGREEN') then TextColor := TCon.clDarkGreenText

    else if (sTextColor = 'BLUE') or (sTextColor = 'LIGHTBLUE') then TextColor := TCon.clLightBlueText
    else if (sTextColor = 'DARKBLUE') then TextColor := TCon.clDarkBlueText

    else if (sTextColor = 'BLACK') or (sTextColor = 'DARKBLACK') then TextColor := TCon.clBlackText
    else if (sTextColor = 'WHITE') or (sTextColor = 'LIGHTWHITE') then TextColor := TCon.clWhiteText

    else if (sTextColor = 'GRAY') or (sTextColor = 'LIGHTGRAY') or (sTextColor = 'DARKWHITE') then TextColor := TCon.clDarkWhiteText
    else if (sTextColor = 'DARKGRAY') or (sTextColor = 'LIGHTBLACK') then TextColor := TCon.clLightBlackText

    else if (sTextColor = 'CYAN') or (sTextColor = 'LIGHTCYAN') then TextColor := TCon.clLightCyanText
    else if (sTextColor = 'DARKCYAN') then TextColor := TCon.clDarkCyanText

    else if (sTextColor = 'MAGENTA') or (sTextColor = 'LIGHTMAGENTA') then TextColor := TCon.clLightMagentaText
    else if (sTextColor = 'DARKMAGENTA') then TextColor := TCon.clDarkMagentaText

    else if (sTextColor = 'YELLOW') or (sTextColor = 'LIGHTYELLOW') then TextColor := TCon.clLightYellowText
    else if (sTextColor = 'DARKYELLOW') then TextColor := TCon.clDarkYellowText

    else if sTextColor = 'PURPLE' then TextColor := TCon.clDarkMagentaText
    else if sTextColor = 'FUCHSIA' then TextColor := TCon.clLightMagentaText
    else if sTextColor = 'AQUA' then TextColor := TCon.clLightCyanText
    else if sTextColor = 'LIME' then TextColor := TCon.clLightGreenText
    ;

  if sBgColor <> '' then
    if (sBgColor = 'RED') or (sBgColor = 'LIGHTRED') then BgColor := TCon.clLightRedBg
    else if (sBgColor = 'DARKRED') then BgColor := TCon.clDarkRedBg

    else if (sBgColor = 'GREEN') or (sBgColor = 'LIGHTGREEN') then BgColor := TCon.clLightGreenBg
    else if (sBgColor = 'DARKGREEN') then BgColor := TCon.clDarkGreenBg

    else if (sBgColor = 'BLUE') or (sBgColor = 'LIGHTBLUE') then BgColor := TCon.clLightBlueBg
    else if (sBgColor = 'DARKBLUE') then BgColor := TCon.clDarkBlueBg

    else if (sBgColor = 'BLACK') or (sBgColor = 'DARKBLACK') then BgColor := TCon.clBlackBg
    else if (sBgColor = 'WHITE') or (sBgColor = 'LIGHTWHITE') then BgColor := TCon.clWhiteBg

    else if (sBgColor = 'GRAY') or (sBgColor = 'LIGHTGRAY') or (sBgColor = 'DARKWHITE') then BgColor := TCon.clDarkWhiteBg
    else if (sBgColor = 'DARKGRAY') or (sBgColor = 'LIGHTBLACK') then BgColor := TCon.clLightBlackBg

    else if (sBgColor = 'CYAN') or (sBgColor = 'LIGHTCYAN') then BgColor := TCon.clLightCyanBg
    else if (sBgColor = 'DARKCYAN') then BgColor := TCon.clDarkCyanBg

    else if (sBgColor = 'MAGENTA') or (sBgColor = 'LIGHTMAGENTA') then BgColor := TCon.clLightMagentaBg
    else if (sBgColor = 'DARKMAGENTA') then BgColor := TCon.clDarkMagentaBg

    else if (sBgColor = 'YELLOW') or (sBgColor = 'LIGHTYELLOW') then BgColor := TCon.clLightYellowBg
    else if (sBgColor = 'DARKYELLOW') then BgColor := TCon.clDarkYellowBg

    else if sBgColor = 'PURPLE' then BgColor := TCon.clDarkMagentaBg
    else if sBgColor = 'FUCHSIA' then BgColor := TCon.clLightMagentaBg
    else if sBgColor = 'AQUA' then BgColor := TCon.clLightCyanBg
    else if sBgColor = 'LIME' then BgColor := TCon.clLightGreenBg
    ;

end;
{$endregion ConGetColorsFromStr}

{$region '                  ConColorToStr                                 '}
function ConColorToStr(const Color: Byte): string;
begin
  case Color of
    // background colors = foreground (text) colors
    TCon.clDarkRedText: Result := 'Dark Red';
    TCon.clLightRedText: Result := 'Light Red';

    TCon.clDarkGreenText: Result := 'Dark Green';
    TCon.clLightGreenText: Result := 'Light Green';

    TCon.clDarkBlueText: Result := 'Dark Blue';
    TCon.clLightBlueText: Result := 'Light Blue';

    TCon.clBlackText: Result := 'Black';
    TCon.clLightBlackText: Result := 'Light Black'; // Dark Gray

    TCon.clDarkWhiteText: Result := 'Dark White'; // Light Gray
    TCon.clWhiteText: Result := 'White';

    TCon.clDarkCyanText: Result := 'Dark Cyan';
    TCon.clLightCyanText: Result := 'Light Cyan';

    TCon.clDarkMagentaText: Result := 'Dark Magenta';
    TCon.clLightMagentaText: Result := 'Light Magenta';

    TCon.clDarkYellowText: Result := 'Dark Yellow';
    TCon.clLightYellowText: Result := 'Light Yellow';
  else
    Result := 'UNKNOWN color';
  end;
end;

{$endregion ConColorToStr}

function ConColorToStrID(const Color: Byte; const sInvalidColor: string = 'none'): string;
begin
  Result := ConColorToStr(Color);
  Result := RemoveAll(Result, ' ');
  if UpperCase(Result) = 'UNKNOWNCOLOR' then Result := sInvalidColor;
end;

{$region '                  ConWriteTaggedText & Line                     '}
procedure ConWriteTaggedText(s: string);
var
  x, xpe: integer;
  sColor, sn, sInTag: string;
  TextColor, BgColor: Byte;
begin

  x := Pos('<color=', s);
  if x <= 0 then
  begin
    Write(s);
    Exit;
  end;

  while x > 0 do
  begin

    x := Pos('<color=', s);

    if x = 0 then
    begin
      Write(s);
      Break;
    end;

    sn := Copy(s, 1, x - 1);
    if sn <> '' then Write(sn);

    s := Copy(s, x + Length('<color='), Length(s));

    xpe := Pos('>', s);

    if xpe > 0 then
    begin
      sColor := Copy(s, 1, xpe - 1);
      ConGetColorsFromStr(sColor, TextColor, BgColor);
      s := Copy(s, xpe + 1, Length(s));

      xpe := Pos('</color>', s);

      if xpe > 0 then
      begin
        sInTag := Copy(s, 1, xpe - 1);
        if TextColor <> CON_COLOR_NONE then ConSetTextColor(TextColor);
        if BgColor <> CON_COLOR_NONE then ConSetBackgroundColor(BgColor);
        Write(sInTag);
        ConResetColors;

        s := Copy(s, xpe + Length('</color>'), Length(s));
      end;
    end

    else

    begin
      Write(s);
      Break; // niedomkniêty znacznik
    end;

  end; // while

  ConResetColors;

end;

procedure ConWriteTaggedTextLine(s: string);
begin
  ConWriteTaggedText(s);
  Writeln;
end;
{$endregion ConWriteTaggedText & Line}



{$region ' ---------------------------------- TCon --------------------------------------- '}

class procedure TCon.SetOutputCodePage(AValue: UINT);
begin
  if FOutputCodePage = AValue then Exit;
  SetConsoleOutputCP(AValue);
  FOutputCodePage := GetConsoleOutputCP;
end;

class function TCon.GetOutputCodePage: UINT;
begin
  Result := GetConsoleOutputCP;
end;

class function TCon.GetStdErrorHandle: HWND;
begin
  ConUpdateStandardHandles;
  Result := ConStdError;
end;

class function TCon.GetStdOutputHandle: HWND;
begin
  ConUpdateStandardHandles;
  Result := ConStdOut;
end;

class function TCon.GetStdInputHandle: HWND;
begin
  ConUpdateStandardHandles;
  Result := ConStdInput;
end;

class function TCon.RestoreOriginalOutputCodePage: Boolean;
begin
  if GetConsoleOutputCP = FOriginalOutputCodePage then Exit(True);
  if not SetConsoleOutputCP(FOriginalOutputCodePage) then Exit(False);
  Result := GetConsoleOutputCP = FOriginalOutputCodePage;
end;

class function TCon.IsInputRedirected: Boolean;
begin
  Result := ConIsInputRedirected;
end;

{$IFDEF DELPHIXE2_OR_ABOVE}
class procedure TCon.SetTextCodePage(AValue: Cardinal);
begin
  System.SetTextCodePage(Output, AValue);
end;

class function TCon.GetTextCodePage: Cardinal;
begin
  Result := System.GetTextCodePage(Output);
end;
{$ENDIF}

class procedure TCon.ResetColors;
begin
  ConResetColors;
end;

class procedure TCon.ResetColorsAEC;
begin
  ConResetColorsAEC
end;

class procedure TCon.SetTextColor(const Color: Byte);
begin
  ConSetTextColor(Color);
end;

class procedure TCon.SetBackgroundColor(const Color: Byte);
begin
  ConSetBackgroundColor(Color);
end;

class procedure TCon.SetColors(const TextColor, BgColor: Byte);
begin
  ConSetColors(TextColor, BgColor);
end;

class procedure TCon.WriteColoredText(const s: string; const TextColor, BgColor: Byte);
begin
  ConWriteColoredText(s, TextColor, BgColor);
end;

class procedure TCon.WriteColoredText(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredText(s, cc);
end;

class procedure TCon.WriteColoredTextLine(const s: string; const TextColor: Byte; BgColor: Byte);
begin
  ConWriteColoredTextLine(s, TextColor, BgColor);
end;

class procedure TCon.WriteColoredTextLine(const s: string; const cc: TConsoleColors);
begin
  ConWriteColoredTextLine(s, cc);
end;

class procedure TCon.WriteTaggedText(s: string);
begin
  ConWriteTaggedText(s);
end;

class procedure TCon.WriteTaggedTextLine(s: string);
begin
  ConWriteTaggedTextLine(s);
end;

class procedure TCon.WriteTLine(s: string);
begin
  ConWriteTaggedTextLine(s);
end;

class procedure TCon.Init;
begin
  FOriginalOutputCodePage := GetConsoleOutputCP;
end;

{$endregion TCon}





function OutputIsCharacterDevice: Boolean;
begin
  if not ConOK then Exit(True);

  // GetFileType - min. OS: Windows XP | Windows Server 2003
  Result := GetFileType(ConStdOut) = FILE_TYPE_CHAR;
end;

function ConIsInputRedirected: Boolean;
begin
  if not ConOK then Exit(False);
  Result := GetFileType(ConStdInput) <> FILE_TYPE_CHAR;
end;


function ConOK: Boolean;
begin
  Result := ConInitialized;
end;

procedure ConUpdateStandardHandles;
begin
  ConStdInput := GetStdHandle(STD_INPUT_HANDLE);
  ConStdError := GetStdHandle(STD_ERROR_HANDLE);
  ConStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
end;


procedure ConInit;
var
  csbi: TConsoleScreenBufferInfo;
begin
  ConInitialized := False;

  ConUpdateStandardHandles;
  if ConStdOut <> INVALID_HANDLE_VALUE then
  begin
    csbi.wAttributes := 0; // FPC-LAZ: initialize
    FillChar(csbi, SizeOf(csbi), 0);
    if GetConsoleScreenBufferInfo(ConStdOut, csbi) then
    begin
      ConInitialized := True;
      ConOriginalTextAttrs := csbi.wAttributes;
      ConCurrentTextAttrs := ConOriginalTextAttrs;
    end;
  end;

  ConOutputIsCharacterDevice := OutputIsCharacterDevice;
end;




initialization

  ConInit;
  TCon.Init;

end.
