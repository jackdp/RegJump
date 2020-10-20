unit RJMP.Types;

interface

uses
  Windows;

const
  APP_NAME = 'RegJump';
  APP_VER_STR = '1.0';
  APP_FULL_NAME = APP_NAME + ' ' + APP_VER_STR;
  APP_DATE_STR = '2020.10.20';
  URL_HOME = 'https://www.pazera-software.com/products/regjump';
  URL_GITHUB = 'https://github.com/jackdp/RegJump';
  APP_LICENSE = 'Freeware';
  {$IFDEF CPUX64}
  APP_BITS_STR = '64';
  {$ELSE}
  APP_BITS_STR = '32';
  {$ENDIF}

  HKEY_NONE = HKEY(integer($2785493));


var
  ExeShortName: string;
  RegKey: string;
  Param1: string;
  UParam1: string;


implementation

end.
