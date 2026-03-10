import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import font_manager
import os

def plot_charts():
    # 1. 检查并创建 output 目录
    output_dir = 'output'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 2. 读取数据
    try:
        df = pd.read_csv('chart_data.csv')
    except FileNotFoundError:
        print("错误: 未找到 chart_data.csv，请先运行生成数据的代码。")
        return

    # 3. 设置字体路径 (根据你的目录结构)
    # simsun.ttf 用于中文显示
    font_path_cn = os.path.join('字体', 'simsun.ttf')
    # times.ttf 用于数字和英文显示 (可选，如果想让数字更像Times New Roman)
    font_path_en = os.path.join('字体', 'times.ttf')

    # 加载字体属性
    if os.path.exists(font_path_cn):
        prop_cn = font_manager.FontProperties(fname=font_path_cn, size=12)
        prop_title = font_manager.FontProperties(fname=font_path_cn, size=14)
    else:
        print(f"警告: 未找到字体文件 {font_path_cn}，将使用默认字体，中文可能乱码。")
        prop_cn = None
        prop_title = None
    
    if os.path.exists(font_path_en):
        prop_en = font_manager.FontProperties(fname=font_path_en, size=12)
    else:
        prop_en = prop_cn # 如果没有Times，回退到宋体

    # 4. 创建画布 (3行1列)
    # 调整figsize以匹配原图的长宽比
    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(6, 15), dpi=100)
    
    # 设置刻度字体为 Times New Roman 风格
    def set_tick_font(ax):
        if prop_en:
            for label in ax.get_xticklabels() + ax.get_yticklabels():
                label.set_fontproperties(prop_en)

    # ==========================
    # 子图 (a): SM2与ECDSA时间开销对比
    # ==========================
    # 绘制线条 (颜色顺序参考Matplotlib 2.0默认色: Blue, Orange, Green, Red)
    # 注意：原图中图例顺序与线条颜色需要对应
    # 原图线条颜色推测：
    # SM2 Sign: Blue, ECDSA Sign: Orange, SM2 Verify: Green, ECDSA Verify: Red
    
    ax1.plot(df['size_mb'], df['sm2_sign'], label='SM2 Sign Time', color='#4c72b0') # 蓝
    ax1.plot(df['size_mb'], df['ecdsa_sign'], label='ECDSA Sign Time', color='#dd8452') # 橙
    ax1.plot(df['size_mb'], df['sm2_verify'], label='SM2 Verify time', color='#55a868') # 绿
    ax1.plot(df['size_mb'], df['ecdsa_verify'], label='ECDSA Verify time', color='#c44e52') # 红

    ax1.set_ylim(4, 18) # 根据原图Y轴范围
    ax1.set_xlim(0.2, 1.2)
    ax1.set_ylabel('Time/ms', fontproperties=prop_en)
    ax1.set_xlabel('字节数/MB', fontproperties=prop_cn)
    
    # 图例
    ax1.legend(loc='center left', bbox_to_anchor=(0.02, 0.6), prop=prop_en, frameon=True, edgecolor='black')
    
    # 子图标题 (放在下方)
    ax1.set_title('(a) SM2与ECDSA时间开销对比', y=-0.25, fontproperties=prop_title)
    set_tick_font(ax1)

    # ==========================
    # 子图 (b): SM3与SHA256时间开销对比
    # ==========================
    ax2.plot(df['size_mb'], df['sm3_hash'], label='SM3 Hash Time', color='#4c72b0')
    ax2.plot(df['size_mb'], df['sha256_hash'], label='SHA256 Hash Time', color='#dd8452')
    ax2.plot(df['size_mb'], df['ration'], label='Ration', color='#55a868')

    ax2.set_ylim(0, 11)
    ax2.set_xlim(0.2, 1.2)
    ax2.set_ylabel('Time/ms', fontproperties=prop_en)
    ax2.set_xlabel('字节数/MB', fontproperties=prop_cn)
    
    ax2.legend(loc='upper left', prop=prop_en, frameon=True, edgecolor='black')
    ax2.set_title('(b) SM3与SHA256时间开销对比', y=-0.25, fontproperties=prop_title)
    set_tick_font(ax2)

    # ==========================
    # 子图 (c): 多次哈希时间开销对比
    # ==========================
    ax3.plot(df['op_count'], df['multi_sm3'], label='0.63 MB SM3 Hash Time', color='#4c72b0')
    ax3.plot(df['op_count'], df['multi_sha256'], label='0.6 MB SHA256 Hash Time', color='#dd8452')

    ax3.set_ylim(0, 34)
    ax3.set_xlim(1, 6)
    ax3.set_ylabel('Time/ms', fontproperties=prop_en)
    ax3.set_xlabel('总操作次数', fontproperties=prop_cn)
    
    ax3.legend(loc='upper left', prop=prop_en, frameon=True, edgecolor='black')
    ax3.set_title('(c) 多次哈希时间开销对比', y=-0.25, fontproperties=prop_title)
    set_tick_font(ax3)

    # ---------------------------------------------------------
    # 调整布局与保存
    # ---------------------------------------------------------
    plt.subplots_adjust(hspace=0.4) # 增加子图垂直间距以容纳下方标题
    plt.tight_layout()
    # 因为tight_layout可能会移动标题，再次微调边距确保标题不被切掉
    plt.subplots_adjust(bottom=0.08, hspace=0.35)

    save_path = os.path.join(output_dir, 'comparison_chart.png')
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    print(f"图片已生成并保存至: {os.path.abspath(save_path)}")
    plt.close()

if __name__ == "__main__":
    plot_charts()