unit untWowHead;

interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.IOUtils, System.StrUtils, System.DateUtils,
  IdHTTP, IdGlobalProtocols,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, Xml.Win.msxmldom,
  StringFuncs,
  SHDocVw, MSHTML,
  superobject
  ;

implementation

procedure DownloadWowSound;
//var
//  root, node, parentnode, script: IHTMLElement;
//  coll: IHTMLElementCollection;
//  I, ipos: Integer;
//  scripttext: string;
//  obj: ISuperObject;
//  soundI, len: Integer;
//  Title, SubTitle, ZoneID, Url, ID, fname, ext: string;
begin
//  if wbWow.Document = nil then
//    Exit;
//  Title := (wbWow.Document as IHTMLDocument2).title;
//  Title := Trim(Copy(Title, 1, Pos(' -', Title)));
//  Title := ReplaceStr(Title, ':', ' ');
//  Title := ReplaceStr(Title, '"', '_');
//  Title := ReplaceStr(Title, '''', '_');
//
//  if Title = ''  then
//    Title := 'UnknownZone';
//  Url := (wbWow.Document as IHTMLDocument2).url;
//  ipos := Pos('zone=', Url);
//  Url := Copy(Url, ipos + 5, Length(Url));
//  ipos := Pos('\', Url);
//  if ipos = 0 then
//    ipos := Pos('/', Url);
//  if ipos > 0 then
//    ZoneID := Copy(Url, 1, ipos - 1)
//  else
//    ZoneID := 'unknown Id';
//  Title := Title + '_' + ZoneID;
//  node := (wbWow.Document as IHTMLDocument3).getElementById('zonemusicdiv-zonemusic');
//  if node <> nil then
//    parentnode := node.parentElement;
//  if parentnode <> nil then
//  for I := 0 to (parentnode.children as IHTMLElementCollection).length - 1 do
//  begin
//    script := (parentnode.children as IHTMLElementCollection).item(I, 0) as IHTMLElement;
//    if SameText(script.tagName, 'div') then
//      SubTitle := script.id
//    else
//    if SameText(script.tagName, 'script') and not SameText('zonemusicdiv-soundambience', SubTitle) then
//    begin
//      scripttext := script.innerHTML;
//      ipos := Pos('[{', scripttext);
//      scripttext := Copy(scripttext, ipos, Length(scripttext));
//      ipos := Pos('}]', scripttext);
//      scripttext := Copy(scripttext, 1, ipos + 2);
//      obj := SO(scripttext);
//      try
//        len := obj.AsArray.Length;
//        pbCount.Position := 0;
//        pbCount.Max := Len;
//        OutputDebugString(PChar('Len = ' + IntToStr(pbCount.Max)));
//        Application.ProcessMessages;
//        for soundI := 0 to len - 1 do
//        begin
//          ID := obj.AsArray[soundI].S['id'];
//          ID := StringReplace(ID, #10, '', [rfReplaceAll]);
//          ID := StringReplace(ID, #13, '', [rfReplaceAll]);
//          Url := 'http://wowimg.zamimg.com/wowsounds/' + ID;
//          if ContainsText(obj.AsArray[soundI].S['type'], 'ogg') then
//            ext := '.ogg'
//          else
//            ext := '.mp3';
//          fname := obj.AsArray[soundI].S['title'] + '_' + ID + ext;
//          fname := StringReplace(fname, #10, '', [rfReplaceAll]);
//          fname := StringReplace(fname, #13, '', [rfReplaceAll]);
//          pbCount.Position := soundI;
//          Application.ProcessMessages;
//          DownloadFile(Url, fname, 'F:\Music\Soundtracks\Games\WoW\ZoneMusic\' + Title + '\' + SubTitle + '\');
//        end;
//      finally
//        obj := nil;
//        pbCount.Position := 0;
//      end;
//    end;
//  end;
end;

end.
