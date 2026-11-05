from money import to_cents, from_cents
from rates import tax_rate


def line_total(price, qty):
    return to_cents(price) * qty


def invoice_total(items, state, discount_pct=0):
    """items: lista de (preco_em_reais, quantidade).
    Desconto em % sobre o subtotal; o imposto incide sobre o valor já com desconto.
    Tudo em centavos inteiros, imposto arredondado meio-para-cima. Devolve 'RRR.CC'."""
    subtotal = sum(line_total(p, q) for p, q in items)
    discounted = subtotal - (subtotal * discount_pct + 50) // 100
    tax = (discounted * int(round(tax_rate(state) * 100)) + 5000) // 10000
    return from_cents(discounted + tax)
