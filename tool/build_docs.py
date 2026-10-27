"""Build the portable screenshot index from captured app images and Pixso IDs."""
from pathlib import Path
import html
import json
import re
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'
SHOTS = DOCS / 'screenshots'

def read_theme(name):
    nodes = json.loads((DOCS / 'design' / f'{name}.json').read_text(encoding='utf-8-sig'))['nodes']
    return {int(n['name'].split('_')[0]): n for n in nodes if re.match(r'^\d+_', n['name'])}

def module(n):
    if n <= 5: return 'onboarding/onboarding_pages.dart'
    if n <= 23: return 'market/market_pages.dart'
    if n <= 31: return 'statistics/statistics_page.dart'
    if n <= 35 or 58 <= n <= 65: return 'profile/profile_pages.dart'
    if 49 <= n <= 51 or n == 53 or 69 <= n <= 71: return 'nft/create_pages.dart'
    if n <= 57: return 'nft/nft_pages.dart'
    return 'account/account_pages.dart'

def main():
    light, dark = read_theme('light'), read_theme('dark')
    rows = ['# Pixso 画板与 Flutter UI 对照表', '',
            '原文件：**Ossea - NFT Marketplace App UI Kit**。浅色和深色按相同编号配对，共 81 组。', '',
            '应用中通过 **More → Explore All Screens** 进入编号页面。完整页和适配页共用可滚动内容；弹窗编号在进入后显示相应弹窗。', '',
            '下列截图为 Android 模拟器中的 Flutter 运行截图。长图为相同生产组件的完整内容渲染。页面的收藏、购买和关注标签会随本地记录显示相应内容或空状态。', '',
            '| 编号 | Pixso 浅色画板名称 | 浅色 / 深色节点 | Flutter 路由 | 模块 | 运行截图 | 完整内容 |',
            '| --- | --- | --- | --- | --- | --- | --- |']
    cards = []
    for i in range(1,82):
        name = light[i]['name'].split('_',2)[-1]
        long_file = SHOTS / 'long' / f'light-{i:02}.png'
        full = f'[浅色](screenshots/long/light-{i:02}.png) · [深色](screenshots/long/dark-{i:02}.png)' if long_file.exists() else '—'
        rows.append(f'| {i:02} | {name} | `{light[i]["id"]}` / `{dark[i]["id"]}` | `/screen/{i}` | [{module(i)}](../lib/features/{module(i)}) | [浅色](screenshots/light/{i:02}.png) · [深色](screenshots/dark/{i:02}.png) | {full} |')
        for theme in ('light','dark'):
            file = f'{theme}/{i:02}.png'
            title = f'{i:02} · {name}'
            cards.append(f'<a class="card" data-theme="{theme}" data-name="{html.escape(title.lower(),quote=True)}" href="{file}" target="_blank"><img loading="lazy" src="{file}" alt="{html.escape(title,quote=True)}"><span>{html.escape(title)}<small>{theme}</small></span></a>')
    (DOCS / 'UI_COVERAGE.md').write_text('\n'.join(rows)+'\n',encoding='utf-8')
    gallery = '''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ossea · 页面截图</title><style>
body{margin:0;padding:32px;background:#f3f3f8;color:#212121;font:15px system-ui,sans-serif}header{max-width:1400px;margin:auto auto 28px}h1{font-size:32px;margin:0 0 8px}p{color:#707070}nav{display:flex;gap:12px;flex-wrap:wrap;align-items:center}button,input{padding:12px 18px;border:1px solid #d8d8e5;border-radius:12px;background:white;font:inherit}button{cursor:pointer}button.active{background:#5146ff;color:white;border-color:#5146ff}main{max-width:1400px;margin:auto;display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:22px}.card{display:block;text-decoration:none;color:inherit;background:white;border-radius:18px;overflow:hidden;box-shadow:0 3px 18px #2221}.card img{width:100%;display:block;aspect-ratio:1126/2436;object-fit:contain}.card span{display:block;padding:15px;line-height:1.5}.card small{display:block;color:#858585}.card[hidden]{display:none}a:focus,button:focus,input:focus{outline:3px solid #8f86ff}footer{max-width:1400px;margin:30px auto;color:#777}
</style><header><h1>Ossea · 页面截图</h1><p>81 个画板状态 × 浅色 / 深色主题 · Android 模拟器实际运行截图。点击图片查看原图。</p><nav><button class="active" data-filter="light">浅色</button><button data-filter="dark">深色</button><button data-filter="all">全部</button><input id="search" placeholder="搜索编号或页面名称" aria-label="搜索截图"><a href="../UI_COVERAGE.md">画板对照表</a><a href="../../README.md">项目说明</a></nav></header><main>'''+''.join(cards)+'''</main><footer>完整滚动内容长图另存于 long/。参考设计图在 ../design/，与应用运行截图分开保存。</footer><script>
let theme='light';function refresh(){const q=document.querySelector('#search').value.toLowerCase();document.querySelectorAll('.card').forEach(c=>c.hidden=(theme!=='all'&&c.dataset.theme!==theme)||!c.dataset.name.includes(q));}document.querySelectorAll('button').forEach(b=>b.onclick=()=>{theme=b.dataset.filter;document.querySelectorAll('button').forEach(x=>x.classList.toggle('active',x===b));refresh();});document.querySelector('#search').oninput=refresh;refresh();</script></html>'''
    (SHOTS / 'index.html').write_text(gallery,encoding='utf-8')
    previews=[('light/07','Home'),('light/40','NFT Details'),('light/63','Profile'),('dark/07','Dark Home'),('light/67','Wallet'),('light/74','Settings')]
    board=Image.new('RGB',(1284,1900),'#e9e9ee'); draw=ImageDraw.Draw(board)
    for i,(file,label) in enumerate(previews):
        with Image.open(SHOTS/f'{file}.png') as im:
            board.paste(im.convert('RGB').resize((400,866),Image.Resampling.LANCZOS),(14+(i%3)*428,40+(i//3)*940))
        draw.text((14+(i%3)*428,18+(i//3)*940),label,fill='#212121')
    board.save(SHOTS/'overview.png')
    print(f'Indexed {len(cards)} device screenshots and {len(list((SHOTS/"long").glob("*.png")))} long captures.')

if __name__=='__main__': main()
