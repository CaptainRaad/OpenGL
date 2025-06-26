unit Prototype.Threads;

interface

uses
  System.Classes,
  WinAPi.Windows;

type
  TMethod = procedure of object;

  TUPSC = record
    UPS, UPSC, FQ, CPS, TS, PTS:Int64;
  end;

  TMiniThread = class(TThread)
  private
    UPSC : TUPSC;
    ThreadMethod  : TMethod;
    SleepInterval : Uint16;
  protected
    procedure Execute; override;
  public
    constructor Create;
    function GetUPS : Int64;
    procedure SetThreadMethod(Method : TMethod);
    procedure SetSleepInterval(Value : UInt16);
  end;

implementation

function GetNumberOfProcessors: UInt16;
  var
     SIRecord: TSystemInfo;
  begin
     GetSystemInfo(SIRecord);
     Result := SIRecord.dwNumberOfProcessors;
  end;

{ TMiniThread }

{
    LoopThread := TLoopThread.Create;
    LoopThread.SetSleepInterval(1);
    LoopThread.Priority := tpNormal;
    LoopThread.SetThreadMethod(Method);
}

{
    LoopThread.Terminate;
    LoopThread.WaitFor;
    LoopThread.Free;
}

constructor TMiniThread.Create;
  begin
    inherited;
    QUERYPERFORMANCEFREQUENCY(UPSC.FQ);
    QUERYPERFORMANCECOUNTER(UPSC.TS);
    UPSC.CPS := 8;  UPSC.PTS := 0;
  end;

procedure TMiniThread.Execute;
  begin
    inherited;
    repeat
      Synchronize(Self.ThreadMethod);
      inc(UPSC.UPSC);
      QUERYPERFORMANCECOUNTER(UPSC.TS);
      if UPSC.TS - UPSC.PTS > UPSC.FQ div UPSC.CPS then
        begin
          UPSC.UPS  := UPSC.UPSC * UPSC.CPS;
          UPSC.UPSC := 0;
          UPSC.PTS := UPSC.TS;
        end;
      Sleep(SleepInterval);
    until Terminated;
  end;

function TMiniThread.GetUPS: Int64;
  begin
    Result := UPSC.UPS;
  end;

procedure TMiniThread.SetSleepInterval(Value: UInt16);
  begin
    SleepInterval := Value;
  end;

procedure TMiniThread.SetThreadMethod(Method: TMethod);
  begin
    ThreadMethod := Method;
  end;
end.


