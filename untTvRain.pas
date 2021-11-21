unit untTvRain;

interface
uses Windows, Classes, SysUtils, StrUtils, Vcl.Forms, System.DateUtils, System.IOUtils,
  SHDocVw, MSHTML, untIECompat,
  Character,
  IdHTTP, IdUri, IdSSLOpenSSL,
  untM3U,
  superobject,
  untSettings,
  untDownloadCommon
  ;

type
  EDemo = class(Exception);

  TM3UPlayListJson = class helper for TM3UPlayList
  function GetAsJSON: ISuperObject;
  end;

  TProgressEvent = procedure(AMax, APos: Integer) of object;

function CheckTvRainIsDemo(AEwb: TWebBrowser): Boolean;
procedure TvRainLogin(AEwb: TWebBrowser; ALogin, APassword: string; ATimeout: Integer = 15000);
function GetTVRainTitle(AEwb: TWebBrowser): string;
procedure GetEagleIDs(AEwb: TWebBrowser; var AEagleList: TArray<Integer>);
procedure FillAllPlayLists(ewb1: TWebBrowser; var APlayLists: TArray<TM3UPlayList>);
procedure DownloadVideoPlayList(APlayList: TM3UPlayList; AProgressEvent: TProgressEvent);

implementation

function CheckTvRainIsDemo(AEwb: TWebBrowser): Boolean;
var
  str: string;
begin
  OutputDebugString(PChar('CheckTvRainIsDemo, ReadyState = ' + inttoStr(AEwb.ReadyState) + ' ' + (AEwb.Document as IHTMLDocument2).url));
  str := (AEwb.Document as IHTMLDocument2).body.innerHTML;
  Result := AnsiContainsText(str, 'Вы смотрите демо-версию');
end;

procedure TvRainLogin(AEwb: TWebBrowser; ALogin, APassword: string; ATimeout: Integer = 15000);
var
  a: Variant;
  f: IHTMLFormElement;
  StartTm: TDate;
  Url: string;
  WaitLogin: Boolean;
begin
  NavigateAndWait(AEwb, 'https://tvrain.ru/login/');
  OutputDebugStringW(PWideChar(AEwb.LocationURL));
  if not SameText(AEwb.LocationURL, 'https://tvrain.ru/login/') then
    Exit;
  a := (AEwb.Document as IHTMLDocument3).getElementById('User_email');
  try
    a.value:= ALogin;
    Application.ProcessMessages;
  except
    Exit;
  end;

  a := (AEwb.Document as IHTMLDocument3).getElementById('User_password');
  a.value:= APassword;
  Application.ProcessMessages;
  f := (AEwb.Document as IHTMLDocument2).forms.item('login-form', 0) as IHTMLFormElement;
  f.submit;
  Application.ProcessMessages;
  Url := AEwb.LocationURL;
  WaitLogin := SameText(Url, 'https://tvrain.ru/login/');
  WaitLogin := WaitLogin or (AEwb.ReadyState <> READYSTATE_COMPLETE);
  StartTm := GetTime;
  while WaitLogin do
  begin
    Sleep(100);
    Application.ProcessMessages;
    Url := AEwb.LocationURL;
    WaitLogin := SameText(Url, 'https://tvrain.ru/login/');
    WaitLogin := WaitLogin or (AEwb.ReadyState <> READYSTATE_COMPLETE);
    if (MilliSecondsBetween(StartTm, GetTime) > ATimeout) then
      raise Exception.Create('Login Timeout');
  end;
end;

function GetTVRainTitle(AEwb: TWebBrowser): string;
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

procedure GetEagleIDs(AEwb: TWebBrowser; var AEagleList: TArray<Integer>);
var
//  Root, youtube, child,
  node: IHTMLElement;
  coll: IHTMLElementCollection;
  EagleId: Integer;
  I: Integer;
  str: string;
//  attr: OleVariant;
  Arr: TArray<string>;
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
      Arr := string(node.id).Split(['-']);
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

procedure FillPlayList(APlayList: TM3UPlayList);
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
  M3U_List := TStringList.Create;
  try
    Eagle_json := GetHttpStr(eagleLink);
    APlayList.FPlayerData := Eagle_json;
    obj := SO(Eagle_json);
    AppFolder := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
    obj.SaveTo(AppFolder + 'player_data.txt');
//    if AnsiEndsText('трейлер', obj['data']['playlist'].o['title'].AsString) then
//      raise EDemo.Create('');
    SecureLink := obj['data']['playlist'].A['viewports'][0]['medialist']['']['sources']['secure_m3u8']['auto'].AsString;
    if not StartsText('https://', SecureLink) then
      SecureLink := 'https://' + SecureLink;
    secure_link_json := GetHttpStr(SecureLink);
    APlayList.FSecureData := secure_link_json;
    obj := SO(secure_link_json);
    obj.SaveTo(AppFolder + 'secure_link_json.txt');
    if obj.O['data'].s['480'] <> '' then
      M3ULink := obj.O['data'].s['480']
    else
      M3ULink := obj.O['data'].AsArray.S[0];

    M3U_List.Text := GetHttpStr(M3ULink);
    APlayList.FM3UData := M3U_List.Text;
    M3U_List.SaveToFile(AppFolder + 'M3U_List.txt');
    PlayListLink := '';
    for I := 0 to M3U_List.count - 1 do
      if Pos('480p.mp4', M3U_List[I]) > 0 then
        PlayListLink := M3U_List[I]
      else if Pos('360p.mp4', M3U_List[I]) > 0 then
        PlayListLink := M3U_List[I];
    if PlayListLink <> '' then
    begin
      M3U_List.Text := GetHttpStr(PlayListLink);
      if M3U_List.Count < 2 then
        raise Exception.Create('Пустой плейлист!');
      APlayList.SetPlayList(M3U_List);
    end
    else
      raise Exception.Create('Не удалось скачать плейлист!');
    endpos := LastDelimiter('/', PlayListLink);
    if endpos > 0 then
      APlayList.BasePath := Copy(PlayListLink, 1, endpos)
    else
    begin
