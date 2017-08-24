unit untDownloader;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw,
  System.IOUtils, System.IniFiles, System.Types, MSHTML,
  IdURI,
  untTvRain,
  untSettings,
  untIECompat,
  untM3U,
  superobject;

type
  TfrmDownloader = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FLogin,
    FPassword: string;
  public
    { Public declarations }
    procedure ProgressEvent(AMax, APos: Integer);
    procedure DownloadFile;
    procedure ReadSettings;
    procedure ExecuteNext(AFileName: string);
  end;

var
  frmDownloader: TfrmDownloader;

implementation

{$R *.dfm}

{ TfrmDownloader }

procedure TfrmDownloader.DownloadFile;
var
  fname, BasePath, dir, nextfile: string;
  o: ISuperObject;
  PlayLists: TArray<TM3UPlayList>;
  i: Integer;
  filearr: TStringDynArray;
begin
  ReadSettings;
  fname := ParamStr(1);
  try
    if (fname = '') or not FileExists(fname) then
    begin
      BasePath := TPath.GetDirectoryName(Application.ExeName);
      filearr := TDirectory.GetFiles(BasePath + '\Download');
      if Length(filearr) > 0 then
        fname := filearr[0]
      else
        Exit;
    end;
    BasePath := TPath.GetDirectoryName(fname);
    dir := TPath.GetFileName(BasePath);
    BasePath := TPath.GetDirectoryName(BasePath);
    if SameText(dir, 'Complete') then
      Exit;
    o := TSuperObject.ParseFile(fname, True);
    if o.B['IsChunk'] then
      Exit;
    TvRainLogin(WebBrowser1, FLogin, FPassword);
    NavigateAndWait(WebBrowser1, o.S['URL']);
    FilAllPlayLsts(WebBrowser1, PlayLists);
    o.O['playlist'] :=  SO('[]');

    for I := 0 to Length(PlayLists) - 1 do
      o.A['playlist'].Add(PlayLists[I].GetAsJSON);

    o.SaveTo(fname);
    for I := 0 to Length(PlayLists) - 1 do
    begin
      Caption := PlayLists[I].Title;
      Application.ProcessMessages;
      DownloadVideoPlayList(PlayLists[I], nil);
    end;
    if FileExists(BasePath + '\Complete\' + TPath.GetFileName(fname)) then
      TFile.Delete(BasePath + '\Complete\' + TPath.GetFileName(fname));
    TFile.Move(fname, BasePath + '\Complete\' + TPath.GetFileName(fname));
  finally
    filearr := TDirectory.GetFiles(TPath.GetDirectoryName(fname));
    if Length(filearr) > 0 then
    begin
      nextfile := filearr[0];
      if SameText(nextfile, fname) and (Length(filearr) < 2) then
        nextfile := filearr[1];
      if not SameText(nextfile, fname) then
        ExecuteNext(nextfile);
    end;
  end;
end;

procedure TfrmDownloader.ExecuteNext(AFileName: string);
var
  buffer: array[0..511] of Char;
  TmpStr: String;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  TmpStr := Application.ExeName + ' ' + AFileName;
  StrPCopy(buffer,TmpStr);
  FillChar(StartupInfo,Sizeof(StartupInfo),#0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWMINNOACTIVE or SW_SHOWMINIMIZED;
  CreateProcess(nil, buffer, nil, nil, false, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo)
end;

procedure TfrmDownloader.FormActivate(Sender: TObject);
begin
  Application.Minimize;
  ShowWindow(self.Handle, SW_MINIMIZE);
end;

procedure TfrmDownloader.FormCreate(Sender: TObject);
begin
  Left := 0;
  Top := 0;
end;

procedure TfrmDownloader.ProgressEvent(AMax, APos: Integer);
begin
  Application.ProcessMessages;
end;

procedure TfrmDownloader.ReadSettings;
var
  fname: string;
  ini: TIniFile;
begin
  fname := TPath.GetDirectoryName(Application.ExeName) + '\SaveTVRain.ini';
  ini := TIniFile.Create(fname);
  try
    TVRainDownloadPath := ini.ReadString('Main', 'TVRainDownloadPath', '');
    FLogin := ini.ReadString('Main', 'FLogin', '');
    FPassword := ini.ReadString('Main', 'FPassword', '');
  finally
    ini.Free;
  end;
end;

end.
