unit untM3U;

interface

uses System.Classes, System.SysUtils, System.StrUtils;

//#EXTINF:120,¬ас€ барабанщик Ц Kill My
//My Music\Kill_My.mp3
//
//√де [#EXTINF:] служебное слово, [120] Ц длина трека в секундах,
//  [¬ас€ барабанщик Ц Kill My ] Ц тэг, а [ My Music\Kill_My.mp3]

type

  TTrack = record
    Duration: Double;
    Title: string;
    URL,
    FileName: string;
  end;

  TM3UPlayList = class(TPersistent)
  private
    FBasePath: string;
    FTrackCount: Integer;
    FTracks: array of TTrack;
    FTitle: string;
    FPlayTime: string;
    FPlayDate: string;
    procedure SetBasePath(const Value: string);
//    procedure SetTrackCount(const Value: Integer);
    function Get(Index: Integer): TTrack;
    function GetTrackCount: Integer;
  public
    FPlayerId: Integer;
    FTVRainPath: string;
    //
    FSourceURL: string;
    FPlayerData: string;
    FSecureData: string;
    FM3UData: string;
    FPictureLink: string;
    /// <summary>ƒлительность в секундах </summary>
    FDuration: Integer;
    constructor Create;
    procedure SetPlayList(APLayList: TStrings);
    function FullTrackPath(AIndex: Integer): string;
    /// <summary>ѕуть, к которому добавл€ютс€ файлы дл€ скачивани€</summary>
    property BasePath: string read FBasePath write SetBasePath;
    property Tracks[Index: Integer]: TTrack read Get;
    property TrackCount: Integer read GetTrackCount;
    property Title: string read FTitle write FTitle;
    property PlayDate: string read FPlayDate write FPlayDate;
    property PlayTime: string read FPlayTime write FPlayTime;
  end;

implementation

{ TM3UPlayList }

constructor TM3UPlayList.Create;
begin
  inherited;
  SetLength(FTracks, 0);
  FTrackCount := 0;
  FBasePath := '';
end;

function TM3UPlayList.FullTrackPath(AIndex: Integer): string;
begin
  if ContainsStr(FTracks[AIndex].URL, '://') then
    Result := FTracks[AIndex].URL
  else
  if (Copy(FBasePath, Length(FBasePath), 1) = '/') or (Copy(FTracks[AIndex].URL, 1, 1) = '/') then
    Result := FBasePath + FTracks[AIndex].URL
  else
    Result := FBasePath + '/' + FTracks[AIndex].URL;
end;

function TM3UPlayList.Get(Index: Integer): TTrack;
begin
  if Index >= Length(FTracks) then
    raise Exception.CreateFmt('List index out of bounds (%d)', [Index]);
  Result := FTracks[Index];
end;

function TM3UPlayList.GetTrackCount: Integer;
begin
  Result := Length(FTracks);
end;

procedure TM3UPlayList.SetBasePath(const Value: string);
begin
  FBasePath := Value;
end;

procedure TM3UPlayList.SetPlayList(APLayList: TStrings);
var
  I, SeparartorPos: Integer;
  str: string;
begin
  SetLength(FTracks, 0);
  FTrackCount := 0;
  i := 0;
  while I < (APLayList.Count - 1) do
  begin
    if StartsText('#EXTINF:', APLayList[I]) then
      begin
        Inc(FTrackCount);
        SetLength(FTracks, FTrackCount);
        SeparartorPos := Pos(',', APLayList[I]);
        FTracks[FTrackCount - 1].Title := Copy(APLayList[I], SeparartorPos + 1, Length(APLayList[I]));
        str := Copy(APLayList[I], Length('#EXTINF:') + 1, SeparartorPos - 1);
        FTracks[FTrackCount - 1].Duration := StrToFloatDef(str, 0);
        I := I + 1;
        if I < (APLayList.Count - 1) then
        begin
          FTracks[FTrackCount - 1].URL := APLayList[I];
          SeparartorPos := APLayList[I].LastDelimiter('/' + DriveDelim);
          FTracks[FTrackCount - 1].FileName := APLayList[I].SubString(SeparartorPos + 1);
        end;
      end
    else
      I := I + 1;
  end;
end;

end.
