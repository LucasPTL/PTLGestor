unit ptlgestor.controllers.listatarefas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Buttons, ZDataset, Graphics, Controls,
  ptlgestor.dm, ptlgestor.alterarlista,
  ptlgestor.controllers.tarefas, ptlgestor.model.listatarefas,
  ptlgestor.janelacustom, Forms, Dialogs, ComCtrls, StdCtrls, ShellApi;
type
  { TControllerListaTarefas }
  TControllerListaTarefas = class
    private
      FLabelLista: TLabel;
      FPageControlMain: TPageControl;
      FscrollMain: TWinControl;
      FscrollMainTarefas: TWinControl;
      FTabListaTarefas: TTabSheet;
      FTabTarefas: TTabSheet;
      FTextCodigoLista: TEdit;
    public
      procedure AlterarListaTarefas(Sender: TObject);
      procedure AtualizarListasTarefas;
      procedure CarregaTarefas(Sender: TObject);
      procedure ExcluirLista(Sender: TObject);
      procedure LimparListasTarefas;
      function Gravar(IdLista:String;DescLista:String):String;
      procedure GeraRelatorio(Sender: TObject);

      property TextCodigoLista: TEdit read FTextCodigoLista write FTextCodigoLista;
      property labelLista: TLabel read FLabelLista write FLabelLista;
      property pageControlMain: TPageControl read FPageControlMain write FPageControlMain;
      property tabListaTarefas: TTabSheet read FTabListaTarefas write FTabListaTarefas;
      property tabTarefas: TTabSheet read FTabTarefas write FTabTarefas;
      property scrollMain: TWinControl read FscrollMain write FscrollMain;
      property scrollMainTarefas: TWinControl read FscrollMainTarefas write FscrollMainTarefas;


  end;

implementation

{ TControllerListaTarefas }

procedure TControllerListaTarefas.AtualizarListasTarefas;
var
  LQuery: TZQuery;
  LPanelLista,LPanelBotoes: TPanel;
begin
  LimparListasTarefas;
  FPageControlMain.ActivePage := FTabListaTarefas;
  LQuery := TZQuery.Create(Nil);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS where data_exclusao is null ORDER BY ID');
  LQuery.Open;
  while not LQuery.EOF do
  begin
    LPanelLista := TPanel.Create(Nil);
    LPanelLista.Name := 'lista'+LQuery.FieldByName('id').AsString;
    LPanelLista.Hint := LQuery.FieldByName('id').AsString;
    LPanelLista.Parent := FscrollMain;
    LPanelLista.Align := alTop;
    LPanelLista.BorderSpacing.Top := 10;
    LPanelLista.Height := 100;
    LPanelLista.BevelOuter := bvNone;
    LPanelLista.Top:=9999;
    LPanelBotoes := TPanel.Create(Nil);
    LPanelBotoes.BevelOuter := bvNone;
    LPanelBotoes.Parent := LPanelLista;
    LPanelBotoes.Align := alRight;
    LPanelBotoes.Width := 150;
    LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;

    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'pen';
      OnClick:=@AlterarListaTarefas;
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := 21;
      end;
      Height:=Round(LPanelBotoes.Height/3);
    end;
    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'print';
      OnClick := @GeraRelatorio;
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := 21;
        Color := clBlue;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;
    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'trash';
      OnClick := @ExcluirLista;
      Flat:=True;
      Transparent:=False;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := 21;
        Color := clRed;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;

    with TSpeedButton.Create(Nil) do
    begin
      Parent := LPanelLista;
      Align := alClient;
      OnClick := @CarregaTarefas;
      Caption := LQuery.FieldByName('descricao').AsString;
      with Font do
      begin
        Name := 'Inter';
        Size := 21;
      end;
    end;
    LQuery.Next;
  end;
  LQuery.Free;
end;

procedure TControllerListaTarefas.CarregaTarefas(Sender: TObject);
var
  LTarefa: TControllerTarefas;
  LIdLista:String;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  try
    LTarefa := TControllerTarefas.Create;
    LTarefa.IdLista := LIdLista;
    LTarefa.scrollMainTarefas := FscrollMainTarefas;
    FTextCodigoLista.Text := LIdLista;
    LTarefa.CarregaTarefas;
    with TZQuery.Create(Nil) do
      begin
        Connection := DM.Conexao;
        SQL.Add('SELECT DESCRICAO FROM TAREFAS WHERE ID = :pidlista');
        ParamByName('pidlista').AsString:= LIdLista;
        Open;
        FLabelLista.Caption := FieldByName('descricao').AsString;
        Free;
      end;
  finally
    FpageControlMain.ActivePage := FTabTarefas;
  end;
end;
procedure TControllerListaTarefas.ExcluirLista(Sender: TObject);
var
 LListaTarefa: TModelListaTarefas;
 Form: TJanelaCustom;
 Confirma: Boolean;
 LIdLista,LRetorno : String;
