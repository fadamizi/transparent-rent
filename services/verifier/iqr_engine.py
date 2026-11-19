from typing import List, Dict

def evaluate_rent_outlier(new_rent: int, history_rents: List[int]) -> Dict:
    if len(history_rents) < 3:
        return {"status": "VERIFIED", "deviation": 0.0, "msg": "种子样本直接入库"}
    s = sorted(history_rents)
    n = len(s)
    avg = sum(s) / n
    q1, q3 = s[int(n * 0.25)], s[int(n * 0.75)]
    iqr = max(q3 - q1, avg * 0.15)
    low, high = max(500, int(q1 - 1.5 * iqr)), int(q3 + 1.5 * iqr)
    dev = round((new_rent - avg) / avg * 100, 1)
    if new_rent < low or new_rent > high:
        return {"status": "PENDING", "deviation": dev, "msg": f"超出正常区间[{low}~{high}]，进人工复核"}
    return {"status": "VERIFIED", "deviation": dev, "msg": "符合同小区真实成交区间"}
