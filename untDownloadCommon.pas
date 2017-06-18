unit untDownloadCommon;

interface

Uses Windows, Classes, SysUtils, StrUtils, Vcl.Forms, System.DateUtils,
  Winapi.WinInet;


function GetHttpStr(AURL: string): string;
procedure DownloadFile(AURL, AFileName, ADestFolder: string);


implementation

function GetHttpStr(AURL: string): string;
const
  BufferSize = 1024;
var
  StrStream: TStringStream;
  hSession, hURL: HINTERNET;
  Buffer: array [1 .. BufferSize] of Byte;
  BufferLen: DWORD;
begin
  StrStream := TStringStream.Create('', TEncoding.UTF8);
  hSession := nil;
  hURL := nil;
  try
    hSession := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG,nil, nil, 0);
    if hSession = nil then RaiseLastOSError;
    hURL := InternetOpenUrl(hSession, PChar(AURL), nil, 0, INTERNET_FLAG_RELOAD, 0);
    if hURL = nil then RaiseLastOSError;
    repeat
      FillChar(Buffer, SizeOf(Buffer), 0);
      BufferLen := 0;
      if InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) then
        StrStream.WriteBuffer(Buffer, BufferLen)
      else
       RaiseLastOSError;
    until BufferLen = 0;
    Result := StrStream.DataString;
  finally
    InternetCloseHandle(hURL);
    InternetCloseHandle(hSession);
    StrStream.Free;
  end;
end;

procedure DownloadFile(AURL, AFileName, ADestFolder: string);
const
  BufferSize = 1024;
var
  FStream: TFileStream;
  hSession, hURL: HINTERNET;
  Buffer: array [1 .. BufferSize] of Byte;
  BufferLen: DWORD;
begin
  FStream := TFileStream.Create(ADestFolder + AFileName, fmCreate);
  hSession := nil;
  hURL := nil;
  try
    hSession := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG,nil, nil, 0);
    if hSession = nil then RaiseLastOSError;
    hURL := InternetOpenUrl(hSession, PChar(AURL), nil, 0, INTERNET_FLAG_RELOAD, 0);
    if hURL = nil then RaiseLastOSError;
    repeat
      FillChar(Buffer, SizeOf(Buffer), 0);
      BufferLen := 0;
      if InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) then
        FStream.WriteBuffer(Buffer, BufferLen)
      else
        RaiseLastOSError;
    until BufferLen = 0;
  finally
    InternetCloseHandle(hURL);
    InternetCloseHandle(hSession);
    FStream.Free;
  end;
end;

end.
