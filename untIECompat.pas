unit untIECompat;

interface

type
  TCompatibleModeRegistry = (cmrCurrentUser, cmrLocalMachine, cmrBoth);

const
  IECOMPATIBLEMODEKEY =
    'Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\';

procedure PutIECompatible(MajorVer: Integer; CMR: TCompatibleModeRegistry);

implementation

uses Winapi.Windows, System.Win.Registry, Vcl.Forms, System.SysUtils;

type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL)
    : BOOL; stdcall;

function IsWindows64: Boolean;
var
  IsWow64Process: TIsWow64Process;
  IsW64: LongBool;
begin
  IsW64 := False;
  @IsWow64Process := GetProcAddress(GetModuleHandle(kernel32),
    'IsWow64Process');
  if Assigned(@IsWow64Process) then
    IsWow64Process(GetCurrentProcess, IsW64);
  Result := Boolean(IsW64);
end;

Procedure SetReg64Access(R: TRegistry);
begin
  if IsWindows64 and Assigned(R) then
    R.Access := R.Access or KEY_WOW64_64KEY;
end;

procedure PutIECompatible(MajorVer: Integer; CMR: TCompatibleModeRegistry);
var
  Reg: TRegistry;
  HK: array of Cardinal;
  i: Integer;
begin
  case CMR of
    cmrCurrentUser:
      begin
        SetLength(HK, 1);
        HK[0] := HKEY_CURRENT_USER;
      end;
    cmrLocalMachine:
      begin
        SetLength(HK, 1);
        HK[0] := HKEY_LOCAL_MACHINE;
      end;
    cmrBoth:
      begin
        SetLength(HK, 2);
        HK[0] := HKEY_CURRENT_USER;
        HK[1] := HKEY_LOCAL_MACHINE;
      end;
  end;
  for i := 0 to Length(HK) - 1 do
  begin
    Reg := TRegistry.Create;
    try
      SetReg64Access(Reg); // ���� ��������� x32, � ������� x64
      Reg.RootKey := HK[i];
      Reg.OpenKey(IECOMPATIBLEMODEKEY, True);
      Reg.WriteInteger(ExtractFileName(Application.ExeName), MajorVer * 1000);
      // MajorVer IE
    finally
      Reg.Free;
    end;
  end;
end;

end.