"""Builds every app icon of "Con Nước" from one master drawing.

Chrome renders each variant once at 1024 px; Pillow downsizes (LANCZOS).
Usage: python make_icons.py <repo_root>
"""
import json
import os
import subprocess
import sys
import tempfile

from PIL import Image

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
NAVY, TEAL, IVORY, GOLD = '#0B3954', '#3FC1C9', '#F4F1EA', '#F2C14E'

# Artwork on a 240 grid. The moon is a real crescent (mask), so it also works
# on a transparent foreground (Android adaptive icon) and as a silhouette.
def art(moon=GOLD, wave1=TEAL, wave2=IVORY, line=IVORY, fish=IVORY, eye=NAVY):
    """The crescent moon IS the hook: it hangs from a fishing line by its eye,
    its lower tip ends in a sharp point; the tide runs below."""
    return f'''
  <defs><mask id="m"><rect x="-20" y="-20" width="280" height="280" fill="white"/>
    <circle cx="140" cy="82" r="47" fill="black"/></mask></defs>
  <path d="M114.9 -6 V33" stroke="{line}" stroke-width="3.2" stroke-linecap="round"/>
  <circle cx="114.9" cy="37.6" r="4.6" fill="none" stroke="{moon}" stroke-width="3.4"/>
  <circle cx="120" cy="98" r="56" fill="{moon}" mask="url(#m)"/>
  <path d="M162 128 Q 180 121 179 98" fill="none" stroke="{moon}" stroke-width="7" stroke-linecap="round"/>
  <path d="M179 97 L 171.5 104.5" fill="none" stroke="{moon}" stroke-width="5" stroke-linecap="round"/>
  <g transform="translate(146 72) rotate(213) scale(1.02 -1.02)">
    <path d="M-5 -10.5 L 4 -18 L 10 -8.8 Z" fill="{fish}"/>
    <path d="M-24 0 C -20 -9.5, -5 -12.5, 8 -9.5 C 14 -8, 18 -5, 20 -2.2 L 20 2.2 C 18 5, 14 8, 8 9.5 C -5 12.5, -20 9.5, -24 0 Z" fill="{fish}"/>
    <path d="M18.5 -1.2 L 31 -12.5 Q 26 0 31 12.5 L 18.5 1.2 Z" fill="{fish}"/>
    <path d="M-12 -8.6 Q -10 0 -12 8.6" fill="none" stroke="{eye}" stroke-width="1.4" stroke-linecap="round"/>
    <circle cx="-17.8" cy="-2.6" r="1.9" fill="{eye}"/>
  </g>
  <path d="M36 176 C 62 158, 88 158, 112 176 S 164 194, 204 172" fill="none" stroke="{wave1}" stroke-width="12" stroke-linecap="round"/>
  <path d="M62 200 C 82 188, 100 188, 120 200 S 158 212, 180 198" fill="none" stroke="{wave2}" stroke-width="9" stroke-linecap="round"/>'''

def svg(body, bg=None, scale=1.0, rounded=False):
    """Square SVG: optional background, artwork scaled about the centre."""
    off = 120 * (1 - scale)
    back = ''
    if bg:
        back = f'<rect width="240" height="240" rx="{54 if rounded else 0}" fill="{bg}"/>'
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">{back}'
            f'<g transform="translate({off} {off}) scale({scale})">{body}</g></svg>')

VARIANTS = {
    # Opaque square: iOS (the system rounds it), Play Store 512, legacy Android.
    'full': svg(art(), bg=NAVY),
    # Rounded: web favicon, docs.
    'rounded': svg(art(), bg=NAVY, rounded=True),
    # Android adaptive foreground: 108 dp canvas, keep art in the 66 dp circle.
    'foreground': svg(art(), scale=0.62),
    # Android 13 themed icon: one-colour silhouette, same safe zone.
    'monochrome': svg(art('#fff', '#fff', '#fff', '#fff', '#fff', 'none'), scale=0.62),
    # Web maskable: art inside the 80 % safe zone on the navy square.
    'maskable': svg(art(), bg=NAVY, scale=0.8),
    # Status-bar notification icon: white silhouette, waves + moon only (reads at 24 px).
    'notification': svg(art('#fff', '#fff', '#fff', 'none', '#fff', 'none'), scale=1.08),
}

