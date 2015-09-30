unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.OleCtrls, SHDocVw_EWB,
  EwbCore, EmbeddedWB, MSHTML_EWB, Vcl.ComCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP,
  untM3U,
  untfrmWebTab, Vcl.StdCtrls, Vcl.ExtCtrls
//  , cefvcl, ceflib, untChrom_Helper;
  ;

type
  TIntArray = array of Integer;

  TForm1 = class(TForm)
    ewbMain: TEmbeddedWB;
    mmMain: TMainMenu;
    gototvrain1: TMenuItem;
    mniDownload: TMenuItem;
    pgcPages: TPageControl;
    tsMain: TTabSheet;
    IdHTTP1: TIdHTTP;
    mniLog: TMenuItem;
    cbxLog: TComboBox;
    mniWowMp3: TMenuItem;
    mniFastMM1: TMenuItem;
    pnl1: TPanel;
    pnl2: TPanel;
    pbProgressCurrent: TProgressBar;
    pbCount: TProgressBar;
    tmr1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure mniDownloadClick(Sender: TObject);
    procedure ewbMainBeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure ewbMainNavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure mniCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniWowMp3Click(Sender: TObject);
    procedure mniFastMM1Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
    FLog: TStringList;
    function FindNodeByAttrExStarts(ANode: IHTMLElement; NodeName, AttrName, AttrValue: string): IHTMLElement;
    function GetHttpStr(AURL: string): string; // Работает с системными настройками браузера
    procedure Log(AText{, AFileName}: string);

    function GetTVRainTitle(AEwb: TEmbeddedWB): string;
    procedure GetEagleIDs(AEwb: TEmbeddedWB; var AEagleList: TIntArray);
    procedure FillPlayList(AEgleID: Integer; APlayList: TM3UPlayList);

  public
    { Public declarations }
    procedure DownloadFromWebPage(frm: TfrmWebTab);
    function GetHttpString(AURL: string): string; //Не работает без указание проски
    procedure DownloadFile(AURL, AFileName, ADestFolder: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Winapi.WinInet, System.StrUtils, Soap.XSBuiltIns,
  untIECompat, EwbTools, superobject, untRecode;//, FastMMUsageTracker;

procedure TForm1.DownloadFile(AURL, AFileName, ADestFolder: string);
var
  AStream: TFileStream;
begin
  AStream := TFileStream.Create(ADestFolder + AFileName, fmCreate);
  try
    IdHTTP1.Request.Accept := '*/*';
    IdHTTP1.Get(AURL, AStream);
  finally
    AStream.Free;
  end;
end;

procedure TForm1.ewbMainBeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  ts: TTabSheet;
  frm: TfrmWebTab;
begin
  if StartsText('about:blank', URL) or StartsText('https://googleads.g', URL)  then
    Exit;

  OutputDebugString(PChar('BeforeNavigate2: ' + string(URL)));
  if not (StartsText('http://tvrain.ru/archive/', URL) or StartsText('https://tvrain.ru/archive/', URL)) then
    if StartsText('https://tvrain.ru/', URL) then
    begin
      Cancel := True;
      ts := TTabSheet.Create(Self);
      ts.PageControl := pgcPages;
      pgcPages.ActivePage := ts;
      frm := TfrmWebTab.Create(Self);
      frm.Name := '';
      frm.Parent := ts;
      frm.Align := alClient;
      frm.Navigate(URL);
    end;
end;

procedure TForm1.ewbMainNavigateComplete2(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  tsMain.Tag := 0;
end;

procedure TForm1.FillPlayList(AEgleID: Integer; APlayList: TM3UPlayList);
var
  str,
  eagleLink, SecureLink, M3ULink, PlayListLink,
  Eagle_json, secure_link_json: string;
  M3U_List: TStringList;
  I, startpos, endpos: Integer;
  obj: ISuperObject;
begin
  APlayList.FEagleId := AEgleID;
  eagleLink := 'http://tvrainru.media.eagleplatform.com/api/player_data?id=' + IntToStr(AEgleID);
  // Eagle_json
  Eagle_json := GetHttpStr(eagleLink);
  obj := SO(Eagle_json);
  str := obj.S['time'];
  begin
    startpos := PosEx(' ', str, 1);
    APlayList.PlayDate := Copy(str, 1, startpos - 1);
    endpos := PosEx(' ', str, startpos + 1);
    APlayList.PlayTime := Copy(str, startpos + 1, endpos - startpos - 1);
    // очищаем от неподдерживаемых символов
    APlayList.PlayDate := StringReplace(APlayList.PlayDate, '/', '_', [rfReplaceAll]);
    APlayList.PlayTime := StringReplace(APlayList.PlayTime, ':', '_', [rfReplaceAll]);
  //  "time":"2015/08/26 15:03:47 +0300",
  end;
  startpos := Pos('tvrainru.panel.eaglecdn.com', Eagle_json);
  endpos := PosEx('"', Eagle_json, startpos);
  SecureLink := Copy(Eagle_json, startpos, endpos - startpos);
  if not StartsText('http://', SecureLink) then
    SecureLink := 'http://' + SecureLink;
  // SecureLink
  secure_link_json := GetHttpStr(SecureLink);
  obj := SO(secure_link_json);
  M3ULink := obj.O['data'].AsArray.S[0];
  M3U_List := TStringList.Create;
  try
    M3U_List.Text := GetHttpStr(M3ULink);
    PlayListLink := '';
    for I := 0 to M3U_List.count - 1 do
      if Pos('480p.mp4', M3U_List[I]) > 0 then
        PlayListLink := M3U_List[I]
      else if Pos('360p.mp4', M3U_List[I]) > 0 then
        PlayListLink := M3U_List[I];
    if PlayListLink <> '' then
      M3U_List.Text := GetHttpStr(PlayListLink);
    APlayList.SetPlayList(M3U_List);
    // http://stream.b39.servers.eaglecdn.com/tvrainru/2015-08-26/55dd939c53e11_video_480p.mp4/index.m3u8?st=yIOV_QrZE5-ii1RobBxlnQ&e=1440621898
    // http://stream.b39.servers.eaglecdn.com/tvrainru/2015-08-26/55dd939c53e11_video_480p.mp4/seg-1-v1-a1.ts
    endpos := LastDelimiter('/', PlayListLink);
    if endpos > 0 then
      APlayList.BasePath := Copy(PlayListLink, 1, endpos)
    else
    begin
      Log('Не найден базовый путь: ' + PlayListLink);
      APlayList.BasePath := PlayListLink;
    end;
    startpos := Pos('/tvrainru/', PlayListLink);
    startpos := startpos + Length('/tvrainru/');
    endpos := PosEx('/', PlayListLink, startpos);
    str := Copy(PlayListLink, startpos, endpos - startpos);
    str := StringReplace(str, '/', '', [rfReplaceAll]);
    APlayList.PlayDate := str;
  finally
    M3U_List.Free;
  end;
end;

function TForm1.FindNodeByAttrExStarts(ANode: IHTMLElement; NodeName, AttrName,
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  FLog := TStringList.Create;
  PutIECompatible(GetIEVersionMajor, cmrCurrentUser);
  tsMain.Tag := 1;
  ewbMain.Navigate('http://tvrain.ru/archive/?tab=Video');
//  chrm1.Browser.MainFrame.LoadUrl('http://tvrain.ru/teleshow/here_and_now/alkogol_budet_deshevle-393275/');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FLog);
end;

procedure TForm1.DownloadFromWebPage(frm: TfrmWebTab);
var
  Title: string;
  PlayList: TM3UPlayList;
  I: Integer;
  IDs: TIntArray;
begin
  Title := GetTVRainTitle(frm.ewb1);
  SetLength(IDs, 0);
  GetEagleIDs(frm.ewb1, IDs);
  for I := 0 to Length(IDs) - 1 do
  begin
    PlayList := TM3UPlayList.Create;
    try
      PlayList.Title := GetTVRainTitle(frm.ewb1);
      FillPlayList(IDs[I], PlayList);
      if Length(IDs) > 1 then
        PlayList.Title := PlayList.Title + ' Часть ' + IntToStr(I + 1);
      AddTask(PlayList);
    except
      FreeAndNil(PlayList);
    end;
  end;
end;

function TForm1.GetHttpString(AURL: string): string;
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

procedure TForm1.GetEagleIDs(AEwb: TEmbeddedWB;
  var AEagleList: TIntArray);
var
  node, child: IHTMLElement;
  EagleId: Integer;
  I: Integer;
  str: string;
  attr: OleVariant;
begin
  SetLength(AEagleList, 0);
  node := FindNodeByAttrExStarts((AEwb.Document as IHTMLDocument3).documentElement, 'div', 'class', 'eagle-player-series');
  if node <> nil then
  begin
    for I := 0 to (node.children as IHTMLElementCollection).length - 1 do
    begin
      child := (node.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
      if SameText(child.tagName, 'div') and StartsText('eagle-player-series', child.className) then
      begin
        attr := child.getAttribute('data-id', 0);
        if not VarIsNull(attr) then
        begin
          SetLength(AEagleList, Length(AEagleList) + 1);
          AEagleList[Length(AEagleList) - 1] := attr;
        end;
      end;
    end;
  end
  else
  begin
    node := FindNodeByAttrExStarts((AEwb.Document as IHTMLDocument3).documentElement, 'div', 'id', 'eagleplayer-');
    if node <> nil then
    begin
      str := node.id;
      str := StringReplace(str, 'eagleplayer-', '', []);
      EagleId := StrToIntDef(str, 0);
      if EagleId <> 0 then
      begin
        SetLength(AEagleList, 1);
        AEagleList[0] := EagleId;
      end;
    end;
  end;
end;

function TForm1.GetTVRainTitle(AEwb: TEmbeddedWB): string;
var
  root, node: IHTMLElement;
begin
  Result := '';
  root := (AEwb.Document as IHTMLDocument3).documentElement;
  node := FindNodeByAttrExStarts(root, 'article', 'class', 'article article-full');
  if node <> nil then
  begin
    node := FindNodeByAttrExStarts(node, 'h1', 'class', 'article-full__title');
    if node <> nil then
      Result := node.innerText;
  end;
  Result := StringReplace(Result, ':', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '/', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '\', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '?', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '*', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '"', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '>', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '<', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '|', ' ', [rfReplaceAll]);
end;

procedure TForm1.Log(AText{, AFileName}: string);
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

function TForm1.GetHttpStr(AURL: string): string;
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

procedure TForm1.mniCloseClick(Sender: TObject);
var
  ts: TTabSheet;
begin
  ts := pgcPages.ActivePage;
  ts.PageControl := nil;
  FreeAndNil(ts);
end;

procedure TForm1.mniDownloadClick(Sender: TObject);
var
  control: TControl;
  I: Integer;
begin
  for I := 0 to pgcPages.ActivePage.ControlCount - 1 do
  begin
    control := pgcPages.ActivePage.Controls[I];
    if control is TfrmWebTab then
    begin
      DownloadFromWebPage(control as TfrmWebTab);
      mniCloseClick(nil);
    end;

//    if control is TEmbeddedWB then
//      GetEagleID(control as TEmbeddedWB);
  end;
end;


procedure TForm1.mniFastMM1Click(Sender: TObject);
begin
//  ShowFastMMUsageTracker;
//chrm1.Browser.ShowDevTools;
//  chrm1.Browser.MainFrame.VisitDomProc(AddEagleToDownloaList);
end;

procedure TForm1.mniWowMp3Click(Sender: TObject);
//var
//  obj: ISuperObject;
//  I, len: Integer;
//  Url, ID, fname: string;
begin
//  obj := SO(mmoJS.Text);
//  len := obj.AsArray.Length;
//  for I := 0 to len - 1 do
//  begin
//    ID := obj.AsArray[I].S['id'];
//    ID := StringReplace(ID, #10, '', [rfReplaceAll]);
//    ID := StringReplace(ID, #13, '', [rfReplaceAll]);
//    Url := 'http://wowimg.zamimg.com/wowsounds/' + ID;
//    fname := obj.AsArray[I].S['title'] + '_' + ID + '.ogg';
//    fname := StringReplace(fname, #10, '', [rfReplaceAll]);
//    fname := StringReplace(fname, #13, '', [rfReplaceAll]);
//    DownloadFile(Url, fname, 'C:\Users\User\Downloads\Остров грома\1\');
//  end;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
  i: Integer;
  found: Boolean;
begin
  pbCount.Max := DownloadList.Count;
  found := False;
  for I := DownloadList.Count - 1 downto 0 do
    if not (DownloadList.Items[I] as TTaskItem).SuccessDownloaded then
    begin
      pbCount.Position := I;
      pbProgressCurrent.Max := (DownloadList.Items[I] as TTaskItem).FPlayList.TrackCount;
      pbProgressCurrent.Position := (DownloadList.Items[I] as TTaskItem).FCurrentFile;
      found := True;
    end;
  if not found then
  begin
    pbCount.Position := 0;
    pbProgressCurrent.Position := 0;
  end;
end;

end.
