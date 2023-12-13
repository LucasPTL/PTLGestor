unit PTLGestor.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls, ptlgestor.janelacustom, ptlgestor.configConexao,
  ptlgestor.criarlista, ptlgestor.criartarefa, ptlgestor.dm, ZDataset;

type

  { TFormMain }

  TFormMain = class(TForm)
    btnAddLista: TSpeedButton;
    btnAddTarefa: TSpeedButton;
    textCodigoTarefa: TEdit;
    labelNomeTarefa: TLabel;
    labelAvisoConexao: TLabel;
    pageControlMain: TPageControl;
    panelConteudoTopTarefas: TPanel;
    panelListaTarefasMain: TPanel;
    panelConteudo: TPanel;
    panelBotoesBarra: TPanel;
    panelConteudoTopListaTarefas: TPanel;
    panelTarefasMain: TPanel;
    panelTop: TPanel;
    btnMinimizar: TSpeedButton;
    btnMaximizar: TSpeedButton;
    btnFechar: TSpeedButton;
    panelBottom: TPanel;
    btnConfigBanco: TSpeedButton;
    scrollMain: TScrollBox;
    scrollMainTarefas: TScrollBox;
    btnVoltar: TSpeedButton;
    tabTarefas: TTabSheet;
    tabListaTarefas: TTabSheet;
    timerVerificaConexao: TTimer;
    procedure btnAddTarefaClick(Sender: TObject);
    procedure btnConfigBancoClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnMaximizarClick(Sender: TObject);
    procedure btnMinimizarClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure panelTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure panelTopMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure panelTopMouseUp;
    procedure btnAddListaClick;
    procedure btnVoltarClick(Sender: TObject);
    procedure timerVerificaConexaoTimer;
    procedure AtualizarListas;
  private
    FMouseDown: Boolean;
    FMousePos: TPoint;
    procedure LimparListas;
    procedure ExcluirLista(Sender: TObject);
    procedure AlterarLista(Sender: TObject);
    procedure CarregaListaTarefas(Sender: TObject);
    procedure LimparTarefas;
  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.panelTopMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FMouseDown := True;
    FMousePos := Point(X, Y);
  end;
end;

procedure TFormMain.btnFecharClick(Sender: TObject);
var
  Form: TJanelaCustom;
  Fechar: Boolean;
begin
  try
    Form:= TJanelaCustom.Create(Self);
    Form.BorderStyle:=bsNone;
    Form.Position:=poMainFormCenter;
    Form.labelTitulo.Caption:='Deseja realmente fechar o sistema?';
    Form.labelTexto.Caption:='';
    Form.AddBotao('Cancelar',False);
    Form.AddBotao('Fechar',True);
    Form.ShowModal;
  finally
    Form.Free;
    Fechar:=Form.Retorno;
    if Fechar then Application.Terminate;
  end;

end;

procedure TFormMain.btnConfigBancoClick(Sender: TObject);
var
  Form: TFormConfigConexao;
begin
  try
    Form := TFormConfigConexao.Create(Self);
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFormMain.btnAddTarefaClick(Sender: TObject);
var
  Form: TFormCriarTarefa;
begin
 if btnConfigBanco.Color <> clRed then
 begin
   try
     Form := TFormCriarTarefa.Create(Self);
     Form.IdLista := textCodigoTarefa.Text;
     Form.ShowModal;
   finally
     Form.Free;
     CarregaListaTarefas(Self);
   end;
 end;
end;

procedure TFormMain.btnMaximizarClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
     WindowState := wsNormal
  else
     WindowState := wsMaximized;
end;

procedure TFormMain.btnMinimizarClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFormMain.FormPaint(Sender: TObject);
begin

end;

procedure TFormMain.FormResize(Sender: TObject);
begin
 scrollMain.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMain.BorderSpacing.Right:=Round(Self.Width*0.20);

 scrollMainTarefas.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMainTarefas.BorderSpacing.Right:=Round(Self.Width*0.20);
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
 AtualizarListas;
 scrollMain.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMain.BorderSpacing.Right:=Round(Self.Width*0.20);

 scrollMainTarefas.BorderSpacing.Left:=Round(Self.Width*0.20);
 scrollMainTarefas.BorderSpacing.Right:=Round(Self.Width*0.20);
end;

procedure TFormMain.panelTopMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 NewPos: TPoint;
begin
 if FMouseDown then
 begin
   NewPos := Point(X + Self.Left, Y + Self.Top);

   Self.Left := NewPos.X;
   Self.Top := NewPos.Y;
 end;