//      Log('Не найден базовый путь: ' + PlayListLink);
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

procedure DownloadVideoPlayList(APlayList: TM3UPlayList; AProgressEvent: TProgressEvent);
var
  I: Integer;
  TempResFile, NewFileName: string;
  ResultFile, TempFile: TFileStream;
  FIdHTTP: TIdHTTP;
  HandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
  FDownloadPath,
  FTempPath: string;
begin
  if APlayList <> nil then
  begin
    FDownloadPath := IncludeTrailingPathDelimiter(TVRainDownloadPath) + APlayList.PlayDate + '\';
    if not DirectoryExists(FDownloadPath) then
      TDirectory.CreateDirectory(FDownloadPath);
    //
    FTempPath := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'Eagle-' + IntToStr(APlayList.FPlayerId) + '\';
    if not DirectoryExists(FTempPath) then
      CreateDir(FTempPath);
    if DirectoryExists(FTempPath) then
      TDirectory.Delete(FTempPath, True);
    CreateDir(FTempPath);
    FIdHTTP := TIdHTTP.Create(nil);
    HandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create;
    FIdHTTP.IOHandler := HandlerSocket;
   { TODO : Notify progress Start}
    try
      for I := 0 to APlayList.TrackCount - 1 do
      begin
        if Assigned(AProgressEvent) then
          AProgressEvent(APlayList.TrackCount - 1, 0);
        DownloadFile(APlayList.FullTrackPath(I), APlayList.Tracks[I].FileName, FTempPath);

//        FCurrentFile := I;
        { TODO : Notify progress }
      end;
      // последнюю часть также объединяем
      TempResFile := 'Res_Eagle' + IntToStr(APlayList.FPlayerId) + '.mp4';
      NewFileName := Trim(FDownloadPath + Trim(APlayList.Title)) + '.mp4';

      ResultFile := TFileStream.Create(FTempPath + TempResFile, fmCreate + fmOpenWrite);
      try
        for I := 0 to APlayList.TrackCount - 1 do
        begin
          TempFile := System.IOUtils.TFile.OpenRead(FTempPath + APlayList.Tracks[I].FileName);
          try
            TempFile.Position := 0;
            ResultFile.CopyFrom(TempFile, TempFile.Size);
          finally
            FreeAndNil(TempFile);
          end;
        end;
      finally
        ResultFile.Free;
      end;
      if FileExists(NewFileName) then
        TFile.Delete(NewFileName);
      if FileExists(FTempPath + TempResFile) then
        TFile.Copy(FTempPath + TempResFile, NewFileName);
      SavePlayList(APlayList);
   { TODO : Notify progress End}
    finally
      FIdHTTP.IOHandler := nil;
      FreeAndNil(HandlerSocket);
      FreeAndNil(FIdHTTP);
      try
        TDirectory.Delete(FTempPath, True);
      except
      end;
    end;
  end;
end;


procedure FillAllPlayLists(ewb1: TWebBrowser; var APlayLists: TArray<TM3UPlayList>);
var
  Title: string;
  I: Integer;
  IDs: TArray<Integer>;
  URL: TIdURI;
begin
  Title := GetTVRainTitle(ewb1);
  SetLength(IDs, 0);
  GetEagleIDs(ewb1, IDs);
  SetLength(APlayLists, Length(IDs));
  for I := 0 to Length(IDs) - 1 do
  begin
    APlayLists[I] := TM3UPlayList.Create;
    APlayLists[I].Title := Copy(GetTVRainTitle(ewb1), 1, 130);
    APlayLists[I].FPlayerId := IDs[I];
    APlayLists[I].FSourceURL := (ewb1.Document as IHTMLDocument2).url;
    URL := TIdURI.Create(APlayLists[I].FSourceURL);
    try
      APlayLists[I].FTVRainPath := URL.Path;
    finally
      URL.Free;
    end;
    FillPlayList(APlayLists[I]);
    if Length(IDs) > 1 then
      APlayLists[I].Title := Copy(APlayLists[I].Title, 1, 121) + ' Часть ' + IntToStr(I + 1);
  end;
end;

{ TM3UPlayListJson }

function TM3UPlayListJson.GetAsJSON: ISuperObject;
var
  track: ISuperObject;
  I: Integer;
begin
  Result := SO();
  Result.I['FPlayerId'] := FPlayerId;
  Result.S['FTVRainPath'] := FTVRainPath;

  Result.S['FSourceURL'] := FSourceURL;
  Result.S['FPlayerData'] := FPlayerData;
  Result.S['FSecureData'] := FSecureData;
  Result.S['FM3UData'] := FM3UData;
  Result.S['FPictureLink'] := FPictureLink;
  Result.I['FDuration'] := FDuration;

  Result.S['BasePath'] := BasePath;
  Result.S['Title'] := Title;
  Result.S['PlayDate'] := PlayDate;
  Result.S['PlayTime'] := PlayTime;
  Result.I['TrackCount'] := TrackCount;
  Result.O['Tracks'] := SO('[]');
  for I := 0 to TrackCount - 1 do
  begin
    track := SO();
    track.D['Duration'] := Tracks[I].Duration;
    track.S['Title'] := Tracks[I].Title;
    track.S['URL'] := Tracks[I].URL;
    track.S['FileName'] := Tracks[I].FileName;
    Result.A['Tracks'].Add(track);
  end;
end;

end.
