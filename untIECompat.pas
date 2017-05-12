unit untIECompat;

interface

uses System.SysUtils, System.StrUtils,
  MSHTML_EWB;

type
  TCompatibleModeRegistry = (cmrCurrentUser, cmrLocalMachine, cmrBoth);

const
  IECOMPATIBLEMODEKEY =
    'Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\';

procedure PutIECompatible(MajorVer: Integer; CMR: TCompatibleModeRegistry);

function FindNodeByAttrExStarts(ANode: IHTMLElement; NodeName, AttrName,
  AttrValue: string): IHTMLElement;

function UrlEncode(Str: string): string;

implementation

uses Winapi.Windows, System.Win.Registry, Vcl.Forms;

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
      SetReg64Access(Reg); // если программа x32, а система x64
      Reg.RootKey := HK[i];
      Reg.OpenKey(IECOMPATIBLEMODEKEY, True);
      Reg.WriteInteger(ExtractFileName(Application.ExeName), MajorVer * 1000);
      // MajorVer IE
    finally
      Reg.Free;
    end;
  end;
end;

function FindNodeByAttrExStarts(ANode: IHTMLElement; NodeName, AttrName,
  AttrValue: string): IHTMLElement;
var
  I: Integer;
  child: IHTMLElement;
  str: string;
begin
  if ANode = nil then
    begin
      Result := nil;
      Exit;
    end;
  Result := nil;
//  OutputDebugString(PChar(
//    Format('FindNodeByAttrEx: %s _ %s _ %s in  %s id = %s, class = %s ',
//    [NodeName,  AttrName,  AttrValue,
//      ANode.tagName, ANode.id,  ANode.classname])));
  if Sametext(ANode.tagName, NodeName) then
  begin
    if AttrName.IsEmpty then
      Result := ANode
    else if SameText(AttrName, 'class') then
    begin
      if StartsText(AttrValue, ANode.classname) then
        Result := ANode;
    end
    else // для иных атрибутов
    begin
      str := ANode.getAttribute(AttrName, 0);
      if AttrValue.IsEmpty or StartsText(AttrValue, str) then
        Result := ANode
    end
  end;
  if not Assigned(Result) then
  for I := 0 to (ANode.children as IHTMLElementCollection).length - 1 do
    begin
      child := (ANode.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
      Result := FindNodeByAttrExStarts(child, NodeName, AttrName, AttrValue);
      if Result <> nil then
        Exit;
    end;
end;

function UrlEncode(Str: string): string;
var
  i, Len: Integer;
  Ch: Char;
begin
  Result:='';
  Len:=Length(Str);
  for i:=1 to Len do
  begin
    Ch:= Str[i];
    if Ch in ['0'..'9', 'A'..'Z', 'a'..'z', '_'] then
      Result:=Result+Ch
    else
    begin
      if Ch = ' ' then Result:=Result+'+' else
        Result:=Result + '%' + IntToHex(Ord(AnsiChar(Ch)) - Ord('0') + $30, 2)
        //https://tvrainru.media.eagleplatform.com/api/player_data?id=709969&referrer=https%3A%2F%2Ftvrain.ru%2Flite%2Fteleshow%2Fsindeeva%2Fvayser-429533%2F
    end;
  end;
end;


end.