end;

procedure TFormMain.panelTopMouseUp;
begin
 FMouseDown := False;
end;

procedure TFormMain.btnAddListaClick;
var
  Form: TFormCriarLista;
begin
 if btnConfigBanco.Color <> clRed then
 begin
   try
     Form := TFormCriarLista.Create(Self);
     Form.labelTitulo.Caption:='Criação de lista';
     Form.ShowModal;
   finally
     Form.Free;
     AtualizarListas;
   end;
 end;
end;

procedure TFormMain.btnVoltarClick(Sender: TObject);
begin
  pageControlMain.ActivePage := tabListaTarefas;
end;

procedure TFormMain.timerVerificaConexaoTimer;
begin
 with timerVerificaConexao do
 begin
   Enabled:=False;
   if DM.Conexao.Ping then
   begin
     btnConfigBanco.Color:=clGreen;
     labelAvisoConexao.Caption:='';
   end
   else
   begin
     btnConfigBanco.Color:=clRed;
     labelAvisoConexao.Caption:='Verificar conexão.';
   end;
   Enabled:=True;
 end;
end;

procedure TFormMain.AtualizarListas;
var
  LQuery: TZQuery;
  LPanelLista,LPanelBotoes: TPanel;
begin
  LimparListas;
  pageControlMain.ActivePage := tabListaTarefas;
  LQuery := TZQuery.Create(Self);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS where data_exclusao is null');
  LQuery.Open;
  while not LQuery.EOF do
  begin
    LPanelLista := TPanel.Create(Self);
    LPanelLista.Name := 'lista'+LQuery.FieldByName('id').AsString;
    LPanelLista.Hint := LQuery.FieldByName('id').AsString;
    LPanelLista.Parent := scrollMain;
    LPanelLista.Align := alTop;
    LPanelLista.Height := 100;
    LPanelLista.BevelOuter := bvNone;
    LPanelLista.Top:=9999;
    LPanelBotoes := TPanel.Create(Self);
    LPanelBotoes.BevelOuter := bvNone;
    LPanelBotoes.Parent := LPanelLista;
    LPanelBotoes.Align := alRight;
    LPanelBotoes.Width := Round(panelBotoesBarra.Width);
    LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;

    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'pen';
      OnClick:=@AlterarLista;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
      end;
      Height:=Round(LPanelBotoes.Height/3);
    end;
    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'print';
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        Color := clBlue;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;
    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'trash';
      OnClick := @ExcluirLista;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        Color := clRed;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;

    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelLista;
      Align := alClient;
      OnCLick := @CarregaListaTarefas;
      Caption := LQuery.FieldByName('descricao').AsString;
      with Font do
      begin
        Name := 'Inter';
        Size := Round(LPanelLista.Height/6);
      end;
    end;
    LQuery.Next;
  end;
  LQuery.Free;

end;

procedure TFormMain.LimparListas;
var
 i: Integer;
begin
 for i := scrollMain.ControlCount -1 downto 0 do
   scrollMain.Controls[i].Free;
end;

procedure TFormMain.ExcluirLista(Sender: TObject);
var
 Form: TJanelaCustom;
 Fechar: Boolean;
 LIdLista: String;
 LQuery: TZQuery;
begin
 LIdLista := TControl(Sender).Parent.Hint;
 try
   Form:= TJanelaCustom.Create(Self);
   Form.BorderStyle := bsNone;
   Form.Position := poMainFormCenter;
   Form.labelTitulo.Caption := 'Deseja realmente excluir a lista?';
   with TZQuery.Create(Self) do
   begin
     Connection := DM.Conexao;
     SQL.Add('SELECT DESCRICAO FROM TAREFAS WHERE ID = :pidlista');
     ParamByName('pidlista').AsString:=LIdLista;
     Open;
     Form.labelTexto.Caption:='A Lista '+ FieldByName('descricao').AsString + ' será excluida.';
     Free;
   end;
   Form.AddBotao('Cancelar',False);
   Form.AddBotao('Excluir',True);
   Form.ShowModal;
 finally
   Form.Free;
   Fechar:=Form.Retorno;
 end;
 if Fechar then
 begin
   LQuery := TZQuery.Create(Self);
   LQuery.Connection := DM.Conexao;
   LQuery.SQL.Add('select * from TAREFAS_ITENS where ID_LISTA = :pidlista and DATA_EXCLUSAO is null');
   LQuery.ParamByName('pidlista').AsString:=LIdLista;
   if not LQuery.EOF then
   begin
     ShowMessage('Lista contém itens, impossível exclusão.');
     LQuery.Free;
   end
   else
   begin
     LQuery.SQL.Clear;
     try
       try
         DM.Conexao.StartTransaction;
         LQuery.SQL.Add('update TAREFAS set DATA_EXCLUSAO = CURRENT_TIMESTAMP WHERE ID = :pidlista');
         LQuery.ParamByName('pidlista').AsString:=LIdLista;
         LQuery.ExecSQL;
         DM.Conexao.Commit;
       except
         on E: Exception do
         begin
           ShowMessage('Erro ao excluir lista: ' +  E.ClassName +  '/' +  E.Message);
           DM.Conexao.Rollback;
         end;
       end;
     finally
       LQuery.Free;
     end;
   end;
   AtualizarListas;
 end;
