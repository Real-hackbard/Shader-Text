unit Unit1;

interface

uses
  WinApi.Windows, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.Controls, Vcl.Forms, Vcl.Graphics, System.Classes,
  System.SysUtils, Vcl.Samples.Spin, Vcl.Mask, PngImage, GIFImg, Jpeg;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    FontDialog1: TFontDialog;
    Edit1: TLabeledEdit;
    btnPolice: TBitBtn;
    edtOmbreX: TEdit;
    UpDown1: TUpDown;
    edtOmbreY: TEdit;
    UpDown2: TUpDown;
    Label1: TLabel;
    Label3: TLabel;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    Button2: TButton;
    Button3: TButton;
    StatusBar1: TStatusBar;
    Button4: TButton;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    Shape1: TShape;
    ColorDialog1: TColorDialog;
    Edit2: TEdit;
    ComboBox1: TComboBox;
    Label2: TLabel;
    SpinEdit5: TSpinEdit;
    Label8: TLabel;
    Label9: TLabel;
    CheckBox1: TCheckBox;
    ComboBox2: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    ComboBox3: TComboBox;
    CheckBox2: TCheckBox;
    Shape2: TShape;
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure PreVisualiser(Sender: TObject);
    procedure btnPoliceClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure SpinEdit4Change(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure UpDown2Changing(Sender: TObject; var AllowChange: Boolean);
    procedure SpinEdit5Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }

  end;

var
  Form1: TForm1;

type
  PixArray = Array [0..2] of Byte;

implementation

{$R *.dfm}
procedure Bmp2Jpeg(const BmpFileName, JpgFileName: string);
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
begin
  Bmp := TBitmap.Create;
  Jpg := TJPEGImage.Create;
  try
    Bmp.LoadFromFile(BmpFileName);
    Jpg.Assign(Bmp);
    Jpg.SaveToFile(JpgFileName);
  finally
    Jpg.Free;
    Bmp.Free;
  end;
end;

procedure BitmapFileToPNG(const Source, Dest: String);
var
  Bitmap: TBitmap;
  PNG: TPNGObject;
begin
  Bitmap := TBitmap.Create;
  PNG := TPNGObject.Create;
  {In case something goes wrong, free booth Bitmap and PNG}
  try
    Bitmap.LoadFromFile(Source);
    //Convert data into png
    PNG.Assign(Bitmap);

    if Form1.CheckBox1.Checked = true then
    begin
      PNG.TransparentColor := clBlack;
      PNG.Transparent := true;
    end;

    PNG.SaveToFile(Dest);
  finally
    Bitmap.Free;
    PNG.Free;
  end
end;

function TColorToHex( Color : TColor ) : string;
begin
  Result :=
    { red value }
    IntToHex( GetRValue( Color ), 2 ) +
    { green value }
    IntToHex( GetGValue( Color ), 2 ) +
    { blue value }
    IntToHex( GetBValue( Color ), 2 );
end;

function HexToTColor( sColor : string ) : TColor;
begin
  Result :=
    RGB(
      { get red value }
      StrToInt( '$'+Copy( sColor, 1, 2 ) ),
      { get green value }
      StrToInt( '$'+Copy( sColor, 3, 2 ) ),
      { get blue value }
      StrToInt( '$'+Copy( sColor, 5, 2 ) )
    );
end;

procedure Antialiasing(Bitmap: TBitmap; Rect: TRect; Percent: Integer);
var
  pix, prevscan, nextscan, hpix: ^PixArray;
  l, p: Integer;
  R, G, B: Integer;
  R1, R2, G1, G2, B1, B2: Byte;
