unit untEchoMskRu;

interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.IOUtils, System.StrUtils, System.DateUtils,
  IdHTTP, IdGlobalProtocols,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, Xml.Win.msxmldom
  ;

procedure EchoDownloadFromRSS(AIdHTTP: TIdHTTP);
// Сетевизор:    PlayListLink := 'http://team1.setevisor.tv:1935/archive/_definst_/echomsk/echomsk.rec/2015/12/echomsk-1449075780.mp4/playlist.m3u8?s=1ug854dm45slqd7mctn4s8tre0&wowzasessionid=1363426954';

implementation


procedure DownloadFile(AIdHTTP: TIdHTTP; AURL, AFileName, ADestFolder: string);
var
  AStream: TFileStream;
  cnt: Integer;
begin
  if not TDirectory.Exists(ADestFolder) then
    TDirectory.CreateDirectory(ADestFolder);
  AStream := TFileStream.Create(ADestFolder + AFileName, fmCreate);
  try
    AIdHTTP.Request.Accept := '*/*';
    cnt := 1;
    repeat
      try
        AIdHTTP.Get(AURL, AStream);
        cnt := 5;
      except
        cnt := cnt + 1;
      end;
    until cnt >= 5;
  finally
    AStream.Free;
  end;
end;

procedure EchoDownloadFromRSS(AIdHTTP: TIdHTTP);
var
  doc: IXMLDocument;
  AStream: TMemoryStream;
  NewFile: TFileStream;
  root, item: IXMLNode;
  I: Integer;
  Arr: TArray<string>;
  URL, Filename, NewFilename, FileDay, ProgramName, FileTime, Title: string;
  dt: TDate;
  tf: TFormatSettings;
begin
  doc := TXMLDocument.Create(nil);
  AStream := TMemoryStream.Create;
  try
    AIdHTTP.Request.Accept := '*/*';
    AIdHTTP.Get('http://echo.msk.ru/interview/rss-audio.xml', AStream);
    doc.LoadFromStream(AStream);
    root := doc.DocumentElement;
    root := root.ChildNodes.FindNode('channel');
//    pbCount.Position := 0;
//    cbxLog.Items.Clear;
    if root <> nil then
    for I := 0 to root.ChildNodes.Count - 1 do
      if SameText(root.ChildNodes.Get(I).LocalName, 'item') then
      begin
//        pbCount.Max := root.ChildNodes.Count - 1;
//        pbCount.Position := I;
        try
          item := root.ChildNodes.Get(I);
          URL := item.ChildValues['guid'];
          Title := item.ChildValues['title'];
          if URL <> '' then //<guid>http://cdn.echo.msk.ru/snd/2015-10-11-razvorot-morning-0706.mp3</guid>
          begin
            Filename := Copy(URL, LastDelimiter('/', URL) + 1, Length(URL));
            Filename := ReplaceStr(Filename, '.mp3', '');
            Arr := Filename.Split(['-']); //2015-10-04-tabel-2005
            if Length(Arr) >= 3 then
            if SameText('bigecho', Arr[3]) or SameText('classicrock', Arr[3])
              or SameText('odna', Arr[3]) or SameText('risk', Arr[3])
              or SameText('vinil', Arr[3]) or SameText('peskov', Arr[3])
              or SameText('unpast', Arr[3])
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
              or AnsiContainsText(Filename, 'buntman') or AnsiContainsText(Filename, 'just')
              or AnsiContainsText(Filename, 'kid') or AnsiContainsText(Filename, 'just')
              or AnsiContainsText(Filename, 'keys') or AnsiContainsText(Filename, 'radiodetaly')
              or SameText('blogout1', Arr[3]) or SameText('beatles', Arr[3])
              or SameText('bombard', Arr[3]) or SameText('', Arr[3])
              or AnsiContainsText(Filename, 'garage') or AnsiContainsText(Filename, 'dream')
              or AnsiContainsText(Filename, 'blokadagolosa') or AnsiContainsText(Filename, 'victory')
              or AnsiContainsText(Filename, 'help') or AnsiContainsText(Filename, 'dalvostok')
              or AnsiContainsText(Filename, '-0805.mp3')
              or AnsiContainsText(Title, 'Интервью : Колыбельная') or AnsiContainsText(Title, 'Интервью : Для Самых Больших')
              or AnsiContainsText(Title, 'Особое мнение : Особое мнение СПб')
  //            or SameText('', Arr[3]) or SameText('', Arr[3])
            then
              Continue;

            if Length(Arr) >= 3 then
              FileDay := Format('%s-%s', [Arr[1], Arr[2]])
            else
            begin  // FileDay остается от предыдущего файла
              FileDay := item.ChildValues['pubDate'];
              dt := StrInternetToDateTime(FileDay);
              // 'Mon, 22 May 2017 17:35:00 +0300'
//              dt := XMLTimeToDateTime(FileDay);
              FileDay := Format('%2d-%2d', [MonthOf(dt), DayOf(dt)]);
            end;
            case Length(Arr) of
              5: NewFilename := Format('%s_%s_%s.mp3', [Arr[0] + '-' + FileDay, Arr[4], Arr[3]]);
              6: NewFilename := Format('%s_%s_%s-%s.mp3', [Arr[0] + '-' + FileDay, Arr[5], Arr[3], Arr[4]]);
              else
                NewFilename := Filename + '.mp3';
            end;
            // Если есть уже такой файл с таким размером, то пропускаем
            if TFile.Exists('H:\Downloads\Echo\' + FileDay + '\' + NewFilename) then
            begin
              NewFile := TFileStream.Create('H:\Downloads\Echo\' + FileDay + '\' + NewFilename, fmOpenRead);
              try
                AIdHTTP.Head(URL);
                if AIdHTTP.Response.ContentLength = NewFile.Size then
                  Continue;
              finally
                NewFile.Free;
              end;
            end;
            DownloadFile(AIdHTTP, URL, NewFilename, 'H:\Downloads\Echo\' + FileDay + '\');
          end;
        except
          on E: Exception do
          begin
//            cbxLog.Items.Add(Format('Error %s on download file %s', [E.Message, URL] ));
//            if cbxLog.Items.Count = 1 then
//              cbxLog.ItemIndex := 0;
          end;
        end;
      end;
  finally
    AStream.Free;
  end;
end;

end.