def render(name, svg_text, out_dir):
    html = os.path.join(out_dir, f'{name}.html')
    with open(html, 'w', encoding='utf-8') as f:
        f.write('<!doctype html><html><head><style>html,body{margin:0;background:transparent}'
                'svg{display:block;width:1024px;height:1024px}</style></head><body>'
                + svg_text + '</body></html>')
    png = os.path.join(out_dir, f'{name}.png')
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
                    '--force-device-scale-factor=1', '--default-background-color=00000000',
                    f'--window-size=1024,1024', f'--screenshot={png}', 'file:///' + html.replace('\\', '/')],
                   check=True, capture_output=True)
    img = Image.open(png).convert('RGBA')
    assert img.size == (1024, 1024), (name, img.size)
    return img

def save(img, path, size, opaque=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if opaque:  # App Store / Play: no alpha channel at all
        bg = Image.new('RGB', out.size, NAVY)
        bg.paste(out, mask=out.split()[3])
        out = bg
    out.save(path, optimize=True)  # Pillow writes no EXIF/metadata

def main(repo):
    app = os.path.join(repo, 'app')
    with tempfile.TemporaryDirectory() as tmp:
        imgs = {k: render(k, v, tmp) for k, v in VARIANTS.items()}
    brand = os.path.join(repo, 'docs', 'brand')
    for k, v in VARIANTS.items():
        open(os.path.join(brand, f'icon-{k}.svg'), 'w', encoding='utf-8').write(v)
    save(imgs['full'], os.path.join(brand, 'play-store-icon-512.png'), 512, opaque=True)
    save(imgs['full'], os.path.join(brand, 'app-store-icon-1024.png'), 1024, opaque=True)

    res = os.path.join(app, 'android', 'app', 'src', 'main', 'res')
    for d, px in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        save(imgs['full'], os.path.join(res, f'mipmap-{d}', 'ic_launcher.png'), px)
        fg = round(px * 108 / 48)
        save(imgs['foreground'], os.path.join(res, f'mipmap-{d}', 'ic_launcher_foreground.png'), fg)
        save(imgs['monochrome'], os.path.join(res, f'mipmap-{d}', 'ic_launcher_monochrome.png'), fg)
        save(imgs['notification'], os.path.join(res, f'drawable-{d}', 'ic_stat_con_nuoc.png'), px // 2)

    icon_set = os.path.join(app, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
    for entry in json.load(open(os.path.join(icon_set, 'Contents.json'), encoding='utf-8'))['images']:
        name = entry.get('filename')
        if not name:
            continue
        pt = float(entry['size'].split('x')[0])
        px = round(pt * int(entry['scale'].rstrip('x')))
        save(imgs['full'], os.path.join(icon_set, name), px, opaque=True)

    web = os.path.join(app, 'web')
    save(imgs['rounded'], os.path.join(web, 'favicon.png'), 64)
    save(imgs['full'], os.path.join(web, 'icons', 'Icon-192.png'), 192)
    save(imgs['full'], os.path.join(web, 'icons', 'Icon-512.png'), 512)
    save(imgs['maskable'], os.path.join(web, 'icons', 'Icon-maskable-192.png'), 192)
    save(imgs['maskable'], os.path.join(web, 'icons', 'Icon-maskable-512.png'), 512)
    save(imgs['full'], os.path.join(web, 'icons', 'apple-touch-icon.png'), 180, opaque=True)
    print('icons written')

if __name__ == '__main__':
    main(sys.argv[1])
