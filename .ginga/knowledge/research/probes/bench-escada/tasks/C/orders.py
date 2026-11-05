def process_orders(orders):
    """Processa pedidos e devolve um resumo por pedido."""
    results = []
    for o in orders:
        oid = o.get("id")
        if not oid:
            results.append({"id": None, "status": "invalid", "reason": "missing id"})
            continue
        items = o.get("items") or []
        if len(items) == 0:
            results.append({"id": oid, "status": "invalid", "reason": "no items"})
            continue
        invalid = False
        for it in items:
            if it["qty"] <= 0 or it["price"] < 0:
                invalid = True
        if invalid:
            results.append({"id": oid, "status": "invalid", "reason": "bad item"})
            continue
        subtotal = 0
        units = 0
        for it in items:
            subtotal += it["price"] * it["qty"]
            units += it["qty"]
        discount = 0
        if units >= 10:
            discount = subtotal * 0.10
        elif units >= 5:
            discount = subtotal * 0.05
        coupon = o.get("coupon")
        if coupon == "WELCOME":
            discount += 10
        elif coupon == "VIP":
            discount += subtotal * 0.15
        if discount > subtotal:
            discount = subtotal
        net = subtotal - discount
        country = o.get("country", "BR")
        if country == "BR":
            if net >= 200:
                shipping = 0
            else:
                shipping = 20
        elif country in ("AR", "UY", "PY"):
            shipping = 45
        else:
            shipping = 90
        total = net + shipping
        results.append({
            "id": oid,
            "status": "ok",
            "subtotal": round(subtotal, 2),
            "discount": round(discount, 2),
            "shipping": shipping,
            "total": round(total, 2),
        })
    return results