begin
  Bitmap.PixelFormat := pf24bit;
  with Bitmap.Canvas do
  begin
    Brush.Style := bsclear;
    for l := Rect.Top to Rect.Bottom - 1 do
    begin
      pix:= Bitmap.ScanLine[l];
      if l <> Rect.Top then prevscan := Bitmap.ScanLine[l-1]
      else prevscan := nil;
      if l <> Rect.Bottom - 1 then nextscan := Bitmap.ScanLine[l+1]
      else nextscan := nil;

      for p := Rect.Left to Rect.Right - 1 do
      begin
        R1 := pix^[2];
        G1 := pix^[1];
        B1 := pix^[0];

        if p <> Rect.Left then
        begin
          //Pixel left
          hpix := pix;
          dec(hpix);
          R2 := hpix^[2];
          G2 := hpix^[1];
          B2 := hpix^[0];

          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := R1 + (R2 - R1) * 50 div (Percent + 50);
            G := G1 + (G2 - G1) * 50 div (Percent + 50);
            B := B1 + (B2 - B1) * 50 div (Percent + 50);
            hpix^[2] := R;
            hpix^[1] := G;
            hpix^[0] := B;
          end;
        end;

        if p <> Rect.Right - 1 then
        begin
          //Pixel right
          hpix := pix;
          inc(hpix);
          R2 := hpix^[2];
          G2 := hpix^[1];
          B2 := hpix^[0];

          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := R1 + (R2 - R1) * 50 div (Percent + 50);
            G := G1 + (G2 - G1) * 50 div (Percent + 50);
            B := B1 + (B2 - B1) * 50 div (Percent + 50);
            hpix^[2] := R;
            hpix^[1] := G;
            hpix^[0] := B;
          end;
        end;

        if prevscan <> nil then
        begin
          //Pixel up
          R2 := prevscan^[2];
          G2 := prevscan^[1];
          B2 := prevscan^[0];

          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := R1 + (R2 - R1) * 50 div (Percent + 50);
            G := G1 + (G2 - G1) * 50 div (Percent + 50);
            B := B1 + (B2 - B1) * 50 div (Percent + 50);
            prevscan^[2] := R;
            prevscan^[1] := G;
            prevscan^[0] := B;
          end;
          Inc(prevscan);
        end;

        if nextscan <> nil then
        begin
          //Pixel down
          R2 := nextscan^[2];
          G2 := nextscan^[1];
          B2 := nextscan^[0];

          if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
          begin
            R := R1 + (R2 - R1) * 50 div (Percent + 50);
            G := G1 + (G2 - G1) * 50 div (Percent + 50);
            B := B1 + (B2 - B1) * 50 div (Percent + 50);
            nextscan^[2] := R;
            nextscan^[1] := G;
            nextscan^[0] := B;
          end;
          Inc(nextscan);
        end;
        Inc(pix);
      end;
    end;
  end;
end;

function GetShadowColor( BaseColor: TColor ): TColor;
     var rgbtResult: TRGBQuad ABSOLUTE Result;
begin
{$R-}
  Result := ColorToRGB( BaseColor );
  with rgbtResult do begin
    //if (rgbRed <= $34) and (rgbGreen <= $34) and (rgbBlue <= $34) then begin
      //Result := clWhite;                // Not very pretty in this case.
      //Exit;
    //end;

    if rgbRed   > 63 then Dec( rgbRed,    64 )
                     else rgbRed   := 0;
    if rgbGreen > 63 then Dec( rgbGreen,  64 )
                     else rgbGreen := 0;
    if rgbBlue  > 63 then Dec( rgbBlue,   64 )
                     else rgbBlue  := 0;
  end;
{$R+}
end;

procedure TForm1.PreVisualiser(Sender: TObject);
var
  Bmp : TBitmap;
begin
  FontDialog1.Font.Size := SpinEdit5.Value;
  FontDialog1.Font.Color := Shape2.Brush.Color;
  FontDialog1.Font.Style := [];

  if Form1.Edit1.Text = '' then exit;

  Bmp := TBitmap.Create;
  try
    Bmp.Canvas.Font := Form1.FontDialog1.Font;
    Bmp.Height      := Bmp.Canvas.TextHeight( Form1.Edit1.Text );
    // Larger for italicized font.
    Bmp.Width       := Bmp.Canvas.TextWidth ( Form1.Edit1.Text ) + Bmp.Height div 2;
    Bmp.Canvas.TextOut( 0, 0 , Form1.Edit1.Text );
    //Form1.imgPreVisuel.Picture.Bitmap.Assign( Bmp );
  finally
    Bmp.Free;
  end;

  Button2.Click;
  StatusBar1.Panels[1].Text := FontDialog1.Font.Name;
