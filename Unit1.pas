unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.OleCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.DateUtils, System.Types,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  SHDocVw_EWB, EwbCore, EmbeddedWB, MSHTML_EWB, SHDocVw,

  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdURI,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, Xml.Win.msxmldom,
  untM3U,
  untfrmWebTab,
  fmuDownloadFile,
  superobject
//  , cefvcl, ceflib, untChrom_Helper;
  ;

type
  TIntArray = array of Integer;

  TMainForm = class(TForm)
    ewbMain: TEmbeddedWB;
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
    xmdSettings: TXMLDocument;
    spl1: TSplitter;
    tsWowSound: TTabSheet;
    wbWow: TEmbeddedWB;
    pnlTop: TPanel;
    edtWowURL: TEdit;
    btnGoWow: TBitBtn;
    btnDownloadWowSound: TButton;
    mniDownloadAllTVRain: TMenuItem;
    pnlFileList: TScrollBox;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    mniEchoDownloadLast: TMenuItem;
    mniEchoMakePlaylist: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure mniDownloadClick(Sender: TObject);
    procedure ewbMainBeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure ewbMainNavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure mniCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGoWowClick(Sender: TObject);
    procedure btnDownloadWowSoundClick(Sender: TObject);
    procedure tsMainShow(Sender: TObject);
    procedure mniDownloadAllTVRainClick(Sender: TObject);
    procedure mniEchoDownloadLastClick(Sender: TObject);
    procedure mniEchoMakePlaylistClick(Sender: TObject);
  private
    { Private declarations }
    FLog: TStringList;
    function GetHttpStr(AURL: string): string; // Работает с системными настройками браузера
    procedure Log(AText{, AFileName}: string);

    function GetTVRainTitle(AEwb: TEmbeddedWB): string;
    procedure GetEagleIDs(AEwb: TEmbeddedWB; var AEagleList: TIntArray);
    procedure FillVideoURLs(AEwb: TEmbeddedWB; AUrls: TStrings);
    procedure FillPlayList(APlayList: TM3UPlayList);
    procedure ReadSettings;
    procedure SaveSettings;
    function CheckTvRainIsDemo: Boolean;
    function VideoIsChunk: Boolean;
    procedure TvRainLogin;
    procedure NavigateAndWait(AEWB: TEmbeddedWB; AUrl: string; ATimeout: Cardinal = 15000);
    function URLInQueue(AUrl: string): Boolean;

  public
    { Public declarations }
    procedure DownloadFromWebPage(ewb1: TEmbeddedWB);
    function GetHttpString(AURL: string): string; //Не работает без указание прокси
    procedure DownloadFile(AURL, AFileName, ADestFolder: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses Winapi.WinInet, System.StrUtils, Soap.XSBuiltIns,
  StringFuncs, System.IOUtils,
  untSettings,
  untIECompat, EwbTools, untRecode;

procedure TMainForm.btnDownloadWowSoundClick(Sender: TObject);
var
//  root,
  node, parentnode, script: IHTMLElement;
//  coll: IHTMLElementCollection;
  I, ipos: Integer;
  scripttext: string;
  obj: ISuperObject;
  soundI, len: Integer;
  Title, SubTitle, ZoneID, Url, ID, fname, ext: string;
begin
  if wbWow.Document = nil then
    Exit;
  Title := (wbWow.Document as IHTMLDocument2).title;
  Title := Trim(Copy(Title, 1, Pos(' -', Title)));
  Title := ReplaceStr(Title, ':', ' ');
  Title := ReplaceStr(Title, '"', '_');
  Title := ReplaceStr(Title, '''', '_');

  if Title = ''  then
    Title := 'UnknownZone';
  Url := (wbWow.Document as IHTMLDocument2).url;
  ipos := Pos('zone=', Url);
  Url := Copy(Url, ipos + 5, Length(Url));
  ipos := Pos('\', Url);
  if ipos = 0 then
    ipos := Pos('/', Url);
  if ipos > 0 then
    ZoneID := Copy(Url, 1, ipos - 1)
  else
    ZoneID := 'unknown Id';
  Title := Title + '_' + ZoneID;
  node := (wbWow.Document as IHTMLDocument3).getElementById('zonemusicdiv-zonemusic');
  if node <> nil then
    parentnode := node.parentElement;
  if parentnode <> nil then
  for I := 0 to (parentnode.children as IHTMLElementCollection).length - 1 do
  begin
    script := (parentnode.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
    if SameText(script.tagName, 'div') then
      SubTitle := script.id
    else
    if SameText(script.tagName, 'script') and not SameText('zonemusicdiv-soundambience', SubTitle) then
    begin
      scripttext := script.innerHTML;
      ipos := Pos('[{', scripttext);
      scripttext := Copy(scripttext, ipos, Length(scripttext));
      ipos := Pos('}]', scripttext);
      scripttext := Copy(scripttext, 1, ipos + 2);
      obj := SO(scripttext);
      try
        len := obj.AsArray.Length;
        pbCount.Position := 0;
        pbCount.Max := Len;
        OutputDebugString(PChar('Len = ' + IntToStr(pbCount.Max)));
        Application.ProcessMessages;
        for soundI := 0 to len - 1 do
        begin
          ID := obj.AsArray[soundI].S['id'];
          ID := StringReplace(ID, #10, '', [rfReplaceAll]);
          ID := StringReplace(ID, #13, '', [rfReplaceAll]);
          Url := 'http://wowimg.zamimg.com/wowsounds/' + ID;
          if ContainsText(obj.AsArray[soundI].S['type'], 'ogg') then
            ext := '.ogg'
          else
            ext := '.mp3';
          fname := obj.AsArray[soundI].S['title'] + '_' + ID + ext;
          fname := StringReplace(fname, #10, '', [rfReplaceAll]);
          fname := StringReplace(fname, #13, '', [rfReplaceAll]);
          pbCount.Position := soundI;
          Application.ProcessMessages;
          DownloadFile(Url, fname, 'F:\Music\Soundtracks\Games\WoW\ZoneMusic\' + Title + '\' + SubTitle + '\');
        end;
      finally
        obj := nil;
        pbCount.Position := 0;
      end;
    end;
  end;
end;

procedure TMainForm.btnGoWowClick(Sender: TObject);
begin
  NavigateAndWait(wbWow, edtWowURL.Text);
end;

function TMainForm.CheckTvRainIsDemo: Boolean;
var
//  demo: IHTMLElement;
  str: string;
begin
//  demo := FindNodeByAttrExStarts(ewbMain.Doc2.body, 'div', 'class', 'player_notification');
  OutputDebugString(PChar('CheckTvRainIsDemo, ReadyState = ' + inttoStr(ewbMain.ReadyState) + ' ' + ewbMain.Doc2.url));
  str := ewbMain.Doc2.body.innerHTML;
  Result := AnsiContainsText(str, 'Вы смотрите демо-версию');
//  demo <> nil) and ContainsText(demo.innerText, 'демо');
end;

procedure TMainForm.DownloadFile(AURL, AFileName, ADestFolder: string);
var
  AStream: TFileStream;
  cnt: Integer;
begin
  if not TDirectory.Exists(ADestFolder) then
    TDirectory.CreateDirectory(ADestFolder);
  AStream := TFileStream.Create(ADestFolder + AFileName, fmCreate);
  try
    IdHTTP1.Request.Accept := '*/*';
    cnt := 1;
    repeat
      try
        IdHTTP1.Get(AURL, AStream);
        cnt := 5;
      except
        cnt := cnt + 1;
      end;
    until cnt >= 5;
  finally
    AStream.Free;
  end;
end;

procedure TMainForm.ewbMainBeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
//var
//  ts: TTabSheet;
//  frm: TfrmWebTab;
begin
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

procedure TMainForm.ewbMainNavigateComplete2(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  tsMain.Tag := 0;
  OutputDebugString(PChar('NavigateComplete2: ' + string(URL)));
end;

procedure TMainForm.FillPlayList(APlayList: TM3UPlayList);
var
  str,
  eagleLink, SecureLink, M3ULink, PlayListLink,
  Eagle_json, secure_link_json: string;
  AppFolder: string;
  M3U_List: TStringList;
  I, startpos, endpos: Integer;
  obj: ISuperObject;
begin
  eagleLink := 'http://tvrainru.media.eagleplatform.com/api/player_data?id=' + IntToStr(APlayList.FPlayerId) +
    '&referrer=' + URLEncode(APlayList.FSourceURL);
  // Eagle_json
  Eagle_json := GetHttpStr(eagleLink);
  APlayList.FPlayerData := Eagle_json;
  obj := SO(Eagle_json);
  AppFolder := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  obj.SaveTo(AppFolder + 'player_data.txt');
//  str := obj.S['time'];
//  begin
//    startpos := PosEx(' ', str, 1);
//    APlayList.PlayDate := Copy(str, 1, startpos - 1);
//    endpos := PosEx(' ', str, startpos + 1);
//    APlayList.PlayTime := Copy(str, startpos + 1, endpos - startpos - 1);
//    // очищаем от неподдерживаемых символов
//    APlayList.PlayDate := StringReplace(APlayList.PlayDate, '/', '-', [rfReplaceAll]);
//    if Length(APlayList.PlayDate) = Length('20151201') then
//      APlayList.PlayDate := Copy(APlayList.PlayDate, 1, 4) + '-' + Copy(APlayList.PlayDate, 5, 2) + '-' + Copy(APlayList.PlayDate, 7, 2);
//    APlayList.PlayTime := StringReplace(APlayList.PlayTime, ':', '_', [rfReplaceAll]);
//  //  "time":"2015/08/26 15:03:47 +0300",
//  end;
//  startpos := Pos('panel.eaglecdn.com', Eagle_json);
//  endpos := PosEx('"', Eagle_json, startpos);
//  SecureLink := Copy(Eagle_json, startpos, endpos - startpos);
  SecureLink := obj['data']['playlist'].A['viewports'][0]['medialist']['']['sources']['secure_m3u8']['auto'].AsString;
  if not StartsText('https://', SecureLink) then
    SecureLink := 'https://' + SecureLink;
  // SecureLink
  secure_link_json := GetHttpStr(SecureLink);
  APlayList.FSecureData := secure_link_json;
  obj := SO(secure_link_json);
  obj.SaveTo(AppFolder + 'secure_link_json.txt');
  if obj.O['data'].s['480'] <> '' then
    M3ULink := obj.O['data'].s['480']
  else
    M3ULink := obj.O['data'].AsArray.S[0];
  M3U_List := TStringList.Create;
  try
    IdHTTP1.Head(M3ULink);
//    IdHTTP1.Response.
    //video/mp4


    M3U_List.Text := GetHttpStr(M3ULink);
    APlayList.FM3UData := M3U_List.Text;
    M3U_List.SaveToFile(AppFolder + 'M3U_List.txt');
    PlayListLink := '';
    for I := 0 to M3U_List.count - 1 do
      if Pos('480p.mp4', M3U_List[I]) > 0 then
        PlayListLink := M3U_List[I]
      else if Pos('360p.mp4', M3U_List[I]) > 0 then
        PlayListLink := M3U_List[I];
//    PlayListLink := 'http://team1.setevisor.tv:1935/archive/_definst_/echomsk/echomsk.rec/2015/12/echomsk-1449075780.mp4/playlist.m3u8?s=1ug854dm45slqd7mctn4s8tre0&wowzasessionid=1363426954';
    if PlayListLink <> '' then
    begin
      M3U_List.Text := GetHttpStr(PlayListLink);
      if M3U_List.Count < 2 then
        raise Exception.Create('Пустой плейлист!');
      APlayList.SetPlayList(M3U_List);
    end
    else
      raise Exception.Create('Не удалось скачать плейлист!');

    // http://stream.b39.servers.eaglecdn.com/tvrainru/2015-08-26/55dd939c53e11_video_480p.mp4/index.m3u8?st=yIOV_QrZE5-ii1RobBxlnQ&e=1440621898
    // http://stream.b39.servers.eaglecdn.com/tvrainru/2015-08-26/55dd939c53e11_video_480p.mp4/seg-1-v1-a1.ts
//http://team1.setevisor.tv:1935/archive/_definst_/echomsk/echomsk.rec/2015/12/echomsk-1449075780.mp4/playlist.m3u8?s=1ug854dm45slqd7mctn4s8tre0&wowzasessionid=1363426954
    endpos := LastDelimiter('/', PlayListLink);
    if endpos > 0 then
      APlayList.BasePath := Copy(PlayListLink, 1, endpos)
    else
    begin
      Log('Не найден базовый путь: ' + PlayListLink);
      APlayList.BasePath := PlayListLink;
    end;
    if APlayList.PlayDate = '' then
    begin
      startpos := Pos('/tvrainru/', PlayListLink);
      startpos := startpos + Length('/tvrainru/');
      endpos := PosEx('/', PlayListLink, startpos);
      str := Copy(PlayListLink, startpos, endpos - startpos);
      str := StringReplace(str, '/', '-', [rfReplaceAll]);
      if Length(str) = Length('20151201') then
        str := Copy(str, 1, 4) + '-' + Copy(str, 5, 2) + '-' + Copy(str, 7, 2);
      APlayList.PlayDate := str;
    end;
  finally
    M3U_List.Free;
  end;
end;

procedure TMainForm.FillVideoURLs(AEwb: TEmbeddedWB; AUrls: TStrings);
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
    if ContainsText(node.className, 'chrono_list__item') then
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
//  chrm1.Browser.MainFrame.LoadUrl('http://tvrain.ru/teleshow/here_and_now/alkogol_budet_deshevle-393275/');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FLog);
end;

procedure TMainForm.DownloadFromWebPage(ewb1: TEmbeddedWB);
var
  Title: string;
  PlayList: TM3UPlayList;
  I: Integer;
  IDs: TIntArray;
  URL: TIdURI;
begin
  Title := GetTVRainTitle(ewb1);
  SetLength(IDs, 0);
  GetEagleIDs(ewb1, IDs);
  for I := 0 to Length(IDs) - 1 do
  begin
    PlayList := TM3UPlayList.Create;
    try
      PlayList.Title := GetTVRainTitle(ewb1);
      PlayList.FPlayerId := IDs[I];
      PlayList.FSourceURL := ewb1.Doc2.url;
      URL := TIdURI.Create(PlayList.FSourceURL);
      try
        PlayList.FTVRainPath := URL.Path;
      finally
        URL.Free;
      end;
      FillPlayList(PlayList);
      if Length(IDs) > 1 then
        PlayList.Title := PlayList.Title + ' Часть ' + IntToStr(I + 1);
      if AddTask(PlayList) then
        TFrmDownloadFile.CreateFrame(PlayList, pnlFileList);
    except
      FreeAndNil(PlayList);
    end;
  end;
end;

function TMainForm.GetHttpString(AURL: string): string;
var
  AStream: TStringStream;
begin
  AStream := TStringStream.Create('', TEncoding.UTF8);
  try
    IdHTTP1.Request.Accept := '*/*';
  //    IdHTTPconnect.Request.Accept := 'application/json, text/javascript, */*';
  //    IdHTTPconnect.Request.AcceptLanguage := 'ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3';
  //    IdHTTPconnect.Request.ContentType := 'application/x-www-form-urlencoded; charset=UTF-8';
    //'application/json;charset=utf-8'
    IdHTTP1.Get(AURL, AStream);
    Result := AStream.DataString;
  finally
    AStream.Free;
//    IdHTTPconnect.Free;
  end;
end;

procedure TMainForm.GetEagleIDs(AEwb: TEmbeddedWB;
  var AEagleList: TIntArray);
var
//  Root, youtube, child,
  node: IHTMLElement;
  coll: IHTMLElementCollection;
  EagleId: Integer;
  I: Integer;
  str: string;
//  attr: OleVariant;
  Arr: TStrArray;
begin
  SetLength(AEagleList, 0);
//  Root := FindNodeByAttrExStarts((AEwb.Document as IHTMLDocument3).documentElement, 'div', 'class', 'main-data-nest');
  coll := (AEwb.Document as IHTMLDocument3).getElementsByTagName('div');
  if coll <> nil then
  for i := 0 to coll.length - 1 do
  begin
    node := coll.item(i, 0) as IHTMLElement;    // div id="vodplayer-411021"
    if StartsText('vodplayer-', node.id) or StartsText('eagleplayer-', node.id) then
    begin
      DecomposeText(Arr, '-', node.id);
      if (Length(Arr) > 1) and (StrToIntDef(Arr[1], 0) <> 0) then
      if not ((Length(AEagleList) <> 0) and (AEagleList[Length(AEagleList) - 1] = StrToInt(Arr[1]))) then
      begin
        SetLength(AEagleList, Length(AEagleList) + 1);
        AEagleList[Length(AEagleList) - 1] := StrToInt(Arr[1]);
      end;
    end;
  end;
  if Length(AEagleList) = 0 then
  begin //   <div class="eagleplayer" id="vodplayer-715921"
    node := FindNodeByAttrExStarts((AEwb.Document as IHTMLDocument3).documentElement, 'div', 'class', 'eagleplayer');
    if node <> nil then
    begin
      str := node.id;
      str := StringReplace(str, 'vodplayer-', '', []);
      EagleId := StrToIntDef(str, 0);
      if EagleId <> 0 then
      begin
        SetLength(AEagleList, 1);
        AEagleList[0] := EagleId;
      end;
    end;
  end;

//  youtube := FindNodeByAttrExStarts(Root, 'iframe', 'id', 'player');
//  node := FindNodeByAttrExStarts(Root, 'div', 'class', 'eagle-player-series');
//  if node = nil then
//    node := FindNodeByAttrExStarts(Root, 'div', 'class', 'vodplayer-series clearfix');
//
//  if node <> nil then
//  begin
//    for I := 0 to (node.children as IHTMLElementCollection).length - 1 do
//    begin
//      child := (node.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
//      if SameText(child.tagName, 'div') and
//        ( StartsText('eagle-player-series', child.className)
//          or StartsText('vodplayer-', child.className)) then
//      begin
//        attr := child.getAttribute('data-id', 0);
//        if VarIsNull(attr) then
//          attr := child.getAttribute('data-player', 0);
//        if not VarIsNull(attr) then
//          if not ((Length(AEagleList) <> 0) and (AEagleList[Length(AEagleList) - 1] = attr)) then
//          begin
//            SetLength(AEagleList, Length(AEagleList) + 1);
//            AEagleList[Length(AEagleList) - 1] := attr;
//          end;
//      end;
//    end;
//    if Length(AEagleList) = 0 then
//      if StartsText('eagleplayer-', node.id) then
//      begin // <div id="eagleplayer-335957-series" class="eagle-player-series clearfix">
//        attr := Copy(node.id, Length('eagleplayer-') + 1, Length(node.id));
//        attr := Copy(attr, 1, LastDelimiter('-', attr) - 1);
//        if not ((Length(AEagleList) <> 0) and (AEagleList[Length(AEagleList) - 1] = attr)) then
//        begin
//          SetLength(AEagleList, Length(AEagleList) + 1);
//          AEagleList[Length(AEagleList) - 1] := attr;
//        end;
//      end
//      else if StartsText('vodplayer-', node.id) then
//      begin // <div id="vodplayer-349699-series" class="vodplayer-series clearfix">
//        attr := Copy(node.id, Length('vodplayer-') + 1, Length(node.id));
//        attr := Copy(attr, 1, LastDelimiter('-', attr) - 1);
//        if not ((Length(AEagleList) <> 0) and (AEagleList[Length(AEagleList) - 1] = attr)) then
//        begin
//          SetLength(AEagleList, Length(AEagleList) + 1);
//          AEagleList[Length(AEagleList) - 1] := attr;
//        end;
//      end
//  end
//  else
//  begin
//    node := FindNodeByAttrExStarts((AEwb.Document as IHTMLDocument3).documentElement, 'div', 'id', 'eagleplayer-');
//    if node <> nil then
//    begin
//      str := node.id;
//      str := StringReplace(str, 'eagleplayer-', '', []);
//      EagleId := StrToIntDef(str, 0);
//      if EagleId <> 0 then
//      begin
//        SetLength(AEagleList, 1);
//        AEagleList[0] := EagleId;
//      end;
//    end;
//  end;
//  if Length(AEagleList) = 0 then
//  begin
//    node := FindNodeByAttrExStarts(Root, 'div', 'data-player', '');
//    if node <> nil then
//    begin
//      attr := child.getAttribute('data-id', 0);
//      if VarIsNull(attr) then
//        attr := child.getAttribute('data-player', 0);
//      if not VarIsNull(attr) then
//        if not ((Length(AEagleList) <> 0) and (AEagleList[Length(AEagleList) - 1] = attr)) then
//        begin
//          SetLength(AEagleList, Length(AEagleList) + 1);
//          AEagleList[Length(AEagleList) - 1] := attr;
//        end;
//    end;
//  end;
end;

function TMainForm.GetTVRainTitle(AEwb: TEmbeddedWB): string;
var
  root, node: IHTMLElement;
begin
  Result := (AEwb.Document as IHTMLDocument2).title;
  root := (AEwb.Document as IHTMLDocument3).documentElement;
  node := FindNodeByAttrExStarts(root, 'div', 'class', 'document-head');
  if node <> nil then
  begin
    node := FindNodeByAttrExStarts(node, 'h1', '', '');
    if node <> nil then
      Result := node.innerText
  end;
  Result := Trim(StringReplace(Result, ':', ' ', [rfReplaceAll]));
  Result := StringReplace(Result, '/', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '\', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '?', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '*', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '"', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '>', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '<', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '|', ' ', [rfReplaceAll]);
end;

function TMainForm.VideoIsChunk: Boolean;
var
  str: string;
begin
//div class="meta__item meta__item--fullversion"
  str := ewbMain.Doc2.body.innerHTML;
  Result := AnsiContainsStr(str, 'Cмотреть полную версию');
end;

procedure TMainForm.Log(AText{, AFileName}: string);
//var
//  SaveFile: TStringList;
begin
  cbxLog.Items.Add(AText);
  cbxLog.ItemIndex := cbxLog.Items.Count - 1;
//  SaveFile := TStringList.Create;
//  try
//    SaveFile.Text := AText;
//    SaveFile.SaveToFile(AFileName);
//  finally
//    SaveFile.Free;
//  end;
end;

function TMainForm.GetHttpStr(AURL: string): string;
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
    hURL := internetopenurl(hSession, PChar(AURL), nil, 0, INTERNET_FLAG_RELOAD, 0);
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
  BaseUrl: string;
begin
  Urls := TStringList.Create;
  try
    BaseUrl := ewbMain.Doc2.url;
    FillVideoURLs(ewbMain, Urls);
    pbProgressCurrent.Max := Urls.Count;
    pbProgressCurrent.Position := 0;
    for I := 0 to Urls.Count - 1 do
    begin
      NavigateAndWait(ewbMain, Urls[I]);
      if not VideoIsChunk then
      begin
        if CheckTvRainIsDemo then
        begin
          TvRainLogin;
          NavigateAndWait(ewbMain, Urls[I]);
        end;
        DownloadFromWebPage(ewbMain);
      end;
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
      DownloadFromWebPage((control as TfrmWebTab).ewb1);
      mniCloseClick(nil);
    end
    else if control is TEmbeddedWB then
    begin
      DownloadFromWebPage(control as TEmbeddedWB);
      (control as TEmbeddedWB).GoBack;
    end
  end;
end;

procedure TMainForm.mniEchoDownloadLastClick(Sender: TObject);
var
  doc: IXMLDocument;
  AStream: TMemoryStream;
  root, item: IXMLNode;
  I: Integer;
  Arr: TStrArray;
  URL, Filename, NewFilename, FileDay, ProgramName, FileTime: string;
begin
  doc := TXMLDocument.Create(nil);
  AStream := TMemoryStream.Create;
  try
    IdHTTP1.Request.Accept := '*/*';
    IdHTTP1.Get('http://echo.msk.ru/interview/rss-audio.xml', AStream);
    doc.LoadFromStream(AStream);
    root := doc.DocumentElement;
    root := root.ChildNodes.FindNode('channel');
    pbCount.Position := 0;
    cbxLog.Items.Clear;
    if root <> nil then
    for I := 0 to root.ChildNodes.Count - 1 do
      if SameText(root.ChildNodes.Get(I).LocalName, 'item') then
      begin
        pbCount.Max := root.ChildNodes.Count - 1;
        pbCount.Position := I;
        item := root.ChildNodes.Get(I);
        URL := item.ChildValues['guid'];
        if URL <> '' then //<guid>http://cdn.echo.msk.ru/snd/2015-10-11-razvorot-morning-0706.mp3</guid>
        begin
          Filename := Copy(URL, LastDelimiter('/', URL) + 1, Length(URL));
          Filename := ReplaceStr(Filename, '.mp3', '');
          DecomposeText(Arr, '-', Filename); //2015-10-04-tabel-2005
          if SameText('bigecho', Arr[3]) or SameText('classicrock', Arr[3])
            or SameText('odna', Arr[3]) or SameText('risk', Arr[3])
            or SameText('vinil', Arr[3]) or SameText('peskov', Arr[3])
            or SameText('unpast', Arr[3]) or SameText('buntman', Arr[3])
            or SameText('farm', Arr[3]) or SameText('apriscatole', Arr[3])
            or SameText('moscowtravel', Arr[3]) or SameText('speakrus', Arr[3])
            or SameText('orders', Arr[3]) or SameText('kazino', Arr[3])
            or SameText('autorsong', Arr[3]) or SameText('redrquare', Arr[3])
            or SameText('museum', Arr[3]) or SameText('voensovet', Arr[3])
            or SameText('parking', Arr[3]) or SameText('graniweek', Arr[3])
            or SameText('gorodovoy', Arr[3]) or SameText('proehali', Arr[3])
            or SameText('skaner', Arr[3]) or SameText('doehali', Arr[3])
            or SameText('zoloto', Arr[3]) or SameText('glam', Arr[3])
            or SameText('babnik', Arr[3]) or SameText('blues', Arr[3])
            or SameText('znamenatel', Arr[3]) or SameText('arsenal', Arr[3])
            or SameText('football', Arr[3]) or SameText('galopom', Arr[3])
            or SameText('autorsong', Arr[3]) or SameText('tabel', Arr[3])
            or SameText('kid', Arr[3]) or SameText('just', Arr[3])
            or SameText('radiodetaly', Arr[3]) or SameText('keys', Arr[3])
            or SameText('blogout1', Arr[3]) or SameText('beatles', Arr[3])
            //or SameText('', Arr[3]) or SameText('', Arr[3])
          then
            Continue;

          FileDay := Format('%s-%s', [Arr[1], Arr[2]]);
          case Length(Arr) of
            5: NewFilename := Format('%s_%s_%s.mp3', [Arr[0] + '-' + FileDay, Arr[4], Arr[3]]);
            6: NewFilename := Format('%s_%s_%s-%s.mp3', [Arr[0] + '-' + FileDay, Arr[5], Arr[3], Arr[4]]);
            else
              NewFilename := Filename;
          end;
          try
            DownloadFile(URL, NewFilename, 'H:\Downloads\Echo\' + FileDay + '\');
          except
            on E: Exception do
            begin
              cbxLog.Items.Add(Format('Error %s on download file %s', [E.Message, URL] ));
              if cbxLog.Items.Count = 1 then
                cbxLog.ItemIndex := 0;
            end;
          end;
        end;
      end;
  finally
    AStream.Free;
    cbxLog.ItemIndex := 0;
  end;
//  ShowFastMMUsageTracker;
//chrm1.Browser.ShowDevTools;
//  chrm1.Browser.MainFrame.VisitDomProc(AddEagleToDownloaList);
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
  SaveData: ISuperObject;
  strs: TStringList;
  fname: string;
begin
  fname := ChangeFileExt(Application.ExeName, '.json');
  if FileExists(fname) then
  begin
    strs := TStringList.Create;
    try
      strs.LoadFromFile(fname);
      SaveData := SO(strs.Text);
    finally
      strs.Free;
    end;
    TVRainDownloadPath := SaveData.S['TVRainDownloadPath'];
    SaveData := nil;
  end;
end;

procedure TMainForm.SaveSettings;
var
  SaveData: ISuperObject;
  strs: TStringList;
  fname: string;
begin
  fname := ChangeFileExt(Application.ExeName, '.json');
  if FileExists(fname) then
  begin
    strs := TStringList.Create;
    try
      strs.LoadFromFile(fname);
      SaveData := SO(strs.Text);
    finally
      strs.Free;
    end;
  end
  else
    SaveData := TSuperObject.Create();
  //
  SaveData. S['TVRainDownloadPath'] := TVRainDownloadPath;
  SaveData.SaveTo(fname, True, True);
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
//    ewbMain.Navigate('https://tvrain.ru/archive/?tab=Video');
  ewbMain.Navigate('https://tvrain.ru/archive/?search_year=2017&search_month=2&search_day=3&query=&type=&tab=Video&page=1');
//  ewbMain.Navigate('https://tvrain.ru/lite/teleshow/sindeeva/vayser-429533/');
//  OutputDebugString(PChar(UrlEncode('https://tvrain.ru/lite/teleshow/sindeeva/vayser-429533/')));
//  OutputDebugString(PChar(UrlEncode('://')));
//  Sleep(12000);
//  Halt;
end;

procedure TMainForm.NavigateAndWait(AEWB: TEmbeddedWB; AUrl: string; ATimeout: Cardinal = 15000);
var
  StartTm: TDate;
begin
  StartTm := GetTime;
  AEWB.Navigate(AUrl);
  try
    Enabled := False;
    while (not (AEWB.ReadyState in [READYSTATE_COMPLETE{, READYSTATE_INTERACTIVE}])) and (MilliSecondsBetween(StartTm, GetTime) < ATimeout) do
    begin
      Sleep(50);
      Application.ProcessMessages;
    end;
  finally
    Enabled := True;
  end;
end;

procedure TMainForm.TvRainLogin;
var
  a: Variant;
  f: IHTMLFormElement;
begin
  NavigateAndWait(ewbMain, 'https://tvrain.ru/login/');
  a := (ewbMain.Document as IHTMLDocument3).getElementById('User_email');
  a.value:= 'Vladimir.Srednikh@gmail.com';

  a := (ewbMain.Document as IHTMLDocument3).getElementById('User_password');
  a.value:= '3qw999asd';
  f := (ewbMain.Document as IHTMLDocument2).forms.item('login-form', 0) as IHTMLFormElement;
  f.submit;
////  a.form.submit;
//  while not (ewbMain.ReadyState in [READYSTATE_COMPLETE, READYSTATE_INTERACTIVE]) do
//  begin
//    Sleep(100);
//    Application.ProcessMessages;
//  end;
end;

function TMainForm.URLInQueue(AUrl: string): Boolean;
begin

end;

end.