end;

procedure TFormMain.AlterarLista(Sender: TObject);
var
  LIdLista:String;
  Form: TFormCriarLista;
begin
  LIdLista := TControl(Sender).Parent.Hint;
  try
    Form := TFormCriarLista.Create(Self);
    Form.labelTitulo.Caption:='Alteração de lista: ' + LIdLista;
    Form.IdLista:=LIdLista;
    Form.ShowModal;
  finally
    Form.Free;
    AtualizarListas;
  end;
end;

procedure TFormMain.CarregaListaTarefas(Sender: TObject);
var
  LQuery: TZQuery;
  LPanelTarefa,LPanelBotoes: TPanel;
  LIdLista:String;
begin
  if Assigned(TControl(Sender).Parent) then LIdLista := TControl(Sender).Parent.Hint;
  if LIdLista = '' then LIdLista := textCodigoTarefa.Text;
  LimparTarefas;
  textCodigoTarefa.Text := LIdLista;
  pageControlMain.ActivePage := tabTarefas;
  labelNomeTarefa.Caption := TControl(Sender).Caption;
  LQuery := TZQuery.Create(Self);
  LQuery.Connection := DM.Conexao;
  LQuery.SQL.Add('select * from TAREFAS_ITENS where DATA_EXCLUSAO is null and ID_LISTA = :pidlista');
  LQuery.ParamByName('pidlista').AsString:=LIdLista;
  LQuery.Open;
  while not LQuery.EOF do
  begin

    LPanelTarefa := TPanel.Create(Self);
    LPanelTarefa.Name := 'tarefa' + LQuery.FieldByName('id').AsString;
    LPanelTarefa.Hint := LQuery.FieldByName('id').AsString;
    LPanelTarefa.Parent := scrollMainTarefas;
    LPanelTarefa.Align := alTop;
    LPanelTarefa.Caption := LQuery.FieldByName('titulo').AsString + ': ' + LQuery.FieldByName('descricao').AsString;
    LPanelTarefa.Color := clWhite;
    LPanelTarefa.Font.Name := 'Inter';
    LPanelTarefa.Font.Size := Round(LPanelTarefa.Width*0.028);
    LPanelTarefa.Height := 100;
    LPanelTarefa.BevelOuter := bvNone;
    LPanelTarefa.Top:=9999;
    LPanelBotoes := TPanel.Create(Self);
    LPanelBotoes.BevelOuter := bvNone;
    LPanelBotoes.Parent := LPanelTarefa;
    LPanelBotoes.Align := alRight;
    LPanelBotoes.Width := Round(panelBotoesBarra.Width);
    LPanelBotoes.Hint := LQuery.FieldByName('id').AsString;

    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'pen';
      OnClick:=@AlterarLista;
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
      end;
      Height:=Round(LPanelBotoes.Height/3);
    end;

    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      if LQuery.FieldByName('data_conclusao').AsString = '' then Caption := 'check' else Caption := 'xmark';
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        if LQuery.FieldByName('data_conclusao').AsString = '' then Color := clGreen else Color := clRed;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;

    with TSpeedButton.Create(Self) do
    begin
      Parent := LPanelBotoes;
      Align := alTop;
      Caption := 'trash';
      with Font do
      begin
        Name := 'Font Awesome 6 Free Solid';
        Size := Round(LPanelBotoes.Width/7);
        Color := clRed;
      end;
      Height:=Round(LPanelBotoes.Height/3);
      Top := 9999;
    end;
    LQuery.Next;
  end;
  LQuery.Free;

end;

procedure TFormMain.LimparTarefas;
var
 i: Integer;
begin
 for i := scrollMainTarefas.ControlCount -1 downto 0 do
   scrollMainTarefas.Controls[i].Free;
end;

end.

