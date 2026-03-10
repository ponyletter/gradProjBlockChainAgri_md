import pandas as pd
import numpy as np
import os

def generate_csv():

    
    data = {
        # --- 公共 X 轴 (图 a 和 b) ---
        'size_mb': [0.2, 0.4, 0.6, 0.8, 1.0, 1.2],
        
        # --- 图 (a) 数据 ---
        # SM2 Verify (绿色): 约 18ms, 中间微降
        'sm2_verify': [17.9, 17.7, 17.7, 17.8, 17.9, 17.95],
        # ECDSA Verify (红色): 约 14ms (平稳)
        'ecdsa_verify': [13.9, 13.9, 13.9, 13.9, 13.9, 13.9],
        # ECDSA Sign (橙色): 约 8.4ms (平稳)
        'ecdsa_sign': [8.4, 8.4, 8.4, 8.4, 8.4, 8.4],
        # SM2 Sign (蓝色): 约 4ms (平稳)
        'sm2_sign': [4.0, 4.0, 4.0, 3.9, 3.9, 4.0],
        
        # --- 图 (b) 数据 ---
        # SM3 Hash (蓝色): 线性上升, 0.2MB~2ms -> 1.2MB~11ms
        'sm3_hash': [1.8, 4.0, 5.8, 7.8, 8.8, 10.9],
        # SHA256 Hash (橙色): 线性上升, 0.2MB~0.5ms -> 1.2MB~3ms
        'sha256_hash': [0.45, 1.0, 1.45, 1.95, 2.4, 2.95],
        # Ration (绿色): 约 4.0, 后期微降
        'ration': [3.95, 3.92, 3.90, 3.88, 3.6, 3.65],
        
        # --- 图 (c) 数据 ---
        # X 轴: 操作次数
        'op_count': [1, 2, 3, 4, 5, 6],
        # 0.6 MB SHA256 Hash (橙色): 1次~6ms -> 6次~33ms
        'multi_sha256': [6.0, 11.0, 16.5, 22.0, 26.0, 33.0],
        # 0.63 MB SM3 Hash (蓝色): 1次~1.5ms -> 6次~8ms
        'multi_sm3': [1.5, 3.0, 4.0, 6.0, 7.0, 8.0]
    }
    
    df = pd.DataFrame(data)
    
    # 保存 CSV
    csv_filename = 'chart_data.csv'
    df.to_csv(csv_filename, index=False, encoding='utf-8')
    print(f"成功生成数据文件: {os.path.abspath(csv_filename)}")
    print(df)

if __name__ == "__main__":
    generate_csv()