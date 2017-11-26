unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.OleCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Winapi.WinInet, System.StrUtils, System.IOUtils,
  System.DateUtils, System.Types, IniFiles,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdGlobalProtocols,
  SHDocVw, MSHTML,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdURI,
  untM3U,
  untfrmWebTab,
  fmuDownloadFile,
  superobject
  , untWowHead
  ;

type
  TMainForm = class(TForm)
    mmMain: TMainMenu;
    gototvrain1: TMenuItem;
    mniDownload: TMenuItem;
    pgcPages: TPageControl;
    tsMain: TTabSheet;
    IdHTTP1: TIdHTTP;
    mniLog: TMenuItem;
    cbxLog: TComboBox;
    mniEchoMsk: TMenuItem;
    pnlBottom: TPanel;
    pnl2: TPanel;
    pbProgressCurrent: TProgressBar;
    pbCount: TProgressBar;
    tmr1: TTimer;
    spl1: TSplitter;
    tsWowSound: TTabSheet;
    pnlTop: TPanel;
    edtWowURL: TEdit;
    btnGoWow: TBitBtn;
    btnDownloadWowSound: TButton;
    mniDownloadAllTVRain: TMenuItem;
    pnlFileList: TScrollBox;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    mniEchoDownloadLast: TMenuItem;
    mniEchoMakePlaylist: TMenuItem;
    ewbMain: TWebBrowser;
    ewbWoW: TWebBrowser;
    btnEnumAllZones: TButton;
    procedure FormCreate(Sender: TObject);
    procedure mniDownloadClick(Sender: TObject);
    procedure mniCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tsMainShow(Sender: TObject);
    procedure mniDownloadAllTVRainClick(Sender: TObject);
    procedure mniEchoMakePlaylistClick(Sender: TObject);
    procedure ewbMainNavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure mniEchoDownloadLastClick(Sender: TObject);
    procedure btnGoWowClick(Sender: TObject);
    procedure btnDownloadWowSoundClick(Sender: TObject);
    procedure btnEnumAllZonesClick(Sender: TObject);
  private
    { Private declarations }
    FLog: TStringList;
    Fsearch_year,
    Fsearch_month,
    Fsearch_day: string;
    FLogin,
    FPassword: string;
    procedure Log(AText{, AFileName}: string);
    procedure FillVideoURLs(AEwb: TWebBrowser; AUrls: TStrings);
    procedure ReadSettings;
    procedure SaveSettings;
    function VideoIsChunk: Boolean;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  StringFuncs,
  untSettings, untTvRain, untEchoMskRu,
  untIECompat, EwbTools, untRecode;

procedure TMainForm.FillVideoURLs(AEwb: TWebBrowser; AUrls: TStrings);
var
  node: IHTMLElement;
  coll: IHTMLElementCollection;
  i: Integer;
  Url: string;
begin
  coll := (AEwb.Document as IHTMLDocument3).getElementsByTagName('a');
  if coll <> nil then
  for i := 0 to coll.length - 1 do
  begin
    node := coll.item(i, 0) as IHTMLElement;    // div id="vodplayer-411021"
    if ContainsText(node._className, 'chrono_list__item') then
    begin
      Url := node.getAttribute('href', 0);
      if (Url <> '') and (AUrls.IndexOf(Url) = -1) then
        AUrls.Add(Url);
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ReadSettings;
  FLog := TStringList.Create;
  PutIECompatible(GetIEVersionMajor, cmrCurrentUser);
  tsMain.Tag := 1;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ewbMain.OnBeforeNavigate2 := nil;
  FreeAndNil(FLog);
end;

