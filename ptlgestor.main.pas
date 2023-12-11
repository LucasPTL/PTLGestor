unit PTLGestor.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons;

type

  { TFormMain }

  TFormMain = class(TForm)
    panelBotoesBarra1: TPanel;
    panelConteudo: TPanel;
    panelBotoesBarra: TPanel;
    panelTop: TPanel;
    btnMinimizar: TSpeedButton;
    btnMaximizar: TSpeedButton;
    btnFechar: TSpeedButton;
    panelBottom: TPanel;
    btnConfigBanco: TSpeedButton;
  private

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

end.

