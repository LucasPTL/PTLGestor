unit ptlgestor.criartarefa;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, EditBtn, ptlgestor.dm, ZDataset;

type

  { TFormCriarTarefa }

  TFormCriarTarefa = class(TForm)
    btnConfirmar: TSpeedButton;
    dateConclusao: TDateEdit;
    labelData: TLabel;
    labelTitulo: TLabel;
    textDescTarefa: TLabeledEdit;
    panelBottom: TPanel;
    panelConteudo: TPanel;
    panelFundo: TPanel;
    panelMid: TPanel;
    panelTop: TPanel;
    textTituloTarefa: TLabeledEdit;
    procedure btnConfirmarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIdLista: String;
    FIdTarefa: String;

  public
    property IdLista:String read FIdLista write FIdLista;
    property IdTarefa:String read FIdTarefa write FIdTarefa;
  end;

var
  FormCriarTarefa: TFormCriarTarefa;

implementation

{$R *.lfm}

{ TFormCriarTarefa }

procedure TFormCriarTarefa.btnConfirmarClick(Sender: TObject);
var
  LQuery: TZQuery;
begin
   if (textDescTarefa.Text <> '') and (textTituloTarefa.Text <> '') then
   begin
     try
       LQuery := TZQuery.Create(Self);
       LQuery.Connection := DM.Conexao;
       LQuery.SQL.Clear;
       DM.Conexao.StartTransaction;
       if FIdTarefa = '' then
       begin
          LQuery.SQL.Add('INSERT INTO TAREFAS_ITENS (ID, ID_LISTA, TITULO, DESCRICAO, DATA_CONCLUSAO, DATA_EXCLUSAO) VALUES(GEN_ID(GEN_IDTAREFA, 1), :pidlista :ptitulo, :pdesc, :pdataconclusao, NULL)');
          LQuery.ParamByName('pidlista').AsString := FIdLista;
       end
       else
       begin
          LQuery.SQL.Add('UPDATE TAREFAS_ITENS SET TITULO = :ptitulo, DESCRICAO = :pdesc, DATA_CONCLUSAO = :pdataconclusao where ID = :pidtarefa');
          LQuery.ParamByName('pidtarefa').AsString := FIdTarefa;
       end;
       LQuery.ParamByName('ptitulo').AsString := textTituloTarefa.Text;
       LQuery.ParamByName('pdesc').AsString := textDescTarefa.Text;
       LQuery.ParamByName('pdataconclusao').AsDate := dateConclusao.Date;
       LQuery.ExecSQL;
       LQuery.Free;
       DM.Conexao.Commit;
       Self.Close;
     except
       on E: Exception do
       begin
         ShowMessage('Erro ao criar tarefa: ' +  E.ClassName +  '/' +  E.Message);
         DM.Conexao.Rollback;
       end;
     end;
  end;
end;


procedure TFormCriarTarefa.FormShow(Sender: TObject);
begin
  if FIdLista <> '' then
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

