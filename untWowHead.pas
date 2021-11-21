unit untWowHead;

interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.IOUtils, System.StrUtils, System.DateUtils,
  Vcl.ComCtrls, Vcl.Forms,
  IdHTTP, IdGlobalProtocols,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, Xml.Win.msxmldom,
  SHDocVw, MSHTML,
  superobject, untDownloadCommon;

procedure DownloadWowSound(AwbWow: TWebBrowser; ADestination: string; AProgress: TProgressBar);
procedure AddWowFiles(AwbWow: TWebBrowser; AWowFiles: ISuperObject);

implementation

procedure DownloadWowSound(AwbWow: TWebBrowser; ADestination: string; AProgress: TProgressBar);
var
  root, node, parentnode, script: IHTMLElement;
  coll: IHTMLElementCollection;
  I, ipos, lastDelim: Integer;
  scripttext, zonetext: string;
  obj: ISuperObject;
  soundI, len: Integer;
  Title, SubTitle, ZoneID, Url, ID, fname, ext: string;
begin
  if AwbWow.Document = nil then
    Exit;
  Title := (AwbWow.Document as IHTMLDocument2).Title;
  Title := Trim(Copy(Title, 1, Pos(' -', Title)));
  Title := ReplaceStr(Title, ':', ' ');
  Title := ReplaceStr(Title, '"', '_');
  Title := ReplaceStr(Title, '''', '_');

  if Title = '' then
    Title := 'UnknownZone';
  Url := (AwbWow.Document as IHTMLDocument2).Url;
  ipos := Pos('zone=', Url);
  if ipos > 0 then
  begin
    Url := Copy(Url, ipos + 5, Length(Url));
    ipos := Pos('\', Url);
    if ipos = 0 then
      ipos := Pos('/', Url);
    if ipos > 0 then
      ZoneID := Copy(Url, 1, ipos - 1)
    else
      ZoneID := 'unknown Id';
  end
  else
  begin
    node := (AwbWow.Document as IHTMLDocument3).getElementById('infobox-original-position');
    if node = nil then
      ZoneID := 'unknown Id'
    else
    begin
      zonetext := node.innerHTML;
      ipos := Pos('Zone ID:', zonetext); // Zone ID: 7543<
      if ipos = 0 then
        ZoneID := 'unknown Id'
      else
      begin
        ipos := ipos + Length('Zone ID:') + 1;
        while zonetext[ipos] = ' ' do
          Inc(ipos); // пропустить пробелы
        lastDelim := PosEx('<', zonetext, ipos);
        ZoneID := Copy(zonetext, ipos, lastDelim - ipos);
        if not TryStrToInt(ZoneID, ipos) then
          ZoneID := 'unknown Id';
      end;
    end;
  end;

  Title := Title + '_' + ZoneID;
  node := (AwbWow.Document as IHTMLDocument3).getElementById('zonemusicdiv-zonemusic');
  if node <> nil then
    parentnode := node.parentElement;
  if parentnode <> nil then
    for I := 0 to (parentnode.children as IHTMLElementCollection).Length - 1 do
    begin
      script := (parentnode.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
      if SameText(script.tagName, 'div') then
        SubTitle := script.ID
    else
    if SameText(script.tagName, 'script') and not SameText('zonemusicdiv-soundambience', SubTitle) then
      begin
        scripttext := script.innerHTML;
        ipos := Pos('[{', scripttext);
        scripttext := Copy(scripttext, ipos, Length(scripttext));
        ipos := Pos('}]', scripttext);
        scripttext := Copy(scripttext, 1, ipos + 2);
        obj := SO(scripttext);
        obj.SaveTo('C:\Users\User\Documents\Embarcadero\Studio\Projects\tvrain\Bin\Wow_zone.json', True, False);
        try
          len := obj.AsArray.Length;
          AProgress.Position := 0;
          AProgress.Max := len;
          OutputDebugString(PChar('Len = ' + IntToStr(AProgress.Max)));
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
            AProgress.Position := soundI;
            Application.ProcessMessages;
            DownloadFile(Url, fname, ADestination + Title + '\' + SubTitle + '\');
          end;
        finally
          obj := nil;
          AProgress.Position := 0;
        end;
      end;
    end;
end;

procedure AddWowFiles(AwbWow: TWebBrowser; AWowFiles: ISuperObject);
var
  root, node, parentnode, script: IHTMLElement;
  coll: IHTMLElementCollection;
  I, ipos, lastDelim: Integer;
  scripttext, zonetext: string;
  obj: ISuperObject;
  soundI, len: Integer;
  Title, SubTitle, ZoneID, Url, ID, fname, ext: string;
begin
  if AwbWow.Document = nil then
    Exit;
  Title := (AwbWow.Document as IHTMLDocument2).Title;
  Title := Trim(Copy(Title, 1, Pos(' -', Title)));
  Title := ReplaceStr(Title, ':', ' ');
  Title := ReplaceStr(Title, '"', '_');
  Title := ReplaceStr(Title, '''', '_');

  if Title = '' then
    Title := 'UnknownZone';
  Url := (AwbWow.Document as IHTMLDocument2).Url;
  ipos := Pos('zone=', Url);
  if ipos > 0 then
  begin
    Url := Copy(Url, ipos + 5, Length(Url));
    ipos := Pos('\', Url);
    if ipos = 0 then
      ipos := Pos('/', Url);
    if ipos > 0 then
      ZoneID := Copy(Url, 1, ipos - 1)
    else
      ZoneID := 'unknown Id';
  end
  else
  begin
    node := (AwbWow.Document as IHTMLDocument3).getElementById('infobox-original-position');
    if node = nil then
      ZoneID := 'unknown Id'
    else
    begin
      zonetext := node.innerHTML;
      ipos := Pos('Zone ID:', zonetext); // Zone ID: 7543<
      if ipos = 0 then
        ZoneID := 'unknown Id'
      else
      begin
        ipos := ipos + Length('Zone ID:') + 1;
        while zonetext[ipos] = ' ' do
          Inc(ipos); // пропустить пробелы
        lastDelim := PosEx('<', zonetext, ipos);
        ZoneID := Copy(zonetext, ipos, lastDelim - ipos);
        if not TryStrToInt(ZoneID, ipos) then
          ZoneID := 'unknown Id';
      end;
    end;
  end;

  Title := Title + '_' + ZoneID;
  node := (AwbWow.Document as IHTMLDocument3).getElementById('zonemusicdiv-zonemusic');
  if node <> nil then
    parentnode := node.parentElement;
  if parentnode <> nil then
    for I := 0 to (parentnode.children as IHTMLElementCollection).Length - 1 do
    begin
      script := (parentnode.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
      if SameText(script.tagName, 'div') then
        SubTitle := script.ID
    else
    if SameText(script.tagName, 'script') and not SameText('zonemusicdiv-soundambience', SubTitle) then
      begin
        scripttext := script.innerHTML;
        ipos := Pos('[{', scripttext);
        scripttext := Copy(scripttext, ipos, Length(scripttext));
        ipos := Pos('}]', scripttext);
        scripttext := Copy(scripttext, 1, ipos + 2);
        obj := SO(scripttext);
        obj.SaveTo('C:\Users\User\Documents\Embarcadero\Studio\Projects\tvrain\Bin\Wow_zone.json', True, False);
        try
          len := obj.AsArray.Length;
          // AProgress.Position := 0;
          // AProgress.Max := Len;
          // OutputDebugString(PChar('Len = ' + IntToStr(AProgress.Max)));
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
            // AProgress.Position := soundI;
            // Application.ProcessMessages;
            // DownloadFile(Url, fname, ADestination + Title + '\' + SubTitle + '\');
          end;
        finally
          obj := nil;
          // AProgress.Position := 0;
        end;
      end;
    end;
end;

end.
