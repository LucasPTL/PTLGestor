unit ptlgestor.criarlista;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ptlgestor.dm, ZDataset;

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

  public
    property IdLista:String read FIdLista write FIdLista;
  end;

var
  FormCriarLista: TFormCriarLista;

implementation

{$R *.lfm}

{ TFormCriarLista }

procedure TFormCriarLista.btnConfirmarClick(Sender: TObject);
var
  LQuery: TZQuery;
begin
   if textDescLista.Text <> '' then
   begin
     try
       LQuery := TZQuery.Create(Self);
       LQuery.Connection := DM.Conexao;
       LQuery.SQL.Add('SELECT * FROM TAREFAS WHERE DESCRICAO = :pdesc and ID <> :pidlista');
       LQuery.ParamByName('pidlista').AsString:=FIdLista;
       LQuery.ParamByName('pdesc').AsString:=textDescLista.Text;
       LQuery.Open;
       if not LQuery.eof then
       begin
         ShowMessage('Nome de lista já em uso.');
         LQuery.Free;
       end
       else
       begin
         LQuery.SQL.Clear;
         DM.Conexao.StartTransaction;
         if FIdLista = '' then
            LQuery.SQL.Add('INSERT INTO TAREFAS (ID, DESCRICAO, DATA_EXCLUSAO) VALUES(GEN_ID(GEN_ID, 1), :pdesc, NULL)')
         else
         begin
            LQuery.SQL.Add('UPDATE TAREFAS SET DESCRICAO = :pdesc where ID = :pidlista');
            LQuery.ParamByName('pidlista').AsString:=FIdLista;
         end;
         LQuery.ParamByName('pdesc').AsString:=textDescLista.Text;
         LQuery.ExecSQL;
         LQuery.Free;
         DM.Conexao.Commit;
         Self.Close;
       end;
     except
       on E: Exception do
       begin
         ShowMessage('Erro ao criar lista: ' +  E.ClassName +  '/' +  E.Message);
         DM.Conexao.Rollback;
       end;
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

