unit untRecode;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, System.IOUtils, untM3U,
  IdHTTP, System.SyncObjs
  ;

type

  TTaskItem = class(TCollectionItem)
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

procedure AddTask(APlayList: TM3UPlayList);

var
  DownloadList: TCollection;
  Event: TEvent;
  RemakeThread: TRemakeThread;

implementation

var
  cs: TCriticalSection;

procedure AddTask(APlayList: TM3UPlayList);
var
  t: TTaskItem;
begin
  cs.Enter;
  try
    t := DownloadList.Add as TTaskItem;
    t.FPlayList := APlayList;
    t.SuccessDownloaded := False;
    t.FCurrentFile := 0;
    Event.SetEvent;
  finally
    cs.Leave;
  end;
end;

{ TRemakeThread }

constructor TRemakeThread.Create;
begin
  FreeOnTerminate := True;
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
  CreateProcess(nil, PChar('cmd.exe  /c ' + FTempPath + 'Makefile.bat'), 0, 0, False, 0, 0,
    PChar(FTempPath), st, pi);
  // Ждать окончание процесса
  WaitForSingleObject(pi.hProcess, INFINITE);
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
end;

procedure TRemakeThread.DoTask(ATask: TTaskItem);
var
  I, PartI: Integer;
  TempResFile, NewFileName: string;
begin
  if ATask.FPlayList <> nil then
  begin
    FDownloadPath := 'H:\Downloads\TVRain\' + ATask.FPlayList.PlayDate + '\';
    if not DirectoryExists(FDownloadPath) then
      TDirectory.CreateDirectory(FDownloadPath);
    //
    FTempPath := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'Eagle-' + IntToStr(ATask.FPlayList.FEagleId) + '\';
    try
      if DirectoryExists(FTempPath) then
        TDirectory.Delete(FTempPath, True);
    except
    end;
    CreateDir(FTempPath);
    FIdHTTP := TIdHTTP.Create(nil);
    try
      TFile.Copy(FSelfPath + 'ffmpeg.exe', FTempPath + 'ffmpeg.exe');
      PartI := 0;
      for I := 0 to ATask.FPlayList.TrackCount - 1 do
      begin
        DownloadFile(ATask.FPlayList.FullTrackPath(I), ATask.FPlayList.Tracks[I].FileName, FTempPath);
        ATask.FCurrentFile := I;
      end;
      // последнюю часть также объединяем
      TempResFile := 'Res_Eagle' + IntToStr(ATask.FPlayList.FEagleId) + '.mp4';
      MergeFiles(LastFileSeq, TempResFile, FTempPath);
      NewFileName := Trim(FDownloadPath + Trim(ATask.FPlayList.Title)) + '.mp4';
      if FileExists(NewFileName) then
        TFile.Delete(NewFileName);
      if FileExists(FTempPath + TempResFile) then
        TFile.Copy(FTempPath + TempResFile, NewFileName);
      ATask.SuccessDownloaded := True;
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
  DownloadList := TCollection.Create(TTaskItem);
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