procedure TMainForm.btnDownloadWowSoundClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  Self.Cursor := crHourGlass;
  try
    DownloadWowSound(ewbWoW, 'F:\Music\Soundtracks\Games\WoW\ZoneMusic\', pbProgressCurrent);
  finally
    Screen.Cursor := crDefault;
    Self.Cursor := crDefault;
  end;
end;

procedure TMainForm.btnEnumAllZonesClick(Sender: TObject);
var
  zonei: Integer;
  I: Integer;
  WowFiles: ISuperObject;
  filename: string;
begin
  filename := ExtractFileDir(Application.ExeName) + '\WowSound.json';
  if FileExists(filename) then
    WowFiles := TSuperObject.ParseFile(filename, True)
  else
    WowFiles := SO('{Zone:[], Files:[]}');
//  for I := 1 to 999 do
  for I := 1 to 1 do
  begin
    IdHTTP1.HandleRedirects := True;
    IdHTTP1.Head('http://www.wowhead.com/zone=' + IntToStr(I));
//    if not AnsiContainsText(IdHTTP1.request.URL, 'zones?notFound') then
      begin
        NavigateAndWait(ewbWow, 'http://www.wowhead.com/zone=' + IntToStr(I));
        AddWowFiles(ewbWow, WowFiles);
        WowFiles.SaveTo(filename, True, True);
      end;
    Sleep(1000);
  end;
end;

procedure TMainForm.btnGoWowClick(Sender: TObject);
begin
  ewbWoW.Navigate(edtWowURL.Text);
end;

procedure TMainForm.ewbMainNavigateComplete2(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
var
  idURL: TIdURI;
  params: TArray<string>;
  str: string;
  strs: TStringList;
begin
  if ((ewbMain.Document as IHTMLDocument2) <> nil) then
    idURL := TIdURI.Create((ewbMain.Document as IHTMLDocument2).url)
  else
    idURL := TIdURI.Create(URL);
  try  //    https://tvrain.ru/archive/?search_year=2017&search_month=5&search_day=4&query=&type=
    if ContainsText(idURL.Host, 'tvrain.ru') and ContainsText(idURL.Path, 'archive') then
    begin
      params := idURL.Params.Split(['&']);
      strs := TStringList.Create;
      try
        for str in params do
          strs.Add(str);
        if strs.Values['search_year'] <> '' then
          Fsearch_year := strs.Values['search_year'];
        if strs.Values['search_month'] <> '' then
          Fsearch_month := strs.Values['search_month'];
        if strs.Values['search_day'] <> '' then
          Fsearch_day := strs.Values['search_day'];
      finally
        strs.Free;
      end;
      SaveSettings;
    end;
  finally
    idURL.Free;
  end;

//  if StartsText('about:blank', URL) or StartsText('https://googleads.g', URL)  then
//    Exit;
//
//  OutputDebugString(PChar(Format('BeforeNavigate2: %s', [URL, ])));
//  if not (StartsText('http://tvrain.ru/archive/', URL) or StartsText('https://tvrain.ru/archive/', URL)) then
//    if StartsText('https://tvrain.ru/', URL) {and (
//      ContainsStr(URL, '/teleshow/') or ContainsStr(URL, '/news/')
//      or ContainsStr(URL, '/short/')
//    ) }then
//    begin
//      Cancel := True;
//      ts := TTabSheet.Create(Self);
//      ts.PageControl := pgcPages;
//      pgcPages.ActivePage := ts;
//      frm := TfrmWebTab.Create(Self);
//      frm.Name := '';
//      frm.Parent := ts;
//      frm.Align := alClient;
//      frm.Navigate(URL);
//    end;
end;

function TMainForm.VideoIsChunk: Boolean;
var
  str: string;
begin
//div class="meta__item meta__item--fullversion"
  str := (ewbMain.Document as IHTMLDocument2).body.innerHTML;
  Result := AnsiContainsStr(str, 'Cмотреть полную версию');
end;

procedure TMainForm.Log(AText{, AFileName}: string);
begin
  cbxLog.Items.Add(AText);
  cbxLog.ItemIndex := cbxLog.Items.Count - 1;
end;

procedure TMainForm.mniCloseClick(Sender: TObject);
var
  ts: TTabSheet;
begin
  ts := pgcPages.ActivePage;
  ts.PageControl := nil;
  FreeAndNil(ts);
end;

procedure TMainForm.mniDownloadAllTVRainClick(Sender: TObject);
var
  Urls: TStringList;
  I: Integer;
  BaseUrl, BaseDir, tvrainID: string;
  arr: TArray<string>;
  o: ISuperObject;
begin
  Urls := TStringList.Create;
  try
    BaseUrl := (ewbMain.Document as IHTMLDocument2).url;
    FillVideoURLs(ewbMain, Urls);
    pbProgressCurrent.Max := Urls.Count;
    pbProgressCurrent.Position := 0;
    BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
    TDirectory.CreateDirectory(BaseDir + 'Complete\');
    TDirectory.CreateDirectory(BaseDir + 'Download\');

    for I := 0 to Urls.Count - 1 do
    begin // https://tvrain.ru/lite/teleshow/sindeeva/kazarnovsky_sindeeva-436897/
      arr := Urls[I].Split(['/']);
      if Length(arr) = 0 then
        Continue;
      tvrainID := arr[Length(arr) - 1];
      arr := tvrainID.Split(['-']);
      if Length(arr) = 0 then
        Continue;
      tvrainID := arr[Length(arr) - 1];
      if FileExists(BaseDir + 'Complete\' + tvrainID + '.json') or
         FileExists(BaseDir + 'Download\' + tvrainID + '.json') then
        Continue;
      NavigateAndWait(ewbMain, Urls[I]);
      o := SO();
      o.S['URL'] := Urls[I];
      o.B['IsChunk'] := VideoIsChunk;
      if o.B['IsChunk'] then
        o.SaveTo(BaseDir + 'Complete\' + tvrainID + '.json')
      else
        o.SaveTo(BaseDir + 'Download\' + tvrainID + '.json');

//      if not VideoIsChunk then
//      begin
//        if CheckTvRainIsDemo then
//        begin
//          TvRainLogin;
//          NavigateAndWait(ewbMain, Urls[I]);
//        end;
//        DownloadFromWebPage(ewbMain);
//      end;
      pbProgressCurrent.StepBy(1);
    end;
  finally
    Urls.Free;
    pbProgressCurrent.Position := 0;
    NavigateAndWait(ewbMain, BaseUrl);
  end;
end;

procedure TMainForm.mniDownloadClick(Sender: TObject);
var
  control: TControl;
  I: Integer;
begin
  for I := 0 to pgcPages.ActivePage.ControlCount - 1 do
  begin
    control := pgcPages.ActivePage.Controls[I];
    if control is TfrmWebTab then
    begin
//      DownloadFromWebPage((control as TfrmWebTab).ewb1);
      mniCloseClick(nil);
    end
    else if control is TWebBrowser then
    begin
//      DownloadFromWebPage(control as TWebBrowser);
      (control as TWebBrowser).GoBack;
    end
  end;
end;

procedure TMainForm.mniEchoDownloadLastClick(Sender: TObject);
begin
  EchoDownloadFromRSS(IdHTTP1);
end;

procedure TMainForm.mniEchoMakePlaylistClick(Sender: TObject);
var
  Workdir, mp3file: string;
  dirs, files: TStringDynArray;
  PlayList: TStringList;
begin
  PlayList := TStringList.Create;
  try
    dirs := TDirectory.GetDirectories('H:\Downloads\Echo\', '*');
    for Workdir in dirs do
    begin
      files := TDirectory.GetFiles(Workdir, '*.mp3');
      if Length(files) > 0 then
      begin
        PlayList.Text := '#EXTM3U';
        for mp3file in files do
        begin
          PlayList.Add('#EXTINF:200,' + ExtractFileName(mp3file));
          PlayList.Add(ExtractFileName(mp3file));
        end;
        PlayList.SaveToFile(Workdir + '\Echo_' + ExtractFileName(Workdir) + '.m3u');
      end;
    end;
//  'H:\Downloads\Echo\' + FileDay + '\');
  finally
    PlayList.Free;
  end;
end;

procedure TMainForm.ReadSettings;
var
  fname: string;
  ini: TIniFile;
begin
  fname := ChangeFileExt(Application.ExeName, '.ini');
  ini := TIniFile.Create(fname);
  try
    Fsearch_year := ini.ReadString('Main', 'Fsearch_year', '');
    Fsearch_month := ini.ReadString('Main', 'Fsearch_month', '');
    Fsearch_day := ini.ReadString('Main', 'Fsearch_day', '');
    TVRainDownloadPath := ini.ReadString('Main', 'TVRainDownloadPath', '');
    FLogin := ini.ReadString('Main', 'FLogin', '');
    FPassword := ini.ReadString('Main', 'FPassword', '');
  finally
    ini.Free;
  end;
end;

procedure TMainForm.SaveSettings;
var
  fname: string;
  ini: TIniFile;
begin
  fname := ChangeFileExt(Application.ExeName, '.ini');
  ini := TIniFile.Create(fname);
  try
    ini.WriteString('Main', 'Fsearch_year', Fsearch_year);
    ini.WriteString('Main', 'Fsearch_month', Fsearch_month);
    ini.WriteString('Main', 'Fsearch_day', Fsearch_day);
    ini.WriteString('Main', 'TVRainDownloadPath', TVRainDownloadPath);
    ini.WriteString('Main', 'FLogin', FLogin);
    ini.WriteString('Main', 'FPassword', FPassword);
  finally
    ini.Free;
  end;
end;

procedure TMainForm.tmr1Timer(Sender: TObject);
  function GetFrame(AEagelId: Integer): TFrmDownloadFile;
  var
    I: Integer;
    frm: TFrmDownloadFile;
  begin
    Result := nil;
    for I := 0 to pnlFileList.ControlCount - 1 do
    if pnlFileList.Controls[I] is TFrmDownloadFile then
    begin
      frm := pnlFileList.Controls[I] as TFrmDownloadFile;
      if frm.EagleId = AEagelId then
        Exit(frm);
    end;
  end;
var
  i: Integer;
  found: Boolean;
  frm2: TFrmDownloadFile;
begin
//  pbCount.Max := DownloadList.Count;
  found := False;
  for I := DownloadList.Count - 1 downto 0 do
    begin
      frm2 := GetFrame(DownloadList[I].FPlayList.FPlayerId);
      if frm2 <> nil then
      begin
        if DownloadList[I].SuccessDownloaded then
          frm2.pbFile.Visible := False
        else
        begin
          frm2.pbFile.Max := DownloadList[I].FPlayList.TrackCount;
          frm2.pbFile.Position := DownloadList[I].FCurrentFile;
        end;
      end;
    end;
  if not found then
  begin
//    pbCount.Position := 0;
    pbProgressCurrent.Position := 0;
  end;
end;

procedure TMainForm.tsMainShow(Sender: TObject);
begin
  if tsMain.Tag = 1 then
    ewbMain.Navigate(Format('https://tvrain.ru/archive/?search_year=%s&search_month=%s&search_day=%s&query=&type=&tab=Video&page=1',
      [Fsearch_year, Fsearch_month, Fsearch_day]));
end;

{ TODO :
ќтслеживание прогресса скачивани€ - какой-то сервер, который будет принимать сообщени€ от другого процесса
что-то типа "TVRainID/Title/Duration/MaxProgress/CurrentProgress"
      if AddTask(PlayList) then
        TFrmDownloadFile.CreateFrame(PlayList, pnlFileList);
}

end.
