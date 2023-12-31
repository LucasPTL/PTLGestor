unit ptlgestor.criarlista;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls, ptlgestor.dm, ptlgestor.controllers.listatarefas,
  ZDataset;

type

  { TFormCriarLista }

  TFormCriarLista = class(TForm)
    btnConfirmar: TSpeedButton;
    labelTitulo: TLabel;
    textDescLista: TLabeledEdit;
    panelBottom: TPanel;
    panelConteudo: TPanel;
    panelFundo: TPanel;
    panelMid: TPanel;
    panelTop: TPanel;
    procedure btnConfirmarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIdLista: String;
    FLabelLista: TLabel;
    FOk: Boolean;
    FPageControlMain: TPageControl;
    FscrollMain: TWinControl;
    FscrollMainTarefas: TWinControl;
    FTabListaTarefas: TTabSheet;
    FTabTarefas: TTabSheet;
    FTextCodigoLista: TEdit;

  public
    property IdLista:String read FIdLista write FIdLista;
    property Ok:Boolean read FOk write FOk;

    property pageControlMain: TPageControl read FPageControlMain write FPageControlMain;
    property tabListaTarefas: TTabSheet read FTabListaTarefas write FTabListaTarefas;
    property scrollMain: TWinControl read FscrollMain write FscrollMain;
    property tabTarefas: TTabSheet read FTabTarefas write FTabTarefas;
    property scrollMainTarefas: TWinControl read FscrollMainTarefas write FscrollMainTarefas;
    property TextCodigoLista: TEdit read FTextCodigoLista write FTextCodigoLista;
    property labelLista: TLabel read FLabelLista write FLabelLista;
  end;

var
  FormCriarLista: TFormCriarLista;

implementation

{$R *.lfm}

{ TFormCriarLista }

procedure TFormCriarLista.btnConfirmarClick(Sender: TObject);
var
  LLista: TControllerListaTarefas;
  Retorno: String;
begin
   if textDescLista.Text <> '' then
   begin
     Ok := False;
     try
       LLista := TControllerListaTarefas.Create;
       LLista.pageControlMain := pageControlMain;
       LLista.tabListaTarefas := tabListaTarefas;
       LLista.scrollMain := scrollMain;
       LLista.scrollMainTarefas := scrollMainTarefas;
       LLista.TextCodigoLista := TextCodigoLista;
       LLista.labelLista := labelLista;
       LLista.tabTarefas := tabTarefas;
       Retorno := LLista.Gravar(FIdLista,Trim(textDescLista.Text));
       if Retorno <> '' then ShowMessage(Retorno) else Ok := True;
     finally
       //LLista.Free; <------- Limpando referencia dos controles usado
       Self.Close;
     end;
  end;
end;


procedure TFormCriarLista.FormShow(Sender: TObject);
begin
  if FIdLista <> '' then
  begin
    with TZQuery.Create(Self) do
    begin
      Connection:=DM.Conexao;
      SQL.Add('select DESCRICAO from TAREFAS where ID = :pidlista and DATA_EXCLUSAO is null');
      ParamByName('pidlista').AsString:=FIdLista;
      Open;
      if not EOF then textDescLista.Text:=FieldByName('descricao').AsString;
      Free;
    end;
  end;
end;

end.

