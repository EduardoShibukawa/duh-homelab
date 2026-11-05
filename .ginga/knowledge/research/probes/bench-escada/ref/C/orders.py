SHIPPING_ABROAD = 90


def _validate(o):
    if not o.get("id"):
        return "missing id"
    items = o.get("items") or []
    if not items:
        return "no items"
    if any(it["qty"] <= 0 or it["price"] < 0 for it in items):
        return "bad item"
    return None


def _discount(o, subtotal):
    units = sum(it["qty"] for it in o["items"])
    d = subtotal * 0.10 if units >= 10 else subtotal * 0.05 if units >= 5 else 0
    coupon = o.get("coupon")
    if coupon == "WELCOME":
        d += 10
    elif coupon == "VIP":
        d += subtotal * 0.15
    return min(d, subtotal)


def _shipping(o, net):
    if o.get("coupon") == "FRETEGRATIS":
        return 0
    country = o.get("country", "BR")
    if country == "BR":
        return 0 if net >= 200 else 20
    return 45 if country in ("AR", "UY", "PY") else SHIPPING_ABROAD


def _summary(o):
    subtotal = sum(it["price"] * it["qty"] for it in o["items"])
    discount = _discount(o, subtotal)
    shipping = _shipping(o, subtotal - discount)
    return {"id": o["id"], "status": "ok", "subtotal": round(subtotal, 2),
            "discount": round(discount, 2), "shipping": shipping,
            "total": round(subtotal - discount + shipping, 2)}


def process_orders(orders):
    """Processa pedidos e devolve um resumo por pedido."""
    results = []
    for o in orders:
        reason = _validate(o)
        if reason:
            results.append({"id": o.get("id") or None, "status": "invalid", "reason": reason})
        else:
            results.append(_summary(o))
    return results
