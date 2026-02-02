program HappyNumbers;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, SyncObjs;

type
  TWorkerThread = class(TThread)
  private
    FStart: Integer;
    FEnd: Integer;
    FHappyCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(AStart, AEnd: Integer);
    property HappyCount: Integer read FHappyCount;
  end;

var
  Bound: Integer;
  ErrorCode: Integer;
  TotalHappyCount: Integer;
  Percentage: Double;
  NumThreads: Integer;
  Threads: array of TWorkerThread;
  i, NumbersPerThread, Remainder, CurrentStart: Integer;

{ Calculate sum of squares of digits }
function SumOfSquares(N: Integer): Integer;
var
  Sum, Digit: Integer;
begin
  Sum := 0;
  while N > 0 do
  begin
    Digit := N mod 10;
    Sum := Sum + Digit * Digit;
    N := N div 10;
  end;
  Result := Sum;
end;

{ Check if a number is happy }
function IsHappy(N: Integer): Boolean;
var
  Seen: array[0..999] of Integer;
  SeenCount: Integer;
  Current: Integer;
  i: Integer;
  Found: Boolean;
begin
  Current := N;
  SeenCount := 0;
  Result := False;
  
  while Current <> 1 do
  begin
    { Check if we've seen this number before (cycle detection) }
    Found := False;
    for i := 0 to SeenCount - 1 do
    begin
      if Seen[i] = Current then
      begin
        Found := True;
        Break;
      end;
    end;
    
    if Found then
      Exit; { Cycle detected, not happy }
    
    { Add current number to seen list }
    if SeenCount < 1000 then
    begin
      Seen[SeenCount] := Current;
      Inc(SeenCount);
    end
    else
      Exit; { Too many iterations, assume not happy }
    
    Current := SumOfSquares(Current);
  end;
  
  Result := True;
end;

{ TWorkerThread implementation }
constructor TWorkerThread.Create(AStart, AEnd: Integer);
begin
  inherited Create(False);
  FStart := AStart;
  FEnd := AEnd;
  FHappyCount := 0;
  FreeOnTerminate := False;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
begin
  for i := FStart to FEnd do
  begin
    if IsHappy(i) then
      Inc(FHappyCount);
  end;
end;

{ Main program }
begin
  { Check command line arguments }
  if ParamCount <> 1 then
  begin
    WriteLn(StdErr, 'Usage: ', ParamStr(0), ' BOUND');
    WriteLn(StdErr, '  BOUND: positive integer to check happy numbers from 1 to BOUND');
    Halt(1);
  end;
  
  { Parse BOUND argument }
  Val(ParamStr(1), Bound, ErrorCode);
  
  if ErrorCode <> 0 then
  begin
    WriteLn(StdErr, 'Error: BOUND must be a valid integer');
    Halt(1);
  end;
  
  if Bound < 1 then
  begin
    WriteLn(StdErr, 'Error: BOUND must be a positive integer (greater than 0)');
    Halt(1);
  end;
  
  { Determine number of threads (use CPU count) }
  NumThreads := GetCPUCount;
  if NumThreads < 1 then
    NumThreads := 4; { Default fallback }
  
  { Don't create more threads than numbers to process }
  if NumThreads > Bound then
    NumThreads := Bound;
  
  { Create and start worker threads }
  SetLength(Threads, NumThreads);
  NumbersPerThread := Bound div NumThreads;
  Remainder := Bound mod NumThreads;
  CurrentStart := 1;
  
  for i := 0 to NumThreads - 1 do
  begin
    { Calculate work distribution }
    if i < Remainder then
      Threads[i] := TWorkerThread.Create(CurrentStart, CurrentStart + NumbersPerThread)
    else
      Threads[i] := TWorkerThread.Create(CurrentStart, CurrentStart + NumbersPerThread - 1);
    
    CurrentStart := Threads[i].FEnd + 1;
  end;
  
  { Wait for all threads to complete and collect results }
  TotalHappyCount := 0;
  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].WaitFor;
    TotalHappyCount := TotalHappyCount + Threads[i].HappyCount;
    Threads[i].Free;
  end;
  
  { Calculate and print percentage }
  Percentage := (TotalHappyCount / Bound) * 100.0;
  WriteLn(Format('Happy numbers from 1 to %d: %d (%.2f%%)', 
                 [Bound, TotalHappyCount, Percentage]));
end.
