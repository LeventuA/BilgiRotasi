from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

OUT = Path('assets/word_hunt/baslangic_limani')
OUT.mkdir(parents=True, exist_ok=True)
S, Q, N = 256, 4, 1024

def c(value, alpha=255):
    value = value.lstrip('#')
    return tuple(int(value[i:i+2], 16) for i in (0, 2, 4)) + (alpha,)

def ellipse(draw, box, fill, outline=None, width=1):
    draw.ellipse(tuple(v * Q for v in box), fill=fill, outline=outline, width=width * Q)

def medal(challenge):
    image = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    glow = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((12*Q, 12*Q, 244*Q, 244*Q), fill=c('#F2A51A' if challenge else '#FFD34E', 95))
    image.alpha_composite(glow.filter(ImageFilter.GaussianBlur(9*Q)))
    d = ImageDraw.Draw(image)
    palette = ('#A65B09','#F5A623','#7B4A0B','#FFC64A','#3B1B05','#251405','#F5B93F') if challenge else ('#8A6511','#FFD45A','#8E6A14','#F1BE31','#46370A','#2A2306','#E8B82C')
    ellipse(d,(18,18,238,238),c(palette[0]),c('#4B2B08'),4)
    ellipse(d,(27,27,229,229),c(palette[1]),c('#FFE29A'),3)
    ellipse(d,(37,37,219,219),c(palette[2]),c('#4B2B08'),2)
    ellipse(d,(45,45,211,211),c(palette[3]),c('#FFF0B7'),3)
    ellipse(d,(57,57,199,199),c(palette[4]),c('#7A4B0A'),2)
    ellipse(d,(64,64,192,192),c(palette[5]),c(palette[6]),2)
    for i in range(12):
        a = 2*math.pi*i/12-math.pi/2
        x, y = 128+94*math.cos(a), 128+94*math.sin(a)
        d.ellipse(((x-3)*Q,(y-3)*Q,(x+3)*Q,(y+3)*Q),fill=c('#FFE7A3'),outline=c('#7B4708'),width=Q)
    return image.resize((S,S), Image.Resampling.LANCZOS)

def star(cx, cy, outer, inner):
    pts=[]
    for i in range(8):
        r = outer if i%2 == 0 else inner
        a = -math.pi/2+i*math.pi/4
        pts.append(((cx+math.cos(a)*r)*Q,(cy+math.sin(a)*r)*Q))
    return pts

def book():
    image = Image.new('RGBA',(N,N),(0,0,0,0))
    glow = Image.new('RGBA',(N,N),(0,0,0,0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((12*Q,12*Q,244*Q,244*Q),fill=c('#EFB93F',90))
    image.alpha_composite(glow.filter(ImageFilter.GaussianBlur(9*Q)))
    d = ImageDraw.Draw(image)
    ellipse(d,(17,17,239,239),c('#3C2A08'),c('#1E1505'),4)
    ellipse(d,(25,25,231,231),c('#E2B23E'),c('#FFF0B5'),3)
    ellipse(d,(34,34,222,222),c('#12202B'),c('#6F4A12'),3)
    ellipse(d,(43,43,213,213),c('#0B151D'),c('#F1C85E'),2)
    for i in range(10):
        a=2*math.pi*i/10-math.pi/2
        x,y=128+91*math.cos(a),128+91*math.sin(a)
        d.ellipse(((x-2.3)*Q,(y-2.3)*Q,(x+2.3)*Q,(y+2.3)*Q),fill=c('#FFE8A6'))
    left=[(67,80),(104,73),(126,84),(126,157),(104,146),(70,153)]
    right=[(128,84),(151,73),(190,80),(184,153),(151,146),(128,157)]
    d.polygon([(x*Q,y*Q) for x,y in left],fill=c('#FFF1C9'),outline=c('#8D651C'))
    d.polygon([(x*Q,y*Q) for x,y in right],fill=c('#FFF5D8'),outline=c('#8D651C'))
    d.line((127*Q,84*Q,127*Q,157*Q),fill=c('#A77A28'),width=2*Q)
    for y in (112,124,136): d.line((137*Q,y*Q,177*Q,y*Q),fill=c('#C8A96C',150),width=Q)
    d.polygon([(160*Q,73*Q),(176*Q,76*Q),(174*Q,116*Q),(166*Q,108*Q),(158*Q,116*Q)],fill=c('#7A2FB5'),outline=c('#C88EF1'))
    font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf',54*Q)
    box=d.textbbox((0,0),'A',font=font); w,h=box[2]-box[0],box[3]-box[1]
    d.text((97*Q-w/2,109*Q-h/2-5*Q),'A',font=font,fill=c('#5A3812'))
    d.polygon(star(151,118,10,3.3),fill=c('#F2C746'),outline=c('#7A2FB5'))
    d.rounded_rectangle((75*Q,158*Q,181*Q,174*Q),radius=7*Q,fill=c('#6F2FA8'),outline=c('#D69CF4'),width=Q)
    return image.resize((S,S), Image.Resampling.LANCZOS)

for name, image in {'node_challenge.webp':medal(True),'node_final.webp':medal(False),'book_button.webp':book()}.items():
    image.save(OUT/name,'WEBP',lossless=True,method=6)
    print(name,(OUT/name).stat().st_size)
