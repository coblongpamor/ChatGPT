﻿unit ChatGPT.FrameChat;

interface

{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(IOS64)}
  {$DEFINE MOBILE}
{$ENDIF}

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.Memo.Style, FMX.ScrollBox, FMX.Memo, OpenAI, OpenAI.Completions,
  FMX.Edit.Style, ChatGPT.FrameMessage, ChatGPT.Classes, System.Threading,
  FMX.Edit, FMX.ImgList, OpenAI.Chat, System.Generics.Collections, OpenAI.Audio,
  OpenAI.Utils.ChatHistory, OpenAI.Images, ChatGPT.ChatSettings, System.JSON,
  FMX.Effects, FMX.ListBox, System.Skia, FMX.Skia, ChatGPT.SoundRecorder,
  FMX.InertialMovement, System.RTLConsts, OpenAI.Chat.Functions;

type
  TButton = class(FMX.StdCtrls.TButton)
  public
    procedure SetBounds(X, Y, AWidth, AHeight: Single); override;
  end;

  TLabel = class(FMX.StdCtrls.TLabel)
  public
    procedure SetBounds(X, Y, AWidth, AHeight: Single); override;
  end;

  TFixedScrollCalculations = class(TScrollCalculations)
  protected
    procedure DoChanged; override;
  end;

  TVertScrollBox = class(FMX.Layouts.TVertScrollBox)
  private
    FViewPositionY: Single;
    procedure SetViewPositionY(const Value: Single);
  protected
    function CreateAniCalculations: TScrollCalculations; override;
  published
    property ViewPositionY: Single read FViewPositionY write SetViewPositionY;
  end;

  TMemo = class(FMX.Memo.TMemo)
  private
    FViewPos: Single;
    procedure SetViewPos(const Value: Single);
  public
    property ViewPos: Single read FViewPos write SetViewPos;
  end;

  TFrameChat = class(TFrame)
    VertScrollBoxChat: TVertScrollBox;
    LayoutSend: TLayout;
    RectangleSendBG: TRectangle;
    MemoQuery: TMemo;
    LayoutQuery: TLayout;
    RectangleMemoBG: TRectangle;
    LayoutSendControls: TLayout;
    LayoutTyping: TLayout;
    TimerTyping: TTimer;
    LayoutTypingContent: TLayout;
    Layout3: TLayout;
    RectangleBot: TRectangle;
    Path3: TPath;
    Layout4: TLayout;
    RectangleIndicate: TRectangle;
    LabelTyping: TLabel;
    LineBorder: TLine;
    LayoutWelcome: TLayout;
    RectangleBG: TRectangle;
    LabelWelcomeTitle: TLabel;
    FlowLayoutWelcome: TFlowLayout;
    LayoutExampleTitle: TLayout;
    PathExaFull: TPath;
    ButtonExample3: TButton;
    ButtonExample2: TButton;
    ButtonExample1: TButton;
    LayoutCapabilitiesTitle: TLayout;
    PathCapFull: TPath;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    LayoutLimitationsTitle: TLayout;
    PathLimFull: TPath;
    Label8: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    LayoutSendCommons: TLayout;
    ButtonAudio: TButton;
    Path8: TPath;
    ButtonSend: TButton;
    PathSend: TPath;
    OpenDialogAudio: TOpenDialog;
    ButtonImage: TButton;
    PathImage: TPath;
    RectangleImageMode: TRectangle;
    RectangleTypeBG: TRectangle;
    LabelSendTip: TLabel;
    Layout5: TLayout;
    Label2: TLabel;
    PathExaCompact: TPath;
    Layout6: TLayout;
    Label1: TLabel;
    PathCapCompact: TPath;
    Layout7: TLayout;
    Label11: TLabel;
    PathLimCompact: TPath;
    LayoutChatSettings: TLayout;
    ButtonSettings: TButton;
    Path9: TPath;
    LayoutButtom: TLayout;
    ButtonRetry: TButton;
    ShadowEffect1: TShadowEffect;
    LayoutScrollDown: TLayout;
    ButtonScrollDown: TButton;
    PathAudio: TPath;
    LayoutAudioRecording: TLayout;
    AnimatedImageRecording: TSkAnimatedImage;
    PathStopRecord: TPath;
    TimerCheckRecording: TTimer;
    LabelRecordingTime: TLabel;
    ButtonContinue: TButton;
    ShadowEffect2: TShadowEffect;
    FlowLayoutActions: TFlowLayout;
    ButtonExportImport: TButton;
    ShadowEffect3: TShadowEffect;
    Rectangle1: TRectangle;
    LabelTest: TLabel;
    Rectangle2: TRectangle;
    Label3: TLabel;
    procedure LayoutSendResize(Sender: TObject);
    procedure MemoQueryChange(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure TimerTypingTimer(Sender: TObject);
    procedure LayoutTypingResize(Sender: TObject);
    procedure MemoQueryKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure LayoutWelcomeResize(Sender: TObject);
    procedure FlowLayoutWelcomeResize(Sender: TObject);
    procedure ButtonExample1Click(Sender: TObject);
    procedure ButtonExample2Click(Sender: TObject);
    procedure ButtonExample3Click(Sender: TObject);
    procedure ButtonAudioClick(Sender: TObject);
    procedure ButtonImageClick(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
    procedure ButtonRetryClick(Sender: TObject);
    procedure ButtonScrollDownClick(Sender: TObject);
    procedure VertScrollBoxChatViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
    procedure TimerCheckRecordingTimer(Sender: TObject);
    procedure ButtonExample1Tap(Sender: TObject; const Point: TPointF);
    procedure ButtonExample2Tap(Sender: TObject; const Point: TPointF);
    procedure ButtonExample3Tap(Sender: TObject; const Point: TPointF);
    procedure MemoQueryKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure MemoQueryEnter(Sender: TObject);
    procedure MemoQueryViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
    procedure ButtonContinueClick(Sender: TObject);
    procedure ButtonExportImportClick(Sender: TObject);
  private
    FAPI: IOpenAI;
    FChatId: string;
    FPool: TThreadPool;
    FTitle: string;
    FMode: TWindowMode;
    FIsTyping: Boolean;
    FBuffer: TChatHistory;
    FIsImageMode: Boolean;
    FTemperature: Single;
    FLastRequest: TProc;
    FMenuItem: TListBoxItem;
    FIsFirstMessage: Boolean;
    FPresencePenalty: Single;
    FModel: string;
    FMaxTokens: Integer;
    FMaxTokensQuery: Integer;
    FFrequencyPenalty: Single;
    FTopP: Single;
    FAudioRecord: TAudioRecord;
    FRecordingStartTime: TDateTime;
    FOnNeedFuncList: TOnNeedFuncList;
    FUseFunctions: Boolean;
    FAutoExecFuncs: Boolean;
    FOnTitleChanged: TNotifyEvent;
    procedure DoOnUpdateChatItems;
    function NewMessage(const Text: string; Role: TMessageKind; UseBuffer: Boolean = True; IsAudio: Boolean = False): TFrameMessage;
    function NewMessageImage(Role: TMessageKind; Images: TArray<string>): TFrameMessage;
    procedure ClearChat;
    procedure SetTyping(const Value: Boolean);
    procedure SetAPI(const Value: IOpenAI);
    procedure SetChatId(const Value: string);
    procedure ShowError(const Text: string);
    procedure AppendMessages(Response: TChat); overload;
    procedure AppendMessages(Response: TImageGenerations); overload;
    procedure ScrollDown(Animate: Boolean = False);
    procedure SetTitle(const Value: string);
    procedure SetMode(const Value: TWindowMode);
    procedure AppendAudio(Response: TAudioTranscriptionObject);
    procedure SetIsImageMode(const Value: Boolean);
    procedure SendRequestImage;
    procedure SendRequestPrompt;
    procedure SetTemperature(const Value: Single);
    procedure RequestPrompt;
    procedure RequestImage(const Prompt: string);
    procedure RequestAudio(const AudioFile: string);
    procedure SetLastRequest(const Value: TProc);
    procedure SetMenuItem(const Value: TListBoxItem);
    procedure SetFrequencyPenalty(const Value: Single);
    procedure SetMaxTokens(const Value: Integer);
    procedure SetMaxTokensQuery(const Value: Integer);
    procedure SetModel(const Value: string);
    procedure SetPresencePenalty(const Value: Single);
    procedure ChatToUp;
    procedure SetTopP(const Value: Single);
    procedure FOnMessageDelete(Sender: TObject);
    procedure StopRecording;
    procedure StartRecording;
    function GenerateAudioFileName: string;
    procedure FOnStartRecord(Sender: TObject);
    procedure UpdateSendControls;
    procedure SetOnNeedFuncList(const Value: TOnNeedFuncList);
    function GetFuncs: TArray<IChatFunction>;
    procedure ProcFunction(Func: TChatFunctionCall);
    procedure RequestFunc(FuncResult: string);
    function NewMessageFunc(const FuncName, FuncArgs: string): TFrameMessage;
    procedure FOnMessageTextUpdated(Sender: TObject; const MessageId, Text: string);
    procedure FOnExecuteFunc(Sender: TObject; const FuncName, FuncArgs: string; Callback: TProc<Boolean, string>);
    procedure ExecuteFunc(const FuncName, FuncArgs: string; Callback: TProc<Boolean, string>);
    procedure SetUseFunctions(const Value: Boolean);
    procedure SetAutoExecFuncs(const Value: Boolean);
    procedure SetOnTitleChanged(const Value: TNotifyEvent);
    procedure SendText;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function MakeContentScreenshot: TBitmap;
    function SaveAsJson: TJSONObject;
    procedure LoadFromJson(JSON: TJSONObject);
    property API: IOpenAI read FAPI write SetAPI;
    property ChatId: string read FChatId write SetChatId;
    property Title: string read FTitle write SetTitle;
    property Mode: TWindowMode read FMode write SetMode;
    property Temperature: Single read FTemperature write SetTemperature;
    property MaxTokens: Integer read FMaxTokens write SetMaxTokens;
    property MaxTokensQuery: Integer read FMaxTokensQuery write SetMaxTokensQuery;
    property PresencePenalty: Single read FPresencePenalty write SetPresencePenalty;
    property FrequencyPenalty: Single read FFrequencyPenalty write SetFrequencyPenalty;
    property Model: string read FModel write SetModel;
    property TopP: Single read FTopP write SetTopP;
    property IsImageMode: Boolean read FIsImageMode write SetIsImageMode;
    property LastRequest: TProc read FLastRequest write SetLastRequest;
    property MenuItem: TListBoxItem read FMenuItem write SetMenuItem;
    property IsFirstMessage: Boolean read FIsFirstMessage write FIsFirstMessage;
    property OnNeedFuncList: TOnNeedFuncList read FOnNeedFuncList write SetOnNeedFuncList;
    property UseFunctions: Boolean read FUseFunctions write SetUseFunctions;
    property AutoExecFuncs: Boolean read FAutoExecFuncs write SetAutoExecFuncs;
    property OnTitleChanged: TNotifyEvent read FOnTitleChanged write SetOnTitleChanged;
    procedure Init;
  end;

const
  MAX_TOKENS = 1024;
  MODEL_TOKENS_LIMIT = 4096;
  ErrorHintTimeout = 'If the error is due to a timeout, you can increase the response timeout in the general program settings.';

implementation

uses
  FMX.Ani, System.Math, OpenAI.API, System.IOUtils, ChatGPT.Manager,
  ChatGPT.Overlay, FMX.BehaviorManager, HGM.FMX.Ani, System.Net.HttpClient,
  {$IFDEF ANDROID}
  ChatGPT.Android, FMX.Platform.UI.Android,
  {$ENDIF}
  System.DateUtils, ChatGPT.ImportExport, FMX.Text;

{$R *.fmx}

function HumanTime(Value: TTime): string;
var
  H, M, S, Ms: Word;
begin
  DecodeTime(Value, H, M, S, Ms);
  Result := '';
  if H > 0 then
    Result := Result + H.ToString + ' ч. ';
  if M > 0 then
    Result := Result + M.ToString + ' мин. ';
  if S > 0 then
    Result := Result + S.ToString + ' сек. ';
  if Result.IsEmpty then
    Result := Result + '< 1 сек. ';
end;

function SecondsToTime(Value: Double): TTime;
begin
  Result := Value / SecsPerDay;
end;

procedure TFrameChat.ShowError(const Text: string);
begin
  TThread.Queue(nil,
    procedure
    begin
      var Frame := NewMessage(Text, TMessageKind.Error, False);
      Frame.IsError := True;
    end);
end;

procedure TFrameChat.AppendMessages(Response: TImageGenerations);
begin
  try
    var Images: TArray<string>;
    SetLength(Images, Length(Response.Data));
    for var i := 0 to High(Response.Data) do
      Images[i] := Response.Data[i].Url;
    NewMessageImage(TMessageKind.Assistant, Images);
  finally
    Response.Free;
  end;
end;

function TFrameChat.NewMessageFunc(const FuncName, FuncArgs: string): TFrameMessage;
begin
  ChatToUp;
  LayoutWelcome.Visible := False;
  Result := TFrameMessage.Create(VertScrollBoxChat);
  Result.SetMode(FMode);
  Result.Position.Y := VertScrollBoxChat.ContentBounds.Height;
  Result.Parent := VertScrollBoxChat;
  Result.Align := TAlignLayout.MostTop;
  Result.Id := '';
  Result.OnDelete := FOnMessageDelete;
  Result.OnTextUpdated := FOnMessageTextUpdated;
  TFrameMessage(Result).MessageRole := TMessageKind.Func;
  TFrameMessage(Result).FuncName := FuncName;
  TFrameMessage(Result).FuncArgs := FuncArgs;
  TFrameMessage(Result).FuncState := TMessageFuncState.Wait;
  TFrameMessage(Result).OnFuncExecute := FOnExecuteFunc;
  Result.StartAnimate;
  DoOnUpdateChatItems;
  if AutoExecFuncs then
    TFrameMessage(Result).ExecuteFunc;
end;

function TFrameChat.NewMessageImage(Role: TMessageKind; Images: TArray<string>): TFrameMessage;
begin
  ChatToUp;
  LayoutWelcome.Visible := False;
  Result := TFrameMessage.Create(VertScrollBoxChat);
  Result.SetMode(FMode);
  Result.Position.Y := VertScrollBoxChat.ContentBounds.Height;
  Result.Parent := VertScrollBoxChat;
  Result.Align := TAlignLayout.MostTop;
  Result.Id := '';
  Result.OnDelete := FOnMessageDelete;
  Result.OnTextUpdated := FOnMessageTextUpdated;
  TFrameMessage(Result).MessageRole := Role;
  TFrameMessage(Result).Images := Images;
  Result.StartAnimate;
  DoOnUpdateChatItems;
end;

procedure TFrameChat.ExecuteFunc(const FuncName, FuncArgs: string; Callback: TProc<Boolean, string>);
begin
  var Funcs := GetFuncs;
  for var Item in Funcs do
    if Item.Name = FuncName then
    begin
      TTask.Run(
        procedure
        begin
          var FuncResult := '';
          var ErrorText: string;
          try
            try
              FuncResult := Item.Execute(FuncArgs);
            except
              on E: Exception do
              begin
                ErrorText := E.Message;
                FuncResult := '';
              end;
            end;
            TThread.Queue(nil,
              procedure
              begin
                Callback(not FuncResult.IsEmpty, ErrorText);
                if not FuncResult.IsEmpty then
                begin
                  FBuffer.NewFunc(FuncName, FuncResult, TGUID.NewGuid.ToString);
                  RequestFunc(FuncResult);
                end;
              end);
          finally
            //
          end;
        end);
      Exit;
    end;
  Callback(False, 'Function not found');
end;

procedure TFrameChat.ProcFunction(Func: TChatFunctionCall);
begin
  FBuffer.NewAsistantFunc(Func.Name, Func.Arguments, TGUID.NewGuid.ToString);
  var Funcs := GetFuncs;
  for var Item in Funcs do
    if Item.Name = Func.Name then
    begin
      NewMessageFunc(Func.Name, Func.Arguments);
      Exit;
    end;
  ShowError('Function with name "' + Func.Name + '" not found');
end;

procedure TFrameChat.AppendMessages(Response: TChat);
begin
  try
    for var Item in Response.Choices do
      if Item.FinishReason = TFinishReason.FunctionCall then
        ProcFunction(Item.Message.FunctionCall)
      else
        NewMessage(Item.Message.Content, TMessageKind.Assistant);
  finally
    Response.Free;
  end;
end;

procedure TFrameChat.AppendAudio(Response: TAudioTranscriptionObject);
begin
  try
    NewMessage(Response.Text, TMessageKind.Assistant, True, True);
  finally
    Response.Free;
  end;
end;

function TFrameChat.SaveAsJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  try
    var JArray := TJSONArray.Create;
    Result.AddPair('chat_id', FChatId);
    Result.AddPair('temperature', TJSONNumber.Create(FTemperature));
    Result.AddPair('title', FTitle);
    Result.AddPair('items', JArray);

    Result.AddPair('frequency_penalty', TJSONNumber.Create(FrequencyPenalty));
    Result.AddPair('presence_penalty', TJSONNumber.Create(PresencePenalty));
    Result.AddPair('max_tokens', TJSONNumber.Create(MaxTokens));
    Result.AddPair('max_tokens_query', TJSONNumber.Create(MaxTokensQuery));
    Result.AddPair('top_p', TJSONNumber.Create(TopP));
    Result.AddPair('model', Model);
    Result.AddPair('is_image_mode', IsImageMode);
    Result.AddPair('draft', MemoQuery.Text);
    Result.AddPair('use_functions', UseFunctions);
    Result.AddPair('auto_exec_funcs', AutoExecFuncs);

    for var Control in VertScrollBoxChat.Content.Controls do
      if Control is TFrameMessage then
        if not TFrameMessage(Control).IsError then
          if not (TFrameMessage(Control).MessageRole in [TMessageKind.Error, TMessageKind.Func]) then
            JArray.Add(TFrameMessage(Control).ToJsonObject);
  except
    //
  end;
end;

procedure TFrameChat.FOnExecuteFunc(Sender: TObject; const FuncName, FuncArgs: string; Callback: TProc<Boolean, string>);
begin
  ExecuteFunc(FuncName, FuncArgs, Callback);
end;

procedure TFrameChat.FOnMessageDelete(Sender: TObject);
var
  Frame: TFrameMessage absolute Sender;
begin
  if not (Sender is TFrameMessage) then
    Exit;
  FBuffer.DeleteByTag(Frame.Id);
  if VertScrollBoxChat.Content.ControlsCount <= 3 then
    LayoutWelcome.Visible := True;
end;

procedure TFrameChat.FOnMessageTextUpdated(Sender: TObject; const MessageId, Text: string);
var
  Frame: TFrameMessage absolute Sender;
begin
  if not (Sender is TFrameMessage) then
    Exit;
  FBuffer.SetContentByTag(MessageId, Text);
end;

function TFrameChat.GenerateAudioFileName: string;
begin
  Result := TPath.Combine(Manager.AudioCacheFolder, 'audio_record' + FormatDateTime('DDMMYYYY_HHNNSS', Now) + '.wav');
end;

procedure TFrameChat.Init;
begin
  //Opacity := 0;
  //TAnimator.AnimateFloat(Self, 'Opacity', 1);
  {$IFNDEF MOBILE}
  MemoQuery.SetFocus;
  {$ENDIF}
  TThread.ForceQueue(nil,
    procedure
    begin
      MemoQuery.PrepareForPaint;
      MemoQueryChange(nil);
    end);
end;

procedure TFrameChat.LoadFromJson(JSON: TJSONObject);
begin
  var ItemCount: Integer := 0;
  var LastRoleIsUser: Boolean := False;
  if FChatId.IsEmpty then
    FChatId := JSON.GetValue('chat_id', TGUID.NewGuid.ToString);
  Title := JSON.GetValue('title', FTitle);
  FTemperature := JSON.GetValue('temperature', FTemperature);
  FrequencyPenalty := JSON.GetValue<Single>('frequency_penalty', FrequencyPenalty);
  PresencePenalty := JSON.GetValue<Single>('presence_penalty', PresencePenalty);
  TopP := JSON.GetValue<Single>('top_p', TopP);
  Model := JSON.GetValue('model', Model);
  MaxTokens := JSON.GetValue<Integer>('max_tokens', MaxTokens);
  MaxTokensQuery := JSON.GetValue<Integer>('max_tokens_query', MaxTokensQuery);
  IsImageMode := JSON.GetValue('is_image_mode', IsImageMode);
  UseFunctions := JSON.GetValue('use_functions', UseFunctions);
  AutoExecFuncs := JSON.GetValue('auto_exec_funcs', AutoExecFuncs);
  MemoQuery.Text := JSON.GetValue('draft', MemoQuery.Text);
  MemoQuery.SelStart := MemoQuery.Text.Length;
  MemoQuery.SelLength := 0;

  var JArray: TJSONArray;
  if JSON.TryGetValue<TJSONArray>('items', JArray) then
    for var JItem in JArray do
    begin
      var Item: TChatMessageBuild;
      var IsAudio := JItem.GetValue('is_audio', False);

      Item.Role := TMessageRole.FromString(JItem.GetValue('role', 'user'));
      Item.Content := JItem.GetValue('content', '');
      Item.Tag := JItem.GetValue('id', TGUID.NewGuid.ToString);
      Item.Name := JItem.GetValue('name', '');
      var Func: TFunctionCallBuild;
      Func.Name := JItem.GetValue('func_name', '');
      Func.Arguments := JItem.GetValue('func_args', '');
      Item.FunctionCall := Func;

      if not (IsAudio and (Item.Role = TMessageRole.User)) then
        FBuffer.Add(Item);

      var Frame := TFrameMessage.Create(VertScrollBoxChat);
      Frame.Position.Y := VertScrollBoxChat.ContentBounds.Height;
      VertScrollBoxChat.AddObject(Frame);
      Frame.Align := TAlignLayout.MostTop;
      case Item.Role of
        TMessageRole.System:
          Frame.MessageRole := TMessageKind.System;
        TMessageRole.User:
          Frame.MessageRole := TMessageKind.User;
        TMessageRole.Assistant:
          Frame.MessageRole := TMessageKind.Assistant;
        TMessageRole.Func:
          Frame.MessageRole := TMessageKind.Func;
      end;
      Frame.OnDelete := FOnMessageDelete;
      Frame.OnTextUpdated := FOnMessageTextUpdated;
      Frame.Id := Item.Tag;
      Frame.Text := Item.Content;
      Frame.IsAudio := IsAudio;
      Frame.Images := JItem.GetValue<TArray<string>>('images', []);
      Frame.FuncName := Item.FunctionCall.Name;
      Frame.FuncArgs := Item.FunctionCall.Arguments;
      Frame.FuncState := TMessageFuncState(JItem.GetValue('func_state', 0));
      if not Frame.FuncName.IsEmpty then
        Frame.OnFuncExecute := FOnExecuteFunc;
      Frame.SetMode(FMode);
      Frame.UpdateContentSize;
      Inc(ItemCount);
    end;
  DoOnUpdateChatItems;
  if ItemCount > 0 then
  begin
    LayoutWelcome.Visible := False;
    IsFirstMessage := False;
    ScrollDown;
    if LastRoleIsUser then
      LastRequest := RequestPrompt;
  end;
end;

procedure TFrameChat.ScrollDown(Animate: Boolean = False);
begin
  VertScrollBoxChat.RecalcSize;
  if Animate then
    TAnimator.AnimateFloat(VertScrollBoxChat, 'ViewPositionY', VertScrollBoxChat.ContentBounds.Height - VertScrollBoxChat.Height, 1, TAnimationType.out, TInterpolationType.Circular)
  else
    VertScrollBoxChat.ViewportPosition := TPointF.Create(0, VertScrollBoxChat.ContentBounds.Height - VertScrollBoxChat.Height);
end;

function TFrameChat.MakeContentScreenshot: TBitmap;

  function GetMaxBitmapRect: TRectF;
  var
    MaxDimensionSize: Integer;
  begin
    MaxDimensionSize := TCanvasManager.DefaultCanvas.GetAttribute(TCanvasAttribute.MaxBitmapSize);
    Result := TRectF.Create(0, 0, MaxDimensionSize, MaxDimensionSize);
  end;

var
  SceneScale: Single;
  BitmapRect: TRectF;
begin
  if Scene <> nil then
    SceneScale := Scene.GetSceneScale
  else
    SceneScale := 1;

  // TBitmap has limitation of size. It's a max texture size. If we takes screenshot of control, which exceeds this
  // limitation, we get "Bitmap size to big" exception. So we normalize size for avoiding it.
  BitmapRect := TRectF.Create(0, 0, VertScrollBoxChat.Content.ScrollBox.ContentBounds.Width * SceneScale, VertScrollBoxChat.Content.ScrollBox.ContentBounds.Height * SceneScale);
  BitmapRect := BitmapRect.PlaceInto(GetMaxBitmapRect);

  Result := TBitmap.Create(Round(BitmapRect.Width), Round(BitmapRect.Height));
  Result.BitmapScale := SceneScale;
  Result.Clear(0);
  if Result.Canvas.BeginScene then
  try
    VertScrollBoxChat.Content.PaintTo(Result.Canvas, TRectF.Create(0, 0, Result.Width / SceneScale, Result.Height / SceneScale));
  finally
    Result.Canvas.EndScene;
  end;
end;

procedure TFrameChat.ButtonSettingsClick(Sender: TObject);
begin
  TFrameChatSettings.Execute(Self,
    procedure(Frame: TFrameChatSettings)
    begin
      Frame.Mode := FMode;
      Frame.TrackBarTemp.Value := Temperature * 10;
      Frame.TrackBarPP.Value := PresencePenalty * 10;
      Frame.TrackBarFP.Value := FrequencyPenalty * 10;
      if MaxTokens <> 0 then
        Frame.EditMaxTokens.Text := MaxTokens.ToString
      else
        Frame.EditMaxTokens.Text := '';
      if MaxTokensQuery <> 0 then
        Frame.EditQueryMaxToken.Text := MaxTokensQuery.ToString
      else
        Frame.EditQueryMaxToken.Text := '';
      Frame.ComboEditModel.Text := Model;
      Frame.TrackBarTopP.Value := TopP * 10;
      Frame.SwitchUseFunctions.IsChecked := UseFunctions;
      Frame.SwitchAutoExecFuncs.IsChecked := AutoExecFuncs;
    end,
    procedure(Frame: TFrameChatSettings; Success: Boolean)
    begin
      MemoQuery.SetFocus;
      if not Success then
        Exit;
      Temperature := Frame.TrackBarTemp.Value / 10;
      PresencePenalty := Frame.TrackBarPP.Value / 10;
      FrequencyPenalty := Frame.TrackBarFP.Value / 10;
      MaxTokens := StrToIntDef(Frame.EditMaxTokens.Text, 0);
      MaxTokensQuery := StrToIntDef(Frame.EditQueryMaxToken.Text, 0);
      TopP := Frame.TrackBarTopP.Value / 10;
      Model := Frame.ComboEditModel.Text;
      UseFunctions := Frame.SwitchUseFunctions.IsChecked;
      AutoExecFuncs := Frame.SwitchAutoExecFuncs.IsChecked;
    end);
end;

procedure TFrameChat.ButtonAudioClick(Sender: TObject);
begin
  if FIsTyping then
    Exit;
  {$IFNDEF ANDROID}
  if not OpenDialogAudio.Execute then
    Exit;
  var AudioFile := OpenDialogAudio.FileName;
  //MemoQuery.Text := '';
  NewMessage(TPath.GetFileName(AudioFile), TMessageKind.User, False, True);
  RequestAudio(AudioFile);
  {$ELSE}
  try
    OpenFileDialog('*/*',
      procedure(FilePath: string)
      begin
        //MemoQuery.Text := '';
        NewMessage(TPath.GetFileName(FilePath), TMessageKind.User, False, True);
        RequestAudio(FilePath);
      end);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
  {$ENDIF}
end;

procedure TFrameChat.ButtonContinueClick(Sender: TObject);
begin
  RequestPrompt;
end;

procedure TFrameChat.RequestAudio(const AudioFile: string);
begin
  SetTyping(True);
  ScrollDown;
  LastRequest := nil;
  TTask.Run(
    procedure
    begin
      try
        var Audio := API.Audio.CreateTranscription(
          procedure(Params: TAudioTranscription)
          begin
            Params.&File(AudioFile);
            Params.Temperature(Temperature / 2);
            Params.Language('ru');
          end);
        TThread.Queue(nil,
          procedure
          begin
            AppendAudio(Audio);
          end);
      except
        on E: OpenAIException do
        begin
          ShowError(E.Message);
          LastRequest :=
            procedure
            begin
              RequestAudio(AudioFile);
            end;
        end;
        on E: Exception do
        begin
          ShowError(E.Message);
          LastRequest :=
            procedure
            begin
              RequestAudio(AudioFile);
            end;
        end;
      end;
      TThread.Queue(nil,
        procedure
        begin
          SetTyping(False);
        end);
    end, FPool);
end;

procedure TFrameChat.ButtonExample1Click(Sender: TObject);
begin
  if MemoQuery.Text.IsEmpty then
    MemoQuery.Text := 'Explain quantum computing in simple terms';
end;

procedure TFrameChat.ButtonExample1Tap(Sender: TObject; const Point: TPointF);
begin
  ButtonExample1Click(Sender);
end;

procedure TFrameChat.ButtonExample2Click(Sender: TObject);
begin
  if MemoQuery.Text.IsEmpty then
    MemoQuery.Text := 'Got any creative ideas for a 10 year old’s birthday?';
end;

procedure TFrameChat.ButtonExample2Tap(Sender: TObject; const Point: TPointF);
begin
  ButtonExample2Click(Sender);
end;

procedure TFrameChat.ButtonExample3Click(Sender: TObject);
begin
  if MemoQuery.Text.IsEmpty then
    MemoQuery.Text := 'How do I make an HTTP request in Javascript?';
end;

procedure TFrameChat.ButtonExample3Tap(Sender: TObject; const Point: TPointF);
begin
  ButtonExample3Click(Sender);
end;

procedure TFrameChat.ButtonExportImportClick(Sender: TObject);
begin
  TFrameImportExport.Execute(Self,
    procedure(Frame: TFrameImportExport)
    begin
      Frame.Mode := FMode;
    end,
    procedure(Frame: TFrameImportExport; Success: Boolean)
    begin
      MemoQuery.SetFocus;
      if not Success then
        Exit;
      if Frame.RadioButtonExport.IsChecked then
      begin
        if Frame.EditExport.Text.EndsWith('.json') then
        begin
          var JSON := SaveAsJson;
          if Assigned(JSON) then
          try
            TFile.WriteAllText(Frame.EditExport.Text, JSON.ToJSON, TEncoding.UTF8);
          finally
            JSON.Free;
          end;
        end
        else
        begin
          var Stream := TFile.Create(Frame.EditExport.Text);
          try
            for var Control in VertScrollBoxChat.Content.Controls do
              if Control is TFrameMessage then
                if not TFrameMessage(Control).IsError then
                begin
                  var Buff := TEncoding.UTF8.GetBytes(TFrameMessage(Control).MessageRole.ToString + #13#10 + TFrameMessage(Control).Text + #13#10 + #13#10 + #13#10);
                  Stream.WriteBuffer(Buff, Length(Buff));
                end;
          finally
            Stream.Free;
          end;
        end;
      end
      else
      begin
        var JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(Frame.EditImport.Text, TEncoding.UTF8));
        if Assigned(JSON) then
        try
          LoadFromJson(JSON as TJSONObject);
        finally
          JSON.Free;
        end;
      end;
    end);
end;

procedure TFrameChat.ButtonImageClick(Sender: TObject);
begin
  IsImageMode := not IsImageMode;
end;

procedure TFrameChat.ButtonRetryClick(Sender: TObject);
begin
  if Assigned(FLastRequest) then
    FLastRequest;
end;

procedure TFrameChat.SendRequestImage;
begin
  if FIsTyping then
    Exit;
  var Prompt := MemoQuery.Text;
  if Prompt.IsEmpty then
    Exit;
  MemoQuery.Text := '';
  NewMessage(Prompt, TMessageKind.User, False);
  RequestImage(Prompt);
end;

procedure TFrameChat.RequestImage(const Prompt: string);
begin
  SetTyping(True);
  ScrollDown;
  LastRequest := nil;
  TTask.Run(
    procedure
    begin
      try
        var Images := API.Image.Create(
          procedure(Params: TImageCreateParams)
          begin
            Params.Prompt(Prompt);
            Params.ResponseFormat(TImageResponseFormat.Url);
            Params.N(4);
            Params.Model('');
            Params.Size(TImageSize.s1024x1024);
            Params.User(FChatId);
          end);
        TThread.Queue(nil,
          procedure
          begin
            AppendMessages(Images);
          end);
      except
        on E: OpenAIException do
        begin
          ShowError(E.Message);
          LastRequest :=
            procedure
            begin
              RequestImage(Prompt);
            end;
        end;
        on E: Exception do
        begin
          ShowError(E.Message);
          LastRequest :=
            procedure
            begin
              RequestImage(Prompt);
            end;
        end;
      end;
      TThread.Queue(nil,
        procedure
        begin
          SetTyping(False);
        end);
    end, FPool);
end;

procedure TFrameChat.SendRequestPrompt;
begin
  if FIsTyping then
    Exit;
  var Prompt := MemoQuery.Text.Trim([' ', #13, #10]);
  if Prompt.IsEmpty then
    Exit;
  MemoQuery.Text := '';
  NewMessage(Prompt, TMessageKind.User);
  if (not Prompt.StartsWith('/system ')) and (not Prompt.StartsWith('/assistant ')) and (not Prompt.StartsWith('/user ')) then
    RequestPrompt;
end;

function TFrameChat.GetFuncs: TArray<IChatFunction>;
begin
  if Assigned(FOnNeedFuncList) and FUseFunctions then
    FOnNeedFuncList(Self, Result)
  else
    Result := [];
end;

function CreateTools(Funcs: TArray<IChatFunction>): TArray<TChatToolParam>;
begin
  for var Item in Funcs do
    Result := Result + [TChatToolFunctionParam.Create(Item)];
end;

procedure TFrameChat.RequestFunc(FuncResult: string);
begin
  SetTyping(True);
  ScrollDown;
  LastRequest := nil;
  TTask.Run(
    procedure
    begin
      try
        var Funcs := GetFuncs;
        var Completions := API.Chat.Create(
          procedure(Params: TChatParams)
          begin
            if not Model.IsEmpty then
              Params.Model(Model);
            if PresencePenalty <> 0 then
              Params.PresencePenalty(PresencePenalty);
            if FrequencyPenalty <> 0 then
              Params.FrequencyPenalty(FrequencyPenalty);
            Params.Messages(FBuffer.ToArray);
            if FBuffer.MaxTokensForQuery <> 0 then
              Params.MaxTokens(FBuffer.MaxTokensForQuery);
            Params.Temperature(Temperature);
            if Length(Funcs) > 0 then
            begin
              Params.Tools(CreateTools(Funcs));
              Params.ToolChoice(TChatToolChoiceParam.Auto);
            end;
            Params.User(FChatId);
          end);
        TThread.Queue(nil,
          procedure
          begin
            AppendMessages(Completions);
          end);
      except
        on E: OpenAIException do
        begin
          ShowError(E.Message);
          LastRequest :=
            procedure
            begin
              RequestFunc(FuncResult);
            end;
        end;
        on E: Exception do
        begin
          ShowError(E.Message);
          LastRequest :=
            procedure
            begin
              RequestFunc(FuncResult);
            end;
        end;
      end;
      TThread.Queue(nil,
        procedure
        begin
          SetTyping(False);
        end);
    end, FPool);
end;

procedure TFrameChat.RequestPrompt;
begin
  SetTyping(True);
  ScrollDown;
  LastRequest := nil;
  TTask.Run(
    procedure
    begin
      try
        var Funcs := GetFuncs;
        var Completions := API.Chat.Create(
          procedure(Params: TChatParams)
          begin
            if not Model.IsEmpty then
              Params.Model(Model);
            if PresencePenalty <> 0 then
              Params.PresencePenalty(PresencePenalty);
            if FrequencyPenalty <> 0 then
              Params.FrequencyPenalty(FrequencyPenalty);
            Params.Messages(FBuffer.ToArray);
            if FBuffer.MaxTokensForQuery <> 0 then
              Params.MaxTokens(FBuffer.MaxTokensForQuery);
            Params.Temperature(Temperature);
            if Length(Funcs) > 0 then
            begin
              Params.Tools(CreateTools(Funcs));
              Params.ToolChoice(TChatToolChoiceParam.Auto);
            end;
            Params.User(FChatId);
          end);
        TThread.Queue(nil,
          procedure
          begin
            AppendMessages(Completions);
          end);
      except
        on E: OpenAIException do
        begin
          ShowError(E.Message);
          LastRequest := RequestPrompt;
        end;
        on E: Exception do
        begin
          if E is ENetHTTPClientException then
            E.Message := E.Message + #13#10 + ErrorHintTimeout;
          ShowError(E.Message);

          LastRequest := RequestPrompt;
        end;
      end;
      TThread.Queue(nil,
        procedure
        begin
          SetTyping(False);
        end);
    end, FPool);
end;

procedure TFrameChat.ButtonScrollDownClick(Sender: TObject);
begin
  ScrollDown(True);
end;

procedure TFrameChat.StopRecording;
begin
  LayoutAudioRecording.Visible := False;
  MemoQuery.Visible := True;
  PathStopRecord.Visible := False;
  PathAudio.Visible := True;
  TimerCheckRecording.Enabled := False;
end;

procedure TFrameChat.StartRecording;
begin
  FAudioRecord.StartRecord(GenerateAudioFileName);
end;

procedure TFrameChat.ButtonSendClick(Sender: TObject);
begin
  if FAudioRecord.IsAvailableDevice then
  begin
    if FAudioRecord.IsMicrophoneRecording then
    begin
      FAudioRecord.StopRecord;
      Exit;
    end;
  end;
  if MemoQuery.Text.IsEmpty and FAudioRecord.IsAvailableDevice then
    StartRecording
  else
    SendText;
end;

procedure TFrameChat.SendText;
begin
  if IsImageMode then
    SendRequestImage
  else
    SendRequestPrompt;
end;

procedure TFrameChat.ClearChat;
begin
  LayoutTyping.Parent := nil;
  LayoutWelcome.Parent := nil;
  while VertScrollBoxChat.Content.ControlsCount > 0 do
    VertScrollBoxChat.Content.Controls[0].Free;
  LayoutTyping.Parent := VertScrollBoxChat;
  LayoutWelcome.Parent := VertScrollBoxChat;
  DoOnUpdateChatItems;
end;

procedure TFrameChat.FOnStartRecord(Sender: TObject);
begin
  FRecordingStartTime := Now;
  TimerCheckRecording.Enabled := True;
  LabelRecordingTime.Text := '';
  LayoutAudioRecording.Visible := True;
  MemoQuery.Visible := False;
  PathStopRecord.Visible := True;
  PathAudio.Visible := False;
end;

constructor TFrameChat.Create(AOwner: TComponent);
begin
  inherited;
  FIsFirstMessage := True;
  LastRequest := nil;
  FAudioRecord := TAudioRecord.Create(Self);
  FAudioRecord.OnStartRecord := FOnStartRecord;
  FBuffer := TChatHistory.Create;
  FBuffer.MaxTokensForQuery := MAX_TOKENS;
  FBuffer.MaxTokensOfModel := MODEL_TOKENS_LIMIT;
  FBuffer.AutoTrim := True;
  FPool := TThreadPool.Create;
  Temperature := 0.2;
  Name := '';
  VertScrollBoxChat.AniCalculations.Animation := True;
  VertScrollBoxChat.AniCalculations.Interval := 1;
  VertScrollBoxChat.AniCalculations.Averaging := True;
  {$IFDEF MOBILE}
  VertScrollBoxChat.AniCalculations.BoundsAnimation := True;
  {$ENDIF}

  MemoQuery.ScrollAnimation := TBehaviorBoolean.True;
  PathStopRecord.Visible := False;
  PathAudio.Visible := False;
  PathSend.Visible := True;
  LayoutAudioRecording.Visible := False;

  {$IFDEF MOBILE}
  ButtonExample1.OnClick := nil;
  ButtonExample2.OnClick := nil;
  ButtonExample3.OnClick := nil;
  //(MemoQuery.Presentation as TStyledMemo).NeedSelectorPoints := True;
  ButtonExportImport.Visible := False;
  {$ENDIF}

  SetTyping(False);
  ClearChat;
  IsImageMode := False;
  MemoQueryChange(nil);
  MemoQuery.ApplyStyleLookup;
end;

destructor TFrameChat.Destroy;
begin
  FMenuItem := nil;
  FPool.Free;
  FBuffer.Free;
  inherited;
end;

procedure TFrameChat.DoOnUpdateChatItems;
begin
  ButtonContinue.Visible := FBuffer.Count > 0;
end;

procedure TFrameChat.FlowLayoutWelcomeResize(Sender: TObject);
begin
  var W: Single := 0;
  case Mode of
    TWindowMode.Compact:
      W := FlowLayoutWelcome.Width;
    TWindowMode.Full:
      W := Trunc(FlowLayoutWelcome.Width / FlowLayoutWelcome.ControlsCount);
  end;
  for var Control in FlowLayoutWelcome.Controls do
    Control.Width := W;

  var B: Single := 0;
  for var Control in LayoutExampleTitle.Controls do
    B := Max(B, Control.Position.Y + Control.Height + Control.Margins.Bottom);
  if LayoutExampleTitle.Height <> B then
    LayoutExampleTitle.Height := B;

  B := 0;
  for var Control in LayoutCapabilitiesTitle.Controls do
    B := Max(B, Control.Position.Y + Control.Height + Control.Margins.Bottom);
  if LayoutCapabilitiesTitle.Height <> B then
    LayoutCapabilitiesTitle.Height := B;

  B := 0;
  for var Control in LayoutLimitationsTitle.Controls do
    B := Max(B, Control.Position.Y + Control.Height + Control.Margins.Bottom);
  if LayoutLimitationsTitle.Height <> B then
    LayoutLimitationsTitle.Height := B;

  B := 0;
  for var Control in FlowLayoutWelcome.Controls do
    B := Max(B, Control.Position.Y + Control.Height);

  B := B + FlowLayoutWelcome.Position.Y;
  if LayoutWelcome.Height <> B then
    LayoutWelcome.Height := B;
end;

procedure TFrameChat.LayoutSendResize(Sender: TObject);
begin
  LayoutQuery.Width := Min(768, LayoutSend.Width - 48);
  VertScrollBoxChat.Padding.Bottom := LayoutSend.Height + LayoutButtom.Height + 20;
end;

procedure TFrameChat.LayoutTypingResize(Sender: TObject);
begin
  LayoutTypingContent.Width := Min(LayoutTyping.Width - (LayoutTyping.Padding.Left + LayoutTyping.Padding.Right), MaxMessageWidth);
end;

procedure TFrameChat.LayoutWelcomeResize(Sender: TObject);
begin
  FlowLayoutWelcome.Width := Min(720, LayoutWelcome.Width);
end;

procedure TFrameChat.MemoQueryChange(Sender: TObject);
begin
  LabelSendTip.Visible := MemoQuery.Text.IsEmpty;
  var H: Single := 0;
  if not LabelSendTip.Visible then
    H := H + MemoQuery.ContentBounds.Height;
  //LayoutAudioRecording
  //LayoutSend.Height := Max(LayoutSend.TagFloat, Min(H, 400));

  var MaxMemoH := Min(H, 400 - (LayoutSend.Padding.Top + LayoutSend.Padding.Bottom + LayoutQuery.Padding.Top + LayoutQuery.Padding.Bottom));
  MemoQuery.Height := Max(26, MaxMemoH);
  H := H + LayoutSend.Padding.Top + LayoutSend.Padding.Bottom + LayoutQuery.Padding.Top + LayoutQuery.Padding.Bottom;
  TAnimator.DetachPropertyAnimation(LayoutSend, 'Height');
  TAnimator.AnimateFloat(LayoutSend, 'Height', Max(LayoutSend.TagFloat, Min(H, 400)), 0.1);
  MemoQuery.ShowScrollBars := H > 400;

  {$IFDEF MOBILE}
  if LabelSendTip.Visible then
  begin
    LayoutChatSettings.Visible := True;
    RectangleMemoBG.Margins.Left := 15;
  end
  else
  begin
    LayoutChatSettings.Visible := False;
    RectangleMemoBG.Margins.Left := -11;
  end;
  {$ENDIF}
  UpdateSendControls;
end;

procedure TFrameChat.MemoQueryEnter(Sender: TObject);
begin
  MemoQuery.PrepareForPaint;
end;

procedure TFrameChat.UpdateSendControls;
begin
  PathAudio.Visible := FAudioRecord.IsAvailableDevice and LabelSendTip.Visible;
  PathSend.Visible := not PathAudio.Visible;
  ButtonAudio.Visible := MemoQuery.Text.IsEmpty;
  ButtonAudio.Position.X := 0;
  var i := 0;
  for var Control in LayoutSendCommons.Controls do
    if Control.IsVisible then
      Inc(i);
  LayoutSendControls.Width := LayoutSendCommons.Height * i;
  LayoutSendCommons.RecalcSize;
end;

procedure TFrameChat.MemoQueryKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Manager.SendByEnter then
  begin
    if (Key = vkReturn) and not ((ssCtrl in Shift) or (ssShift in Shift)) then
    begin
      Key := 0;
      KeyChar := #0;
      SendText;
    end;
  end
  else
  begin
    if (Key = vkReturn) and (ssCtrl in Shift) then
    begin
      Key := 0;
      KeyChar := #0;
      SendText;
    end;
  end;
  MemoQueryChange(Sender);
end;

procedure TFrameChat.MemoQueryKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  MemoQueryChange(Sender);
end;

procedure TFrameChat.MemoQueryViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
begin
  MemoQueryChange(Sender);
end;

procedure TFrameChat.VertScrollBoxChatViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
begin
  VertScrollBoxChat.FViewPositionY := NewViewportPosition.Y;
  LayoutScrollDown.Visible := NewViewportPosition.Y < VertScrollBoxChat.ContentBounds.Height - VertScrollBoxChat.Height - 100;
end;

procedure TFrameChat.ChatToUp;
begin
  if not Assigned(FMenuItem) then
    Exit;
  FMenuItem.Index := 0;
  FMenuItem.IsSelected := True;
end;

function TFrameChat.NewMessage(const Text: string; Role: TMessageKind; UseBuffer: Boolean; IsAudio: Boolean): TFrameMessage;
begin
  ChatToUp;
  if (Role = TMessageKind.User) and IsFirstMessage then
  begin
    IsFirstMessage := False;
    Title := Text;
  end;

  var AppendText := Text;
  var MessageTag := TGUID.NewGuid.ToString;
  if UseBuffer then
  begin
    if Role = TMessageKind.User then
    begin
      if AppendText.StartsWith('/system ') then
      begin
        AppendText := AppendText.Replace('/system ', '', []);
        FBuffer.New(TMessageRole.System, AppendText, MessageTag);
        Role := TMessageKind.System;
      end
      else if AppendText.StartsWith('/user ') then
      begin
        AppendText := AppendText.Replace('/user ', '', []);
        FBuffer.New(TMessageRole.User, AppendText, MessageTag);
        Role := TMessageKind.User;
      end
      else if AppendText.StartsWith('/assistant ') then
      begin
        AppendText := AppendText.Replace('/assistant ', '', []);
        FBuffer.New(TMessageRole.Assistant, AppendText, MessageTag);
        Role := TMessageKind.Assistant;
      end
      else
      begin
        FBuffer.New(TMessageRole.User, AppendText, MessageTag);
      end;
    end
    else
    begin
      AppendText := AppendText;
      FBuffer.New(TMessageRole.Assistant, AppendText, MessageTag);
    end;
  end;
  LayoutWelcome.Visible := False;
  Result := TFrameMessage.Create(VertScrollBoxChat);
  Result.Position.Y := VertScrollBoxChat.ContentBounds.Height;
  Result.Parent := VertScrollBoxChat;
  Result.Align := TAlignLayout.MostTop;
  Result.Id := MessageTag;
  Result.MessageRole := Role;
  Result.IsAudio := IsAudio;
  Result.Text := AppendText;
  Result.OnDelete := FOnMessageDelete;
  Result.OnTextUpdated := FOnMessageTextUpdated;
  Result.SetMode(FMode);
  Result.UpdateContentSize;
  Result.StartAnimate;
  DoOnUpdateChatItems;
end;

procedure TFrameChat.SetAPI(const Value: IOpenAI);
begin
  FAPI := Value;
end;

procedure TFrameChat.SetAutoExecFuncs(const Value: Boolean);
begin
  FAutoExecFuncs := Value;
end;

procedure TFrameChat.SetChatId(const Value: string);
begin
  FChatId := Value;
end;

procedure TFrameChat.SetFrequencyPenalty(const Value: Single);
begin
  FFrequencyPenalty := Value;
end;

procedure TFrameChat.SetIsImageMode(const Value: Boolean);
begin
  FIsImageMode := Value;
  if FIsImageMode then
  begin
    PathImage.Fill.Color := $FFDDDDE4;
    RectangleImageMode.Visible := True;
  end
  else
  begin
    PathImage.Fill.Color := $FFACACBE;
    RectangleImageMode.Visible := False;
  end;
end;

procedure TFrameChat.SetLastRequest(const Value: TProc);
begin
  FLastRequest := Value;
  ButtonRetry.Visible := Assigned(FLastRequest);
end;

procedure TFrameChat.SetMaxTokens(const Value: Integer);
begin
  FMaxTokens := Value;
  FBuffer.MaxTokensOfModel := FMaxTokens;
end;

procedure TFrameChat.SetMaxTokensQuery(const Value: Integer);
begin
  FMaxTokensQuery := Value;
  FBuffer.MaxTokensForQuery := FMaxTokensQuery;
end;

procedure TFrameChat.SetMenuItem(const Value: TListBoxItem);
begin
  FMenuItem := Value;
end;

procedure TFrameChat.SetMode(const Value: TWindowMode);
begin
  FMode := Value;
  for var Control in Controls do
    if Control is TFrameOveraly then
    begin
      var Frame := Control as TFrameOveraly;
      Frame.Mode := FMode;
    end;
  for var Control in VertScrollBoxChat do
    if Control is TFrameMessage then
    begin
      var Frame := Control as TFrameMessage;
      Frame.SetMode(FMode);
    end;

  case FMode of
    TWindowMode.Compact:
      begin
        {$IFNDEF MOBILE}
        LayoutSend.Margins.Right := 11;
        {$ELSE}
        LayoutSend.Margins.Right := 0;
        {$ENDIF}
        LabelWelcomeTitle.Margins.Top := 20;
        LayoutSend.TagFloat := 100;
        LayoutSend.Height := 100;
        LayoutButtom.Margins.Bottom := 0;
        LineBorder.Visible := True;
        PathExaCompact.Visible := True;
        PathExaFull.Visible := False;
        PathCapCompact.Visible := True;
        PathCapFull.Visible := False;
        PathLimCompact.Visible := True;
        PathLimFull.Visible := False;
        LayoutSend.Padding.Rect := TRectF.Create(0, 10, 0, 40);
        RectangleSendBG.Fill.Kind := TBrushKind.Solid;
        RectangleSendBG.Fill.Color := $FF343541;
        ButtonExportImport.Width := ButtonExportImport.Height;
      end;
    TWindowMode.Full:
      begin
        {$IFNDEF MOBILE}
        LayoutSend.Margins.Right := 11;
        {$ELSE}
        LayoutSend.Margins.Right := 0;
        {$ENDIF}
        LabelWelcomeTitle.Margins.Top := 188;
        LayoutSend.TagFloat := 170;
        LayoutButtom.Margins.Bottom := -70;
        LayoutSend.Height := 170;
        LineBorder.Visible := False;
        PathExaCompact.Visible := False;
        PathExaFull.Visible := True;
        PathCapCompact.Visible := False;
        PathCapFull.Visible := True;
        PathLimCompact.Visible := False;
        PathLimFull.Visible := True;
        LayoutSend.Padding.Rect := TRectF.Create(0, 80, 0, 40);
        RectangleSendBG.Fill.Kind := TBrushKind.Gradient;
        ButtonExportImport.Width := 165;
      end;
  end;
  FlowLayoutWelcomeResize(nil);
end;

procedure TFrameChat.SetModel(const Value: string);
begin
  FModel := Value;
end;

procedure TFrameChat.SetOnNeedFuncList(const Value: TOnNeedFuncList);
begin
  FOnNeedFuncList := Value;
end;

procedure TFrameChat.SetOnTitleChanged(const Value: TNotifyEvent);
begin
  FOnTitleChanged := Value;
end;

procedure TFrameChat.SetPresencePenalty(const Value: Single);
begin
  FPresencePenalty := Value;
end;

procedure TFrameChat.SetTemperature(const Value: Single);
begin
  FTemperature := Value;
end;

procedure TFrameChat.SetTitle(const Value: string);
begin
  FTitle := Value.Replace(#10, '').Replace(#13, '').Replace('&', '').Substring(0, 50);
  if Assigned(FOnTitleChanged) then
    FOnTitleChanged(Self);
end;

procedure TFrameChat.SetTopP(const Value: Single);
begin
  FTopP := Value;
end;

procedure TFrameChat.SetTyping(const Value: Boolean);
begin
  FIsTyping := Value;
  ButtonSend.Enabled := not Value;
  TimerTyping.Enabled := Value;
  LayoutTyping.Visible := Value;
  FlowLayoutActions.Enabled := not Value;
  if LayoutTyping.Visible then
  begin
    LayoutTyping.Margins.Top := 40;
    LayoutTyping.Opacity := 0;
    TAnimator.AnimateFloat(LayoutTyping, 'Margins.Top', 0);
    TAnimator.AnimateFloat(LayoutTyping, 'Opacity', 1);
  end;
  LabelTyping.Visible := Value;
  LabelTyping.Position.X := 0;
  UpdateSendControls;
end;

procedure TFrameChat.SetUseFunctions(const Value: Boolean);
begin
  FUseFunctions := Value;
end;

procedure TFrameChat.TimerCheckRecordingTimer(Sender: TObject);
begin
  if FAudioRecord.IsMicrophoneRecording then
  begin
    LabelRecordingTime.Text := HumanTime(SecondsToTime(SecondsBetween(Now, FRecordingStartTime)));
  end
  else
  begin
    StopRecording;
  end;
end;

procedure TFrameChat.TimerTypingTimer(Sender: TObject);
begin
  RectangleIndicate.Visible := not RectangleIndicate.Visible;
  if LabelTyping.Text.Length > 2 then
    LabelTyping.Text := '.'
  else
    LabelTyping.Text := LabelTyping.Text + '.';
end;

{ TButton }

procedure TButton.SetBounds(X, Y, AWidth, AHeight: Single);
begin
  inherited;
  if Assigned(Canvas) and (Tag = 1) then
  begin
    var H := TRectF.Create(0, 0, Width - 20, 10000);
    Canvas.Font.Size := Font.Size;
    Canvas.MeasureText(H, Text, WordWrap, [], TextAlign, VertTextAlign);
    if AHeight <> H.Height + 24 then
      Height := H.Height + 24;
  end;
end;

{ TLabel }

procedure TLabel.SetBounds(X, Y, AWidth, AHeight: Single);
begin
  inherited;
  if Assigned(Canvas) and (Tag = 1) then
  begin
    var H := TRectF.Create(0, 0, Width - 20, 10000);
    Canvas.Font.Size := Font.Size;
    Canvas.MeasureText(H, Text, WordWrap, [], TextAlign, VertTextAlign);
    if AHeight <> H.Height + 24 then
      Height := H.Height + 24;
  end;
end;

{ TVertScrollBox }

function TVertScrollBox.CreateAniCalculations: TScrollCalculations;
begin
  Result := TFixedScrollCalculations.Create(Self);
end;

procedure TVertScrollBox.SetViewPositionY(const Value: Single);
begin
  FViewPositionY := Value;
  ViewportPosition := TPointF.Create(ViewportPosition.X, FViewPositionY);
end;

{ TMemo }

procedure TMemo.SetViewPos(const Value: Single);
begin
  FViewPos := Value;
  ViewportPosition := TPointF.Create(ViewportPosition.X, Value);
end;

{ TFixedScrollCalculations }

type
  TControlHook = class(TControl)
  end;

procedure TFixedScrollCalculations.DoChanged;
begin
  //inherited .DoChanged;
  TControlHook(ScrollBox).FDisableAlign := True;
  try
    inherited;
  finally
    TControlHook(ScrollBox).FDisableAlign := False;
  end;
end;

end.

