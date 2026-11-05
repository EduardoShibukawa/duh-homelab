import unittest
from money import to_cents, from_cents


class MoneyTests(unittest.TestCase):
    def test_to_cents_simple(self):
        self.assertEqual(to_cents(10), 1000)
        self.assertEqual(to_cents("5.50"), 550)

    def test_to_cents_float_noise(self):
        self.assertEqual(to_cents(19.99), 1999)
        self.assertEqual(to_cents(0.29), 29)

    def test_to_cents_half_up(self):
        self.assertEqual(to_cents("2.675"), 268)
        self.assertEqual(to_cents("0.004"), 0)

    def test_to_cents_returns_int(self):
        self.assertIsInstance(to_cents(1.1), int)

    def test_from_cents(self):
        self.assertEqual(from_cents(5), "0.05")
        self.assertEqual(from_cents(12345), "123.45")
        self.assertEqual(from_cents(0), "0.00")


if __name__ == "__main__":
    unittest.main()
