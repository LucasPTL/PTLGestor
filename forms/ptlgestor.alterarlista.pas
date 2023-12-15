unit ptlgestor.alterarlista;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ptlgestor.dm, ZDataset;

type

  { TFormAlterarLista }

  TFormAlterarLista = class(TForm)
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
    FDescLista: String;
    FIdLista: String;


  public
    property IdLista:String read FIdLista write FIdLista;
    property DescLista:String read FDescLista write FDescLista;
  end;

var
  FormAlterarLista: TFormAlterarLista;

implementation

{$R *.lfm}

{ TFormAlterarLista }

procedure TFormAlterarLista.btnConfirmarClick(Sender: TObject);
begin
   if textDescLista.Text <> '' then
   begin
     try
       DescLista := Trim(textDescLista.Text);
     finally
       Self.Close;
     end;
  end;
end;


procedure TFormAlterarLista.FormShow(Sender: TObject);
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

