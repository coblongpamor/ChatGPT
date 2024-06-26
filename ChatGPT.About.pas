﻿unit ChatGPT.About;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  ChatGPT.Overlay, FMX.Objects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.ComboEdit, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts,
  ChatGPT.Classes;

{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(IOS64)}
  {$DEFINE MOBILE}
{$ENDIF}

type
  TFrameAbout = class(TFrameOveraly)
    LayoutClient: TLayout;
    RectangleFrame: TRectangle;
    VertScrollBoxContent: TVertScrollBox;
    Label1: TLabel;
    Label5: TLabel;
    LabelAppearance: TLabel;
    LabelVersion: TLabel;
    Layout2: TLayout;
    ButtonOk: TButton;
    Label34: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Layout4: TLayout;
    ButtonGitHub: TButton;
    Layout1: TLayout;
    ButtonReport: TButton;
    procedure ButtonOkClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure ButtonGitHubClick(Sender: TObject);
    procedure ButtonReportClick(Sender: TObject);
    procedure ButtonGitHubTap(Sender: TObject; const Point: TPointF);
    procedure ButtonReportTap(Sender: TObject; const Point: TPointF);
  private
    FProcCallback: TProc<TFrameAbout, Boolean>;
    FLayoutClientWidth, FLayoutClientHeight: Single;
  protected
    procedure SetMode(const Value: TWindowMode); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Cancel; override;
    class procedure Execute(AParent: TControl; ProcSet: TProc<TFrameAbout>; ProcExecuted: TProc<TFrameAbout, Boolean>);
  end;

var
  FrameAbout: TFrameAbout;

implementation

uses
  System.Math;

{$R *.fmx}

procedure TFrameAbout.ButtonGitHubClick(Sender: TObject);
begin
  OpenUrl('https://github.com/HemulGM/ChatGPT');
end;

procedure TFrameAbout.ButtonGitHubTap(Sender: TObject; const Point: TPointF);
begin
  ButtonGitHubClick(nil);
end;

procedure TFrameAbout.ButtonOkClick(Sender: TObject);
begin
  Cancel;
end;

procedure TFrameAbout.ButtonReportClick(Sender: TObject);
begin
  OpenUrl('https://github.com/HemulGM/ChatGPT/issues');
end;

procedure TFrameAbout.ButtonReportTap(Sender: TObject; const Point: TPointF);
begin
  ButtonReportClick(nil);
end;

procedure TFrameAbout.Cancel;
begin
  if Assigned(FProcCallback) then
    FProcCallback(Self, True);
  Release;
end;

constructor TFrameAbout.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
  FLayoutClientWidth := LayoutClient.Width;
  FLayoutClientHeight := LayoutClient.Height;
  VertScrollBoxContent.AniCalculations.Animation := True;
  VertScrollBoxContent.AniCalculations.Interval := 1;
  VertScrollBoxContent.AniCalculations.Averaging := True;
  VertScrollBoxContent.ViewportPosition := TPoint.Zero;
  {$IFDEF MOBILE}
  ButtonReport.OnClick := nil;
  ButtonGitHub.OnClick := nil;
  {$ENDIF}
end;

class procedure TFrameAbout.Execute(AParent: TControl; ProcSet: TProc<TFrameAbout>; ProcExecuted: TProc<TFrameAbout, Boolean>);
begin
  var Frame := TFrameAbout.Create(AParent);
  Frame.Parent := AParent;
  Frame.FProcCallback := ProcExecuted;
  Frame.Align := TAlignLayout.Contents;
  Frame.BringToFront;
  if Assigned(ProcSet) then
    ProcSet(Frame);
  Frame.ButtonOk.SetFocus;
end;

procedure TFrameAbout.FrameResize(Sender: TObject);
begin
  LayoutClient.Width := Min(FLayoutClientWidth, Width);
  LayoutClient.Height := Min(FLayoutClientHeight, Height);
end;

procedure TFrameAbout.SetMode(const Value: TWindowMode);
begin
  inherited;
  if Mode = TWindowMode.Compact then
  begin
    LayoutClient.Align := TAlignLayout.Client;
    RectangleFrame.Corners := [];
  end
  else
  begin
    LayoutClient.Align := TAlignLayout.Center;
    RectangleFrame.Corners := AllCorners;
  end;
  FrameResize(nil);
end;

end.

