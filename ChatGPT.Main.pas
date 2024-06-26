﻿unit ChatGPT.Main;

interface

{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(IOS64)}
  {$DEFINE MOBILE}
{$ENDIF}

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, OpenAI,
  FMX.Objects, FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls,
  System.ImageList, FMX.ImgList, FMX.SVGIconImageList, ChatGPT.FrameChat,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Effects, FMX.Filter.Effects,
  FMX.Edit, ChatGPT.Classes, System.JSON, FMX.ComboEdit, FMX.Menus, System.Skia,
  System.Generics.Collections, System.Actions, FMX.ActnList, FMX.StdActns,
  FMX.MediaLibrary.Actions, OpenAI.Chat.Functions, FMX.Gestures, FMX.Ani,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client;

type
  TListBoxItemChat = class(TListBoxItem)
  public
    JSON: TJSONObject;
    ChatId: string;
    procedure Paint; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TFormMain = class(TForm)
    LayoutChats: TLayout;
    Rectangle1: TRectangle;
    StyleBook: TStyleBook;
    LayoutHead: TLayout;
    ButtonMenu: TButton;
    ButtonNewChatCompact: TButton;
    LabelChatName: TLabel;
    LayoutMenuContent: TLayout;
    RectangleMenu: TRectangle;
    LayoutMenu: TLayout;
    ButtonNewChat: TButton;
    ListBoxChatList: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    RectangleMenuBG: TRectangle;
    ButtonCloseMenu: TButton;
    LayoutMenuContainer: TLayout;
    LayoutCloseMenu: TLayout;
    Line1: TLine;
    ButtonClear: TButton;
    ButtonFAQ: TButton;
    LayoutChatsBox: TLayout;
    Layout2: TLayout;
    ButtonClearConfirm: TButton;
    ButtonClearCancel: TButton;
    LayoutOverlay: TLayout;
    ButtonSettings: TButton;
    Line2: TLine;
    ButtonAbout: TButton;
    LayoutMenuButtons: TLayout;
    ButtonMenuButonsSwitch: TButton;
    TimerFPS: TTimer;
    GestureManager: TGestureManager;
    FDConnection: TFDConnection;
    procedure ButtonNewChatClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonMenuClick(Sender: TObject);
    procedure ButtonCloseMenuClick(Sender: TObject);
    procedure ButtonNewChatCompactClick(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Single);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonClearConfirmClick(Sender: TObject);
    procedure ButtonClearCancelClick(Sender: TObject);
    procedure ButtonFAQClick(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
    procedure ButtonAboutClick(Sender: TObject);
    procedure ButtonMenuButonsSwitchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormSaveState(Sender: TObject);
    procedure TimerFPSTimer(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    class var
      FChatIdCount: Integer;
  private
    FOpenAI: TOpenAIComponent;
    FMode: TWindowMode;
    FToken: string;
    FTemperature: Single;
    FChatsFileName: string;
    FSettingsFileName: string;
    FSelectedChatId: string;
    FPresencePenalty: Single;
    FMaxTokens: Integer;
    FMaxTokensQuery: Integer;
    FFrequencyPenalty: Single;
    FOrganization: string;
    FBaseUrl: string;
    FModel: string;
    FTopP: Single;
    FGPTFuncList: TList<IChatFunction>;
    FUseFunctions: Boolean;
    FAutoExecFuncs: Boolean;
    FTimeout: Integer;
    procedure SetMode(const Value: TWindowMode);
    procedure UpdateMode;
    procedure SelectChat(const ChatId: string);
    procedure DeleteChat(const ChatId: string);
    procedure FOnChatItemClick(Sender: TObject);
    {$HINTS OFF}
    procedure FOnChatItemTap(Sender: TObject; const Point: TPointF);
    {$HINTS ON}
    function CreateChat(JSON: TJSONObject = nil): string;
    procedure CloseMenu;
    procedure Clear;
    procedure ShowClearConfirm;
    procedure HideClearConfirm;
    procedure FOnChatEditClick(Sender: TObject);
    procedure FOnChatDeleteClick(Sender: TObject);
    procedure OpenSettings;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure SetToken(const Value: string);
    procedure SetTemperature(const Value: Single);
    function GetSettingsFileName: string;
    function GetChatsFileName: string;
    procedure SetFrequencyPenalty(const Value: Single);
    procedure SetMaxTokens(const Value: Integer);
    procedure SetMaxTokensQuery(const Value: Integer);
    procedure SetPresencePenalty(const Value: Single);
    procedure SetOrganization(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure SetModel(const Value: string);
    function GetChatFrame(const ChatId: string): TFrameChat;
    procedure SetTopP(const Value: Single);
    procedure Defaults;
    procedure FOnNeedFuncList(Sender: TObject; out Items: TArray<IChatFunction>);
    procedure CreateGPTFunctions;
    procedure SetUseFunctions(const Value: Boolean);
    procedure SetAutoExecFuncs(const Value: Boolean);
    procedure SetTimeout(const Value: Integer);
    procedure RenameChat(const ChatId, Text: string);
    procedure FOnChatTitleChanged(Sender: TObject);
  protected
    procedure CreateHandle; override;
  public
    procedure LoadChats;
    procedure SaveChats;
    class function NextChatId: Integer; static;
    property UseFunctions: Boolean read FUseFunctions write SetUseFunctions;
    property AutoExecFuncs: Boolean read FAutoExecFuncs write SetAutoExecFuncs;
    property OpenAI: TOpenAIComponent read FOpenAI;
    property Mode: TWindowMode read FMode write SetMode;
    property Token: string read FToken write SetToken;
    property Temperature: Single read FTemperature write SetTemperature;
    property Timeout: Integer read FTimeout write SetTimeout;
    property Organization: string read FOrganization write SetOrganization;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
    property MaxTokens: Integer read FMaxTokens write SetMaxTokens;
    property MaxTokensQuery: Integer read FMaxTokensQuery write SetMaxTokensQuery;
    property PresencePenalty: Single read FPresencePenalty write SetPresencePenalty;
    property FrequencyPenalty: Single read FFrequencyPenalty write SetFrequencyPenalty;
    property TopP: Single read FTopP write SetTopP;
    property Model: string read FModel write SetModel;
    property GPTFuncList: TList<IChatFunction> read FGPTFuncList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

const
  URL_FAQ = 'https://help.openai.com/en/collections/3742473-chatgpt';
  DEFAULT_TIMEOUT = 120000;

const
  VersionName = '1.1.30';

var
  FormMain: TFormMain;

const
  AniInterpolation = TInterpolationType.Quadratic;

implementation

uses
  FMX.Text, System.Math, System.Rtti, FMX.Utils, FMX.DialogService,
  System.Threading, System.Net.URLClient, System.IOUtils, ChatGPT.Settings,
  ChatGPT.Overlay, FMX.Styles, HGM.FMX.Ani, HGM.FMX.Image, OpenAI.API,
  ChatGPT.Manager,
  {$IFDEF MSWINDOWS}
  DarkModeApi.FMX, FMX.Platform.Win,
  {$ENDIF}
  ChatGPT.About, ChatGPT.Functions, System.Math.Vectors;

{$R *.fmx}

{ TFormMain }

class function TFormMain.NextChatId: Integer;
begin
  Inc(FChatIdCount);
  Result := FChatIdCount;
end;

procedure TFormMain.ShowClearConfirm;
begin
  ButtonClear.Text := 'Confirm clear';
  ButtonClearConfirm.Visible := True;
  ButtonClearCancel.Visible := True;
end;

procedure TFormMain.TimerFPSTimer(Sender: TObject);
begin
  Invalidate;
end;

procedure TFormMain.HideClearConfirm;
begin
  ButtonClear.Text := 'Clear conversations';
  ButtonClearConfirm.Visible := False;
  ButtonClearCancel.Visible := False;
end;

procedure TFormMain.ButtonAboutClick(Sender: TObject);
begin
  LayoutOverlay.BringToFront;
  TFrameAbout.Execute(LayoutOverlay,
    procedure(Frame: TFrameAbout)
    begin
      Frame.Mode := Mode;
    end,
    procedure(Frame: TFrameAbout; Success: Boolean)
    begin
      //
    end);
end;

procedure TFormMain.ButtonClearCancelClick(Sender: TObject);
begin
  HideClearConfirm;
end;

procedure TFormMain.ButtonClearClick(Sender: TObject);
begin
  ShowClearConfirm;
end;

procedure TFormMain.ButtonClearConfirmClick(Sender: TObject);
begin
  Clear;
  SelectChat(CreateChat);
end;

procedure TFormMain.ButtonCloseMenuClick(Sender: TObject);
begin
  CloseMenu;
end;

procedure TFormMain.ButtonFAQClick(Sender: TObject);
begin
  OpenUrl(URL_FAQ);
end;

procedure TFormMain.ButtonMenuButonsSwitchClick(Sender: TObject);
begin
  if LayoutMenuButtons.Height < 210 then
  begin
    TAnimator.AnimateFloat(LayoutMenuButtons, 'Height', 210, 0.1);
    ButtonMenuButonsSwitch.RotationAngle := 0;
  end
  else
  begin
    TAnimator.AnimateFloat(LayoutMenuButtons, 'Height', 17, 0.1);
    ButtonMenuButonsSwitch.RotationAngle := 180;
  end;
end;

procedure TFormMain.ButtonMenuClick(Sender: TObject);
begin
  RectangleMenuBG.Opacity := 0;
  LayoutMenuContainer.Opacity := 0;
  LayoutMenuContainer.Margins.Left := -(LayoutMenuContainer.Width - 45);
  ButtonCloseMenu.Opacity := 0;
  LayoutMenuContent.Visible := True;
  TAnimator.AnimateFloat(RectangleMenuBG, 'Opacity', 1, 0.2, TAnimationType.InOut, AniInterpolation);
  TAnimator.AnimateFloat(ButtonCloseMenu, 'Opacity', 1, 0.2, TAnimationType.InOut, AniInterpolation);
  TAnimator.AnimateFloat(LayoutMenuContainer, 'Opacity', 1, 0.2, TAnimationType.InOut, AniInterpolation);
  TAnimator.AnimateFloat(LayoutMenuContainer, 'Margins.Left', 0, 0.2, TAnimationType.InOut, AniInterpolation);
end;

procedure TFormMain.CloseMenu;
begin
  TAnimator.AnimateFloat(RectangleMenuBG, 'Opacity', 0, 0.2, TAnimationType.InOut, AniInterpolation);
  TAnimator.AnimateFloat(ButtonCloseMenu, 'Opacity', 0, 0.2, TAnimationType.InOut, AniInterpolation);
  TAnimator.AnimateFloat(LayoutMenuContainer, 'Opacity', 0, 0.2, TAnimationType.InOut, AniInterpolation);
  TAnimator.AnimateFloatWithFinish(LayoutMenuContainer, 'Margins.Left', -(LayoutMenuContainer.Width - 45),
    procedure
    begin
      LayoutMenuContent.Visible := False;
    end, 0.2, TAnimationType.InOut, AniInterpolation);
end;

function TFormMain.CreateChat(JSON: TJSONObject): string;
begin
  var IsNew: Boolean := not Assigned(JSON);
  var ItemList := TListBoxItemChat.Create(ListBoxChatList);
  if IsNew then
  begin
    ItemList.JSON := nil;
    ItemList.ChatId := TGUID.NewGuid.ToString;
    ItemList.Text := 'New chat ' + NextChatId.ToString;
  end
  else
  begin
    ItemList.JSON := JSON.Clone as TJSONObject;
    ItemList.Text := JSON.GetValue('title', '').Replace(#13, ' ').Replace(#10, ' ').Replace('&', '');
    ItemList.ChatId := JSON.GetValue('chat_id', TGUID.NewGuid.ToString);
  end;
  ItemList.TabStop := False;
  ItemList.HitTest := True;
  {$IFDEF MOBILE}
  ItemList.OnTap := FOnChatItemTap;
  {$ELSE}
  ItemList.OnClick := FOnChatItemClick;
  {$ENDIF}
  ItemList.Margins.Bottom := 8;
  ItemList.TextSettings.WordWrap := False;
  ItemList.ImageIndex := 1;
  ItemList.DisableDisappear := True;
  ItemList.StylesData['edit.OnClick'] := TValue.From<TNotifyEvent>(FOnChatEditClick);
  ItemList.StylesData['delete.OnClick'] := TValue.From<TNotifyEvent>(FOnChatDeleteClick);
  if IsNew then
    ListBoxChatList.InsertObject(0, ItemList)
  else
    ListBoxChatList.AddObject(ItemList);
  ItemList.ApplyStyleLookup;

  Result := ItemList.ChatId;
end;

procedure TFormMain.CreateHandle;
begin
  inherited;
  {$IFDEF MSWINDOWS}
  SetWindowColorModeAsSystem;
  {$ENDIF}
end;

procedure TFormMain.DeleteChat(const ChatId: string);
begin
  for var Control in LayoutChatsBox.Controls do
    if Control is TFrameChat then
    begin
      var Frame := TFrameChat(Control);
      if Frame.ChatId = ChatId then
      begin
        Frame.Release;
        Break;
      end;
    end;
  var DeletedIndex: Integer := -1;
  for var i := 0 to Pred(ListBoxChatList.Count) do
    if ListBoxChatList.ListItems[i] is TListBoxItemChat then
      if TListBoxItemChat(ListBoxChatList.ListItems[i]).ChatId = ChatId then
      begin
        DeletedIndex := i;
        ListBoxChatList.ListItems[i].Release;
        Break;
      end;
  if ListBoxChatList.Count <= 0 then
    SelectChat(CreateChat)
  else
  begin
    DeletedIndex := Max(0, Min(DeletedIndex - 1, ListBoxChatList.Count - 1));
    SelectChat((ListBoxChatList.ListItems[DeletedIndex] as TListBoxItemChat).ChatId);
  end;
end;

procedure TFormMain.RenameChat(const ChatId, Text: string);
begin
  for var Control in LayoutChatsBox.Controls do
    if Control is TFrameChat then
    begin
      var Frame := TFrameChat(Control);
      if Frame.ChatId = ChatId then
      begin
        Frame.Title := Text;
        Break;
      end;
    end;
end;

destructor TFormMain.Destroy;
begin
  FGPTFuncList.Free;
  inherited;
end;

procedure TFormMain.ButtonNewChatClick(Sender: TObject);
begin
  SelectChat(CreateChat);
  if Mode = TWindowMode.Compact then
    CloseMenu;
end;

procedure TFormMain.ButtonNewChatCompactClick(Sender: TObject);
begin
  SelectChat(CreateChat);
end;

procedure TFormMain.ButtonSettingsClick(Sender: TObject);
begin
  OpenSettings;
end;

procedure TFormMain.FOnChatEditClick(Sender: TObject);
var
  Button: TButton absolute Sender;
  ListItem: TListBoxItemChat;
  ChatId: string;
begin
  if TFMXObjectHelper.FindNearestParentOfClass<TListBoxItemChat>(Button, ListItem) then
  begin
    ChatId := ListItem.ChatId;
    TDialogService.InputQuery('New Chat name', ['Name'], [ListItem.Text],
      procedure(const AResult: TModalResult; const AValues: array of string)
      begin
        if AResult = mrOk then
          RenameChat(ChatId, AValues[0]);
      end);
  end;
end;

procedure TFormMain.FOnChatDeleteClick(Sender: TObject);
var
  Button: TButton absolute Sender;
  ListItem: TListBoxItemChat;
  ChatId: string;
begin
  if TFMXObjectHelper.FindNearestParentOfClass<TListBoxItemChat>(Button, ListItem) then
  begin
    ChatId := ListItem.ChatId;
    TDialogService.MessageDialog('Delete "' + ListItem.Text + '"?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
          DeleteChat(ChatId);
      end);
  end;
end;

procedure TFormMain.FOnChatItemClick(Sender: TObject);
var
  Item: TListBoxItemChat absolute Sender;
begin
  if not (Item is TListBoxItemChat) then
    Exit;
  SelectChat(Item.ChatId);
  if Mode = TWindowMode.Compact then
    CloseMenu;
end;

procedure TFormMain.FOnChatItemTap(Sender: TObject; const Point: TPointF);
begin
  FOnChatItemClick(Sender);
end;

procedure TFormMain.FOnNeedFuncList(Sender: TObject; out Items: TArray<IChatFunction>);
begin
  Items := FGPTFuncList.ToArray;
end;

function TFormMain.GetSettingsFileName: string;
begin
  if FSettingsFileName.IsEmpty then
    FSettingsFileName := TPath.Combine(Manager.AppFolder, 'settings.json');
  Result := FSettingsFileName;
end;

function TFormMain.GetChatsFileName: string;
begin
  if FChatsFileName.IsEmpty then
    FChatsFileName := TPath.Combine(Manager.AppFolder, 'chats.json');
  Result := FChatsFileName;
end;

procedure TFormMain.Defaults;
begin
  TimeOut := DEFAULT_TIMEOUT;
  Token := '';
  Temperature := 1;
  FrequencyPenalty := 0;
  PresencePenalty := 0;
  TopP := 1;
  Model := '';
  MaxTokens := 0;
  MaxTokensQuery := 0;
  FSelectedChatId := '';
end;

procedure TFormMain.LoadSettings;
begin
  try
    if not TFile.Exists(GetSettingsFileName) then
      Exit;
    var JsonText: string := '';
    try
      JsonText := TFile.ReadAllText(GetSettingsFileName, TEncoding.UTF8);
    except
      Exit;
    end;
    if JsonText.IsEmpty then
      Exit;
    var JSON := TJSONObject.ParseJSONValue(JsonText);
    if Assigned(JSON) then
    try
      Token := JSON.GetValue('api_key', '');
      Temperature := JSON.GetValue<Single>('temperature', 1);
      FrequencyPenalty := JSON.GetValue<Single>('frequency_penalty', 0.0);
      PresencePenalty := JSON.GetValue<Single>('presence_penalty', 0.0);
      TopP := JSON.GetValue<Single>('top_p', 1);
      Model := JSON.GetValue('model', '');
      MaxTokens := JSON.GetValue<Integer>('max_tokens', 0);
      MaxTokensQuery := JSON.GetValue<Integer>('max_tokens_query', 0);
      FSelectedChatId := JSON.GetValue('selected_chat', '');
      OpenAI.BaseUrl := JSON.GetValue('base_url', OpenAI.BaseUrl);
      UseFunctions := JSON.GetValue<Boolean>('use_functions', False);
      AutoExecFuncs := JSON.GetValue<Boolean>('auto_exec_funcs', False);
      Manager.SendByEnter := JSON.GetValue<Boolean>('send_by_enter', True);

      if JSON.GetValue('on_top', False) then
        FormStyle := TFormStyle.StayOnTop
      else
        FormStyle := TFormStyle.Normal;

      OpenAI.API.ProxySettings := TProxySettings.Create(
        JSON.GetValue('proxy_host', ''),
        JSON.GetValue<Integer>('proxy_port', 0),
        JSON.GetValue('proxy_username', ''),
        JSON.GetValue('proxy_password', ''));
      TBitmap.Client.ProxySettings := OpenAI.API.ProxySettings;

      var Headers: TNetHeaders;
      try
        var JHeaders: TJSONArray;
        if JSON.TryGetValue<TJSONArray>('custom_headers', JHeaders) then
          for var JHead in JHeaders do
            if JHead is TJSONObject then
            begin
              var HName: string;
              var HValue: string;
              if JHead.TryGetValue('name', HName) and JHead.TryGetValue('value', HValue) then
              begin
                SetLength(Headers, Length(Headers) + 1);
                Headers[High(Headers)] := TNetHeader.Create(HName, HValue);
              end;
            end;
      except
        //
      end;

      Width := Max(Trunc(Constraints.MinWidth), JSON.GetValue<Integer>('width', Width));
      Height := Max(Trunc(Constraints.MinHeight), JSON.GetValue<Integer>('height', Height));
      Left := JSON.GetValue<Integer>('left', Left);
      Top := JSON.GetValue<Integer>('top', Top);

      if JSON.GetValue('menubuttons', True) then
      begin
        LayoutMenuButtons.Height := 210;
        ButtonMenuButonsSwitch.RotationAngle := 0;
      end
      else
      begin
        LayoutMenuButtons.Height := 17;
        ButtonMenuButonsSwitch.RotationAngle := 180;
      end;

      OpenAI.API.CustomHeaders := Headers;
    finally
      JSON.Free;
    end;
  finally
    if Token.IsEmpty then
      OpenSettings;
  end;
end;

procedure TFormMain.SaveSettings;
begin
  var JSON := TJSONObject.Create;
  try
    JSON.AddPair('api_key', Token);
    JSON.AddPair('temperature', TJSONNumber.Create(Temperature));
    JSON.AddPair('selected_chat', FSelectedChatId);

    JSON.AddPair('frequency_penalty', TJSONNumber.Create(FrequencyPenalty));
    JSON.AddPair('presence_penalty', TJSONNumber.Create(PresencePenalty));
    JSON.AddPair('top_p', TJSONNumber.Create(TopP));
    JSON.AddPair('max_tokens', TJSONNumber.Create(MaxTokens));
    JSON.AddPair('max_tokens_query', TJSONNumber.Create(MaxTokensQuery));
    JSON.AddPair('model', Model);

    JSON.AddPair('on_top', FormStyle = TFormStyle.StayOnTop);
    JSON.AddPair('use_functions', UseFunctions);
    JSON.AddPair('auto_exec_funcs', AutoExecFuncs);
    JSON.AddPair('send_by_enter', Manager.SendByEnter);

    JSON.AddPair('proxy_host', OpenAI.API.ProxySettings.Host);
    JSON.AddPair('proxy_port', OpenAI.API.ProxySettings.Port);
    JSON.AddPair('proxy_username', OpenAI.API.ProxySettings.UserName);
    JSON.AddPair('proxy_password', OpenAI.API.ProxySettings.Password);

    JSON.AddPair('base_url', OpenAI.BaseUrl);

    JSON.AddPair('width', Width);
    JSON.AddPair('height', Height);
    JSON.AddPair('left', Left);
    JSON.AddPair('top', Top);

    JSON.AddPair('menubuttons', LayoutMenuButtons.Height >= 210);

    if Length(OpenAI.API.CustomHeaders) > 0 then
    begin
      var JHeaders := TJSONArray.Create;
      JSON.AddPair('custom_headers', JHeaders);
      for var Header in OpenAI.API.CustomHeaders do
      begin
        var JHead := TJSONObject.Create;
        JHead.AddPair('name', Header.Name);
        JHead.AddPair('value', Header.Value);
        JHeaders.Add(JHead);
      end;
    end;

    TFile.WriteAllText(GetSettingsFileName, JSON.ToJSON, TEncoding.UTF8);
  except
    //
  end;
  JSON.Free;
end;

procedure TFormMain.LoadChats;
begin
  try
    if not TFile.Exists(GetChatsFileName) then
      Exit;
    var JsonText: string := '';
    try
      JsonText := TFile.ReadAllText(GetChatsFileName, TEncoding.UTF8);
    except
      Exit;
    end;
    if JsonText.IsEmpty then
      Exit;
    var JSON := TJSONObject.ParseJSONValue(JsonText);
    if Assigned(JSON) then
    try
      var JSONChats: TJSONArray;
      if JSON.TryGetValue('items', JSONChats) then
      begin
        for var JChat in JSONChats do
          if JChat is TJSONObject then
            CreateChat(TJSONObject(JChat));
      end;
      SelectChat(FSelectedChatId);
    finally
      JSON.Free;
    end;
  finally
    if LayoutChatsBox.ControlsCount <= 0 then
      SelectChat(CreateChat)
    else if (ListBoxChatList.Count > 0) and (ListBoxChatList.Selected = nil) then
      SelectChat((ListBoxChatList.ListItems[0] as TListBoxItemChat).ChatId);
  end;
end;

procedure TFormMain.SaveChats;
begin
  var JSON := TJSONObject.Create;
  try
    var JSONChats := TJSONArray.Create;
    JSON.AddPair('items', JSONChats);
    for var i := 0 to ListBoxChatList.Count - 1 do
      if ListBoxChatList.ListItems[i] is TListBoxItemChat then
      begin
        var Frame := GetChatFrame(TListBoxItemChat(ListBoxChatList.ListItems[i]).ChatId);
        if Assigned(Frame) then
          JSONChats.Add(Frame.SaveAsJson)
        else
          JSONChats.Add(TListBoxItemChat(ListBoxChatList.ListItems[i]).JSON.Clone as TJSONObject);
      end;
    TFile.WriteAllText(GetChatsFileName, JSON.ToJSON, TEncoding.UTF8);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
  JSON.Free;
end;

function TFormMain.GetChatFrame(const ChatId: string): TFrameChat;
begin
  for var Control in LayoutChatsBox.Controls do
    if Control is TFrameChat then
    begin
      var Frame := TFrameChat(Control);
      if Frame.ChatId = ChatId then
        Exit(Frame);
    end;
  Result := nil;
end;

procedure TFormMain.SelectChat(const ChatId: string);
begin
  FSelectedChatId := ChatId;

  var ItemList: TListBoxItemChat := nil;
  for var i := 0 to Pred(ListBoxChatList.Count) do
    if (ListBoxChatList.ListItems[i] as TListBoxItemChat).ChatId = ChatId then
    begin
      ListBoxChatList.ListItems[i].IsSelected := True;
      LabelChatName.Text := ListBoxChatList.ListItems[i].Text;
      ItemList := TListBoxItemChat(ListBoxChatList.ListItems[i]);
      Break;
    end;
  if not Assigned(ItemList) then
    Exit;

  var SelFrame: TFrameChat := nil;
  for var Control in LayoutChatsBox.Controls do
    if Control is TFrameChat then
    begin
      var Frame := TFrameChat(Control);
      Frame.Visible := Frame.ChatId = ChatId;
      if Frame.Visible then
        SelFrame := Frame;
    end;

  if not Assigned(SelFrame) then
  begin
    SelFrame := TFrameChat.Create(LayoutChatsBox);
    SelFrame.Parent := LayoutChatsBox;
    SelFrame.Align := TAlignLayout.Client;
    SelFrame.API := OpenAI;
    SelFrame.Mode := Mode;
    SelFrame.OnNeedFuncList := FOnNeedFuncList;
    SelFrame.OnTitleChanged := FOnChatTitleChanged;
    if Assigned(ItemList.JSON) then
      SelFrame.LoadFromJson(ItemList.JSON)
    else
    begin
      SelFrame.ChatId := ItemList.ChatId;
      SelFrame.Title := ItemList.Text;
      SelFrame.Temperature := Temperature;
      SelFrame.TopP := TopP;
      SelFrame.PresencePenalty := PresencePenalty;
      SelFrame.FrequencyPenalty := FrequencyPenalty;
      SelFrame.Model := Model;
      SelFrame.MaxTokens := MaxTokens;
      SelFrame.MaxTokensQuery := MaxTokensQuery;
      SelFrame.UseFunctions := UseFunctions;
      SelFrame.AutoExecFuncs := AutoExecFuncs;
    end;
    SelFrame.MenuItem := ItemList;
    SelFrame.Visible := True;
  end;
  SelFrame.Init;
end;

procedure TFormMain.FOnChatTitleChanged(Sender: TObject);
var
  Frame: TFrameChat absolute Sender;
begin
  for var i := 0 to Pred(ListBoxChatList.Count) do
    if ListBoxChatList.ListItems[i] is TListBoxItemChat then
      if TListBoxItemChat(ListBoxChatList.ListItems[i]).ChatId = Frame.ChatId then
      begin
        ListBoxChatList.ListItems[i].Text := Frame.Title;
        Break;
      end;
  if FSelectedChatId = Frame.ChatId then
    LabelChatName.Text := Frame.Title;
end;

procedure TFormMain.CreateGPTFunctions;
begin
  // FGPTFuncList.Add(TChatFunctionWeather.Create);
  FGPTFuncList.AddRange(LoadExternalFunctions);
end;

constructor TFormMain.Create(AOwner: TComponent);
begin
  inherited;
  FMode := TWindowMode.Full;
  TAnimation.AniFrameRate := 300;
  ListBoxChatList.AniCalculations.Animation := True;
  ListBoxChatList.AniCalculations.Interval := 1;
  ListBoxChatList.AniCalculations.Averaging := True;
  ListBoxChatList.DisableDisappear := True;
  {$IFDEF NEW_MEMO}
  var Style := StyleBook.Style;
  if Assigned(Style) then
  begin
    var ObjStyle := Style.FindStyleResource('memostyle_clear');
    if Assigned(ObjStyle) then
    begin
      var Sel := ObjStyle.FindStyleResource('selection');
      if Assigned(Sel) and (Sel is TBrushObject) then
        TBrushObject(Sel).Brush.Color := $FF1F2027;
    end;
    ObjStyle := Style.FindStyleResource('memostyle_code');
    if Assigned(ObjStyle) then
    begin
      var Sel := ObjStyle.FindStyleResource('selection');
      if Assigned(Sel) and (Sel is TBrushObject) then
        TBrushObject(Sel).Brush.Color := $FF4E4E53;
    end;
    TStyleManager.UpdateScenes;
  end;
  {$ENDIF}
  LayoutOverlay.Visible := True;
  LayoutOverlay.BringToFront;
  ListBoxChatList.AniCalculations.Animation := True;
  FGPTFuncList := TList<IChatFunction>.Create;
  FOpenAI := TOpenAIComponent.Create(Self);
  FOpenAI.API.ConnectionTimeout := 30000;

  Manager.OverlayContainer := LayoutOverlay;
  Manager.GPTFuncList := FGPTFuncList;

  CreateGPTFunctions;
  Defaults;
  Clear;
  UpdateMode;
end;

procedure TFormMain.Clear;
begin
  HideClearConfirm;
  ListBoxChatList.Clear;
  LayoutChatsBox.BeginUpdate;
  try
    while LayoutChatsBox.ControlsCount > 0 do
      LayoutChatsBox.Controls[0].Free;
  finally
    LayoutChatsBox.EndUpdate;
  end;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  {$IFDEF MOBILE}
  if Overlays.Count > 0 then
  begin
    var Active := Overlays.Last;
    Active.Cancel;
    CanClose := False;
  end;
  {$ENDIF}
end;

procedure TFormMain.FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Single);
begin
  FormResize(Sender);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  LoadSettings;
  LoadChats;
end;

procedure TFormMain.FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  if (EventInfo.GestureID = sgiRightLeft) then
  begin
    Handled := True;
    ButtonMenuClick(nil);
  end;
end;

procedure TFormMain.OpenSettings;
begin
  LayoutOverlay.BringToFront;
  TFrameSettings.Execute(LayoutOverlay,
    procedure(Frame: TFrameSettings)
    begin
      Frame.Mode := FMode;
      Frame.EditToken.Text := Token;
      Frame.EditOrg.Text := Organization;
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
      if (Timeout <> 0) and (Timeout <> DEFAULT_TIMEOUT) then
        Frame.EditTimeout.Text := Timeout.ToString
      else
        Frame.EditTimeout.Text := '';
      Frame.ComboEditModel.Text := Model;
      Frame.TrackBarTopP.Value := TopP * 10;
      Frame.SwitchOnTop.IsChecked := FormStyle = TFormStyle.StayOnTop;
      Frame.EditProxyServer.Text := OpenAI.API.ProxySettings.Host;
      Frame.EditProxyPort.Text := OpenAI.API.ProxySettings.Port.ToString;
      Frame.EditProxyUsername.Text := OpenAI.API.ProxySettings.UserName;
      Frame.EditProxyPassword.Text := OpenAI.API.ProxySettings.Password;
      Frame.LabelVersion.Text := 'Version: ' + VersionName;
      Frame.EditBaseUrl.Text := OpenAI.BaseUrl;
      Frame.SwitchUseFunctions.IsChecked := UseFunctions;
      Frame.SwitchAutoExecFuncs.IsChecked := AutoExecFuncs;
      Frame.SwitchSendEnter.IsChecked := Manager.SendByEnter;
      for var Head in OpenAI.API.CustomHeaders do
        Frame.MemoCustomHeaders.Lines.AddPair(Head.Name, Head.Value);
    end,
    procedure(Frame: TFrameSettings; Success: Boolean)
    begin
      if not Success then
        Exit;
      Token := Frame.EditToken.Text;
      Organization := Frame.EditOrg.Text;
      Temperature := Frame.TrackBarTemp.Value / 10;
      PresencePenalty := Frame.TrackBarPP.Value / 10;
      FrequencyPenalty := Frame.TrackBarFP.Value / 10;
      TopP := Frame.TrackBarTopP.Value / 10;
      MaxTokens := StrToIntDef(Frame.EditMaxTokens.Text, 0);
      MaxTokensQuery := StrToIntDef(Frame.EditQueryMaxToken.Text, 0);
      Timeout := StrToIntDef(Frame.EditTimeout.Text, DEFAULT_TIMEOUT);
      Model := Frame.ComboEditModel.Text;
      if Frame.SwitchOnTop.IsChecked then
        FormStyle := TFormStyle.StayOnTop
      else
        FormStyle := TFormStyle.Normal;
      OpenAI.API.ProxySettings := TProxySettings.Create(
        Frame.EditProxyServer.Text,
        StrToIntDef(Frame.EditProxyPort.Text, 0),
        Frame.EditProxyUsername.Text,
        Frame.EditProxyPassword.Text);
      TBitmap.Client.ProxySettings := OpenAI.API.ProxySettings;
      OpenAI.BaseUrl := Frame.EditBaseUrl.Text;
      UseFunctions := Frame.SwitchUseFunctions.IsChecked;
      AutoExecFuncs := Frame.SwitchAutoExecFuncs.IsChecked;
      Manager.SendByEnter := Frame.SwitchSendEnter.IsChecked;

      var FHeaders: TNetHeaders;
      try
        for var Line in Frame.MemoCustomHeaders.Lines do
        begin
          var Pair := Line.Split([':']);
          if Length(Pair) = 2 then
          begin
            SetLength(FHeaders, Length(FHeaders) + 1);
            FHeaders[High(FHeaders)] := TNetHeader.Create(Pair[0], Pair[1]);
          end;
        end;
      except
        //
      end;
      OpenAI.API.CustomHeaders := FHeaders;

      if OpenAI.BaseUrl.IsEmpty then
        OpenAI.BaseUrl := TOpenAIAPI.URL_BASE;
      {$IFDEF MSWINDOWS}
      SetWindowColorModeAsSystem;
      {$ENDIF}
      SaveSettings;
    end);
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  LayoutMenuContainer.Width := Min(320, ClientWidth - 45);
  if ClientWidth < 768 then
    Mode := TWindowMode.Compact
  else
    Mode := TWindowMode.Full;
end;

procedure TFormMain.FormSaveState(Sender: TObject);
begin
  SaveChats;
  SaveSettings;
end;

procedure TFormMain.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TAnimator.AnimateFloat(Self, 'Padding.Bottom', 0);
  TAnimator.AnimateFloat(LayoutOverlay, 'Margins.Bottom', 0);
  // Padding.Bottom := 0;
  // LayoutOverlay.Margins.Bottom := 0;
end;

procedure TFormMain.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TAnimator.AnimateFloat(Self, 'Padding.Bottom', Bounds.Height);
  TAnimator.AnimateFloat(LayoutOverlay, 'Margins.Bottom', Bounds.Height);
  // LayoutOverlay.Margins.Bottom := Bounds.Height;
  // Padding.Bottom := Bounds.Height;
end;

procedure TFormMain.UpdateMode;
begin
  for var Control in LayoutChatsBox.Controls do
    if Control is TFrameChat then
    begin
      var Frame := TFrameChat(Control);
      Frame.Mode := FMode;
    end;
  for var Control in LayoutOverlay.Controls do
    if Control is TFrameOveraly then
    begin
      var Frame := TFrameOveraly(Control);
      Frame.Mode := FMode;
    end;
  case FMode of
    TWindowMode.Compact:
      begin
        RectangleMenu.Align := TAlignLayout.Client;
        RectangleMenu.Parent := LayoutMenuContainer;
        LayoutHead.Visible := True;
        ButtonCloseMenu.Visible := True;
      end;
    TWindowMode.Full:
      begin
        RectangleMenu.Align := TAlignLayout.Left;
        RectangleMenu.Width := 260;
        RectangleMenu.Parent := Self;
        LayoutHead.Visible := False;
        ButtonCloseMenu.Visible := False;
        LayoutMenuContent.Visible := False;
        RectangleMenu.SendToBack;
      end;
  end;
end;

procedure TFormMain.SetAutoExecFuncs(const Value: Boolean);
begin
  FAutoExecFuncs := Value;
end;

procedure TFormMain.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
  OpenAI.BaseUrl := FBaseUrl;
end;

procedure TFormMain.SetFrequencyPenalty(const Value: Single);
begin
  FFrequencyPenalty := Value;
end;

procedure TFormMain.SetMaxTokens(const Value: Integer);
begin
  FMaxTokens := Value;
end;

procedure TFormMain.SetMaxTokensQuery(const Value: Integer);
begin
  FMaxTokensQuery := Value;
end;

procedure TFormMain.SetMode(const Value: TWindowMode);
begin
  if FMode = Value then
    Exit;
  FMode := Value;
  UpdateMode;
end;

procedure TFormMain.SetModel(const Value: string);
begin
  FModel := Value;
end;

procedure TFormMain.SetOrganization(const Value: string);
begin
  FOrganization := Value;
  OpenAI.Organization := FOrganization;
end;

procedure TFormMain.SetPresencePenalty(const Value: Single);
begin
  FPresencePenalty := Value;
end;

procedure TFormMain.SetTemperature(const Value: Single);
begin
  FTemperature := Value;
end;

procedure TFormMain.SetTimeout(const Value: Integer);
begin
  FTimeout := Value;
  if Value <= 0 then
    FTimeout := DEFAULT_TIMEOUT;
  FOpenAI.API.ResponseTimeout := FTimeout;
  FOpenAI.API.SendTimeout := FTimeout;
end;

procedure TFormMain.SetToken(const Value: string);
begin
  FToken := Value;
  FOpenAI.Token := FToken;
end;

procedure TFormMain.SetTopP(const Value: Single);
begin
  FTopP := Value;
end;

procedure TFormMain.SetUseFunctions(const Value: Boolean);
begin
  FUseFunctions := Value;
end;

{ TListBoxItemChat }

constructor TListBoxItemChat.Create(AOwner: TComponent);
begin
  inherited;
  JSON := nil;
end;

destructor TListBoxItemChat.Destroy;
begin
  if Assigned(JSON) then
    JSON.Free;
  inherited;
end;

procedure TListBoxItemChat.Paint;
begin
  var Canv: ISkCanvas;
  if Supports(Canvas, ISkCanvas, Canv) then
    Canv.Skew(1, 0.2);
  Canvas.SetMatrix(TMatrix.CreateScaling(1, 2));
  inherited;
  Canvas.SetMatrix(TMatrix.CreateScaling(1, 2));
end;

initialization
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

end.

