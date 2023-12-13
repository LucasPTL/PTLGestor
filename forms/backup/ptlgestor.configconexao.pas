unit ptlgestor.configConexao;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, MaskEdit,
  StdCtrls, Buttons, LCLType, ZConnection, ZDataset, LCL, ptlgestor.dm,
  SynHighlighterPas, IniFiles;

type

  { TFormConfigConexao }

  TFormConfigConexao = class(TForm)
    testwifi: TSpeedButton;
    btnConfirmar: TButton;
    btnTestar: TButton;
    labelErro: TLabel;
    panelBottom: TPanel;
    textMostraSenha: TSpeedButton;
    textBanco: TLabeledEdit;
    textAbreDiretorio: TSpeedButton;
    textPorta: TLabeledEdit;
    panelConteudo: TPanel;
    panelFundo: TPanel;
    textUser: TLabeledEdit;
    textSenha: TLabeledEdit;
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnTestarClick(Sender: TObject);
    procedure labelErroClick(Sender: TObject);
    procedure textAbreDiretorioClick(Sender: TObject);
    procedure textMostraSenhaMouseEnter(Sender: TObject);
    procedure textMostraSenhaMouseLeave(Sender: TObject);
    procedure textPortaKeyPress(Sender: TObject; var Key: char);
  private
    procedure VerificarErros;

  public

  end;

var
  FormConfigConexao: TFormConfigConexao;

implementation

{$R *.lfm}

{ TFormConfigConexao }

procedure TFormConfigConexao.textMostraSenhaMouseEnter(Sender: TObject);
begin
  textMostraSenha.Font.Color:=clBlue;
  textSenha.PasswordChar:=Chr(0);
end;

procedure TFormConfigConexao.textAbreDiretorioClick(Sender: TObject);
begin
  with TOpenDialog.Create(Self) do
  begin
    try
      InitialDir:=ExtractFilePath(ParamStr(0));
      if Execute then
      begin
       textBanco.Text:=FileName;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TFormConfigConexao.btnConfirmarClick(Sender: TObject);
var
   IniConfig: TIniFile;
begin
  labelErro.Caption:='';
  if testwifi.Color <> clGreen then
  begin
   labelErro.Caption:='Teste a conexão primeiro.';
  end
  else
  begin
    if labelErro.Caption = '' then
    begin
      try
        with DM.Conexao do
        begin
          Database:=textBanco.Text;
          LibraryLocation:=ExtractFilePath(ParamStr(0))+'fbclient.dll';
          User:=textUser.Text;
          Password:=textSenha.Text;
          Port:=StrToInt(textPorta.Text);
          Protocol:='firebird-2.5';
          Connected:=True;
        end;
        try
          IniConfig := TIniFile.Create(ExtractFilePath(ParamStr(0))+'configuracoes.ini');
          IniConfig.WriteString('Banco de dados', 'Database', DM.Conexao.Database);
          IniConfig.WriteString('Banco de dados', 'LibraryLocation', DM.Conexao.LibraryLocation);
          IniConfig.WriteString('Banco de dados', 'User', DM.criptografar(key,DM.Conexao.User));
          IniConfig.WriteString('Banco de dados', 'Password', DM.criptografar(key,DM.Conexao.Password));
          IniConfig.WriteString('Banco de dados', 'Port', IntToStr(DM.Conexao.Port));
          Self.Close;
        except
          on E: Exception do
           labelErro.Caption:='Erro ao salvar banco de dados: ' +  E.ClassName +  '/' +  E.Message;
        end;
      finally
        IniConfig.Free;
        DM.ConfigurarBanco;
      end;
    end;
  end;
end;

procedure TFormConfigConexao.btnTestarClick(Sender: TObject);
begin
  labelErro.Caption:='';
  VerificarErros;
  if labelErro.Caption = '' then
  begin
   try
     with DM.Conexao do
     begin
       Database:=textBanco.Text;
       LibraryLocation:=ExtractFilePath(ParamStr(0))+'fbclient.dll';
       User:=textUser.Text;
       Password:=textSenha.Text;
       Port:=StrToInt(textPorta.Text);
       Protocol:='firebird-2.5';
       Connected:=True;
     end;
     with TZQuery.Create(Self) do
     begin
       Connection:=DM.Conexao;
       SQL.Add('SELECT 1 FROM RDB$DATABASE');
       Open;
       if not eof then
          testwifi.Color:=clGreen
       else
           testwifi.Color:=clRed;
       Free;
     end;
   except
     on E: Exception do
      labelErro.Caption:='Erro ao conectar no banco de dados: ' +  E.ClassName +  '/' +  E.Message;
   end;
  end;

end;

procedure TFormConfigConexao.labelErroClick(Sender: TObject);
begin

end;

procedure TFormConfigConexao.textMostraSenhaMouseLeave(Sender: TObject);
begin
   textMostraSenha.Font.Color:=clBlack;
   textSenha.PasswordChar:='*';
end;

procedure TFormConfigConexao.textPortaKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', Char(VK_BACK), Char(VK_DELETE)]) then Key := #0;
end;

procedure TFormConfigConexao.VerificarErros;
begin
  if not FileExists(textBanco.Text) then
         labelErro.Caption:='Caminho do banco de dados incorreto. ';

  if Trim(textSenha.Text) = '' then
     labelErro.Caption:=labelErro.Caption + 'Senha inválida. ';

  if Trim(textPorta.Text) = '' then
     labelErro.Caption:=labelErro.Caption + 'Porta inválida. ';
end;

end.

