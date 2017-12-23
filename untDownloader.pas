unit untDownloader;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, strutils,
  System.IOUtils, System.IniFiles, System.Types, MSHTML,
  IdURI,
  untTvRain,
  untSettings,
  untIECompat,
  untM3U,
  superobject, System.Win.TaskbarCore, Vcl.Taskbar, Vcl.ExtCtrls;

type
  TfrmDownloader = class(TForm)
    WebBrowser1: TWebBrowser;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FLogin,
    FPassword: string;
    function IsPlayListDemo(APlayList: ISuperObject): Boolean;
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
  fname, BasePath, nextfile: string;
  o: ISuperObject;
  PlayLists: TArray<TM3UPlayList>;
  i, demoi: Integer;
  IsDemo: Boolean;
  filearr: TStringDynArray;
begin
  ReadSettings;
  fname := ParamStr(1);
  try
    BasePath := TPath.GetDirectoryName(Application.ExeName);
    if (fname = '') or not FileExists(fname) then
    begin
      filearr := TDirectory.GetFiles(BasePath + '\Download');
      if Length(filearr) > 0 then
        fname := filearr[0]
      else
        Exit;
    end;
    o := TSuperObject.ParseFile(fname, True);
    if not o.B['IsChunk'] then
    begin
      for demoi := 1 to 2 do   // даю 2-ю попытку если с логином что-то пошло не так.
      begin
        TvRainLogin(WebBrowser1, FLogin, FPassword);
        for I := 1 to 10 do  // Ждать 1 сек.
        begin
          Sleep(100);
          Application.ProcessMessages;
        end;
        NavigateAndWait(WebBrowser1, o.S['URL']);
        IsDemo := CheckTvRainIsDemo(WebBrowser1);
        if not IsDemo then
        begin
          FillAllPlayLists(WebBrowser1, PlayLists);
          o.O['playlist'] :=  SO('[]');
          for I := 0 to Length(PlayLists) - 1 do
            o.A['playlist'].Add(PlayLists[I].GetAsJSON);
          for I := 0 to o.A['playlist'].Length - 1 do
            if IsPlayListDemo(o.A['playlist'].O[I]) then
            begin
              o.A['playlist'].Clear(True);
              IsDemo := True;
              Break;
            end;
        end;
        if not IsDemo then
          Break;
      end;
      o.SaveTo(fname);
      for I := 0 to Length(PlayLists) - 1 do
      begin
        Caption := PlayLists[I].Title;
        Application.ProcessMessages;
        DownloadVideoPlayList(PlayLists[I], nil);
      end;
    end;
    if FileExists(BasePath + '\Complete\' + TPath.GetFileName(fname)) then
      TFile.Delete(BasePath + '\Complete\' + TPath.GetFileName(fname));
    TFile.Move(fname, BasePath + '\Complete\' + TPath.GetFileName(fname));
  finally
    filearr := TDirectory.GetFiles(BasePath + '\Download');
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

function TfrmDownloader.IsPlayListDemo(APlayList: ISuperObject): Boolean;
var
  s: string;
  PlayerData: ISuperObject;
begin
  Result := False;
  if (APlayList.O['FPlayerData'] <> nil) then
  begin
    try
      PlayerData := SO(APlayList.S['FPlayerData']);
      if (PlayerData.O['data'] <> nil) and (PlayerData.O['data'].O['playlist'] <> nil) then
      s := PlayerData.O['data'].O['playlist'].S['title'];
      if EndsText('демо', s) then
        Result := True;
    except
    end;
  end;
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

procedure TfrmDownloader.Timer1Timer(Sender: TObject);
begin
//  Taskbar1.ProgressValue := Taskbar1.ProgressValue + 1;
//  if Taskbar1.ProgressValue = Taskbar1.ProgressMaxValue then
//  begin
//    Taskbar1.ProgressState := TTaskBarProgressState.Paused;
//    Timer1.Enabled := False;
//  end
//  else
//    Taskbar1.ProgressState := TTaskBarProgressState.Normal;
end;

end.
