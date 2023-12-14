program PTLGestor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, zcomponent, PTLGestor.main, ptlgestor.dm, ptlgestor.alterarlista,
  ptlgestor.criartarefa, ptlgestor.criarlista,
  ptlgestor.controllers.listatarefas, ptlgestor.controllers.tarefas,
  ptlgestor.model.tarefas;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

