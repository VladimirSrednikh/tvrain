unit untSettings;

interface

uses System.Generics.Defaults, System.Generics.Collections, System.Classes,
  System.SysUtils, Vcl.Forms,

  untM3U;

var
  TVRainDownloadPath: string = 'H:\Downloads\TVRain';

procedure SavePlayList(APlayList: TM3UPlayList);

implementation

uses superobject;

procedure SavePlayList(APlayList: TM3UPlayList);
var
  SaveData, files, DateArr, obj: ISuperObject;
  strs: TStringList;
  fname: string;
  I: Integer;
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
    files := SaveData.O['Files'];
    if files = nil then
    begin
      SaveData.O['Files'] := TSuperObject.Create(stObject);
      files := SaveData.O['Files'];
    end;
    DateArr := files.O[APlayList.PlayDate];
    if DateArr = nil then
    begin
      files.O[APlayList.PlayDate] := TSuperObject.Create(stObject);
      DateArr := files.O[APlayList.PlayDate];
    end;
    obj := DateArr.O[APlayList.FPlayerId.ToString];
    if obj = nil then
    begin
      DateArr.O[APlayList.FPlayerId.ToString] := TSuperObject.Create(stObject);
      obj := DateArr.O[APlayList.FPlayerId.ToString];
    end;
    obj.S['Title'] := APlayList.Title;
//    obj.I['FTVRainID'] := APlayList.FTVRainID;
    obj.S['FTVRainPath'] := APlayList.FTVRainPath;
    obj.S['PlayDate'] := APlayList.PlayDate;
    obj.S['PlayTime'] := APlayList.PlayTime;
    obj.I['TrackCount'] := APlayList.TrackCount;
    obj.O['Tracks'] := SA([]);
    for I := 0 to APlayList.TrackCount - 1 do
    begin
      obj.A['Tracks'].S[I] := APlayList.Tracks[I].FileName;
    end;
    SaveData.SaveTo(fname, True, True);
//    property BasePath: string read FBasePath write SetBasePath;
//    property Tracks[Index: Integer]: TTrack read Get;
//    property TrackCount: Integer read GetTrackCount;
//    property Title: string read FTitle write FTitle;
//    property PlayDate: string read FPlayDate write FPlayDate;
//    property PlayTime: string read FPlayTime write FPlayTime;

  end;
end;

end.
