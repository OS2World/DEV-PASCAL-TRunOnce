Program RO_Test;

Uses
  Forms, Graphics, RO_Win;

{$r RO_Test.SCU}

Begin
  Application.Create;
  Application.CreateForm (TROTestWin, ROTestWin);
  Application.Run;
  Application.Destroy;
End.
