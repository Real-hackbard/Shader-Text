# Shader-Text

</br>

![Compiler](https://github.com/user-attachments/assets/a916143d-3f1b-4e1f-b1e0-1067ef9e0401) ![10 Seattle](https://github.com/user-attachments/assets/c70b7f21-688a-4239-87c9-9a03a8ff25ab) ![10 1 Berlin](https://github.com/user-attachments/assets/bdcd48fc-9f09-4830-b82e-d38c20492362) ![10 2 Tokyo](https://github.com/user-attachments/assets/5bdb9f86-7f44-4f7e-aed2-dd08de170bd5) ![10 3 Rio](https://github.com/user-attachments/assets/e7d09817-54b6-4d71-a373-22ee179cd49c)  ![10 4 Sydney](https://github.com/user-attachments/assets/e75342ca-1e24-4a7e-8fe3-ce22f307d881) ![11 Alexandria](https://github.com/user-attachments/assets/64f150d0-286a-4edd-acab-9f77f92d68ad) ![12 Athens](https://github.com/user-attachments/assets/59700807-6abf-4e6d-9439-5dc70fc0ceca)  
![Components](https://github.com/user-attachments/assets/d6a7a7a4-f10e-4df1-9c4f-b4a1a8db7f0e) ![None](https://github.com/user-attachments/assets/30ebe930-c928-4aaf-a8e1-5f68ec1ff349)  
![Description](https://github.com/user-attachments/assets/dbf330e0-633c-4b31-a0ef-b1edb9ed5aa7) ![Shader Text](https://github.com/user-attachments/assets/cdd03c33-1be0-4382-a70f-9426efbda2a3)  
![Last Update](https://github.com/user-attachments/assets/e1d05f21-2a01-4ecf-94f3-b7bdff4d44dd) ![032026](https://github.com/user-attachments/assets/0fc2f280-2ec1-45b1-8947-57bfc6683ea0)  
![License](https://github.com/user-attachments/assets/ff71a38b-8813-4a79-8774-09a2f3893b48) ![Freeware](https://github.com/user-attachments/assets/1fea2bbf-b296-4152-badd-e1cdae115c43)  

</br>

TrueType is an outline font standard developed by Apple in the late 1980s as a competitor to Adobe's Type 1 fonts used in PostScript. It has become the most common format for fonts on the classic Mac OS, macOS, and Microsoft Windows operating systems.

</br>

![ShaderText](https://github.com/user-attachments/assets/31fabb01-3278-462b-aff9-647c1d91d796)

</br>

The primary strength of TrueType was originally that it offered [font](https://en.wikipedia.org/wiki/Font) developers a high degree of control over precisely how their fonts are displayed, right down to particular [pixels](https://en.wikipedia.org/wiki/Pixel), at various font sizes. With widely varying [rendering](https://en.wikipedia.org/wiki/Rendering_(computer_graphics)) technologies in use today, pixel-level control is no longer certain in a TrueType font.

</br>

# Where can I get TTF files?
* https://www.fontspace.com/category/ttf
* http://www.myfont.de/fonts/alphabet/ttf-fonts-S.html
* https://fontdrop.info/#/?darkmode=true
* https://font.download/search/Ttf
* https://www.fontsquirrel.com/fonts/list/popular
* https://www.1001freefonts.com/
* https://www.dafont.com/ttf.d592

# Editors:
* https://www.glyphrstudio.com/
* https://fontforge.org/en-US/
* https://www.birdfont.org/
* https://www.calligraphr.com/de/

</br>

Here is my selection of Graffiti fonts that I use :  
https://mega.nz/file/cKoXVArR#GmV-Nay9MJXqcPBiyd-mlsOMZI1E9Z-CwyoBrSZ7tUI

</br>

# Fragment-Shader:
Fragment shaders, also known as pixel shaders, compute color and other attributes of each "fragment": a unit of rendering work affecting at most a single output pixel. The simplest kinds of pixel shaders output one screen pixel as a color value; more complex shaders with multiple inputs/outputs are also possible. Pixel shaders range from simply always outputting the same color, to applying a lighting value, to doing bump mapping, [shadows](https://en.wikipedia.org/wiki/Shadow), specular highlights, translucency and other phenomena. They can alter the depth of the fragment (for Z-buffering), or output more than one color if multiple render targets are active.

</br>

```pascal
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
```








