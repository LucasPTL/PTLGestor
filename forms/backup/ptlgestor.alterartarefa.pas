unit ptlgestor.alterartarefa;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, EditBtn, ptlgestor.dm, ZDataset;

type

  { TFormAlterarTarefa }

  TFormAlterarTarefa = class(TForm)
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
    FDataConclusao: TDateTime;
    FDescTarefa: String;
    FIdLista: String;
    FIdTarefa: String;
    FOk: Boolean;
    FTituloTarefa: String;

  public
    property IdTarefa:String read FIdTarefa write FIdTarefa;
    property TituloTarefa:String read FTituloTarefa write FTituloTarefa;
    property DescTarefa:String read FDescTarefa write FDescTarefa;
    property DataConclusao:TDateTime read FDataConclusao write FDataConclusao;
  end;

var
  FormAlterarTarefa: TFormAlterarTarefa;

implementation

{$R *.lfm}

{ TFormAlterarTarefa }

procedure TFormAlterarTarefa.btnConfirmarClick(Sender: TObject);
var
  LQuery: TZQuery;
begin
   if (textDescTarefa.Text <> '') and (textTituloTarefa.Text <> '') then
   begin
     try
       TituloTarefa := Trim(textTituloTarefa.Text);
       DescTarefa := Trim(textDescTarefa.Text);
       DataConclusao := dateConclusao.Date;
     finally

     end;
  end;
end;

procedure TFormAlterarTarefa.btnNullDataClick(Sender: TObject);
begin
  dateConclusao.Date:=NullDate;
end;


procedure TFormAlterarTarefa.FormShow(Sender: TObject);
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

