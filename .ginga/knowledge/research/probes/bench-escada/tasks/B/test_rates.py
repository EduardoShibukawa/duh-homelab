import unittest
from rates import tax_rate


class RatesTests(unittest.TestCase):
    def test_percent(self):
        self.assertEqual(tax_rate("SP"), 18.0)
        self.assertEqual(tax_rate("rj"), 20.0)

    def test_unknown(self):
        with self.assertRaises(ValueError):
            tax_rate("ZZ")


if __name__ == "__main__":
    unittest.main()
