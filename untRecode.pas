unit untRecode;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, System.IOUtils,
  System.Generics.Collections, System.Generics.Defaults,
  untM3U,IdHTTP, System.SyncObjs
  ;

type

  TTaskItem = class
  public
    FPlayList: TM3UPlayList;
    FCurrentFile: Integer;
    SuccessDownloaded: Boolean;
  end;


  TRemakeThread = class(TThread)
  private
    { Private declarations }
    FIdHTTP: TIdHTTP;
    FDownloadPath,
    FTempPath,
    FSelfPath: string;
  protected
    procedure Execute; override;
    procedure DownloadFile(AURL, AFileName, ADestFolder: string);
    procedure Log(AText: string; AFileName: string);
    procedure DoTask(ATask: TTaskItem);
    procedure MergeFiles(ATrackList, ANewTrack, AFolder: string);
  public
    constructor Create;
  end;

function AddTask(APlayList: TM3UPlayList): Boolean;

var
  DownloadList: TList<TTaskItem>;
  Event: TEvent;
  RemakeThread: TRemakeThread;

implementation

uses untSettings;

var
  cs: TCriticalSection;

 function FileSize(fileName : wideString) : Int64;
 var
   sr : TSearchRec;
 begin
   if System.SysUtils.FindFirst(fileName, faAnyFile, sr ) = 0 then
      result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
   else
      result := -1;

   System.SysUtils.FindClose(sr) ;
 end;


function AddTask(APlayList: TM3UPlayList): Boolean;
var
  t: TTaskItem;
begin
  cs.Enter;
  try
    for t in DownloadList do
      if t.FPlayList.FPlayerId = APlayList.FPlayerId then
        Exit(False);

    t := TTaskItem.Create;
    t.FPlayList := APlayList;
    t.SuccessDownloaded := False;
    t.FCurrentFile := 0;
    DownloadList.Add(t);
    Event.SetEvent;
    Result := True;
  finally
    cs.Leave;
  end;
end;

{ TRemakeThread }

constructor TRemakeThread.Create;
begin
  FSelfPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  inherited Create(False);
end;

procedure TRemakeThread.MergeFiles(ATrackList, ANewTrack, AFolder: string);
var
  ArgumentStr: string;
  st: TStartupInfo;
  pi: TProcessInformation;
begin
  ArgumentStr := Format('ffmpeg -i "concat:%s" -c copy -bsf:a aac_adtstoasc -y %s', [ATrackList, ANewTrack]);
  Log(ArgumentStr, FTempPath + 'Makefile.bat');
  FillChar(st, SizeOf(st), 0);
  st.wShowWindow := SW_SHOWMINIMIZED;
  FillChar(pi, SizeOf(pi), 0);
  CreateProcess(nil, PChar('cmd.exe  /c ' + FTempPath + 'Makefile.bat'), nil, nil, False, 0, nil,
    PChar(FTempPath), st, pi);
  // Ждать окончание процесса
  WaitForSingleObject(pi.hProcess, INFINITE);
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
end;

procedure TRemakeThread.DoTask(ATask: TTaskItem);
var
  I: Integer;
  TempResFile, NewFileName: string;
  ResultFile, TempFile: TFileStream;
