import unittest
from orders import process_orders


def order(oid="o1", items=None, **kw):
    d = {"id": oid, "items": items if items is not None else [{"sku": "a", "price": 50, "qty": 2}]}
    d.update(kw)
    return d


class OrdersTests(unittest.TestCase):
    def one(self, o):
        r = process_orders([o])
        self.assertEqual(len(r), 1)
        return r[0]

    def test_empty(self):
        self.assertEqual(process_orders([]), [])

    def test_simple_ok_pays_shipping_br(self):
        self.assertEqual(self.one(order()), {"id": "o1", "status": "ok", "subtotal": 100, "discount": 0, "shipping": 20, "total": 120})

    def test_missing_id(self):
        self.assertEqual(self.one({"items": [{"sku": "a", "price": 1, "qty": 1}]}),
                         {"id": None, "status": "invalid", "reason": "missing id"})

    def test_no_items(self):
        self.assertEqual(self.one(order(items=[])), {"id": "o1", "status": "invalid", "reason": "no items"})
        self.assertEqual(self.one({"id": "o2"}), {"id": "o2", "status": "invalid", "reason": "no items"})

    def test_bad_item(self):
        self.assertEqual(self.one(order(items=[{"sku": "a", "price": 5, "qty": 0}]))["reason"], "bad item")
        self.assertEqual(self.one(order(items=[{"sku": "a", "price": -1, "qty": 1}]))["reason"], "bad item")
        self.assertEqual(self.one(order(items=[{"sku": "a", "price": 5, "qty": 1}, {"sku": "b", "price": 5, "qty": -2}]))["status"], "invalid")

    def test_volume_discount_5_units(self):
        r = self.one(order(items=[{"sku": "a", "price": 40, "qty": 5}]))
        self.assertEqual((r["subtotal"], r["discount"], r["shipping"], r["total"]), (200, 10, 20, 210))

    def test_volume_discount_10_units(self):
        r = self.one(order(items=[{"sku": "a", "price": 30, "qty": 6}, {"sku": "b", "price": 10, "qty": 4}]))
        self.assertEqual((r["subtotal"], r["discount"], r["shipping"], r["total"]), (220, 22, 20, 218))

    def test_welcome_coupon(self):
        r = self.one(order(coupon="WELCOME"))
        self.assertEqual((r["discount"], r["total"]), (10, 110))

    def test_vip_coupon_and_volume_stack(self):
        r = self.one(order(items=[{"sku": "a", "price": 100, "qty": 5}], coupon="VIP"))
        self.assertEqual((r["subtotal"], r["discount"], r["shipping"], r["total"]), (500, 100, 0, 400))

    def test_unknown_coupon_ignored(self):
        self.assertEqual(self.one(order(coupon="XYZ"))["discount"], 0)

    def test_discount_capped_at_subtotal(self):
        r = self.one(order(items=[{"sku": "a", "price": 4, "qty": 1}], coupon="WELCOME"))
        self.assertEqual((r["subtotal"], r["discount"], r["total"]), (4, 4, 20))

    def test_free_shipping_br_threshold_uses_net(self):
        self.assertEqual(self.one(order(items=[{"sku": "a", "price": 200, "qty": 1}]))["shipping"], 0)
        self.assertEqual(self.one(order(items=[{"sku": "a", "price": 205, "qty": 1}], coupon="WELCOME"))["shipping"], 20)

    def test_shipping_by_country(self):
        for c, s in [("AR", 45), ("UY", 45), ("PY", 45), ("US", 90), ("DE", 90)]:
            self.assertEqual(self.one(order(country=c))["shipping"], s, c)

    def test_country_default_is_br(self):
        self.assertEqual(self.one(order(country="BR")), self.one(order()))

    def test_rounding(self):
        r = self.one(order(items=[{"sku": "a", "price": 19.99, "qty": 3}], coupon="VIP"))
        self.assertEqual((r["subtotal"], r["discount"], r["total"]), (59.97, 9.0, 70.97))

    def test_batch_order_preserved(self):
        r = process_orders([order("a"), {"items": []}, order("c", country="US")])
        self.assertEqual([x["id"] for x in r], ["a", None, "c"])
        self.assertEqual([x["status"] for x in r], ["ok", "invalid", "ok"])

    def test_coupon_free_shipping(self):
        r = self.one(order(coupon="FRETEGRATIS", country="US"))
        self.assertEqual((r["shipping"], r["discount"], r["total"]), (0, 0, 100))
        r = self.one(order(coupon="FRETEGRATIS"))
        self.assertEqual((r["shipping"], r["total"]), (0, 100))


if __name__ == "__main__":
    unittest.main()
