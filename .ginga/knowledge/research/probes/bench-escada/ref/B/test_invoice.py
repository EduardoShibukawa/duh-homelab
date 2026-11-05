import unittest
from invoice import invoice_total, line_total


class InvoiceTests(unittest.TestCase):
    def test_line_total_cents(self):
        self.assertEqual(line_total(19.99, 3), 5997)

    def test_no_tax(self):
        self.assertEqual(invoice_total([(19.99, 3)], "EX"), "59.97")

    def test_tax_sp(self):
        self.assertEqual(invoice_total([(10.00, 2), (5.50, 1)], "SP"), "30.09")

    def test_discount_then_tax(self):
        self.assertEqual(invoice_total([(100, 1)], "SP", discount_pct=10), "106.20")

    def test_tax_rounds_half_up(self):
        # 99 centavos * 18% = 17,82 -> 18
        self.assertEqual(invoice_total([(0.99, 1)], "SP"), "1.17")
        # 50 centavos * 18% = 9,00 exato; 25 * 18% = 4,5 -> 5
        self.assertEqual(invoice_total([(0.25, 1)], "SP"), "0.30")

    def test_unknown_state(self):
        with self.assertRaises(ValueError):
            invoice_total([(1, 1)], "ZZ")


if __name__ == "__main__":
    unittest.main()
