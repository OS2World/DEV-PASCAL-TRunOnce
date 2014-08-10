UNIT RunOnce;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 1998/02/20 *)
(* ENVIRONMENT: Sibyl                                                   *)
(*                                                                      *)
(* RunOnce defines a non-visual component that will allow the program   *)
(* it is dropped on to check that it is only ran once.  If the program  *)
(* wants, it can determine if a previous instance is running and give   *)
(* focus to the previous instance of the program.                       *)
(*                                                                      *)
(* Note: A good clean method could not be found to automatically check  *)
(*  previous instances and halt subsequent instances, so the program    *)
(*  needs to call the checkonly procedure to halt subsequent instances  *)
(*  if that behavior is needed.  If not, a program can use the firstinst*)
(*  property to determine if another instance is already running.       *)
(*                                                                      *)
(* This component is based on a similar one that was written for Delphi *)
(* by S.L.Keyser and on hints from comp.os.os2.programmer.misc.         *)
(*                                                                      *)
(* -------------------------------------------------------------------- *)
(*                                                                      *)
(* REVISED: 1998/02/21 - Initial version completed.  (1.00)             *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms;

 CONST ro_MaxMsgLen = 80;

 {Declare TRunOnce class}
 TYPE TRunOnce = CLASS(TComponent)
                  PRIVATE
                   pWnd : POINTER;
                   FFirstInst : BOOLEAN;
                   FUseNotifyMsg : BOOLEAN;
                   FNotifyMsg : STRING[ro_MaxMsgLen];
                  PROTECTED
                   PROCEDURE SetupComponent; OVERRIDE;
                   FUNCTION  GetNotifyMsg : STRING;
                   PROCEDURE SetNotifyMsg(S : STRING);
                   FUNCTION  GetVersion : STRING;
                  PUBLIC
                   DESTRUCTOR Destroy; OVERRIDE;
                   PROCEDURE CheckOnly;
                   PROPERTY FirstInst : BOOLEAN Read FFirstInst;
                  PUBLISHED
                   PROPERTY UseNotifyMsg : BOOLEAN Read FUseNotifyMsg
                                                   Write FUseNotifyMsg;
                   PROPERTY NotifyMsg : STRING Read GetNotifyMsg
                                               Write SetNotifyMsg;
                   PROPERTY Version : STRING Read GetVersion
                                             Stored FALSE;
                  END;

(************************************************************************)

{make trunonce available to sibyl, to change palette location}
{ change 'custom' to whatever tab you wish.                  }
 EXPORTS TRunOnce,'Custom','RunOnce.BMP';

(************************************************************************)

IMPLEMENTATION

 USES OS2Def, BseDos, PMWin, Dialogs;

 CONST IVersion : STRING[20] = 'Version 1.00';

(************************************************************************)

 PROCEDURE TRunOnce.SetupComponent;
    VAR TT  : STRING[250];
        FNm : STRING[101];
        I   : INTEGER;
        Ret : APIRET;
        pNm : CSTRING[100];
  BEGIN
   Inherited SetupComponent;
   FFirstInst := TRUE; {assume not running}
   FUseNotifyMsg := FALSE; {default is no message}
   FNotifyMsg := 'Application already running!';
   TT := Application.ExeName; I := Length(TT);
   WHILE (I > 0) AND (TT[I] <> '\') DO
    BEGIN {find beginning of exe name}
     Dec(I);
     IF TT[I] = '.' THEN TT[I] := 'x'; {replace '.' with 'x'}
    END; {while}
   FNm := '\SHAREMEM\' + Copy(TT,I+1,90);
   Ret := DosGetNamedSharedMem(pWnd,FNm,pag_Read OR pag_Write);
   IF Ret = 0
    THEN FFirstInst := FALSE {program already running}
   ELSE BEGIN {program not running currently}
         pNm := FNm; {allocate space for mainform handle later}
         DosAllocSharedMem(pWnd,pNm,SizeOf(HWND),
                           pag_Read OR pag_Write OR pag_Commit);
        END; {else}
  END;

(************************************************************************)

 FUNCTION TRunOnce.GetNotifyMsg : STRING;
     (* function returns value of notifymsg property *)

  BEGIN (*trunonce.getnotifymsg*)
   Result := FNotifyMsg;
  END; (*trunonce.getnotifymsg*)

(************************************************************************)

 PROCEDURE TRunOnce.SetNotifyMsg(S : STRING);
     (* procedure used to set the notifymsg property *)

  BEGIN (*trunonce.setnotifymsg*)
   FNotifyMsg := Copy(S,1,ro_MaxMsgLen);
  END; (*trunonce.setnotifymsg*)

(************************************************************************)

 FUNCTION TRunOnce.GetVersion : STRING;
     (* function to return version information to property *)

  BEGIN (*trunonce.getversion*)
   Result := IVersion;
  END; (*trunonce.getversion*)

(************************************************************************)

 PROCEDURE TRunOnce.CheckOnly;
     (* procedure used by program to check if only copy and quit if not *)
     (* - if used, should be called from main forms onshow method       *)

  BEGIN (*trunonce.checkonly*)
   IF FFirstInst
    THEN BEGIN {calling from first instance}
          {save mainform handle in memory}
          HWND(pWnd^) := Application.MainForm.Handle;
          Exit;
         END; {then}
   IF FUseNotifyMsg THEN ShowMessage(FNotifyMsg);
   WinSetActiveWindow(hwnd_Desktop,HWND(pWnd^)); {focus prev window}
   Application.Terminate;
  END; (*trunonce.checkonly*)

(************************************************************************)

 DESTRUCTOR TRunOnce.Destroy;
  BEGIN
   DosFreeMem(pWnd); {release memory object}
   Inherited Destroy;
  END;

(************************************************************************)

INITIALIZATION
 RegisterClasses([TRunOnce]);
END. (*of unit*)