end;

procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ColorDialog1.Execute then
  begin
    Shape1.Brush.Color := ColorDialog1.Color;
    Edit2.Text := TColorToHex(Shape1.Brush.Color);
    Button2Click(self);
  end;
end;

procedure TForm1.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ColorDialog1.Execute then
  begin
    Shape2.Brush.Color := ColorDialog1.Color;
    FontDialog1.Font.Color := Shape2.Brush.Color;
    Button2Click(self);
  end;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Button2Click(self);
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  Button2Click(self);
end;

procedure TForm1.SpinEdit3Change(Sender: TObject);
begin
  Button2Click(self);
end;

procedure TForm1.SpinEdit4Change(Sender: TObject);
begin
  Button2Click(self);
end;

procedure TForm1.SpinEdit5Change(Sender: TObject);
begin
  FontDialog1.Font.Size := SpinEdit5.Value;
  Button2Click(self);
end;

procedure TForm1.UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
begin
  Button2Click(self);
end;

procedure TForm1.UpDown2Changing(Sender: TObject; var AllowChange: Boolean);
begin
  Button2Click(self);
end;

procedure ShadedTextOut( const Bitmap   : TBitmap;   // Graphic
                               Text   : String;      // Shader Text
                               Font   : TFont;       // Font Style
                               X,Y,                  // Position
                               DX,DY  : Integer      // Shadow offset.
                                     );
     type pColArray = ^TColArray;
          TColArray = Array[0..1439] of TColor;
      var MaskAND : TBitmap;
          MaskOR  : TBitmap;
          BmpDest   : TBitmap;
          Ht,Lg     : Integer;
          Pixels    : pColArray;
          NbrePix   : Integer;
begin
{$R-}
  if Text  = ''  then exit;
  if Bitmap   = nil then exit;
  if Font = nil then exit;

  MaskAND := TBitmap.Create;
  MaskOR  := TBitmap.Create;
  BmpDest   := TBitmap.Create;
  try
    MaskAND.Canvas.Brush.Color := clBlack;
    MaskAND.Canvas.Font        := Font;
    MaskAND.Canvas.Font.Color  := clWhite;
    Ht := DY + MaskAND.Canvas.TextHeight( Text );
    // Larger for italicized font.
    Lg := DX + MaskAND.Canvas.TextWidth ( Text ) + Ht div 2;
    // Must be divisible by 4 for a single Scanline.
    if Lg mod 4 <> 0 then Lg := Lg + ( 4 - Lg mod 4 );
    MaskAND.Width  := Lg;
    MaskAND.Height := Ht;
    MaskAND.Canvas.TextOut( DX, DY, Text );

    // To work with TColor.
    MaskOR.PixelFormat := pf32Bit;
    MaskOR.Width       := Lg;
    MaskOR.Height      := Ht;
    // MaskOR will contain the background of the original image...

    MaskOR.Canvas.CopyRect(MaskOR.Canvas.ClipRect,
                             Bitmap.Canvas,
                             Rect(X,Y,X+Lg,Y+Ht));

    // ...as well as BmpDest.
    BmpDest.Assign(MaskOR);

    {We copy the AND mask onto the OR mask using the AND operator.}
    BitBlt(MaskOR.Canvas.Handle,0,0,Lg,Ht,MaskAND.Canvas.Handle,0,0,SRCAND);

    {Destination BMP shading.}
    Pixels := MaskOR.ScanLine[Ht-1];

    for NbrePix := 1 to Lg*Ht do
        if Pixels[NbrePix] <> clBlack then
        Pixels[NbrePix] := GetShadowColor(Pixels[NbrePix]);


    // Invert the colors to obtain a new mask.
    BitBlt(MaskAND.Canvas.Handle,0,0,Lg,Ht,MaskAND.Canvas.Handle,0,0,DSTINVERT	);
    {Classic 2-step raster method.}
    // Copy of MaskAND onto BmpDest using the AND operator.
    BitBlt(BmpDest.Canvas.Handle,0,0,Lg,Ht,MaskAND.Canvas.Handle,0,0,SRCAND);
    // Copy of MaskOR onto BmpDest with the OR operator.
    BitBlt(BmpDest.Canvas.Handle,0,0,Lg,Ht,MaskOR.Canvas.Handle,0,0,SRCPAINT);

    {The shadow is drawn. Now, draw the colored text using the classic method.}
    MaskAND.Canvas.Brush.Color := clWhite;
    // Repaint in white.
    MaskAND.Canvas.FillRect(MaskAND.Canvas.ClipRect);
    MaskAND.Canvas.Font.Color := clBlack;
    // MaskAND = black text on a white background.
    MaskAND.Canvas.TextOut(0, 0, Text);

    MaskOR.Canvas.Brush.Color := clBlack;
    // Repaint in black.
    MaskOR.Canvas.FillRect(MaskOR.Canvas.ClipRect);
    MaskOR.Canvas.Font := Font;
    // MaskOR = colored text on a black background.
    MaskOR.Canvas.TextOut(0, 0, Text);
    // Classical Raster Method...
    BitBlt(BmpDest.Canvas.Handle,0,0,Lg,Ht,MaskAND.Canvas.Handle,0,0,SRCAND);
    // ... in 2 steps.
    BitBlt(BmpDest.Canvas.Handle,0,0,Lg,Ht,MaskOR.Canvas.Handle,0,0,SRCPAINT);
    // We put everything back on the original image.
    Bitmap.Canvas.CopyRect(Rect(X,Y,X+Lg,Y+Ht),BmpDest.Canvas,BmpDest.Canvas.ClipRect);
  finally
    BmpDest.Free;
    MaskOR.Free;
    MaskAND.free;
  end;
