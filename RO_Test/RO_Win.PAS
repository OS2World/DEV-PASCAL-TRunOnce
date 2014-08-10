Unit RO_Win;

Interface

Uses
  Classes, Forms, Graphics, Buttons, RunOnce;

Type
  TROTestWin = Class (TForm)
    BitBtn1: TBitBtn;
    RunOnce1: TRunOnce;
    Procedure ROTestWinOnShow (Sender: TObject);
  Private
    {Insert private declarations here}
  Public
    {Insert public declarations here}
  End;

Var
  ROTestWin: TROTestWin;

Implementation

Procedure TROTestWin.ROTestWinOnShow (Sender: TObject);
Begin
 IF RunOnce1.FirstInst
  THEN Caption := Caption + ' - Original';
 RunOnce1.CheckOnly;
End;

Initialization
  RegisterClasses ([TROTestWin, TBitBtn, TRunOnce]);
End.
