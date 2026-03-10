# -*- coding: utf-8 -*-
"""
中国苹果产量及增速图（2014-2024年）
参考样式：粉色柱状图 + 绿色折线图，双Y轴
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
from matplotlib import rcParams

# ── 字体设置（Windows 中文环境）──────────────────────────────────────────────
rcParams['font.family'] = 'Noto Sans CJK SC'  # 沙箱中文字体（Windows请改为 SimHei）
rcParams['axes.unicode_minus'] = False  # 负号正常显示

# ── 读取数据 ──────────────────────────────────────────────────────────────────
df = pd.read_csv('apple_production.csv', encoding='utf-8-sig')
df.columns = ['年份', '产量', '增速']

years   = df['年份'].astype(str) + '年'   # 横轴标签：2014年…2024年
output  = df['产量'].values               # 苹果产量（万吨）
growth  = df['增速'].values               # 产量增速（%），2014年为 NaN

# ── 画布与双轴 ────────────────────────────────────────────────────────────────
fig, ax1 = plt.subplots(figsize=(13, 6))
ax2 = ax1.twinx()

# ── 柱状图（左轴：产量）──────────────────────────────────────────────────────
bar_color  = '#F9B8C8'   # 粉色填充
edge_color = '#E07090'   # 粉色边框
x = range(len(years))
bars = ax1.bar(x, output, width=0.55,
               color=bar_color, edgecolor=edge_color, linewidth=0.8,
               label='苹果产量（万吨）', zorder=2)

# 柱顶数值标注
for bar, val in zip(bars, output):
    ax1.text(bar.get_x() + bar.get_width() / 2,
             bar.get_height() + 30,
             f'{val:.2f}',
             ha='center', va='bottom', fontsize=8.5, color='#333333')

# ── 折线图（右轴：增速）──────────────────────────────────────────────────────
line_color = '#3CB371'   # 绿色
# 只绘制有增速数据的点（跳过2014年 NaN）
valid_idx    = [i for i, g in enumerate(growth) if not pd.isna(g)]
valid_growth = [growth[i] for i in valid_idx]

ax2.plot(valid_idx, valid_growth,
         color=line_color, marker='o', markersize=6,
         linewidth=1.8, label='增速（%）', zorder=3)

# 折线点数值标注
for i, g in zip(valid_idx, valid_growth):
    offset = 0.15 if g >= 0 else -0.45
    ax2.text(i, g + offset, f'{g:.1f}',
             ha='center', va='bottom', fontsize=8.5, color=line_color)

# ── 轴范围与刻度 ──────────────────────────────────────────────────────────────
ax1.set_ylim(0, 6200)
ax1.yaxis.set_major_locator(mticker.MultipleLocator(1000))
ax2.set_ylim(-8, 11)
ax2.yaxis.set_major_locator(mticker.MultipleLocator(2))

# ── 轴标签 ────────────────────────────────────────────────────────────────────
ax1.set_ylabel('苹果产量（万吨）', fontsize=11)
ax2.set_ylabel('增速（%）',        fontsize=11)
ax1.set_xlabel('年份',             fontsize=11)

# ── 横轴刻度 ──────────────────────────────────────────────────────────────────
ax1.set_xticks(list(x))
ax1.set_xticklabels(years, fontsize=10)

# ── 参考线（增速=0）──────────────────────────────────────────────────────────
ax2.axhline(0, color='gray', linewidth=0.6, linestyle='--', zorder=1)

# ── 图例 ──────────────────────────────────────────────────────────────────────
handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(handles1 + handles2, labels1 + labels2,
           loc='upper left', fontsize=10, framealpha=0.9)

# ── 网格与边框 ────────────────────────────────────────────────────────────────
ax1.yaxis.grid(True, linestyle='--', linewidth=0.5, color='#DDDDDD', zorder=0)
ax1.set_axisbelow(True)
for spine in ['top']:
    ax1.spines[spine].set_visible(False)

# ── 标题 ──────────────────────────────────────────────────────────────────────
plt.title('2014—2024年中国苹果产量及增速', fontsize=13, pad=12)

plt.tight_layout()
plt.savefig('apple_production_2014_2024.png', dpi=200, bbox_inches='tight')
plt.show()
print("图表已保存为 apple_production_2014_2024.png")
