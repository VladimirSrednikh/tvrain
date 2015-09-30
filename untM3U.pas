unit untM3U;

interface

uses System.Classes, System.SysUtils, System.StrUtils;

//#EXTINF:120,Вася барабанщик – Kill My
//My Music\Kill_My.mp3
//
//Где [#EXTINF:] служебное слово, [120] – длина трека в секундах,
//  [Вася барабанщик – Kill My ] – тэг, а [ My Music\Kill_My.mp3]

type

  TTrack = record
    Duration: Double;
    Title: string;
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
    FEagleId: Integer;
    constructor Create;
    procedure SetPlayList(APLayList: TStrings);
    function FullTrackPath(AIndex: Integer): string;
    //
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
var
  Delim: string;
begin
  if (Copy(FBasePath, Length(FBasePath), 1) = '/') or (Copy(FTracks[AIndex].FileName, 1, 1) = '/') then
    Delim := ''
  else
    Delim := '/';
  Result := FBasePath + Delim + FTracks[AIndex].FileName;
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
//  dur: Double;
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
//        str := ReplaceStr(str, ',', FormatSettings.DecimalSeparator);
//        str := ReplaceStr(str, '.', FormatSettings.DecimalSeparator);
        FTracks[FTrackCount - 1].Duration := StrToFloatDef(str, 0);
        I := I + 1;
        if I < (APLayList.Count - 1) then
          FTracks[FTrackCount - 1].FileName := APLayList[I];
      end
    else
      I := I + 1;
  end;
end;

//procedure TM3UPlayList.SetTrackCount(const Value: Integer);
//begin
//  FTrackCount := Value;
//end;

end.