end;  

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
var
  Dx,Dy : Integer;
  Img   : TBitmap;
  s     : String;
begin
  {
  Img := (Sender as TImage).Picture.Bitmap;
  s   := Edit1.Text;
  Dx  := StrToInt(edtOmbreX.text);
  Dy  := StrToInt(edtOmbreY.text);
  ShadedTextOut( Img, s, FontDialog1.Font, X ,Y ,Dx ,Dy );
  }
end;

procedure TForm1.btnPoliceClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    Shape2.Brush.Color := FontDialog1.Font.Color;
    PreVisualiser(Sender);
    Edit1.Font := FontDialog1.Font;
    Edit1.Font.Size := 8;
    Edit1.Font.Color := clBlack;
    StatusBar1.Panels[1].Text := FontDialog1.Font.Name;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  bmp : TBitmap;
  GIF: TGIFImage;
  Ext: TGIFGraphicControlExtension;
begin
   if SaveDialog1.Execute then
   begin
    if SaveDialog1.FilterIndex = 1 then
    begin
      try
        bmp := TBitmap.Create;
        bmp.Assign(Image1.Picture.Bitmap);

        case ComboBox2.ItemIndex of
        0 : bmp.PixelFormat := pf4bit;
        1 : bmp.PixelFormat := pf8bit;
        2 : bmp.PixelFormat := pf24bit;
        3 : bmp.PixelFormat := pf32bit;
        end;

        if CheckBox2.Checked = true then
        begin
          bmp.TransparentColor := clBlack;
          bmp.Transparent := true;
        end;

        bmp.SaveToFile(SaveDialog1.FileName+ '.bmp');
      finally
        bmp.Free;
      end;
    end;

    if SaveDialog1.FilterIndex = 2 then
    begin
      try
        bmp := TBitmap.Create;
        bmp.Assign(Image1.Picture.Bitmap);

        case ComboBox2.ItemIndex of
        0 : bmp.PixelFormat := pf4bit;
        1 : bmp.PixelFormat := pf8bit;
        2 : bmp.PixelFormat := pf24bit;
        3 : bmp.PixelFormat := pf32bit;
        end;

        bmp.SaveToFile(ExtractFilePath(Application.ExeName) + 'Data\Backup\_.bmp');
        BitmapFileToPNG(ExtractFilePath(Application.ExeName) + 'Data\Backup\_.bmp',
                        SaveDialog1.FileName + '.png');
      finally
        bmp.Free;
      end;
    end;

    if SaveDialog1.FilterIndex = 3 then
    begin
      try
        bmp := TBitmap.Create;
        bmp.Assign(Image1.Picture.Bitmap);

        case ComboBox2.ItemIndex of
        0 : bmp.PixelFormat := pf4bit;
        1 : bmp.PixelFormat := pf8bit;
        2 : bmp.PixelFormat := pf24bit;
        3 : bmp.PixelFormat := pf32bit;
        end;

        // Convert bitmap to GIF
        GIF := TGIFImage.Create;
        GIF.Assign(bmp);

        if CheckBox2.Checked = true then
        begin
          // Create an extension to set the transparency flag
          Ext := TGIFGraphicControlExtension.Create(GIF.Images[0]);
          Ext.Transparent := True;

          // Set transparent color to lower left pixel color
          Ext.TransparentColorIndex := GIF.Images[0].Pixels[0, GIF.Height-1];

          // Set transparent color to lower left pixel color
          //Ext.TransparentColorIndex := GIF.Images[0].Pixels[0, GIF.Height-1];
        end;

        GIF.SaveToFile(SaveDialog1.FileName + '.gif');
      finally
        bmp.Free;
        GIF.Free;
      end;
    end;

    if SaveDialog1.FilterIndex = 4 then
    begin
      try
        bmp := TBitmap.Create;
        bmp.Assign(Image1.Picture.Bitmap);

        case ComboBox2.ItemIndex of
        0 : bmp.PixelFormat := pf4bit;
        1 : bmp.PixelFormat := pf8bit;
        2 : bmp.PixelFormat := pf24bit;
        3 : bmp.PixelFormat := pf32bit;
        end;

        if CheckBox2.Checked = true then
        begin
          bmp.TransparentColor := clBlack;
          bmp.Transparent := true;
        end;

        bmp.SaveToFile(ExtractFilePath(Application.ExeName) + 'Data\Backup\_.bmp');
        Bmp2Jpeg(ExtractFilePath(Application.ExeName) + 'Data\Backup\_.bmp',
                 SaveDialog1.FileName+ '.jpg');
      finally
        bmp.Free;
      end;
    end;

   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  s : string;
  Dx, Dy : integer;
  bmp : TBitmap;
  Color : TColor;
