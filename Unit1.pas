unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Bluetooth, System.Bluetooth.Components, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    BluetoothLE1: TBluetoothLE;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure BluetoothLE1DiscoverLEDevice(const Sender: TObject;
      const ADevice: TBluetoothLEDevice; Rssi: Integer;
      const ScanResponse: TScanResponse);
  private
    { private 宣言 }
  public
    { public 宣言 }
  end;

Const
BeaconUUid : array [0..15] of byte = ($00,$05,$00,$01,{-} $00,$00,{-}$10,$00,{-}$80,$00,{-}$00,$80,$5f,$9b,$01,$31);
{ここは自分のビーコンのuuidです。}

type
 TiBeaconData= Record
    CampanyId: WORD;  //  4C00
    i02      : BYTE;  // 0X02
    i15      : BYTE;  // 0X15
    UUID     : array [0..15] of byte; // 16BYTE
    Major    : Word;
    MinorH   : BYTE;
    MinorL   : BYTE;
    TxPower  : BYTE;
 end;
 PiBeaconData = ^TiBeaconData;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.BluetoothLE1DiscoverLEDevice(const Sender: TObject;
  const ADevice: TBluetoothLEDevice; Rssi: Integer;
  const ScanResponse: TScanResponse);
var
  p   : PiBeaconData;
  Hum : Single;
  Temp : Single;
begin
  if not ScanResponse.ContainsKey(TScanResponseKey.ManufacturerSpecificData) then   exit;
  p  := @ScanResponse.Items[TScanResponseKey.ManufacturerSpecificData][0];
  if  CompareMem( @BeaconUUid , @(p^.UUid),sizeof(BeaconUUid)) then
  begin
    Label3.text := Format('%3d',[Rssi])+'dBm';
    Hum := (-6.0) + ((125.0 * p^.MinorH)/256.0) ;
    Label2.Text := Format('%f %',[Hum])+'％';
    Temp := ((175.72*p^.MinorL)/256.0)-46.85;
    Label1.Text := Format('%f %',[Temp])+'℃';
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if( BluetoothLE1.Enabled ) then  BluetoothLE1.CancelDiscovery;
  BluetoothLE1.Enabled := TRUE;
  BluetoothLE1.DiscoverDevices(60000); {1分間検出させます}
end;

end.