begin
  if ATask.FPlayList <> nil then
  begin
    FDownloadPath := IncludeTrailingPathDelimiter(TVRainDownloadPath) + ATask.FPlayList.PlayDate + '\';
    if not DirectoryExists(FDownloadPath) then
      TDirectory.CreateDirectory(FDownloadPath);
    //
    FTempPath := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'Eagle-' + IntToStr(ATask.FPlayList.FPlayerId) + '\';
    if DirectoryExists(FTempPath) then
      TDirectory.Delete(FTempPath, True);
    CreateDir(FTempPath);
    FIdHTTP := TIdHTTP.Create(nil);
    try
      for I := 0 to ATask.FPlayList.TrackCount - 1 do
      begin
        DownloadFile(ATask.FPlayList.FullTrackPath(I), ATask.FPlayList.Tracks[I].FileName, FTempPath);
        OutputDebugString(PChar(Format('download part %d, fileID %d, Size = %d', [I, ATask.FPlayList.FPlayerId, FileSize(FTempPath + ATask.FPlayList.Tracks[I].FileName)])));
        ATask.FCurrentFile := I;
      end;
      // последнюю часть также объединяем
      TempResFile := 'Res_Eagle' + IntToStr(ATask.FPlayList.FPlayerId) + '.mp4';
      NewFileName := Trim(FDownloadPath + Trim(ATask.FPlayList.Title)) + '.mp4';

      ResultFile := TFileStream.Create(FTempPath + TempResFile, fmCreate + fmOpenWrite);
      try
        for I := 0 to ATask.FPlayList.TrackCount - 1 do
        begin
          TempFile := System.IOUtils.TFile.OpenRead(FTempPath + ATask.FPlayList.Tracks[I].FileName);
          try
            OutputDebugString(PChar(Format('Copy part %d, filepath %s, FileSize = %d',
              [I, FTempPath + ATask.FPlayList.Tracks[I].FileName, TempFile.Size])));
            TempFile.Position := 0;
            ResultFile.CopyFrom(TempFile, TempFile.Size);

          finally
            FreeAndNil(TempFile);
          end;
        end;
      finally
        ResultFile.Free;
            OutputDebugString(PChar(Format('finally TempResFile %s, FileSize = %d',
              [FTempPath + TempResFile, FileSize(FTempPath + TempResFile)])));
      end;
      if FileExists(NewFileName) then
        TFile.Delete(NewFileName);
      if FileExists(FTempPath + TempResFile) then
        TFile.Copy(FTempPath + TempResFile, NewFileName);
      ATask.SuccessDownloaded := True;
      SavePlayList(ATask.FPlayList);
    finally
      FIdHTTP.Free;
      try
        TDirectory.Delete(FTempPath, True);
      except
      end;
    end;
  end;
end;

procedure TRemakeThread.DownloadFile(AURL, AFileName, ADestFolder: string);
var
  AStream: TFileStream;
  Count: Integer;
  Success: Boolean;
  ErrText: string;
begin
  AStream := TFileStream.Create(ADestFolder + AFileName, fmCreate);
  try
    Count := 0;
    Success := False;
    FIdHTTP.Request.Accept := '*/*';
    while (not Success) and (Count < 5) do
    begin
      try
        FIdHTTP.Get(AURL, AStream);
        Success := True;
      except
        on E: Exception do
        begin
          ErrText := E.Message;
          Inc(Count);
          Sleep(2000);
        end;
      end;
    end;
    if not Success then
      Log(Format('Download URL: %s ; FileName: %s; ErrText: %s', [AURL, ADestFolder + AFileName, ErrText]), FTempPath + 'Log.txt');
  finally
    AStream.Free;
  end;
end;

procedure TRemakeThread.Execute;
var
  I: Integer;
  task: TTaskItem;
begin
  while (not Terminated) and Assigned(DownloadList) do
//    if Event.WaitFor(1000) = wrSignaled then
    begin
      Sleep(1500);
      cs.Enter;
      try
        task := nil;
        for I := DownloadList.Count - 1 downto 0 do
        begin
          task := DownloadList.Items[I] as TTaskItem;
          if not task.SuccessDownloaded then
            Break
          else
            task := nil;
        end;
      finally
        cs.Leave;
      end;
      Event.ResetEvent;
      if Assigned(task) then
        DoTask(task);
    end;
end;

procedure TRemakeThread.Log(AText: string; AFileName: string);
var
  SaveFile: TStringList;
begin
  SaveFile := TStringList.Create;
  try
    SaveFile.Text := AText;
    SaveFile.SaveToFile(AFileName);
  finally
    SaveFile.Free;
  end;
end;

var
  tmp_g: TGUID;
initialization
  cs := TCriticalSection.Create;
  DownloadList := TList<TTaskItem>.Create;
  CreateGUID(tmp_g);
  Event := TEvent.Create(nil, False, False, GUIDToString(tmp_g));
  RemakeThread := TRemakeThread.Create;

finalization
  RemakeThread.Terminate;
  RemakeThread.WaitFor;
  cs.Enter;
  try
    FreeAndNil(DownloadList);
  finally
    cs.Leave;
  end;
  FreeAndNil(cs);
  FreeAndNil(Event);
end.
