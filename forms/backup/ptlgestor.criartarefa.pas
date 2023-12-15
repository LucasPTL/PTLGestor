unit ptlgestor.criartarefa;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, EditBtn, ptlgestor.dm, ptlgestor.controllers.tarefas, ZDataset;

type

  { TFormCriarTarefa }

  TFormCriarTarefa = class(TForm)
    btnConfirmar: TSpeedButton;
    dateConclusao: TDateEdit;
    labelData: TLabel;
    labelTitulo: TLabel;
    btnNullData: TSpeedButton;
    textDescTarefa: TLabeledEdit;
    panelBottom: TPanel;
    panelConteudo: TPanel;
    panelFundo: TPanel;
    panelMid: TPanel;
    panelTop: TPanel;
    textTituloTarefa: TLabeledEdit;
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnNullDataClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIdLista: String;
    FIdTarefa: String;
    FOk: Boolean;
    FscrollMainTarefas: TWinControl;

  public
    property IdLista:String read FIdLista write FIdLista;
    property IdTarefa:String read FIdTarefa write FIdTarefa;
    property Ok:Boolean read FOk write FOk;
    property scrollMainTarefas: TWinControl read FscrollMainTarefas write FscrollMainTarefas;
  end;

var
  FormCriarTarefa: TFormCriarTarefa;

implementation

{$R *.lfm}

{ TFormCriarTarefa }

procedure TFormCriarTarefa.btnConfirmarClick(Sender: TObject);
var
  LQuery: TZQuery;
  LTarefa: TControllerTarefas;
begin
   if (textDescTarefa.Text <> '') and (textTituloTarefa.Text <> '') then
   begin
     try
       LTarefa := TControllerTarefas.Create;
       LTarefa.IdLista := FIdLista;
       Ok := LTarefa.Gravar('',Trim(textTituloTarefa.Text),Trim(textDescTarefa.Text),dateConclusao.Date) = '';
     finally
       LTarefa.Free;
       Self.Close;
     end;
  end;
end;

procedure TFormCriarTarefa.btnNullDataClick(Sender: TObject);
begin
  dateConclusao.Date:=NullDate;
end;


procedure TFormCriarTarefa.FormShow(Sender: TObject);
begin
  if FIdTarefa <> '' then
  begin
    with TZQuery.Create(Self) do
    begin
      Connection:=DM.Conexao;
      SQL.Add('select TITULO,DESCRICAO,DATA_CONCLUSAO from TAREFAS_ITENS where ID = :pidtarefa and DATA_EXCLUSAO is null');
      ParamByName('pidtarefa').AsString:=FIdTarefa;
      Open;
      if not EOF then
      begin
         textTituloTarefa.Text := FieldByName('titulo').AsString;
         textDescTarefa.Text := FieldByName('descricao').AsString;
         dateConclusao.Date := FieldByName('data_conclusao').AsDateTime;
      end;
      Free;
    end;
  end;
end;

end.

