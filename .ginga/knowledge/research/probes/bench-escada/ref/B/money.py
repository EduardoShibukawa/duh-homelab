def to_cents(amount):
    """Converte um valor em reais (float, int ou str como '19.99') para centavos inteiros,
    arredondando meio-para-cima (2.675 -> 268 centavos)."""
    from decimal import Decimal, ROUND_HALF_UP
    return int((Decimal(str(amount)) * 100).quantize(Decimal(1), rounding=ROUND_HALF_UP))


def from_cents(cents):
    """Formata centavos inteiros como 'RRR.CC'."""
    return f"{cents // 100}.{cents % 100:02d}"