begin
 LIdLista := TControl(Sender).Parent.Hint;
 try
   Form:= TJanelaCustom.Create(Nil);
   Form.BorderStyle := bsNone;
   Form.Position := poMainFormCenter;
   Form.labelTitulo.Caption := 'Deseja realmente excluir a lista?';
   with TZQuery.Create(Nil) do
   begin
     Connection := DM.Conexao;
     SQL.Add('SELECT DESCRICAO FROM TAREFAS WHERE ID = :pidlista');
     ParamByName('pidlista').AsString:= LIdLista;
     Open;
     Form.labelTexto.Caption:='A Lista '+ FieldByName('descricao').AsString + ' será excluida.';
     Free;
   end;
   Form.AddBotao('Cancelar',False);
   Form.AddBotao('Excluir',True);
   Form.ShowModal;
 finally
   Form.Free;
   Confirma := Form.Retorno;
 end;
 if Confirma then
 begin
   try
     try
       LListaTarefa := TModelListaTarefas.Create;
       LListaTarefa.IdLista := LIdLista;
       LListaTarefa.Excluir;
       LRetorno := LListaTarefa.Retorno;
     except
         on E: Exception do
         LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
     end;
   finally

   end;
   if LRetorno = '' then
      AtualizarListasTarefas
   else
      ShowMessage(LRetorno);
 end;
end;

procedure TControllerListaTarefas.AlterarListaTarefas(Sender: TObject);
var
  LIdLista, Desc, LRetorno:String;
  Form: TFormAlterarLista;
  LListaTarefa: TModelListaTarefas;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  try
    Form := TFormAlterarLista.Create(Nil);
    Form.IdLista:=LIdLista;
    Form.ShowModal;
  finally
    Desc := Form.DescLista;
    Form.Free;
    if Desc <> '' then
    begin
      try
        try
          LListaTarefa := TModelListaTarefas.Create;
          LListaTarefa.IdLista := LIdLista;
          LListaTarefa.DescLista := Desc;
          LListaTarefa.Gravar;
          LRetorno := LListaTarefa.Retorno;
        except
           on E: Exception do
           LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
        end;
      finally
        if LRetorno = '' then
           AtualizarListasTarefas
        else
           ShowMessage(LRetorno);
        LListaTarefa.Free;
      end;
    end;
  end;
end;

procedure TControllerListaTarefas.LimparListasTarefas;
var
 i: Integer;
begin
 for i := scrollMain.ControlCount -1 downto 0 do
  if FscrollMain.Controls[i].ClassName = 'TPanel' then FscrollMain.Controls[i].Free;
end;

function TControllerListaTarefas.Gravar(IdLista: String; DescLista: String): String;
var
  LListaTarefas: TModelListaTarefas;
  LRetorno: String;
begin
  LListaTarefas := TModelListaTarefas.Create;
  try
    try
      LListaTarefas.IdLista := IdLista;
      LListaTarefas.DescLista := DescLista;
      LListaTarefas.Gravar;
      LRetorno := LListaTarefas.Retorno;
    except
      on E: Exception do
      LRetorno := LRetorno + ' | ' +  E.ClassName +  '/' +  E.Message;
    end;
  finally
    LListaTarefas.Free;
    Result := LRetorno;
    AtualizarListasTarefas;
  end;
end;

procedure TControllerListaTarefas.GeraRelatorio(Sender: TObject);
var
  HTML, LIdLista, NomeArq: string;
  HTMLFile: TextFile;
  Concluido: Boolean;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  HTML := '<html><head><style>';
  HTML := HTML + 'body {display: flex; justify-content: flex-start; align-items: center; height: 100vh; margin: 0; overflow: auto;}';
  HTML := HTML + 'table {border-collapse: collapse; width: 100%;}';
  HTML := HTML + 'th, td {border: 1px solid #ddd; padding: 8px;}';
  HTML := HTML + '</style></head><body>';
  HTML := HTML + '<table>';
  HTML := HTML + '<tr><th>Titulo</th><th>Descricao</th><th>Concluido</th></tr>';
  with TZQuery.Create(Nil) do
  begin
    Connection := DM.Conexao;
    SQL.Add('SELECT * FROM TAREFAS_ITENS WHERE ID_LISTA = :pidlista AND DATA_EXCLUSAO IS NULL');
    ParamByName('pidlista').AsString := LIdLista;
    Open;
    while not EOF do
    begin
      Concluido := not ((FieldByName('data_conclusao').AsString = '') or (FieldByName('data_conclusao').AsString = '30/12/1899'));
      HTML := HTML + '<tr><td>' + FieldByName('titulo').AsString + '</td><td>' + FieldByName('descricao').AsString + '</td>';
      if Concluido then
        HTML := HTML + '<td style="width: 10px">✅</td></tr>'
      else
        HTML := HTML + '<td style="width: 10px">❌</td></tr>';
      Next;
    end;
    Free;
  end;
  HTML := HTML + '</table>';
  HTML := HTML + '</body></html>';

  AssignFile(HTMLFile, 'report.html');
  Rewrite(HTMLFile);
  Write(HTMLFile, HTML);
  CloseFile(HTMLFile);
  ShellExecute(0, nil, 'lista.html', nil, nil, 1);

end;


end.

