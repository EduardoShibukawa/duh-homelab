import unittest
from lru import LRUCache


class Clock:
    def __init__(self):
        self.t = 0
    def __call__(self):
        return self.t
    def advance(self, dt):
        self.t += dt


class LRUTests(unittest.TestCase):
    def setUp(self):
        self.clk = Clock()

    def make(self, cap=3, ttl=None):
        return LRUCache(cap, ttl=ttl, clock=self.clk)

    def test_basic_put_get(self):
        c = self.make(); c.put("a", 1)
        self.assertEqual(c.get("a"), 1)
        self.assertEqual(len(c), 1)

    def test_get_missing_default(self):
        c = self.make()
        self.assertIsNone(c.get("x"))
        self.assertEqual(c.get("x", 42), 42)

    def test_evicts_least_recently_used(self):
        c = self.make(2); c.put("a", 1); c.put("b", 2); c.put("c", 3)
        self.assertNotIn("a", c); self.assertIn("b", c); self.assertIn("c", c)

    def test_get_refreshes_recency(self):
        c = self.make(2); c.put("a", 1); c.put("b", 2); c.get("a"); c.put("c", 3)
        self.assertIn("a", c); self.assertNotIn("b", c)

    def test_put_existing_updates_and_refreshes(self):
        c = self.make(2); c.put("a", 1); c.put("b", 2); c.put("a", 10); c.put("c", 3)
        self.assertEqual(c.get("a"), 10)
        self.assertNotIn("b", c)
        self.assertEqual(len(c), 2)

    def test_contains_does_not_refresh(self):
        c = self.make(2); c.put("a", 1); c.put("b", 2)
        self.assertIn("a", c)
        c.put("c", 3)
        self.assertNotIn("a", c)

    def test_keys_order_lru_to_mru(self):
        c = self.make(); c.put("a", 1); c.put("b", 2); c.put("c", 3); c.get("a")
        self.assertEqual(c.keys(), ["b", "c", "a"])

    def test_default_ttl_expiry(self):
        c = self.make(ttl=10); c.put("a", 1)
        self.clk.advance(9)
        self.assertEqual(c.get("a"), 1)
        self.clk.advance(1)
        self.assertIsNone(c.get("a"))

    def test_get_does_not_extend_ttl(self):
        c = self.make(ttl=10); c.put("a", 1)
        self.clk.advance(6); c.get("a"); self.clk.advance(4)
        self.assertIsNone(c.get("a"))

    def test_put_resets_ttl(self):
        c = self.make(ttl=10); c.put("a", 1)
        self.clk.advance(8); c.put("a", 2); self.clk.advance(8)
        self.assertEqual(c.get("a"), 2)

    def test_per_item_ttl_overrides_default(self):
        c = self.make(ttl=10); c.put("a", 1, ttl=2); c.put("b", 2)
        self.clk.advance(3)
        self.assertNotIn("a", c); self.assertIn("b", c)

    def test_no_ttl_means_forever(self):
        c = self.make(); c.put("a", 1)
        self.clk.advance(10**9)
        self.assertEqual(c.get("a"), 1)

    def test_len_and_keys_exclude_expired(self):
        c = self.make(ttl=5); c.put("a", 1); c.put("b", 2)
        self.clk.advance(5)
        self.assertEqual(len(c), 0)
        self.assertEqual(c.keys(), [])

    def test_eviction_prefers_expired_over_lru(self):
        c = self.make(3); c.put("a", 1); c.put("b", 2, ttl=1); c.put("c", 3)
        self.clk.advance(2)
        c.put("d", 4)
        self.assertEqual(sorted(c.keys()), ["a", "c", "d"])
        self.assertEqual(c.stats()["evictions"], 0)

    def test_purge(self):
        c = self.make(5); c.put("a", 1, ttl=1); c.put("b", 2, ttl=1); c.put("c", 3)
        self.clk.advance(1)
        self.assertEqual(c.purge(), 2)
        self.assertEqual(c.keys(), ["c"])
        self.assertEqual(c.purge(), 0)

    def test_delete(self):
        c = self.make(); c.put("a", 1)
        self.assertTrue(c.delete("a"))
        self.assertFalse(c.delete("a"))
        self.assertNotIn("a", c)

    def test_delete_expired_returns_false(self):
        c = self.make(ttl=1); c.put("a", 1)
        self.clk.advance(1)
        self.assertFalse(c.delete("a"))

    def test_stats(self):
        c = self.make(2, ttl=5); c.put("a", 1); c.put("b", 2)
        c.get("a"); c.get("zz"); c.put("c", 3)
        self.clk.advance(5)
        self.assertIsNone(c.get("a"))
        self.assertEqual(c.stats(), {"hits": 1, "misses": 2, "evictions": 1, "expirations": 1})

    def test_invalid_args(self):
        with self.assertRaises(ValueError): LRUCache(0)
        with self.assertRaises(ValueError): LRUCache(-1)
        with self.assertRaises(ValueError): LRUCache(1, ttl=0)
        c = self.make()
        with self.assertRaises(ValueError): c.put("a", 1, ttl=-1)

    def test_none_value_is_stored(self):
        c = self.make(); c.put("a", None)
        self.assertIn("a", c)
        self.assertIsNone(c.get("a", "dflt"))

    def test_default_clock_is_usable(self):
        c = LRUCache(2, ttl=60); c.put("a", 1)
        self.assertEqual(c.get("a"), 1)


if __name__ == "__main__":
    unittest.main()