begin
  Image1.Picture.Graphic := nil;
  try
    bmp := TBitmap.Create;

    Image1.Picture.Bitmap.Height := SpinEdit3.Value;
    Image1.Picture.Bitmap.Width := SpinEdit4.Value;

    Color := HexToTColor(Edit2.Text);

    if CheckBox1.Checked = true then
    begin
      Image1.Canvas.Brush.Color := Color;
      Image1.Canvas.Rectangle( 0, 0, SpinEdit4.Value, SpinEdit3.Value);
    end else begin
      Image1.Canvas.Brush.Color := Color;
      Image1.Canvas.Rectangle( -1, -1, SpinEdit4.Value+1, SpinEdit3.Value+1);
    end;

    bmp := Image1.Picture.Bitmap;
    bmp.Height := SpinEdit3.Value;
    bmp.Width := SpinEdit4.Value;

    s   := Edit1.Text;
    Dx  := StrToInt(edtOmbreX.text);
    Dy  := StrToInt(edtOmbreY.text);
    ShadedTextOut( bmp, s, FontDialog1.Font, SpinEdit1.Value ,
                                             SpinEdit2.Value ,Dx ,Dy );
    except
  end;
  Image1.Invalidate;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Image1.Picture.Graphic := nil;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Antialiasing(Image1.Picture.Bitmap,
  Rect(0, 0, Image1.Picture.Bitmap.Width,
             Image1.Picture.Bitmap.Height),
             StrToInt(ComboBox1.Text));
  Image1.Invalidate;
  //Button2Click(self);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  Button2Click(self);
end;

procedure TForm1.ComboBox3Change(Sender: TObject);
begin
  case ComboBox3.ItemIndex of
  0 : FontDialog1.Font.Style := [];
  1 : FontDialog1.Font.Style := [fsItalic];
  2 : FontDialog1.Font.Style := [fsBold];
  3 : FontDialog1.Font.Style := [fsUnderline];
  end;
  Button2.Click;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  Shape1.Brush.Color := HexToTColor(Edit2.Text);
end;

end.
